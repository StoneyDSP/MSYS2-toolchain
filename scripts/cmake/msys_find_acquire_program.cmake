message("Loading ${CMAKE_CURRENT_LIST_FILE}")

function(z_msys_find_acquire_program_version_check out_var)
    message("Calling ${CMAKE_CURRENT_FUNCTION}")

    cmake_parse_arguments(PARSE_ARGV 1 arg
        "EXACT_VERSION_MATCH"
        "MIN_VERSION;PROGRAM_NAME"
        "COMMAND"
    )
    msys_execute_in_download_mode(
        COMMAND ${arg_COMMAND}
        WORKING_DIRECTORY "${MSYS_ROOT_DIR}"
        OUTPUT_VARIABLE program_version_output
    )
    string(STRIP "${program_version_output}" program_version_output)
    #TODO: REGEX MATCH case for more complex cases!
    set(version_compare VERSION_GREATER_EQUAL)
    set(version_compare_msg "at least")
    if(arg_EXACT_VERSION_MATCH)
        set(version_compare VERSION_EQUAL)
        set(version_compare_msg "exact")
    endif()
    if(NOT "${program_version_output}" ${version_compare} "${arg_MIN_VERSION}")
        message(STATUS "Found ${arg_PROGRAM_NAME}('${program_version_output}') but ${version_compare_msg} version ${arg_MIN_VERSION} is required! Trying to use internal version if possible!")
        set("${out_var}" OFF PARENT_SCOPE)
    else()
        message(STATUS "Found external ${arg_PROGRAM_NAME}('${program_version_output}').")
        set("${out_var}" ON PARENT_SCOPE)
    endif()
endfunction()

function(z_msys_find_acquire_program_find_external program)
    message("Calling ${CMAKE_CURRENT_FUNCTION}")

    cmake_parse_arguments(PARSE_ARGV 1 arg
        "EXACT_VERSION_MATCH"
        "INTERPRETER;MIN_VERSION;PROGRAM_NAME"
        "NAMES;VERSION_COMMAND"
    )
    if(arg_EXACT_VERSION_MATCH)
        set(arg_EXACT_VERSION_MATCH EXACT_VERSION_MATCH)
    endif()

    if("${arg_INTERPRETER}" STREQUAL "")
        find_program("${program}" NAMES ${arg_NAMES})
    else()
        find_file(SCRIPT_${arg_PROGRAM_NAME} NAMES ${arg_NAMES})
        if(SCRIPT_${arg_PROGRAM_NAME})
            msys_list(SET program_tmp ${${interpreter}} ${SCRIPT_${arg_PROGRAM_NAME}})
            set("${program}" "${program_tmp}" CACHE INTERNAL "")
        else()
            set("${program}" "" CACHE INTERNAL "")
        endif()
        unset(SCRIPT_${arg_PROGRAM_NAME} CACHE)
    endif()

    if("${version_command}" STREQUAL "")
        set(version_is_good ON) # can't check for the version being good, so assume it is
    elseif(${program}) # only do a version check if ${program} has a value
        z_msys_find_acquire_program_version_check(version_is_good
            ${arg_EXACT_VERSION_MATCH}
            COMMAND ${${program}} ${arg_VERSION_COMMAND}
            MIN_VERSION "${arg_MIN_VERSION}"
            PROGRAM_NAME "${arg_PROGRAM_NAME}"
        )
    endif()

    if(NOT version_is_good)
        unset("${program}" PARENT_SCOPE)
        unset("${program}" CACHE)
    endif()
endfunction()

function(z_msys_find_acquire_program_find_internal program)
    message("Calling ${CMAKE_CURRENT_FUNCTION}")
    cmake_parse_arguments(PARSE_ARGV 1 arg
        ""
        "INTERPRETER"
        "NAMES;PATHS"
    )
    if("${arg_INTERPRETER}" STREQUAL "")
        find_program(${program}
            NAMES ${arg_NAMES}
            PATHS ${arg_PATHS}
            NO_DEFAULT_PATH)
    else()
        msys_find_acquire_program("${arg_INTERPRETER}")
        find_file(SCRIPT_${program}
            NAMES ${arg_NAMES}
            PATHS ${arg_PATHS}
            NO_DEFAULT_PATH)
        if(SCRIPT_${program})
            set("${program}" ${${arg_INTERPRETER}} ${SCRIPT_${program}} CACHE INTERNAL "")
        endif()
        unset(SCRIPT_${program} CACHE)
    endif()
endfunction()

function(msys_find_acquire_program program)
    message("Calling ${CMAKE_CURRENT_FUNCTION}(${program})")
    if(${program})
        return()
    endif()

    set(raw_executable "OFF")
    set(program_name "")
    set(program_version "")
    set(search_names "")
    set(download_urls "")
    set(download_filename "")
    set(download_sha512 "")
    set(rename_binary_to "")
    set(tool_subdirectory "")
    set(interpreter "")
    set(supported_on_unix "")
    set(post_install_command "")
    set(paths_to_search "")
    set(version_command "")
    msys_list(SET sourceforge_args)
    set(brew_package_name "")
    set(apt_package_name "")

    set(program_information "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/msys_find_acquire_program(${program}).cmake")
    if(program MATCHES "^[A-Z0-9]+\$" AND EXISTS "${program_information}")
        include("${program_information}")
    else()
        message(FATAL_ERROR "unknown tool ${program} -- unable to acquire.")
    endif()

    if("${program_name}" STREQUAL "")
        message(FATAL_ERROR "Internal error: failed to initialize program_name for program ${program}")
    endif()

    set(full_subdirectory "${DOWNLOADS}/tools/${program_name}/${tool_subdirectory}")
    if(NOT "${tool_subdirectory}" STREQUAL "")
        list(APPEND paths_to_search ${full_subdirectory})
    endif()
    if("${full_subdirectory}" MATCHES [[^(.*)[/\\]+$]])
        # remove trailing slashes, which may turn into a trailing `\` which CMake _does not like_
        set(full_subdirectory "${CMAKE_MATCH_1}")
    endif()

    if("${search_names}" STREQUAL "")
        set(search_names "${program_name}")
    endif()

    z_msys_find_acquire_program_find_internal("${program}"
        INTERPRETER "${interpreter}"
        PATHS ${paths_to_search}
        NAMES ${search_names}
    )
    if(NOT ${program})
        z_msys_find_acquire_program_find_external("${program}"
            ${extra_search_args}
            PROGRAM_NAME "${program_name}"
            MIN_VERSION "${program_version}"
            INTERPRETER "${interpreter}"
            NAMES ${search_names}
            VERSION_COMMAND ${version_command}
        )
    endif()
    if(NOT ${program})
        if(NOT MSYS_HOST_IS_WINDOWS AND NOT supported_on_unix)
            set(example ".")
            if(NOT "${brew_package_name}" STREQUAL "" AND MSYS_HOST_IS_OSX)
                set(example ":\n    brew install ${brew_package_name}")
            elseif(NOT "${apt_package_name}" STREQUAL "" AND MSYS_HOST_IS_LINUX)
                set(example ":\n    sudo apt-get install ${apt_package_name}")
            endif()
            message(FATAL_ERROR "Could not find ${program_name}. Please install it via your package manager${example}")
        endif()

        if(NOT "${sourceforge_args}" STREQUAL "")
            # Locally change editable to suppress re-extraction each time
            set(_MSYS_EDITABLE 1)
            msys_from_sourceforge(OUT_SOURCE_PATH SFPATH ${sourceforge_args})
            unset(_MSYS_EDITABLE)
        else()
            msys_download_distfile(archive_path
                URLS ${download_urls}
                SHA512 "${download_sha512}"
                FILENAME "${download_filename}"
            )

            file(MAKE_DIRECTORY "${full_subdirectory}")
            if(raw_executable)
                if(NOT "${rename_binary_to}" STREQUAL "")
                    file(INSTALL "${archive_path}"
                        DESTINATION "${full_subdirectory}"
                        RENAME "${rename_binary_to}"
                        FILE_PERMISSIONS
                            OWNER_READ OWNER_WRITE OWNER_EXECUTE
                            GROUP_READ GROUP_EXECUTE
                            WORLD_READ WORLD_EXECUTE
                    )
                else()
                    file(COPY "${archive_path}"
                        DESTINATION "${full_subdirectory}"
                        FILE_PERMISSIONS
                            OWNER_READ OWNER_WRITE OWNER_EXECUTE
                            GROUP_READ GROUP_EXECUTE
                            WORLD_READ WORLD_EXECUTE
                    )
                endif()
            else()
                cmake_path(GET download_filename EXTENSION archive_extension)
                string(TOLOWER "${archive_extension}" archive_extension)
                if("${archive_extension}" MATCHES [[\.msi$]])
                    cmake_path(NATIVE_PATH archive_path archive_native_path)
                    cmake_path(NATIVE_PATH full_subdirectory destination_native_path)
                    msys_execute_in_download_mode(
                        COMMAND msiexec
                            /a "${archive_native_path}"
                            /qn "TARGETDIR=${destination_native_path}"
                        WORKING_DIRECTORY "${DOWNLOADS}"
                    )
                elseif("${archive_extension}" MATCHES [[\.7z\.exe$]])
                    msys_find_acquire_program(7Z)
                    msys_execute_in_download_mode(
                        COMMAND ${7Z} x
                            "${archive_path}"
                            "-o${full_subdirectory}"
                            -y -bso0 -bsp0
                        WORKING_DIRECTORY "${full_subdirectory}"
                    )
                else()
                    msys_execute_in_download_mode(
                        COMMAND "${CMAKE_COMMAND}" -E tar xzf "${archive_path}"
                        WORKING_DIRECTORY "${full_subdirectory}"
                    )
                endif()
            endif()
        endif()

        if(NOT "${post_install_command}" STREQUAL "")
            msys_execute_required_process(
                ALLOW_IN_DOWNLOAD_MODE
                COMMAND ${post_install_command}
                WORKING_DIRECTORY "${full_subdirectory}"
                LOGNAME "${program}-tool-post-install"
            )
        endif()
        unset("${program}")
        unset("${program}" CACHE)
        z_msys_find_acquire_program_find_internal("${program}"
            INTERPRETER "${interpreter}"
            PATHS ${paths_to_search}
            NAMES ${search_names}
        )
        if(NOT ${program})
            message(FATAL_ERROR "Unable to find ${program}")
        endif()
    endif()

    set("${program}" "${${program}}" PARENT_SCOPE)
endfunction()
