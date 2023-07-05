# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.


# This module is shared by multiple languages; use include blocker.
if(__MSYSTEM_COMPILER_GNU)
    return()
endif()
set(__MSYSTEM_COMPILER_GNU 1)

# message(WARNING "ping")

# TODO: Is -Wl,--enable-auto-import now always default?
set(CMAKE_EXE_LINKER_FLAGS_INIT)
string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT " -Wl,--enable-auto-import")
set(CMAKE_EXE_LINKER_FLAGS_INIT "${CMAKE_EXE_LINKER_FLAGS_INIT}")

set(CMAKE_GNULD_IMAGE_VERSION "-Wl,--major-image-version,<TARGET_VERSION_MAJOR>,--minor-image-version,<TARGET_VERSION_MINOR>")
set(CMAKE_GENERATOR_RC windres)

# Features for LINK_LIBRARY generator expression
## check linker capabilities
if(NOT DEFINED _CMAKE_LINKER_PUSHPOP_STATE_SUPPORTED)
    execute_process(COMMAND "${CMAKE_LINKER}" --help
                    OUTPUT_VARIABLE __linker_help
                    ERROR_VARIABLE __linker_help)
    if(__linker_help MATCHES "--push-state" AND __linker_help MATCHES "--pop-state")
        set(_CMAKE_LINKER_PUSHPOP_STATE_SUPPORTED TRUE CACHE INTERNAL "linker supports push/pop state")
    else()
        set(_CMAKE_LINKER_PUSHPOP_STATE_SUPPORTED FALSE CACHE INTERNAL "linker supports push/pop state")
    endif()
    unset(__linker_help)
endif()

## WHOLE_ARCHIVE: Force loading all members of an archive
if(_CMAKE_LINKER_PUSHPOP_STATE_SUPPORTED)
set(CMAKE_LINK_LIBRARY_USING_WHOLE_ARCHIVE "LINKER:--push-state,--whole-archive"
                                            "<LINK_ITEM>"
                                            "LINKER:--pop-state")
else()
set(CMAKE_LINK_LIBRARY_USING_WHOLE_ARCHIVE "LINKER:--whole-archive"
                                            "<LINK_ITEM>"
                                            "LINKER:--no-whole-archive")
endif()
set(CMAKE_LINK_LIBRARY_USING_WHOLE_ARCHIVE_SUPPORTED TRUE)

macro(__msystem_mingw_compiler_gnu lang)
    # Binary link rules.
    set(CMAKE_${lang}_CREATE_SHARED_MODULE "<CMAKE_${lang}_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_MODULE_${lang}_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_MODULE_CREATE_${lang}_FLAGS> -o <TARGET> ${CMAKE_GNULD_IMAGE_VERSION} <OBJECTS> <LINK_LIBRARIES>")
    set(CMAKE_${lang}_CREATE_SHARED_LIBRARY "<CMAKE_${lang}_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_LIBRARY_${lang}_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_${lang}_FLAGS> -o <TARGET> -Wl,--out-implib,<TARGET_IMPLIB> ${CMAKE_GNULD_IMAGE_VERSION} <OBJECTS> <LINK_LIBRARIES>")
    set(CMAKE_${lang}_LINK_EXECUTABLE "<CMAKE_${lang}_COMPILER> <FLAGS> <CMAKE_${lang}_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> -Wl,--out-implib,<TARGET_IMPLIB> ${CMAKE_GNULD_IMAGE_VERSION} <LINK_LIBRARIES>")
    set(CMAKE_${lang}_CREATE_WIN32_EXE "-mwindows")

    # No -fPIC on cygwin
    set(CMAKE_${lang}_COMPILE_OPTIONS_PIC "")
    set(CMAKE_${lang}_COMPILE_OPTIONS_PIE "")
    set(_CMAKE_${lang}_PIE_MAY_BE_SUPPORTED_BY_LINKER NO)
    set(CMAKE_${lang}_LINK_OPTIONS_PIE "")
    set(CMAKE_${lang}_LINK_OPTIONS_NO_PIE "")
    set(CMAKE_SHARED_LIBRARY_${lang}_FLAGS "")

    # Initialize C link type selection flags.  These flags are used when
    # building a shared library, shared module, or executable that links
    # to other libraries to select whether to use the static or shared
    # versions of the libraries.
    foreach(type SHARED_LIBRARY SHARED_MODULE EXE)
        set(CMAKE_${type}_LINK_STATIC_${lang}_FLAGS "-Wl,-Bstatic")
        set(CMAKE_${type}_LINK_DYNAMIC_${lang}_FLAGS "-Wl,-Bdynamic")
    endforeach()

    set(CMAKE_EXE_EXPORTS_${lang}_FLAG "-Wl,--export-all-symbols")
    # TODO: Is -Wl,--enable-auto-import now always default?
    string(APPEND CMAKE_SHARED_LIBRARY_CREATE_${lang}_FLAGS " -Wl,--enable-auto-import")
    set(CMAKE_SHARED_MODULE_CREATE_${lang}_FLAGS "${CMAKE_SHARED_LIBRARY_CREATE_${lang}_FLAGS}")

    if(NOT CMAKE_RC_COMPILER_INIT)
        set(CMAKE_RC_COMPILER_INIT windres)
    endif()

    enable_language(RC)

endmacro()
