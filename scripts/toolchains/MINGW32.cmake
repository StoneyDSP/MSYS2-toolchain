if(NOT _MSYS_MINGW32_TOOLCHAIN)
    set(_MSYS_MINGW32_TOOLCHAIN 1)

    message(STATUS "MinGW x32 toolchain loading...")

    # set(CMAKE_MODULE_PATH)
    # list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../cmake/Modules")

    # # set(ENABLE_MINGW32 ON CACHE BOOL "Enable sub-system: MinGW x32 <MINGW32>." FORCE)

    # Detect <Z_MSYS_ROOT_DIR>/mingw32.ini to figure MINGW32_ROOT_DIR
    set(Z_MINGW32_ROOT_DIR_CANDIDATE "${CMAKE_CURRENT_LIST_DIR}")
    while(NOT DEFINED Z_MINGW32_ROOT_DIR)
        if(EXISTS "${Z_MING32_ROOT_DIR_CANDIDATE}msys64/mingw32.ini")
            set(Z_MINGW32_ROOT_DIR "${Z_MINGW32_ROOT_DIR_CANDIDATE}msys64/mingw32" CACHE INTERNAL "MinGW32 root directory")
        elseif(IS_DIRECTORY "${Z_MINGW32_ROOT_DIR_CANDIDATE}")
            get_filename_component(Z_MINGW32_ROOT_DIR_TEMP "${Z_MINGW32_ROOT_DIR_CANDIDATE}" DIRECTORY)
            if(Z_MINGW32_ROOT_DIR_TEMP STREQUAL Z_MINGW32_ROOT_DIR_CANDIDATE)
                break() # If unchanged, we have reached the root of the drive without finding vcpkg.
            endif()
            set(Z_MINGW32_ROOT_DIR_CANDIDATE "${Z_MINGW32_ROOT_DIR_TEMP}")
            unset(Z_MINGW32_ROOT_DIR_TEMP)
        else()
            message(WARNING "Could not find 'mingw32.ini'... Check your installation!")
            break()
        endif()
    endwhile()
    unset(Z_MINGW32_ROOT_DIR_CANDIDATE)

    if(ENABLE_MINGW32 AND (MSYSTEM STREQUAL "MINGW32"))

    set(CARCH                       "i686")
    set(CHOST                       "i686-w64-mingw32")
    set(MINGW_CHOST                 "i686-w64-mingw32")
    set(MINGW_PREFIX                "/mingw32")
    set(MINGW_PACKAGE_PREFIX        "mingw-w64-i686")
    set(MINGW_MOUNT_POINT           "${MINGW_PREFIX}")

    set(MSYSTEM_TITLE               "MinGW x32"                         CACHE STRING    "MinGW x32: Name of the build system." FORCE)
    set(MSYSTEM_TOOLCHAIN_VARIANT   gcc                                 CACHE STRING    "MinGW x32: Identification string of the compiler toolchain variant." FORCE)
    set(MSYSTEM_CRT_LIBRARY         msvcrt                              CACHE STRING    "MinGW x32: Identification string of the C Runtime variant. Can be 'ucrt' (modern, 64-bit only) or 'msvcrt' (compatibilty for legacy builds)." FORCE)
    set(MSYSTEM_CXX_STD_LIBRARY     libstdc++                           CACHE STRING    "MinGW x32: Identification string of the C++ Standard Library variant. Can be 'libstdc++' (GNU implementation) or 'libc++' (LLVM implementation)." FORCE)
    set(MSYSTEM_PREFIX              "/mingw32"                          CACHE STRING    "MinGW x32: Sub-system prefix." FORCE)
    set(MSYSTEM_ARCH                "i686"                              CACHE STRING    "MinGW x32: Sub-system architecture." FORCE)
    set(MSYSTEM_PLAT                "i686-w64-mingw32"                  CACHE STRING    "MinGW x32: Sub-system name string." FORCE)
    set(MSYSTEM_PACKAGE_PREFIX      "mingw-w64-i686"                    CACHE STRING    "MinGW x32: Sub-system package prefix." FORCE)
    set(MSYSTEM_ROOT                "${Z_MINGW32_ROOT_DIR}"             CACHE PATH      "MinGW x32: Root of the build system." FORCE)

    endif()

    #set(__USE_MINGW_ANSI_STDIO  "1")                                   # CACHE STRING   "Use the MinGW ANSI definition for 'stdio.h'." FORCE)
    #set(_FORTIFY_SOURCE         "2")                                   # CACHE STRING   "Fortify source definition." FORCE)


    # ###########################################################################
    # # CMake vars...
    # ###########################################################################

    ## set(MSYS_TARGET_TRIPLET "x86-mingw-dynamic") ############## One more time!

    set(Z_MSYS_TARGET_TRIPLET_PLAT mingw-dynamic)
    set(Z_MSYS_TARGET_TRIPLET_ARCH x86)

    set(MSYS_TARGET_ARCHITECTURE x86)
    set(MSYS_CRT_LINKAGE dynamic)
    set(MSYS_LIBRARY_LINKAGE dynamic)
    set(MSYS_ENV_PASSTHROUGH PATH)

    set(MSYS_CMAKE_SYSTEM_NAME MinGW)
    set(MSYS_POLICY_DLLS_WITHOUT_LIBS enabled)

    set(MSYS_TARGET_TRIPLET "${Z_MSYS_TARGET_TRIPLET_ARCH}-${Z_MSYS_TARGET_TRIPLET_PLAT}" CACHE STRING "Msys target triplet (ex. x86-windows)" FORCE)


    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
        set(CMAKE_CROSSCOMPILING OFF CACHE BOOL "")
    endif()

    if(MSYS_TARGET_ARCHITECTURE STREQUAL "x86")
        set(CMAKE_SYSTEM_PROCESSOR i686 CACHE STRING "When not cross-compiling, this variable has the same value as the ``CMAKE_HOST_SYSTEM_PROCESSOR`` variable.")
    elseif(MSYS_TARGET_ARCHITECTURE STREQUAL "x64")
        set(CMAKE_SYSTEM_PROCESSOR x86_64 CACHE STRING "When not cross-compiling, this variable has the same value as the ``CMAKE_HOST_SYSTEM_PROCESSOR`` variable.")
    elseif(MSYS_TARGET_ARCHITECTURE STREQUAL "arm")
        set(CMAKE_SYSTEM_PROCESSOR armv7 CACHE STRING "When not cross-compiling, this variable has the same value as the ``CMAKE_HOST_SYSTEM_PROCESSOR`` variable.")
    elseif(MSYS_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(CMAKE_SYSTEM_PROCESSOR aarch64 CACHE STRING "When not cross-compiling, this variable has the same value as the ``CMAKE_HOST_SYSTEM_PROCESSOR`` variable.")
    endif()
    #set(CMAKE_SYSTEM_PROCESSOR "i686" CACHE STRING "When not cross-compiling, this variable has the same value as the ``CMAKE_HOST_SYSTEM_PROCESSOR`` variable." FORCE) # include(Platform/${CMAKE_EFFECTIVE_SYSTEM_NAME}-${CMAKE_CXX_COMPILER_ID}-CXX-${CMAKE_SYSTEM_PROCESSOR} OPTIONAL RESULT_VARIABLE _INCLUDED_FILE)                             #CACHE STRING "When not cross-compiling, this variable has the same value as the ``CMAKE_HOST_SYSTEM_PROCESSOR`` variable." FORCE)


    # Targets for vars

    set(CMAKE_SYSTEM "MINGW32" CACHE STRING "Composite name of operating system CMake is compiling for." FORCE)
    # Need to override MinGW from MSYS_CMAKE_SYSTEM_NAME
    set(CMAKE_SYSTEM_NAME "MINGW32" CACHE STRING "The name of the operating system for which CMake is to build." FORCE)

    foreach(lang C CXX ASM Fortran OBJC OBJCXX)
        ##-- CMakeCXXInformation: include(Compiler/<CMAKE_CXX_COMPILER_ID>-<LANG>)
        #set(CMAKE_${lang}_COMPILER_ID "MINGW32 13.1.0" CACHE STRING "" FORCE) # - actually, let's fallback to Kitware's GNU
        ##-- 'TARGET' tells the compiler in question what it's '--target:' is.
        set(CMAKE_${lang}_COMPILER_TARGET "i686-w64-mingw32" CACHE STRING "The target for cross-compiling, if supported. '--target=i686-w64-mingw32'")

    endforeach()
    set(CMAKE_RC_COMPILER_TARGET "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32" CACHE STRING "The target for cross-compiling, if supported. '--target=x86_64-w64-mingw32'")

    find_program(CMAKE_C_COMPILER "${Z_MINGW32_ROOT_DIR}/bin/i686-mingw32-gcc.exe")
    mark_as_advanced(CMAKE_C_COMPILER)

    find_program(CMAKE_CXX_COMPILER "${Z_MINGW32_ROOT_DIR}/bin/i686-w64-mingw32-g++.exe")
    mark_as_advanced(CMAKE_CXX_COMPILER)

    find_program(CMAKE_RC_COMPILER "${Z_MINGW32_ROOT_DIR}/bin/windres.exe")
    mark_as_advanced(CMAKE_RC_COMPILER)

    find_program(CMAKE_ASM_COMPILER "${Z_MINGW32_ROOT_DIR}/bin/as.exe")
    mark_as_advanced(CMAKE_ASM_COMPILER)

    find_program(CMAKE_OBJCXX_COMPILER "${Z_MINGW32_ROOT_DIR}/bin/i686-w64-mingw32-gcc.exe")
    mark_as_advanced(CMAKE_OBJC_COMPILER)

    find_program(CMAKE_OBJCXX_COMPILER "${Z_MINGW32_ROOT_DIR}/bin/i686-mingw32-g++.exe")
    mark_as_advanced(CMAKE_OBJCXX_COMPILER)

    find_program(CMAKE_RC_COMPILER "${Z_MINGW32_ROOT_DIR}/bin/windres.exe")
    mark_as_advanced(CMAKE_RC_COMPILER)

    if(NOT CMAKE_RC_COMPILER)
        find_program (CMAKE_RC_COMPILER "${Z_MINGW32_ROOT_DIR}/bin/windres" NO_CACHE)
        if(NOT CMAKE_RC_COMPILER)
            find_program(CMAKE_RC_COMPILER "windres" NO_CACHE)
        endif()
    endif()


    get_property(_CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE )

    # The following flags come from 'PORT' files (i.e., build config files for packages)
    if(NOT _CMAKE_IN_TRY_COMPILE)

        set(LDFLAGS)
        string(APPEND LDFLAGS " -pipe")
        string(APPEND LDFLAGS " -Wl,--no-seh")
        string(APPEND LDFLAGS " -Wl,--large-address-aware")
        set(LDFLAGS "${LDFLAGS}")
        set(ENV{LDFLAGS} "${LDFLAGS}")

        # set(CFLAGS)
        # string(APPEND CFLAGS " -march=pentium4")
        # string(APPEND CFLAGS " -mtune=generic")
        # string(APPEND CFLAGS " -pipe")
        # string(APPEND CFLAGS " -Wp,-D_FORTIFY_SOURCE=2")
        # string(APPEND CFLAGS " -fstack-protector-strong")
        # set(CFLAGS "${CFLAGS}")
        # set(ENV{CFLAGS} "${CFLAGS}")

        # set(CXXFLAGS)
        # string(APPEND CXXFLAGS " -march=pentium4")
        # string(APPEND CXXFLAGS " -mtune=generic")
        # string(APPEND CXXFLAGS " -pipe")
        # set(CXXFLAGS "${CXXFLAGS}")
        # set(ENV{CXXFLAGS} "${CXXFLAGS}")

        # Initial configuration flags.
        foreach(lang C CXX ASM Fortran OBJC OBJCXX)
            string(APPEND CMAKE_${lang}_FLAGS_INIT " -march=pentium4")
            string(APPEND CMAKE_${lang}_FLAGS_INIT " -mtune=generic")
            string(APPEND CMAKE_${lang}_FLAGS_INIT " -pipe")
            if(${lang} STREQUAL C)
                string(APPEND CMAKE_${lang}_FLAGS_INIT " -Wp,-D_FORTIFY_SOURCE=2")
                string(APPEND CMAKE_${lang}_FLAGS_INIT " -fstack-protector-strong")
            endif()
        endforeach()

        string(APPEND CMAKE_C_FLAGS_INIT                        " ${MSYS_C_FLAGS} ")
        string(APPEND CMAKE_C_FLAGS_DEBUG_INIT                  " ${MSYS_C_FLAGS_DEBUG} ")
        string(APPEND CMAKE_C_FLAGS_RELEASE_INIT                " ${MSYS_C_FLAGS_RELEASE} ")
        string(APPEND CMAKE_C_FLAGS_MINSIZEREL_INIT             " ${MSYS_C_FLAGS_MINSIZEREL} ")
        string(APPEND CMAKE_C_FLAGS_RELWITHDEBINFO_INIT         " ${MSYS_C_FLAGS_RELWITHDEBINFO} ")

        string(APPEND CMAKE_CXX_FLAGS_INIT                      " ${MSYS_CXX_FLAGS} ")
        string(APPEND CMAKE_CXX_FLAGS_DEBUG_INIT                " ${MSYS_CXX_FLAGS_DEBUG} ")
        string(APPEND CMAKE_CXX_FLAGS_RELEASE_INIT              " ${MSYS_CXX_FLAGS_RELEASE} ")
        string(APPEND CMAKE_CXX_FLAGS_MINSIZEREL_INIT           " ${MSYS_CXX_FLAGS_MINSIZEREL} ")
        string(APPEND CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT       " ${MSYS_CXX_FLAGS_RELWITHDEBINFO} ")

        string(APPEND CMAKE_ASM_FLAGS_INIT                      " ${MSYS_ASM_FLAGS} ")
        string(APPEND CMAKE_ASM_FLAGS_DEBUG_INIT                " ${MSYS_ASM_FLAGS_DEBUG} ")
        string(APPEND CMAKE_ASM_FLAGS_RELEASE_INIT              " ${MSYS_ASM_FLAGS_RELEASE} ")
        string(APPEND CMAKE_ASM_FLAGS_MINSIZEREL_INIT           " ${MSYS_ASM_FLAGS_MINSIZEREL} ")
        string(APPEND CMAKE_ASM_FLAGS_RELWITHDEBINFO_INIT       " ${MSYS_ASM_FLAGS_RELWITHDEBINFO} ")

        string(APPEND CMAKE_Fortran_FLAGS_INIT                  " ${MSYS_Fortran_FLAGS} ")
        string(APPEND CMAKE_Fortran_FLAGS_DEBUG_INIT            " ${MSYS_Fortran_FLAGS_DEBUG} ")
        string(APPEND CMAKE_Fortran_FLAGS_RELEASE_INIT          " ${MSYS_Fortran_FLAGS_RELEASE} ")
        string(APPEND CMAKE_Fortran_FLAGS_MINSIZEREL_INIT       " ${MSYS_Fortran_FLAGS_MINSIZEREL} ")
        string(APPEND CMAKE_Fortran_FLAGS_RELWITHDEBINFO_INIT   " ${MSYS_Fortran_FLAGS_RELWITHDEBINFO} ")

        string(APPEND CMAKE_OBJC_FLAGS_INIT                     " ${MSYS_OBJC_FLAGS} ")
        string(APPEND CMAKE_OBJC_FLAGS_DEBUG_INIT               " ${MSYS_OBJC_FLAGS_DEBUG} ")
        string(APPEND CMAKE_OBJC_FLAGS_RELEASE_INIT             " ${MSYS_OBJC_FLAGS_RELEASE} ")
        string(APPEND CMAKE_OBJC_FLAGS_MINSIZEREL_INIT          " ${MSYS_OBJC_FLAGS_MINSIZEREL} ")
        string(APPEND CMAKE_OBJC_FLAGS_RELWITHDEBINFO_INIT      " ${MSYS_OBJC_FLAGS_RELWITHDEBINFO} ")

        string(APPEND CMAKE_OBJCXX_FLAGS_INIT                   " ${MSYS_OBJCXX_FLAGS} ")
        string(APPEND CMAKE_OBJCXX_FLAGS_DEBUG_INIT             " ${MSYS_OBJCXX_FLAGS_DEBUG} ")
        string(APPEND CMAKE_OBJCXX_FLAGS_RELEASE_INIT           " ${MSYS_OBJCXX_FLAGS_RELEASE} ")
        string(APPEND CMAKE_OBJCXX_FLAGS_MINSIZEREL_INIT        " ${MSYS_OBJCXX_FLAGS_MINSIZEREL} ")
        string(APPEND CMAKE_OBJCXX_FLAGS_RELWITHDEBINFO_INIT    " ${MSYS_OBJCXX_FLAGS_RELWITHDEBINFO} ")

        string(APPEND CMAKE_RC_FLAGS_INIT                       " ${MSYS_RC_FLAGS} ")
        string(APPEND CMAKE_RC_FLAGS_DEBUG_INIT                 " ${MSYS_RC_FLAGS_DEBUG} ")
        string(APPEND CMAKE_RC_FLAGS_RELEASE_INIT               " ${MSYS_RC_FLAGS_RELEASE} ")
        string(APPEND CMAKE_RC_FLAGS_MINSIZEREL_INIT            " ${MSYS_RC_FLAGS_MINSIZEREL} ")
        string(APPEND CMAKE_RC_FLAGS_RELWITHDEBINFO_INIT        " ${MSYS_RC_FLAGS_RELWITHDEBINFO} ")

        string(APPEND CMAKE_SHARED_LINKER_FLAGS_INIT            " ${MSYS_LINKER_FLAGS} ")
        string(APPEND CMAKE_STATIC_LINKER_FLAGS_INIT            " ${MSYS_LINKER_FLAGS} ")
        string(APPEND CMAKE_MODULE_LINKER_FLAGS_INIT            " ${MSYS_LINKER_FLAGS} ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT               " ${MSYS_LINKER_FLAGS} ")

        if(OPTION_STRIP_BINARIES)
            string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT               " --strip-all")
        endif()

        if(OPTION_STRIP_SHARED)
            string(APPEND CMAKE_SHARED_LINKER_FLAGS_INIT            " --strip-unneeded")
        endif()

        if(OPTION_STRIP_STATIC)
            string(APPEND CMAKE_STATIC_LINKER_FLAGS_INIT            " --strip-debug")
        endif()

        if(MSYS_CRT_LINKAGE STREQUAL "static")
            string(APPEND CMAKE_SHARED_LINKER_FLAGS_INIT        " -static")
            string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT           " -static")
        endif()

        string(APPEND CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT              " ${MSYS_LINKER_FLAGS_DEBUG} ")
        string(APPEND CMAKE_SHARED_LINKER_FLAGS_RELEASE_INIT            " ${MSYS_LINKER_FLAGS_RELEASE} ")
        string(APPEND CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL_INIT         " ${MSYS_LINKER_FLAGS_MINSIZEREL} ")
        string(APPEND CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO_INIT     " ${MSYS_LINKER_FLAGS_RELWITHDEBINFO} ")

        string(APPEND CMAKE_STATIC_LINKER_FLAGS_DEBUG_INIT              " ${MSYS_LINKER_FLAGS_DEBUG} ")
        string(APPEND CMAKE_STATIC_LINKER_FLAGS_RELEASE_INIT            " ${MSYS_LINKER_FLAGS_RELEASE} ")
        string(APPEND CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL_INIT         " ${MSYS_LINKER_FLAGS_MINSIZEREL} ")
        string(APPEND CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO_INIT     " ${MSYS_LINKER_FLAGS_RELWITHDEBINFO} ")

        string(APPEND CMAKE_MODULE_LINKER_FLAGS_DEBUG_INIT              " ${MSYS_LINKER_FLAGS_DEBUG} ")
        string(APPEND CMAKE_MODULE_LINKER_FLAGS_RELEASE_INIT            " ${MSYS_LINKER_FLAGS_RELEASE} ")
        string(APPEND CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL_INIT         " ${MSYS_LINKER_FLAGS_MINSIZEREL} ")
        string(APPEND CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO_INIT     " ${MSYS_LINKER_FLAGS_RELWITHDEBINFO} ")

        string(APPEND CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT                 " ${MSYS_LINKER_FLAGS_DEBUG} ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_RELEASE_INIT               " ${MSYS_LINKER_FLAGS_RELEASE} ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_MINSIZEREL_INIT            " ${MSYS_LINKER_FLAGS_MINSIZEREL} ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO_INIT        " ${MSYS_LINKER_FLAGS_RELWITHDEBINFO} ")

        # unset(LDFLAGS)
        # unset(CFLAGS)
        # unset(CXXFLAGS)
        # unset(CPPFLAGS)

    endif()

    message(STATUS "MinGW x32 toolchain loaded")

endif()
