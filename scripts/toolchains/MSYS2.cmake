# # Mark variables as used so cmake doesn't complain about them
# mark_as_advanced(CMAKE_TOOLCHAIN_FILE)

# set(CMAKE_REQUIRED_MINIMUM_VERSION "3.7.2")
# if(CMAKE_VERSION VERSION_LESS CMAKE_REQUIRED_MINIMUM_VERSION)
#     message(FATAL_ERROR "Toolchain requires at least CMake ${CMAKE_REQUIRED_MINIMUM_VERSION}.")
# endif()
# cmake_policy(PUSH)
# cmake_policy(VERSION 3.7.2)

# Info: packages.msys2.org/groups/
#
# Toolchain programs:
#
# CMAKE_AR
# CMAKE_<LANG>_COMPILER_AR (Wrapper)
# CMAKE_RANLIB
# CMAKE_<LANG>_COMPILER_RANLIB
# CMAKE_STRIP
# CMAKE_NM
# CMAKE_OBJDUMP
# CMAKE_DLLTOOL
# CMAKE_MT
# CMAKE_LINKER
# CMAKE_C_COMPILER
# CMAKE_CXX_COMPILER
# CMAKE_RC_COMPILER
#
# Flags:
#
# CMAKE_<LANG>_FLAGS
# CMAKE_<LANG>_FLAGS_<CONFIG>
# CMAKE_RC_FLAGS
# CMAKE_SHARED_LINKER_FLAGS
# CMAKE_STATIC_LINKER_FLAGS
# CMAKE_STATIC_LINKER_FLAGS_<CONFIG>
# CMAKE_EXE_LINKER_FLAGS
# CMAKE_EXE_LINKER_FLAGS_<CONFIG>

# # Pick up the relevant root-level files for just-in-case purposes...?
# string(TOLOWER ${MSYSTEM} MSYSTEM_NAME)
# set(MSYSTEM_CONFIG_FILE "${MSYS_ROOT}/${MSYSTEM_NAME}.ini")
# set(MSYSTEM_LAUNCH_FILE "${MSYS_ROOT}/${MSYSTEM_NAME}.exe")
# set(MSYSTEM_ICON_FILE "${MSYS_ROOT}/${MSYSTEM_NAME}.ico")

# if(DEFINED ENV{MSYSTEM})
#     set(MSYSTEM "$ENV{MSYSTEM}" CACHE STRING "The detected MSYS sub-system in use." FORCE)
# elseif(DEFINED MSYSTEM)
#     set(MSYSTEM "${MSYSTEM}" CACHE STRING "The detected MSYS sub-system in use." FORCE)
# else()
#     set(MSYSTEM "MSYS" CACHE STRING "The detected MSYS sub-system in use." FORCE)
#     message(WARNING "Cannot find any valid msys2 subsystem specification...")
#     message(WARNING "please try passing '-DMSYSTEM:STRING=UCRT64' on the CMake invocation.")
#     message(WARNING "Attempting to use MSYS as a fallback.")
# endif()

set(MSYSTEM "MINGW64" CACHE STRING "The detected MSYS sub-system in use." FORCE)

# Find your msys64 installation root '<MSYS_ROOT>'...
if(NOT DEFINED MSYS_ROOT)
    if(EXISTS "$ENV{HOMEDRIVE}/msys64")
        set(MSYS_ROOT "$ENV{HOMEDRIVE}/msys64" CACHE PATH "Msys2 installation root directory." FORCE)
    else()
        message(FATAL_ERROR "Cannot find any valid msys2 installation..."
        "please try passing '-DMSYS_ROOT:PATH=<path/to/msys64>' on the CMake invocation."
        )
        # cmake_policy(POP)
        return()
    endif()
endif()

# Could keep these all exposed for potential cross-compiling...?
set(CLANGARM64_ROOT "${MSYS_ROOT}/clangarm64" CACHE PATH "")
set(CLANG64_ROOT "${MSYS_ROOT}/clang64" CACHE PATH "")
set(CLANG32_ROOT "${MSYS_ROOT}/clang32" CACHE PATH "")
set(MINGW32_ROOT "${MSYS_ROOT}/mingw32" CACHE PATH "")
set(MINGW64_ROOT "${MSYS_ROOT}/mingw64" CACHE PATH "")
set(UCRT64_ROOT "${MSYS_ROOT}/ucrt64" CACHE PATH "")

if(EXISTS "$ENV{HOMEDRIVE}/cygwin64")
    set(CYGWIN64_ROOT "$ENV{HOMEDRIVE}/cygwin64" CACHE PATH "Path to cygwin installation (64-bit)." FORCE)
endif()
if(EXISTS "$ENV{HOMEDRIVE}/cygwin32")
    set(CYGWIN32_ROOT "$ENV{HOMEDRIVE}/cygwin32" CACHE PATH "Path to cygwin installation (32-bit)." FORCE)
endif()

# Create the standard MSYS2 filepath...
set(MSYS2_DEV_DIR "${MSYS_ROOT}/dev" CACHE PATH "")
set(MSYS2_ETC_DIR "${MSYS_ROOT}/etc" CACHE PATH "")
set(MSYS2_HOME_DIR "${MSYS_ROOT}/home" CACHE PATH "")
set(MSYS2_SHARE_DIR "${MSYS_ROOT}/share" CACHE PATH "")
set(MSYS2_TMP_DIR "${MSYS_ROOT}/tmp" CACHE PATH "")
set(MSYS2_USR_DIR "${MSYS_ROOT}/usr" CACHE PATH "")
set(MSYS2_VAR_DIR "${MSYS_ROOT}/var" CACHE PATH "")
# Additional cross-compiler toolchains are in here...
set(MSYS2_OPT_DIR "${MSYS_ROOT}/opt" CACHE PATH "")

# /etc/profile.sh...

# need prefixing...
set(MSYS2_PATH
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
)
set(MANPATH
    "/usr/local/man"
    "/usr/share/man"
    "/usr/man"
    "/share/man"
)
set(INFOPATH
    "/usr/local/info"
    "/usr/share/info"
    "/usr/info"
    "/share/info"
)

if(MSYS2_PATH_TYPE STREQUAL "strict")
    # Do not inherit any path configuration, and allow for full customization
    # of external path. This is supposed to be used in special cases such as
    # debugging without need to change this file, but not daily usage.
    unset (ORIGINAL_PATH)

elseif(MSYS2_PATH_TYPE STREQUAL "inherit")
    # Inherit previous path. Note that this will make all of the Windows path
    # available in current shell, with possible interference in project builds.
    set(ORIGINAL_PATH "${ORIGINAL_PATH}" "${PATH}")

elseif(NOT DEFINED MSYS2_PATH_TYPE OR (MSYS2_PATH_TYPE STREQUAL "minimal"))
    # Do not inherit any path configuration but configure a default Windows path
    # suitable for normal usage with minimal external interference.
    set(WIN_ROOT "$(PATH=${MSYS2_PATH} exec cygpath -Wu)") # Using cygpath to turn Window's PATH to unix vals... needs CMake-ifying.
    set(ORIGINAL_PATH "${WIN_ROOT}/System32:${WIN_ROOT}:${WIN_ROOT}/System32/Wbem:${WIN_ROOT}/System32/WindowsPowerShell/v1.0/") # can use 'get_powershell_path()' here....

endif()

# unset(MINGW_MOUNT_POINT)

#########################################################################
# ARCHITECTURE, COMPILE FLAGS
#########################################################################
#-- Compiler and Linker Flags
# -march (or -mcpu) builds exclusively for an architecture
# -mtune optimizes for an architecture, but builds for whole processor family

if(MSYSTEM STREQUAL MINGW64)

    if(NOT _VCPKG_MSYS_MINGW64_TOOLCHAIN)
    set(_VCPKG_MSYS_MINGW64_TOOLCHAIN 1)

    set(BUILDSYSTEM             "MinGW x64"                           CACHE STRING   "Name of the build system." FORCE)
    set(BUILDSYSTEM_ROOT        "${MSYS_ROOT}/mingw64"                CACHE PATH     "Root of the build system." FORCE)

    if(NOT DEFINED CRT_LINKAGE)
        set(CRT_LINKAGE "static" CACHE STRING "" FORCE)
    endif()

    set(TOOLCHAIN_VARIANT       gcc                                   CACHE STRING   "Identification string of the compiler toolchain variant." FORCE)
    set(CRT_LIBRARY             msvcrt                                CACHE STRING   "Identification string of the C Runtime variant. Can be 'ucrt' (modern, 64-bit only) or 'msvcrt' (compatibilty for legacy builds)." FORCE)
    set(CXX_STD_LIBRARY         libstdc++                             CACHE STRING   "Identification string of the C++ Standard Library variant. Can be 'libstdc++' (GNU implementation) or 'libc++' (LLVM implementation)." FORCE)
    set(CRT_LINKAGE             "${CRT_LINKAGE}"                      CACHE STRING   "" FORCE)
    set(MINGW64_ROOT            "${MSYS_ROOT}/mingw64"                CACHE PATH     "")

    set(__USE_MINGW_ANSI_STDIO  "1"                                   CACHE STRING   "Use the MinGW ANSI definition for 'stdio.h'." FORCE)
    set(_FORTIFY_SOURCE         "2"                                   CACHE STRING   "Fortify source definition." FORCE)

    set(CC                      "${MINGW64_ROOT}/bin/gcc"             CACHE FILEPATH "The full path to the compiler for <CC>." FORCE)
    set(CXX                     "${MINGW64_ROOT}/bin/g++"             CACHE FILEPATH "The full path to the compiler for <CXX>." FORCE)
    set(LD                      "${MINGW64_ROOT}/bin/ld"              CACHE FILEPATH "The full path to the linker <LD>." FORCE)
    set(RC                      "${MINGW64_ROOT}/bin/windres"         CACHE FILEPATH "" FORCE)

    set(CFLAGS                  "-march=nocona -msahf -mtune=generic -O2 -pipe -Wp,-D_FORTIFY_SOURCE=2 -fstack-protector-strong" CACHE STRING "Default <CFLAGS> flags for all build types." FORCE)
    set(CXXFLAGS                "-march=nocona -msahf -mtune=generic -O2 -pipe" CACHE STRING "Default <CXXFLAGS> flags for all build types." FORCE)
    set(CPPFLAGS                "-D__USE_MINGW_ANSI_STDIO=1"          CACHE STRING    "Default <CPPFLAGS> flags for all build types." FORCE)
    set(LDFLAGS                 "-pipe"                               CACHE STRING    "Default <LD> flags for linker for all build types." FORCE)

    #-- Debugging flags
    set(DEBUG_CFLAGS            "-ggdb -Og"                           CACHE STRING    "Default <CFLAGS_DEBUG> flags." FORCE)
    set(DEBUG_CXXFLAGS          "-ggdb -Og"                           CACHE STRING    "Default <CXXFLAGS_DEBUG> flags." FORCE)

    set(PREFIX                  "/mingw64"                            CACHE PATH      "Sub-system prefix." FORCE)
    set(CARCH                   "x86_64"                              CACHE STRING    "Sub-system architecture." FORCE)
    set(CHOST                   "x86_64-w64-mingw32"                  CACHE STRING    "Sub-system name string." FORCE)

    set(MSYSTEM_PREFIX          "/mingw64"                            CACHE PATH      "Msystem prefix." FORCE)
    set(MSYSTEM_CARCH           "x86_64"                              CACHE STRING    "Msystem architecture." FORCE)
    set(MSYSTEM_CHOST           "x86_64-w64-mingw32"                  CACHE STRING    "Msystem name string." FORCE)

    set(MINGW_CHOST             "${MSYSTEM_CHOST}"                    CACHE STRING    "Sub-system prefix." FORCE)
    set(MINGW_PREFIX            "${MSYSTEM_PREFIX}"                   CACHE PATH      "Sub-system prefix." FORCE)
    set(MINGW_PACKAGE_PREFIX    "mingw-w64-${MSYSTEM_CARCH}"          CACHE STRING    "Sub-system prefix." FORCE)

    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
        set(CMAKE_CROSSCOMPILING OFF CACHE BOOL "")
    endif()

    set(CMAKE_SYSTEM_PROCESSOR x86_64 CACHE STRING "")

    foreach(lang C CXX)
        set(CMAKE_${lang}_COMPILER_TARGET "${CMAKE_SYSTEM_PROCESSOR}-windows-gnu" CACHE STRING "")
    endforeach()

    find_program(CMAKE_C_COMPILER "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32-gcc")
    find_program(CMAKE_CXX_COMPILER "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32-g++")
    find_program(CMAKE_RC_COMPILER "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32-windres")

    if(NOT CMAKE_RC_COMPILER)
        find_program(CMAKE_RC_COMPILER "windres")
    endif()

    get_property( _CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE )
    if(NOT _CMAKE_IN_TRY_COMPILE)
        string(APPEND CMAKE_C_FLAGS_INIT " ${CFLAGS} ")
        string(APPEND CMAKE_CXX_FLAGS_INIT " ${CXXFLAGS} ")
        string(APPEND CMAKE_C_FLAGS_DEBUG_INIT " ${DEBUG_CFLAGS} ")
        string(APPEND CMAKE_CXX_FLAGS_DEBUG_INIT " ${DEBUG_CXXFLAGS} ")
        string(APPEND CMAKE_C_FLAGS_RELEASE_INIT " ${RELEASE_CFLAGS} ")
        string(APPEND CMAKE_CXX_FLAGS_RELEASE_INIT " ${RELEASE_CXXFLAGS} ")

        string(APPEND CMAKE_SHARED_LINKER_FLAGS_INIT " ${LDFLAGS} ${STRIP_SHARED} ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT " ${LDFLAGS} ${STRIP_BINARIES} ")
        if(CRT_LINKAGE STREQUAL "static")
            string(APPEND CMAKE_SHARED_LINKER_FLAGS_INIT "-static ")
            string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT "-static ")
        endif()
        string(APPEND CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT " ${LDFLAGS_DEBUG} ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT " ${LDFLAGS_DEBUG} ")
        string(APPEND CMAKE_SHARED_LINKER_FLAGS_RELEASE_INIT " ${LDFLAGS_RELEASE} ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_RELEASE_INIT " ${LDFLAGS_RELEASE} ")
    endif()
    endif()

elseif(MSYSTEM STREQUAL MINGW32)

    set(BUILDSYSTEM             "MinGW x32"                           CACHE STRING    "Name of the build system." FORCE)
    set(BUILDSYSTEM_ROOT        "${MSYS_ROOT}/mingw32"                CACHE PATH      "Root of the build system." FORCE)

    set(TOOLCHAIN_VARIANT       gcc                                   CACHE STRING    "Identification string of the compiler toolchain variant." FORCE)
    set(CRT_LIBRARY             msvcrt                                CACHE STRING    "Identification string of the C Runtime variant. Can be 'ucrt' (modern, 64-bit only) or 'msvcrt' (compatibilty for legacy builds)." FORCE)
    set(CXX_STD_LIBRARY         libstdc++                             CACHE STRING    "Identification string of the C++ Standard Library variant. Can be 'libstdc++' (GNU implementation) or 'libc++' (LLVM implementation)." FORCE)

    set(__USE_MINGW_ANSI_STDIO  "1"                                   CACHE STRING    "Use the MinGW ANSI definition for 'stdio.h'." FORCE)
    set(_FORTIFY_SOURCE         "2"                                   CACHE STRING    "Fortify source definition." FORCE)

    set(CC                      "gcc"                                 CACHE FILEPATH  "The full path to the compiler for <CC>." FORCE)
    set(CXX                     "g++"                                 CACHE FILEPATH  "The full path to the compiler for <CXX>." FORCE)
    set(LD                      "ld"                                  CACHE FILEPATH  "The full path to the linker <LD>." FORCE)

    set(CFLAGS                  "-march=pentium4 -mtune=generic -O2 -pipe -Wp,-D_FORTIFY_SOURCE=2 -fstack-protector-strong" CACHE STRING "Default <CFLAGS> flags for all build types." FORCE)
    set(CXXFLAGS                "-march=pentium4 -mtune=generic -O2 -pipe" CACHE STRING "Default <CXXFLAGS> flags for all build types." FORCE)
    set(CPPFLAGS                "-D__USE_MINGW_ANSI_STDIO=1"          CACHE STRING    "Default <CPPFLAGS> flags for all build types." FORCE)
    set(LDFLAGS                 "-pipe -Wl,--no-seh -Wl,--large-address-aware" CACHE STRING    "Default <LD> flags for linker for all build types." FORCE)

    #-- Debugging flags
    set(DEBUG_CFLAGS            "-ggdb -Og"                           CACHE STRING    "Default <CFLAGS_DEBUG> flags." FORCE)
    set(DEBUG_CXXFLAGS          "-ggdb -Og"                           CACHE STRING    "Default <CXXFLAGS_DEBUG> flags." FORCE)

    set(PREFIX                  "/mingw32"                            CACHE PATH      "")
    set(CARCH                   "i686"                                CACHE STRING    "")
    set(CHOST                   "i686-w64-mingw32"                    CACHE STRING    "")

    set(MSYSTEM_PREFIX          "/mingw32"                            CACHE PATH      "")
    set(MSYSTEM_CARCH           "i686"                                CACHE STRING    "")
    set(MSYSTEM_CHOST           "i686-w64-mingw32"                    CACHE STRING    "")

    set(MINGW_CHOST             "${MSYSTEM_CHOST}"                    CACHE STRING    "")
    set(MINGW_PREFIX            "${MSYSTEM_PREFIX}"                   CACHE PATH      "")
    set(MINGW_PACKAGE_PREFIX    "mingw-w64-${MSYSTEM_CARCH}"          CACHE STRING    "")

elseif(MSYSTEM STREQUAL CLANG64)

    set(BUILDSYSTEM             "MinGW Clang x64"                     CACHE STRING    "Name of the build system." FORCE)
    set(BUILDSYSTEM_ROOT        "${MSYS_ROOT}/clang64"                CACHE PATH      "Root of the build system." FORCE)

    set(TOOLCHAIN_VARIANT       llvm                                  CACHE STRING    "Identification string of the compiler toolchain variant." FORCE)
    set(CRT_LIBRARY             ucrt                                  CACHE STRING    "Identification string of the C Runtime variant. Can be 'ucrt' (modern, 64-bit only) or 'msvcrt' (compatibilty for legacy builds)." FORCE)
    set(CXX_STD_LIBRARY         libc++                                CACHE STRING    "Identification string of the C++ Standard Library variant. Can be 'libstdc++' (GNU implementation) or 'libc++' (LLVM implementation)." FORCE)

    set(__USE_MINGW_ANSI_STDIO  "1"                                   CACHE STRING    "Use the MinGW ANSI definition for 'stdio.h'." FORCE)
    set(_FORTIFY_SOURCE         "2"                                   CACHE STRING    "Fortify source definition." FORCE)

    set(CC                      "clang"                               CACHE FILEPATH  "The full path to the compiler for <CC>." FORCE)
    set(CXX                     "clang++"                             CACHE FILEPATH  "The full path to the compiler for <CXX>." FORCE)
    set(LD                      "lld"                                 CACHE FILEPATH  "The full path to the linker <LD>." FORCE)

    set(CFLAGS                  "-march=nocona -msahf -mtune=generic -O2 -pipe -Wp,-D_FORTIFY_SOURCE=2 -fstack-protector-strong" CACHE STRING "Default <CFLAGS> flags for all build types." FORCE)
    set(CXXFLAGS                "-march=nocona -msahf -mtune=generic -O2 -pipe" CACHE STRING "Default <CXXFLAGS> flags for all build types." FORCE)
    set(CPPFLAGS                "-D__USE_MINGW_ANSI_STDIO=1"          CACHE STRING "Default <CPPFLAGS> flags for pre-processor runs for all build types." FORCE)
    set(LDFLAGS                 "-pipe"                               CACHE STRING "Default <LD> flags for linker for all build types." FORCE)

    #-- Debugging flags
    set(DEBUG_CFLAGS            "-ggdb -Og"                           CACHE STRING "Default <CFLAGS_DEBUG> flags." FORCE)
    set(DEBUG_CXXFLAGS          "-ggdb -Og"                           CACHE STRING "Default <CXXFLAGS_DEBUG> flags." FORCE)

    set(PREFIX                  "/clang64"                            CACHE PATH      "")
    set(CARCH                   "x86_64"                              CACHE STRING    "")
    set(CHOST                   "x86_64-w64-mingw32"                  CACHE STRING    "")

    set(MSYSTEM_PREFIX          "/clang64"                            CACHE PATH      "")
    set(MSYSTEM_CARCH           "x86_64"                              CACHE STRING    "")
    set(MSYSTEM_CHOST           "x86_64-w64-mingw32"                  CACHE STRING    "")

    set(MINGW_CHOST             "${MSYSTEM_CHOST}"                    CACHE STRING    "")
    set(MINGW_PREFIX            "${MSYSTEM_PREFIX}"                   CACHE PATH      "")
    set(MINGW_PACKAGE_PREFIX    "mingw-w64-clang-${MSYSTEM_CARCH}"    CACHE STRING    "")

elseif(MSYSTEM STREQUAL CLANG32)

    set(BUILDSYSTEM             "MinGW Clang x32"                     CACHE STRING    "Name of the build system." FORCE)
    set(BUILDSYSTEM_ROOT        "${MSYS_ROOT}/clang32"                CACHE PATH      "Root of the build system." FORCE)

    set(TOOLCHAIN_VARIANT       llvm                                  CACHE STRING    "Identification string of the compiler toolchain variant." FORCE)
    set(CRT_LIBRARY             ucrt                                  CACHE STRING    "Identification string of the C Runtime variant. Can be 'ucrt' (modern, 64-bit only) or 'msvcrt' (compatibilty for legacy builds)." FORCE)
    set(CXX_STD_LIBRARY         libc++                                CACHE STRING    "Identification string of the C++ Standard Library variant. Can be 'libstdc++' (GNU implementation) or 'libc++' (LLVM implementation)." FORCE)

    set(__USE_MINGW_ANSI_STDIO  "1"                                   CACHE STRING    "Use the MinGW ANSI definition for 'stdio.h'." FORCE)
    set(_FORTIFY_SOURCE         "2"                                   CACHE STRING    "Fortify source definition." FORCE)

    set(CC                      "clang"                               CACHE FILEPATH  "The full path to the compiler for <CC>." FORCE)
    set(CXX                     "clang++"                             CACHE FILEPATH  "The full path to the compiler for <CXX>." FORCE)
    set(LD                      "lld"                                 CACHE FILEPATH  "The full path to the linker <LD>." FORCE)

    set(CFLAGS                  "-march=pentium4 -mtune=generic -O2 -pipe -Wp,-D_FORTIFY_SOURCE=2 -fstack-protector-strong" CACHE STRING "Default <CFLAGS> flags for all build types." FORCE)
    set(CXXFLAGS                "-march=pentium4 -mtune=generic -O2 -pipe" CACHE STRING "Default <CXXFLAGS> flags for all build types." FORCE)
    set(CPPFLAGS                "-D__USE_MINGW_ANSI_STDIO=1"         CACHE STRING     "Default <CPPFLAGS> flags for all build types." FORCE)
    set(LDFLAGS                 "-pipe -Wl,--no-seh -Wl,--large-address-aware" CACHE STRING "Default <LD> flags for linker for all build types." FORCE)

    set(PREFIX                  "/clang32"                            CACHE PATH      "")
    set(CARCH                   "i686"                                CACHE STRING    "")
    set(CHOST                   "i686-w64-mingw32"                    CACHE STRING    "")

    set(MSYSTEM_PREFIX          "/clang32"                            CACHE PATH      "")
    set(MSYSTEM_CARCH           "i686"                                CACHE STRING    "")
    set(MSYSTEM_CHOST           "i686-w64-mingw32"                    CACHE STRING    "")

    set(MINGW_CHOST             "${MSYSTEM_CHOST}"                    CACHE STRING    "")
    set(MINGW_PREFIX            "${MSYSTEM_PREFIX}"                   CACHE PATH      "")
    set(MINGW_PACKAGE_PREFIX    "mingw-w64-clang-${MSYSTEM_CARCH}"    CACHE STRING    "")

elseif(MSYSTEM STREQUAL CLANGARM64)

    set(BUILDSYSTEM             "MinGW Clang ARM64"                   CACHE STRING    "Name of the build system." FORCE)
    set(BUILDSYSTEM_ROOT        "${MSYS_ROOT}/clangarm64"             CACHE PATH      "Root of the build system." FORCE)

    set(TOOLCHAIN_VARIANT       llvm                                  CACHE STRING    "Identification string of the compiler toolchain variant." FORCE)
    set(CRT_LIBRARY             ucrt                                  CACHE STRING    "Identification string of the C Runtime variant. Can be 'ucrt' (modern, 64-bit only) or 'msvcrt' (compatibilty for legacy builds)." FORCE)
    set(CXX_STD_LIBRARY         libc++                                CACHE STRING    "Identification string of the C++ Standard Library variant. Can be 'libstdc++' (GNU implementation) or 'libc++' (LLVM implementation)." FORCE)

    set(__USE_MINGW_ANSI_STDIO  "1"                                   CACHE STRING    "Use the MinGW ANSI definition for 'stdio.h'." FORCE)
    set(_FORTIFY_SOURCE         "2"                                   CACHE STRING    "Fortify source definition." FORCE)

    set(CC                      "clang"                               CACHE FILEPATH  "The full path to the compiler for <CC>." FORCE)
    set(CXX                     "clang++"                             CACHE FILEPATH  "The full path to the compiler for <CXX>." FORCE)
    set(LD                      "lld"                                 CACHE FILEPATH  "The full path to the linker <LD>." FORCE)

    set(CFLAGS                  "-O2 -pipe -Wp,-D_FORTIFY_SOURCE=2 -fstack-protector-strong" CACHE STRING "Default <CFLAGS> flags for all build types." FORCE)
    set(CXXFLAGS                "-O2 -pipe"                           CACHE STRING    "Default <CXXFLAGS> flags for all build types." FORCE)
    set(CPPFLAGS                "-D__USE_MINGW_ANSI_STDIO=1"          CACHE STRING    "Default <CPPFLAGS> flags for all build types." FORCE)
    set(LDFLAGS                 "-pipe"                               CACHE STRING    "Default <LD> flags for linker for all build types." FORCE)

    set(PREFIX                  "/clangarm64"                         CACHE PATH      "")
    set(CARCH                   "aarch64"                             CACHE STRING    "")
    set(CHOST                   "aarch64-w64-mingw32"                 CACHE STRING    "")

    set(MSYSTEM_PREFIX          "/clangarm64"                         CACHE PATH      "")
    set(MSYSTEM_CARCH           "aarch64"                             CACHE STRING    "")
    set(MSYSTEM_CHOST           "aarch64-w64-mingw32"                 CACHE STRING    "")

    set(MINGW_CHOST             "${MSYSTEM_CHOST}"                    CACHE STRING    "")
    set(MINGW_PREFIX            "${MSYSTEM_PREFIX}"                   CACHE PATH      "")
    set(MINGW_PACKAGE_PREFIX    "mingw-w64-clang-${MSYSTEM_CARCH}"    CACHE STRING    "")

elseif(MSYSTEM STREQUAL UCRT64)

    set(BUILDSYSTEM             "MinGW UCRT x64"                      CACHE STRING    "Name of the build system." FORCE)
    set(BUILDSYSTEM_ROOT        "${MSYS_ROOT}/ucrt64"                 CACHE PATH      "Root of the build system." FORCE)

    set(TOOLCHAIN_VARIANT       gcc                                   CACHE STRING    "Identification string of the compiler toolchain variant." FORCE)
    set(CRT_LIBRARY             ucrt                                  CACHE STRING    "Identification string of the C Runtime variant. Can be 'ucrt' (modern, 64-bit only) or 'msvcrt' (compatibilty for legacy builds)." FORCE)
    set(CXX_STD_LIBRARY         libstdc++                             CACHE STRING    "Identification string of the C++ Standard Library variant. Can be 'libstdc++' (GNU implementation) or 'libc++' (LLVM implementation)." FORCE)

    set(__USE_MINGW_ANSI_STDIO "1"                                    CACHE STRING    "Use the MinGW ANSI definition for 'stdio.h'." FORCE)
    set(_FORTIFY_SOURCE         "2"                                   CACHE STRING    "Fortify source definition." FORCE)

    set(CC                      "gcc"                                 CACHE FILEPATH  "The full path to the compiler for <CC>." FORCE)
    set(CXX                     "g++"                                 CACHE FILEPATH  "The full path to the compiler for <CXX>." FORCE)
    set(LD                      "ld"                                  CACHE FILEPATH  "The full path to the linker <LD>." FORCE)

    set(CFLAGS                  "-march=nocona -msahf -mtune=generic -O2 -pipe -Wp,-D_FORTIFY_SOURCE=2 -fstack-protector-strong" CACHE STRING "Default <CFLAGS> flags for all build types." FORCE)
    set(CXXFLAGS                "-march=nocona -msahf -mtune=generic -O2 -pipe" CACHE STRING "Default <CXXFLAGS> flags for all build types." FORCE)
    set(CPPFLAGS                "-D__USE_MINGW_ANSI_STDIO=1"          CACHE STRING    "Default <CPPFLAGS> flags for all build types." FORCE)
    set(LDFLAGS                 "-pipe"                               CACHE STRING    "Default <LD> flags for linker for all build types." FORCE)

    set(PREFIX                  "/ucrt64"                             CACHE PATH      "")
    set(CARCH                   "x86_64"                              CACHE STRING    "")
    set(CHOST                   "x86_64-w64-mingw32"                  CACHE STRING    "")

    set(MSYSTEM_PREFIX          "/ucrt64"                             CACHE PATH      "")
    set(MSYSTEM_CARCH           "x86_64"                              CACHE STRING    "")
    set(MSYSTEM_CHOST           "x86_64-w64-mingw32"                  CACHE STRING    "")

    set(MINGW_CHOST             "${MSYSTEM_CHOST}"                    CACHE STRING    "")
    set(MINGW_PREFIX            "${MSYSTEM_PREFIX}"                   CACHE PATH      "")
    set(MINGW_PACKAGE_PREFIX    "mingw-w64-ucrt-${MSYSTEM_CARCH}"     CACHE STRING    "")

elseif(MSYSTEM STREQUAL "MSYS")

    set(BUILDSYSTEM             "MSYS2 MSYS"                          CACHE STRING    "Name of the build system." FORCE)
    set(BUILDSYSTEM_ROOT        "${MSYS_ROOT}"                        CACHE PATH      "Root of the build system." FORCE)

    set(TOOLCHAIN_VARIANT       gcc                                   CACHE STRING    "Identification string of the compiler toolchain variant." FORCE)
    set(CRT_LIBRARY             cygwin                                CACHE STRING    "Identification string of the C Runtime variant. Can be 'ucrt' (modern, 64-bit only) or 'msvcrt' (compatibilty for legacy builds)." FORCE)
    set(CXX_STD_LIBRARY         libstdc++                             CACHE STRING    "Identification string of the C++ Standard Library variant. Can be 'libstdc++' (GNU implementation) or 'libc++' (LLVM implementation)." FORCE)

    set(CARCH                   "x86_64"                              CACHE STRING    "" FORCE)
    set(CHOST                   "x86_64-pc-msys"                      CACHE STRING    "" FORCE)

    set(CC                      "gcc"                                 CACHE FILEPATH  "The full path to the compiler for <CC>." FORCE)
    set(CXX                     "g++"                                 CACHE FILEPATH  "The full path to the compiler for <CXX>." FORCE)
    set(LD                      "ld"                                  CACHE FILEPATH "The full path to the linker <LD>." FORCE)

    set(CFLAGS                  "-march=nocona -msahf -mtune=generic -O2 -pipe" CACHE STRING "Default <CFLAGS> flags for all build types." FORCE)
    set(CXXFLAGS                "-march=nocona -msahf -mtune=generic -O2 -pipe" CACHE STRING "" CACHE STRING "Default <CXXFLAGS> flags for all build types." FORCE)
    set(CPPFLAGS                ""                                    CACHE STRING    "Default <CPPFLAGS> flags for all build types." FORCE)
    set(LDFLAGS                 "-pipe"                               CACHE STRING    "Default <LD> flags for linker for all build types." FORCE)

    #-- Debugging flags
    set(DEBUG_CFLAGS "-ggdb -Og" CACHE STRING "" FORCE)
    set(DEBUG_CXXFLAGS "-ggdb -Og" CACHE STRING "" FORCE)

    execute_process(
        COMMAND "${MSYS_ROOT}/usr/bin/uname -m"
        WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
        OUTPUT_VARIABLE DETECTED_CARCH
        # COMMAND_ERROR_IS_FATAL ANY
    )

    set(PREFIX                  "/msys64"                     CACHE PATH      "")
    set(CARCH                   "${DETECTED_CARCH}"           CACHE STRING    "")
    set(CHOST                   "${DETECTED_CARCH}-pc-msys"   CACHE STRING    "")

    set(MSYSTEM_PREFIX          "/usr"                        CACHE PATH      "")
    set(MSYSTEM_CARCH           "${DETECTED_CARCH}"           CACHE STRING    "")
    set(MSYSTEM_CHOST           "${DETECTED_CARCH}-pc-msys"   CACHE STRING    "")

else()
    message(FATAL_ERROR "Unsupported MSYSTEM: ${MSYSTEM}")
    # cmake_policy(POP)
    return()
endif()


# Note that some packages cannot be mixed together, likely to prevent setting
# linkage between mixed C runtimes (which is widely unsupported and not recommended).
set(MINGW_W64_CROSS_CLANG_TOOLCHAIN_PACKAGES
    mingw-w64-cross-clang
    mingw-w64-cross-clang-crt
    mingw-w64-cross-clang-headers
    CACHE STRING "Packages from command: 'pacman -S mingw-w64-cross-clang-toolchain'."
)
set(MINGW_W64_CROSS_UCRT_TOOLCHAIN_PACKAGES
    mingw-w64-cross-ucrt-ucrt
    mingw-w64-cross-ucrt-headers
    CACHE STRING "Packages from command: 'pacman -S mingw-w64-cross-ucrt-toolchain'."
)
set(MINGW_W64_CROSS_TOOLCHAIN_PACKAGES
    mingw-w64-cross-binutils
    mingw-w64-cross-crt
    mingw-w64-cross-gcc
    mingw-w64-cross-headers
    mingw-w64-cross-tools
    mingw-w64-cross-windows-default-manifest
    mingw-w64-cross-winpthreads
    mingw-w64-cross-winstorecompat
    mingw-w64-cross-zlib
    CACHE STRING "Packages from command: 'pacman -S mingw-w64-cross-toolchain'."
)
set(MINGW_W64_CROSS_PACKAGES
    mingw-w64-cross-binutils
    mingw-w64-cross-crt
    mingw-w64-cross-gcc
    mingw-w64-cross-headers
    mingw-w64-cross-tools
    mingw-w64-cross-windows-default-manifest
    mingw-w64-cross-winpthreads
    mingw-w64-cross-winstorecompat
    mingw-w64-cross-zlib
    CACHE STRING "Packages from command: 'pacman -S mingw-w64-cross'."
) # Actually identical to the previous var...

if ((MSYSTEM STREQUAL MINGW64) OR
    (MSYSTEM STREQUAL MINGW32) OR
    (MSYSTEM STREQUAL CLANG64) OR
    (MSYSTEM STREQUAL CLANG32) OR
    (MSYSTEM STREQUAL CLANGARM64) OR
    (MSYSTEM STREQUAL UCRT64)
    )

    # Flag config name fixup...
    set(CFLAGS_DEBUG              "${DEBUG_CFLAGS}"                  CACHE STRING "Default <CFLAGS_DEBUG> flags." FORCE)
    set(CFLAGS_RELEASE            "${RELEASE_CFLAGS}"                CACHE STRING "Default <CFLAGS_RELEASE> flags." FORCE)
    set(CFLAGS_MINSIZEREL         "${MINSIZEREL_CFLAGS}"             CACHE STRING "Default <CFLAGS_MINSIZEREL> flags." FORCE)
    set(CFLAGS_RELWITHDEBINFO     "${RELWITHDEBINFO_CFLAGS}"         CACHE STRING "Default <CFLAGS_RELWITHDEBINFO> flags." FORCE)

    set(CXXFLAGS_DEBUG            "${DEBUG_CXXFLAGS}"                CACHE STRING "Default <CXXFLAGS_DEBUG> flags." FORCE)
    set(CXXFLAGS_RELEASE          "${RELEASE_CXXFLAGS}"              CACHE STRING "Default <CXXFLAGS_RELEASE> flags." FORCE)
    set(CXXFLAGS_MINSIZEREL       "${MINSIZEREL_CXXFLAGS}"           CACHE STRING "Default <CXXFLAGS_MINSIZEREL> flags." FORCE)
    set(CXXFLAGS_RELWITHDEBINFO   "${RELWITHDEBINFO_CXXFLAGS}"       CACHE STRING "Default <CXXFLAGS_RELWITHDEBINFO> flags." FORCE)

    set(CPPFLAGS_DEBUG            "${DEBUG_CPPFLAGS}"                CACHE STRING "Default <CPPFLAGS_DEBUG> flags." FORCE)
    set(CPPFLAGS_RELEASE          "${RELEASE_CPPFLAGS}"              CACHE STRING "Default <CPPFLAGS_RELEASE> flags." FORCE)
    set(CPPFLAGS_MINSIZEREL       "${MINSIZEREL_CPPFLAGS}"           CACHE STRING "Default <CPPFLAGS_MINSIZEREL> flags." FORCE)
    set(CPPFLAGS_RELWITHDEBINFO   "${RELWITHDEBINFO_CPPFLAGS}"       CACHE STRING "Default <CPPFLAGS_RELWITHDEBINFO> flags." FORCE)

    set(RCFLAGS_DEBUG             "${DEBUG_RCFLAGS}"                 CACHE STRING "Default <CFLAGS_DEBUG> flags." FORCE)
    set(RCFLAGS_RELEASE           "${RELEASE_RCFLAGS}"               CACHE STRING "Default <CFLAGS_RELEASE> flags." FORCE)
    set(RCFLAGS_MINSIZEREL        "${MINSIZEREL_RCFLAGS}"            CACHE STRING "Default <CFLAGS_MINSIZEREL> flags." FORCE)
    set(RCFLAGS_RELWITHDEBINFO    "${RELWITHDEBINFO_RCFLAGS}"        CACHE STRING "Default <CFLAGS_RELWITHDEBINFO> flags." FORCE)

    # Set toolchain package suffixes (i.e., '{mingw-w64-clang-x86_64}-avr-toolchain')...
    set(TOOLCHAIN_NATIVE_ARM_NONE_EABI          "${MINGW_PACKAGE_PREFIX}-arm-none-eabi-toolchain" CACHE STRING "" FORCE)
    set(TOOLCHAIN_NATIVE_AVR                    "${MINGW_PACKAGE_PREFIX}-avr-toolchain" CACHE STRING "" FORCE)
    set(TOOLCHAIN_NATIVE_RISCV64_UNKOWN_ELF     "${MINGW_PACKAGE_PREFIX}-riscv64-unknown-elf-toolchain" CACHE STRING "The 'unknown elf' toolchain! Careful with this elf, it is not known." FORCE)
    set(TOOLCHAIN_NATIVE                        "${MINGW_PACKAGE_PREFIX}-toolchain" CACHE STRING "" FORCE)

    # DirectX compatibility environment variable
    set(DXSDK_DIR "${MINGW_PREFIX}/${MINGW_CHOST}" CACHE PATH "DirectX compatibility environment variable." FORCE)

    #-- Make Flags: change this for DistCC/SMP systems
    # This var is attempting to pass '-j' to the underlying buildtool - this flag controls the number of processors to build with.
    # A trypical logical default (as expressed here) is 'number of logical cores' + 1.
    # The var is currently attempting to call 'nproc' from the PATH - CMake has its own vars that are probably better suited for this...
    if(NOT DEFINED MAKEFLAGS)
        set(MAKEFLAGS "-j$(($(nproc)+1))" CACHE STRING "Make Flags: change this for DistCC/SMP systems")
    endif()

    set(ACLOCAL_PATH          "${MINGW_PREFIX}/share/aclocal" "${MSYS_ROOT}/usr/share" CACHE PATH "By default, aclocal searches for .m4 files in the following directories." FORCE)
    set(PKG_CONFIG_PATH       "${MINGW_PREFIX}/lib/pkgconfig" "${MINGW_PREFIX}/share/pkgconfig" CACHE PATH "A colon-separated (on Windows, semicolon-separated) list of directories to search for .pc files. The default directory will always be searched after searching the path." FORCE)

endif()


unset(CC)
unset(CXX)
unset(LD)
unset(RC)
unset(LDFLAGS)
unset(LDFLAGS_DEBUG)
unset(LDFLAGS_MINSIZEREL)
unset(LDFLAGS_RELEASE)
unset(LDFLAGS_RELWITHDEBINFO)
unset(RCFLAGS)
unset(RCFLAGS_DEBUG)
unset(RCFLAGS_MINSIZEREL)
unset(RCFLAGS_RELEASE)
unset(RCFLAGS_RELWITHDEBINFO)
unset(CFLAGS)
unset(CFLAGS_DEBUG)
unset(CFLAGS_MINSIZEREL)
unset(CFLAGS_RELEASE)
unset(CFLAGS_RELWITHDEBINFO)
unset(CXXFLAGS)
unset(CXXFLAGS_DEBUG)
unset(CXXFLAGS_MINSIZEREL)
unset(CXXFLAGS_RELEASE)
unset(CXXFLAGS_RELWITHDEBINFO)
unset(CPPFLAGS)
unset(CPPFLAGS_DEBUG)
unset(CPPFLAGS_MINSIZEREL)
unset(CPPFLAGS_RELEASE)
unset(CPPFLAGS_RELWITHDEBINFO)
unset(DEBUG_CFLAGS)
unset(DEBUG_CPPFLAGS)
unset(DEBUG_CXXFLAGS)
unset(DEBUG_LDFLAGS)
unset(DEBUG_RCFLAGS)
unset(RELEASE_CFLAGS)
unset(RELEASE_CPPFLAGS)
unset(RELEASE_CXXFLAGS)
unset(RELEASE_LDFLAGS)
unset(RELEASE_RCFLAGS)
unset(CARCH)
unset(CHOST)

#########################################################################
# SOURCE ACQUISITION
#########################################################################
#
#-- The download utilities that makepkg should use to acquire sources
#
#########################################################################

set(DLAGENT_FILE_AGENT "/usr/bin/curl")
set(DLAGENT_FTP_AGENT "/usr/bin/curl")
set(DLAGENT_HTTP_AGENT "/usr/bin/curl")
set(DLAGENT_HTTPS_AGENT "/usr/bin/curl")
set(DLAGENT_RSYNC_AGENT "/usr/bin/rsync")
set(DLAGENT_SCP_AGENT "/usr/bin/scp")
# Here were set the <agent> flags for each <protocol>
set(DLAGENT_FILE_FLAGS "-gqC - -o %o %u")
set(DLAGENT_FTP_FLAGS "-gqfC - --ftp-pasv --retry 3 --retry-delay 3 -o %o %u")
set(DLAGENT_HTTP_FLAGS "-gqb \"\" -fLC - --retry 3 --retry-delay 3 -o %o %u")
set(DLAGENT_HTTPS_FLAGS "-gqb \"\" -fLC - --retry 3 --retry-delay 3 -o %o %u")
set(DLAGENT_RSYNC_FLAGS "--no-motd -z %u %o")
set(DLAGENT_SCP_FLAGS "-C %u %o")
#  Format: 'protocol::agent'
set(DLAGENTS
    "file::${DLAGENT_FILE_AGENT} ${DLAGENT_FILE_FLAGS}"
    "ftp::${DLAGENT_FTP_AGENT} ${DLAGENT_FTP_FLAGS}"
    "http::${DLAGENT_HTTP_AGENT} ${DLAGENT_HTTP_FLAGS}"
    "https::${DLAGENT_HTTPS_AGENT} ${DLAGENT_HTTPS_FLAGS}"
    "rsync::${DLAGENT_RSYNC_AGENT} ${DLAGENT_RSYNC_FLAGS}"
    "scp::${DLAGENT_SCP_AGENT} ${DLAGENT_SCP_FLAGS}"
)
# In other words...
# set(DLAGENTS
#     "file::/usr/bin/curl -gqC - -o %o %u"
#     "ftp::/usr/bin/curl -gqfC - --ftp-pasv --retry 3 --retry-delay 3 -o %o %u"
#     "http::/usr/bin/curl -gqb \"\" -fLC - --retry 3 --retry-delay 3 -o %o %u"
#     "https::/usr/bin/curl -gqb \"\" -fLC - --retry 3 --retry-delay 3 -o %o %u"
#     "rsync::/usr/bin/rsync --no-motd -z %u %o"
#     "scp::/usr/bin/scp -C %u %o"
# )

# Other common tools:
# /usr/bin/snarf
# /usr/bin/lftpget -c
# /usr/bin/wget (instead of curl? Could be on a switch...)

#-- The package required by makepkg to download VCS sources.
# We can use vcpkg to fetch these for linking our packages with.
# Format: 'protocol::package'
set(VCSCLIENTS
    bzr::bzr
    fossil::fossil
    git::git
    hg::mercurial
    svn::subversion
)

#########################################################################
# BUILD ENVIRONMENT
#########################################################################
#
# Makepkg defaults: BUILDENV=(!distcc !color !ccache check !sign)
#  A negated environment option will do the opposite of the comments below.
#
#-- distcc:   Use the Distributed C/C++/ObjC compiler
#-- color:    Colorize output messages
#-- ccache:   Use ccache to cache compilation
#-- check:    Run the check() function if present in the PKGBUILD
#-- sign:     Generate PGP signature file
#
if(NOT DEFINED BUILDENV)
    set(BUILDENV !distcc color !ccache check !sign)
endif()
#
#-- If using DistCC, your MAKEFLAGS will also need modification. In addition,
#-- specify a space-delimited list of hosts running in the DistCC cluster.
#DISTCC_HOSTS=""
#
#-- Specify a directory for package building.
#BUILDDIR=/tmp/makepkg

#########################################################################
# GLOBAL PACKAGE OPTIONS
#   These are default values for the options=() settings
#########################################################################
#
# Makepkg defaults: OPTIONS=(!strip docs libtool staticlibs emptydirs !zipman !purge !debug !lto)
#  A negated option will do the opposite of the comments below.
#
#-- strip:      Strip symbols from binaries/libraries
#-- docs:       Save doc directories specified by DOC_DIRS
#-- libtool:    Leave libtool (.la) files in packages
#-- staticlibs: Leave static library (.a) files in packages
#-- emptydirs:  Leave empty directories in packages
#-- zipman:     Compress manual (man and info) pages in MAN_DIRS with gzip
#-- purge:      Remove files specified by PURGE_TARGETS
#-- debug:      Add debugging flags as specified in DEBUG_* variables
#-- lto:        Add compile flags for building with link time optimization
#

# Options handler...

option(OPTION_DOCS "Save doc directories specified by <DOC_DIRS>." ON)
option(OPTION_LIBTOOL "Leave libtool (.la) files in packages." OFF)
option(OPTION_STATIC_LIBS "Leave static library (.a) files in packages." ON)
option(OPTION_EMPTY_DIRS "Leave empty directories in packages." ON)
option(OPTION_ZIPMAN "Compress manual (man and info) pages in <MAN_DIRS> with gzip." ON)
option(OPTION_PURGE "Remove files specified by <PURGE_TARGETS>." ON)
option(OPTION_DEBUG "Add debugging flags as specified in <DEBUG_*> variables." OFF)
option(OPTION_LTO "Add compile flags for building with link time optimization." OFF)

option(OPTION_STRIP "Strip symbols from binaries/libraries." ON)
if(OPTION_STRIP)
    set(OPTION_STRIP_FLAG strip CACHE STRING "A negated option will do the opposite of the comments below." FORCE)
    #-- Options to be used when stripping binaries. See `man strip' for details.
    if(NOT DEFINED STRIP_BINARIES)
        set(STRIP_BINARIES --strip-all CACHE STRING "Options to be used when stripping binaries. See `man strip' for details." FORCE)
    endif()
else()
    set(OPTION_STRIP_FLAG !strip CACHE STRING "A negated option will do the opposite of the comments below." FORCE)
endif()

# And so forth, or nah...?

if(OPTION_DOCS)
    set(OPTION_DOCS_FLAG docs CACHE STRING "A negated option will do the opposite of the comments below." FORCE)
else()
    set(OPTION_DOCS_FLAG !docs CACHE STRING "A negated option will do the opposite of the comments below." FORCE)
endif()

if(OPTION_LIBTOOL)
    set(OPTION_LIBTOOL_FLAG libtool CACHE STRING "A negated option will do the opposite of the comments below." FORCE)
else()
    set(OPTION_LIBTOOL_FLAG !libtool CACHE STRING "A negated option will do the opposite of the comments below." FORCE)
endif()

if(OPTION_STATIC_LIBS)
    set(OPTION_STATIC_LIBS_FLAG staticlibs CACHE STRING "A negated option will do the opposite of the comments below." FORCE)
else()
    set(OPTION_STATIC_LIBS_FLAG !staticlibs CACHE STRING "A negated option will do the opposite of the comments below." FORCE)
endif()

if(OPTION_EMPTY_DIRS)
    set(OPTION_EMPTY_DIRS_FLAG emptydirs CACHE STRING "A negated option will do the opposite of the comments below." FORCE)
else()
    set(OPTION_EMPTY_DIRS_FLAG !emptydirs CACHE STRING "A negated option will do the opposite of the comments below." FORCE)
endif()

if(OPTION_ZIPMAN)
    set(OPTION_ZIPMAN_FLAG zipman CACHE STRING "A negated option will do the opposite of the comments below." FORCE)
else()
    set(OPTION_ZIPMAN_FLAG !zipman CACHE STRING "A negated option will do the opposite of the comments below." FORCE)
endif()

if(OPTION_PURGE)
    set(OPTION_PURGE_FLAG purge CACHE STRING "A negated option will do the opposite of the comments below." FORCE)
else()
    set(OPTION_PURGE_FLAG !purge CACHE STRING "A negated option will do the opposite of the comments below." FORCE)
endif()

if(OPTION_DEBUG)
    set(OPTION_DEBUG_FLAG debug CACHE STRING "A negated option will do the opposite of the comments below." FORCE)
else()
    set(OPTION_DEBUG_FLAG !debug CACHE STRING "A negated option will do the opposite of the comments below." FORCE)
endif()

if(OPTION_LTO)
    set(OPTION_LTO_FLAG lto CACHE STRING "A negated option will do the opposite of the comments below." FORCE)
else()
    set(OPTION_LTO_FLAG !lto CACHE STRING "A negated option will do the opposite of the comments below." FORCE)
endif()

if(NOT DEFINED OPTIONS)
    set(OPTIONS "${OPTION_STRIP_FLAG} ${OPTION_DOCS_FLAG} ${OPTION_LIBTOOL_FLAG} ${OPTION_STATIC_LIBS_FLAG} ${OPTION_EMPTY_DIRS_FLAG} ${OPTION_ZIPMAN_FLAG} ${OPTION_PURGE_FLAG} ${OPTION_DEBUG_FLAG} ${OPTION_LTO_FLAG}")
endif()
set(OPTIONS "${OPTIONS}" CACHE STRING "These are the values for the CMake 'option()' settings." FORCE)

# if(NOT DEFINED OPTIONS)
#     set(OPTIONS "" CACHE STRING "")
#     list(APPEND OPTIONS strip docs !libtool staticlibs emptydirs zipman purge !debug !lto)
# endif()

#-- File integrity checks to use. Valid: md5, sha1, sha256, sha384, sha512
if(NOT DEFINED INTEGRITY_CHECK OR (INTEGRITY_CHECK STREQUAL ""))
    set(INTEGRITY_CHECK sha256)
endif()
set(INTEGRITY_CHECK "${INTEGRITY_CHECK}" CACHE STRING "File integrity checks to use. Valid: md5, sha1, sha256, sha384, sha512" FORCE)

#-- Options to be used when stripping shared libraries. See `man strip' for details.
set(STRIP_SHARED --strip-unneeded CACHE STRING "Options to be used when stripping shared libraries. See `man strip' for details." FORCE)
#-- Options to be used when stripping static libraries. See `man strip' for details.
set(STRIP_STATIC --strip-debug CACHE STRING "Options to be used when stripping static libraries. See `man strip' for details." FORCE)
#-- Manual (man and info) directories to compress (if zipman is specified)
set(MAN_DIRS "\"\${MINGW_PREFIX#/}\"{{,/local}{,/share},/opt/*}/{man,info}" CACHE STRING "Manual (man and info) directories to compress (if zipman is specified)" FORCE)
#-- Doc directories to remove (if !docs is specified)
set(DOC_DIRS "\"\${MINGW_PREFIX#/}\"/{,local/}{,share/}{doc,gtk-doc}" CACHE STRING "Doc directories to remove (if !docs is specified)" FORCE)
#-- Files to be removed from all packages (if purge is specified)
if(NOT DEFINED PURGE_TARGETS)
    set(PURGE_TARGETS "\"\${MINGW_PREFIX#/}\"/{,share}/info/dir .packlist *.pod" CACHE STRING "Files to be removed from all packages (if purge is specified)" FORCE)
endif()


#########################################################################
# PACKAGE OUTPUT
#########################################################################
#
# Default: put built package and cached source in build directory.
#
#########################################################################

#-- Destination: specify a fixed directory where all packages will be placed
if(NOT DEFINED PKGDEST)
    set(PKGDEST "/var/packages-mingw64") # If not yet defined, set a default...
endif() # ...then, write the resulting definition to the cache, with a description attached.
set(PKGDEST "${PKGDEST}" CACHE PATH "Destination: specify a fixed directory where all packages will be placed." FORCE)

#-- Source cache: specify a fixed directory where source files will be cached
if(NOT DEFINED SRCDEST)
    set(SRCDEST "/var/sources")
endif()
set(SRCDEST "${SRCDEST}" CACHE PATH "Source cache: specify a fixed directory where source files will be cached." FORCE)

#-- Source packages: specify a fixed directory where all src packages will be placed
if(NOT DEFINED SRCPKGDEST)
    set(SRCPKGDEST "/var/srcpackages-mingw64")
endif()
set(SRCPKGDEST "${SRCPKGDEST}" CACHE PATH "Source packages: specify a fixed directory where all src packages will be placed" FORCE)

#-- Log files: specify a fixed directory where all log files will be placed
if(NOT DEFINED LOGDEST)
    set(LOGDEST "/var/makepkglogs")
endif()
set(LOGDEST "${LOGDEST}" CACHE PATH "Log files: specify a fixed directory where all log files will be placed" FORCE)

#-- Packager: name/email of the person or organization building packages
if(DEFINED PACKAGER)
    set(PACKAGER "${PACKAGER}" CACHE STRING "Packager: name/email of the person or organization building packages (optional)." FORCE)
else()
    set(PACKAGER "John Doe <john@doe.com>" CACHE STRING "Packager: name/email of the person or organization building packages (Default)." FORCE)
endif()

#-- Specify a key to use for package signing
if(DEFINED GPGKEY)
    set(GPGKEY "${GPGKEY}" CACHE STRING "Specify a key to use for package signing (Optional)." FORCE)
else()
    set(GPGKEY "UNDEFINED" CACHE STRING "Specify a key to use for package signing (Undefined)." FORCE)
endif()

#########################################################################
# COMPRESSION DEFAULTS
#########################################################################

if(NOT DEFINED COMPRESSGZ_FLAGS)
    set(COMPRESSGZ_FLAGS "-c -f -n" CACHE STRING "Flags for the gzip compression utility." FORCE)
endif()
if(NOT DEFINED COMPRESSBZ2_FLAGS)
    set(COMPRESSBZ2_FLAGS "-c -f" CACHE STRING "Flags for the bzip compression utility." FORCE)
endif()
if(NOT DEFINED COMPRESSXZ_FLAGS)
    set(COMPRESSXZ_FLAGS "-c -z -T0 -" CACHE STRING "Flags for the xz compression utility." FORCE)
endif()
if(NOT DEFINED COMPRESSZST_FLAGS)
    set(COMPRESSZST_FLAGS "-c -T0 --ultra -20 -" CACHE STRING "Flags for the zstd compression utility." FORCE)
endif()
if(NOT DEFINED COMPRESSLRZ_FLAGS)
    set(COMPRESSLRZ_FLAGS "-q" CACHE STRING "Flags for the lrzip compression utility." FORCE)
endif()
if(NOT DEFINED COMPRESSLZO_FLAGS)
    set(COMPRESSLZO_FLAGS "-q" CACHE STRING "Flags for the lzop compression utility." FORCE)
endif()
if(NOT DEFINED COMPRESSZ_FLAGS)
    set(COMPRESSZ_FLAGS "-c -f" CACHE STRING "Flags for the compress compression utility." FORCE)
endif()
if(NOT DEFINED COMPRESSLZ4_FLAGS)
    set(COMPRESSLZ4_FLAGS "-q" CACHE STRING "Flags for the lz4 compression utility." FORCE)
endif()
if(NOT DEFINED COMPRESSLZ_FLAGS)
    set(COMPRESSLZ_FLAGS "-c -f" CACHE STRING "Flags for the lzip compression utility." FORCE)
endif()

set(COMPRESSGZ "gzip ${COMPRESSGZ_FLAGS}" CACHE STRING "The gzip compression utility command." FORCE)
set(COMPRESSBZ2 "bzip2 ${COMPRESSBZ2_FLAGS}" CACHE STRING "The bzip compression utility command." FORCE)
set(COMPRESSXZ "xz ${COMPRESSXZ_FLAGS}" CACHE STRING "The xz compression utility command." FORCE)
set(COMPRESSZST "zstd ${COMPRESSZST_FLAGS}" CACHE STRING "The zst compression utility command." FORCE)
set(COMPRESSLRZ "lrzip ${COMPRESSLRZ_FLAGS}" CACHE STRING "The lrzip compression utility command." FORCE)
set(COMPRESSLZO "lzop ${COMPRESSLZO_FLAGS}" CACHE STRING "The lzop compression utility command." FORCE)
set(COMPRESSZ "compress ${COMPRESSZ_FLAGS}" CACHE STRING "The compress compression utility command." FORCE)
set(COMPRESSLZ4 "lz4 ${COMPRESSLZ4_FLAGS}" CACHE STRING "The lz4 compression utility command." FORCE)
set(COMPRESSLZ "lzip ${COMPRESSLZ_FLAGS}" CACHE STRING "The lzip compression utility command." FORCE)

unset(COMPRESSGZ_FLAGS)
unset(COMPRESSBZ2_FLAGS)
unset(COMPRESSXZ_FLAGS)
unset(COMPRESSZST_FLAGS)
unset(COMPRESSLRZ_FLAGS)
unset(COMPRESSLZO_FLAGS)
unset(COMPRESSZ_FLAGS)
unset(COMPRESSLZ4_FLAGS)
unset(COMPRESSLZ_FLAGS)
#########################################################################
# EXTENSION DEFAULTS
#########################################################################

set(PKGEXT ".pkg.tar.zst" CACHE STRING "File extension to use for packages." FORCE)
set(SRCEXT ".src.tar.zst" CACHE STRING "File extension to use for packages containing source code." FORCE)

#########################################################################
# OTHER
#########################################################################

#-- Command used to run pacman as root, instead of trying sudo and su
# PACMAN_AUTH=()
set(PACMAN_AUTH "()" CACHE STRING "Command used to run pacman as root, instead of trying sudo and su" FORCE)

# cmake_policy(POP)

set(ENV_VARS_FILE_PATH "${CMAKE_CURRENT_BINARY_DIR}/.${TARGET_TRIPLET}.env")
# file(WRITE ${ENV_VARS_FILE_PATH} "Generator: Toolchain file.\n")

execute_process(COMMAND "${CMAKE_COMMAND}" -E environment
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE ENV_VARS_FILE
)

file(APPEND ${ENV_VARS_FILE_PATH} "${ENV_VARS_FILE}")

#########################################################################
# NOTES
#########################################################################

# These vars (examples) can be detected in Windows system environments...
# UCRTVersion := 10.0.22621.0
# UniversalCRTSdkDir := C:\Program Files (x86)\Windows Kits\10\
# VCIDEInstallDir := C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\VC\
# VCINSTALLDIR := C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\
# VCToolsRedistDir := C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Redist\MSVC\14.36.32532\
# VisualStudioVersion := 17.0
# VSINSTALLDIR := C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\
# WindowsLibPath := C:\Program Files (x86)\Windows Kits\10\UnionMetadata\10.0.22621.0;C:\Program Files (x86)\Windows Kits\10\References\10.0.22621.0
# WindowsSdkBinPath := C:\Program Files (x86)\Windows Kits\10\bin\
# WindowsSdkDir := C:\Program Files (x86)\Windows Kits\10\
# WindowsSDKLibVersion := 10.0.22621.0\
# WindowsSDKVersion := 10.0.22621.0\
# TMP := C:\Users\natha\AppData\Local\Temp


# # The below is the equivalent to /etc/msystem but for cmake...
# if(MSYSTEM STREQUAL MINGW32)
#     set(MSYSTEM_PREFIX          "/mingw32"                            CACHE PATH      "")
#     set(MSYSTEM_CARCH           "i686"                                CACHE STRING    "")
#     set(MSYSTEM_CHOST           "i686-w64-mingw32"                    CACHE STRING    "")
#     set(MINGW_CHOST             "${MSYSTEM_CHOST}"                    CACHE STRING    "")
#     set(MINGW_PREFIX            "${MSYSTEM_PREFIX}"                   CACHE PATH      "")
#     set(MINGW_PACKAGE_PREFIX    "mingw-w64-${MSYSTEM_CARCH}"          CACHE STRING    "")
# elseif(MSYSTEM STREQUAL MINGW64)
#     set(MSYSTEM_PREFIX          "/mingw64"                            CACHE PATH      "")
#     set(MSYSTEM_CARCH           "x86_64"                              CACHE STRING    "")
#     set(MSYSTEM_CHOST           "x86_64-w64-mingw32"                  CACHE STRING    "")
#     set(MINGW_CHOST             "${MSYSTEM_CHOST}"                    CACHE STRING    "")
#     set(MINGW_PREFIX            "${MSYSTEM_PREFIX}"                   CACHE PATH      "")
#     set(MINGW_PACKAGE_PREFIX    "mingw-w64-${MSYSTEM_CARCH}"          CACHE STRING    "")
# elseif(MSYSTEM STREQUAL CLANG32)
#     set(MSYSTEM_PREFIX          "/clang32"                            CACHE PATH      "")
#     set(MSYSTEM_CARCH           "i686"                                CACHE STRING    "")
#     set(MSYSTEM_CHOST           "i686-w64-mingw32"                    CACHE STRING    "")
#     set(MINGW_CHOST             "${MSYSTEM_CHOST}"                    CACHE STRING    "")
#     set(MINGW_PREFIX            "${MSYSTEM_PREFIX}"                   CACHE PATH      "")
#     set(MINGW_PACKAGE_PREFIX    "mingw-w64-clang-${MSYSTEM_CARCH}"    CACHE STRING    "")
# elseif(MSYSTEM STREQUAL CLANG64)
#     set(MSYSTEM_PREFIX          "/clang64"                            CACHE PATH      "")
#     set(MSYSTEM_CARCH           "x86_64"                              CACHE STRING    "")
#     set(MSYSTEM_CHOST           "x86_64-w64-mingw32"                  CACHE STRING    "")
#     set(MINGW_CHOST             "${MSYSTEM_CHOST}"                    CACHE STRING    "")
#     set(MINGW_PREFIX            "${MSYSTEM_PREFIX}"                   CACHE PATH      "")
#     set(MINGW_PACKAGE_PREFIX    "mingw-w64-clang-${MSYSTEM_CARCH}"    CACHE STRING    "")
# elseif(MSYSTEM STREQUAL CLANGARM64)
#     set(MSYSTEM_PREFIX          "/clangarm64"                         CACHE PATH      "")
#     set(MSYSTEM_CARCH           "aarch64"                             CACHE STRING    "")
#     set(MSYSTEM_CHOST           "aarch64-w64-mingw32"                 CACHE STRING    "")
#     set(MINGW_CHOST             "${MSYSTEM_CHOST}"                    CACHE STRING    "")
#     set(MINGW_PREFIX            "${MSYSTEM_PREFIX}"                   CACHE PATH      "")
#     set(MINGW_PACKAGE_PREFIX    "mingw-w64-clang-${MSYSTEM_CARCH}"    CACHE STRING    "")
# elseif(MSYSTEM STREQUAL UCRT64)
#     set(MSYSTEM_PREFIX          "/ucrt64"                             CACHE PATH      "")
#     set(MSYSTEM_CARCH           "x86_64"                              CACHE STRING    "")
#     set(MSYSTEM_CHOST           "x86_64-w64-mingw32"                  CACHE STRING    "")
#     set(MINGW_CHOST             "${MSYSTEM_CHOST}"                    CACHE STRING    "")
#     set(MINGW_PREFIX            "${MSYSTEM_PREFIX}"                   CACHE PATH      "")
#     set(MINGW_PACKAGE_PREFIX    "mingw-w64-ucrt-${MSYSTEM_CARCH}"     CACHE STRING    "")
# else()
#     execute_process(
#         COMMAND /usr/bin/uname -m
#         WORKING_DIRECTORY "."
#         OUTPUT_VARIABLE MSYSTEM_CARCH
#     )
#     set(MSYSTEM_PREFIX          "/usr"                                CACHE PATH      "")
#     set(MSYSTEM_CARCH           "${MSYSTEM_CARCH}"                    CACHE STRING    "")
#     set(MSYSTEM_CHOST           "${MSYSTEM_CARCH}-pc-msys"            CACHE STRING    "")
#     set(MSYSTEM "MSYS")
# endif()


# # A round of custom vars...
# if(MSYSTEM STREQUAL "MSYS")
#     set(MSYSTEM_TITLE "MSYS2 MSYS")
#     set(MSYSTEM_TOOLCHAIN_VARIANT gcc)
#     set(MSYSTEM_C_LIBRARY cygwin)
#     set(MSYSTEM_CXX_LIBRARY libstdc++)
# elseif(MSYSTEM STREQUAL UCRT64)
#     set(MSYSTEM_TITLE "MinGW UCRT x64")
#     set(MSYSTEM_TOOLCHAIN_VARIANT gcc)
#     set(MSYSTEM_C_LIBRARY ucrt)
#     set(MSYSTEM_CXX_LIBRARY libstdc++)
# elseif(MSYSTEM STREQUAL CLANG64)
#     set(MSYSTEM_TITLE "MinGW Clang x64")
#     set(MSYSTEM_TOOLCHAIN_VARIANT llvm)
#     set(MSYSTEM_C_LIBRARY ucrt)
#     set(MSYSTEM_CXX_LIBRARY libc++)
# elseif(MSYSTEM STREQUAL CLANGARM64)
#     set(MSYSTEM_TITLE "MinGW Clang ARM64")
#     set(MSYSTEM_TOOLCHAIN_VARIANT llvm)
#     set(MSYSTEM_C_LIBRARY ucrt)
#     set(MSYSTEM_CXX_LIBRARY libc++)
# elseif(MSYSTEM STREQUAL CLANG32)
#     set(MSYSTEM_TITLE "MinGW Clang x32")
#     set(MSYSTEM_TOOLCHAIN_VARIANT llvm)
#     set(MSYSTEM_C_LIBRARY ucrt)
#     set(MSYSTEM_CXX_LIBRARY libc++)
# elseif(MSYSTEM STREQUAL MINGW64)
#     set(MSYSTEM_TITLE "MinGW x64")
#     set(MSYSTEM_TOOLCHAIN_VARIANT gcc)
#     set(MSYSTEM_C_LIBRARY msvcrt)
#     set(MSYSTEM_CXX_LIBRARY libstdc++)
# elseif(MSYSTEM STREQUAL MINGW32)
#     set(MSYSTEM_TITLE "MinGW x32")
#     set(MSYSTEM_TOOLCHAIN_VARIANT gcc)
#     set(MSYSTEM_C_LIBRARY msvcrt)
#     set(MSYSTEM_CXX_LIBRARY libstdc++)
# endif()

# # Pass vars to CMake vars...
# set(CMAKE_CPP_FLAGS_INIT "${CPPFLAGS}" CACHE STRING "Value used to initialize the ``CMAKE_<LANG>_FLAGS`` cache entry the first time a build tree is configured for language ``<LANG>``." FORCE)

# set(CMAKE_C_FLAGS_INIT "${CFLAGS}" CACHE STRING "Value used to initialize the ``CMAKE_<LANG>_FLAGS`` cache entry the first time a build tree is configured for language ``<LANG>``." FORCE)
# set(CMAKE_C_FLAGS_DEBUG_INIT "${CFLAGS_DEBUG}" CACHE STRING "Value used to initialize the ``CMAKE_<LANG>_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured for language ``<LANG>``." FORCE)
# set(CMAKE_C_FLAGS_MINSIZEREL_INIT "${CFLAGS_MINSIZEREL}" CACHE STRING "Value used to initialize the ``CMAKE_<LANG>_FLAGS`` cache entry the first time a build tree is configured for language ``<LANG>``." FORCE)
# set(CMAKE_C_FLAGS_RELEASE_INIT "${CFLAGS_RELEASE}" CACHE STRING "Value used to initialize the ``CMAKE_<LANG>_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured for language ``<LANG>``." FORCE)
# set(CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "${CFLAGS_RELWITHDEBINFO}" CACHE STRING "Value used to initialize the ``CMAKE_<LANG>_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured for language ``<LANG>``." FORCE)

# set(CMAKE_CXX_FLAGS_INIT "${CXXFLAGS}" CACHE STRING "Value used to initialize the ``CMAKE_<LANG>_FLAGS`` cache entry the first time a build tree is configured for language ``<LANG>``." FORCE)
# set(CMAKE_CXX_FLAGS_DEBUG_INIT "${CXXFLAGS_DEBUG}" CACHE STRING "Value used to initialize the ``CMAKE_<LANG>_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured for language ``<LANG>``." FORCE)
# set(CMAKE_CXX_FLAGS_MINSIZEREL_INIT "${CXXFLAGS_MINSIZEREL}" CACHE STRING "Value used to initialize the ``CMAKE_<LANG>_FLAGS`` cache entry the first time a build tree is configured for language ``<LANG>``." FORCE)
# set(CMAKE_CXX_FLAGS_RELEASE_INIT "${CXXFLAGS_RELEASE}" CACHE STRING "Value used to initialize the ``CMAKE_<LANG>_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured for language ``<LANG>``." FORCE)
# set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "${CXXFLAGS_RELWITHDEBINFO}" CACHE STRING "Value used to initialize the ``CMAKE_<LANG>_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured for language ``<LANG>``." FORCE)

# set(CMAKE_RC_FLAGS_INIT "${RCFLAGS}" CACHE STRING "Value used to initialize the ``CMAKE_<LANG>_FLAGS`` cache entry the first time a build tree is configured for language ``<LANG>``." FORCE)
# set(CMAKE_RC_FLAGS_DEBUG_INIT "${RCFLAGS_DEBUG}" CACHE STRING "Value used to initialize the ``CMAKE_<LANG>_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured for language ``<LANG>``." FORCE)
# set(CMAKE_RC_FLAGS_MINSIZEREL_INIT "${RCFLAGS_MINSIZEREL}" CACHE STRING "Value used to initialize the ``CMAKE_<LANG>_FLAGS`` cache entry the first time a build tree is configured for language ``<LANG>``." FORCE)
# set(CMAKE_RC_FLAGS_RELEASE_INIT "${RCFLAGS_RELEASE}" CACHE STRING "Value used to initialize the ``CMAKE_<LANG>_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured for language ``<LANG>``." FORCE)
# set(CMAKE_RC_FLAGS_RELWITHDEBINFO_INIT "${RCFLAGS_RELWITHDEBINFO}" CACHE STRING "Value used to initialize the ``CMAKE_<LANG>_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured for language ``<LANG>``." FORCE)

# set(CMAKE_C_COMPILER "${CC}" CACHE FILEPATH "The full path to the compiler for ``LANG``." FORCE)
# set(CMAKE_CXX_COMPILER "${CXX}" CACHE FILEPATH "The full path to the compiler for ``LANG``." FORCE)


# set(CMAKE_LINK_LIBRARY_FLAG)
# set(CMAKE_CXX_LINKER_WRAPPER_FLAG)
# set(CMAKE_CXX_LINKER_WRAPPER_FLAG_SEP)

# set(CMAKE_EXE_LINKER_FLAGS_INIT "${STRIP_BINARIES}" CACHE STRING "Value used to initialize the ``CMAKE_EXE_LINKER_FLAGS`` cache entry the first time a build tree is configured." FORCE)
# set(CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT "" CACHE STRING "Value used to initialize the ``CMAKE_EXE_LINKER_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured." FORCE)
# set(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL_INIT "" CACHE STRING "Value used to initialize the ``CMAKE_EXE_LINKER_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured." FORCE)
# set(CMAKE_EXE_LINKER_FLAGS_RELEASE_INIT "" CACHE STRING "Value used to initialize the ``CMAKE_EXE_LINKER_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured." FORCE)
# set(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO_INIT "" CACHE STRING "Value used to initialize the ``CMAKE_EXE_LINKER_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured." FORCE)

# set(CMAKE_STATIC_LINKER_FLAGS_INIT "${STRIP_STATIC}" CACHE STRING "Value used to initialize the ``CMAKE_STATIC_LINKER_FLAGS`` cache entry the first time a build tree is configured." FORCE)
# set(CMAKE_STATIC_LINKER_FLAGS_DEBUG_INIT "" CACHE STRING "Value used to initialize the ``CMAKE_STATIC_LINKER_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured." FORCE)
# set(CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL_INIT "" CACHE STRING "Value used to initialize the ``CMAKE_STATIC_LINKER_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured." FORCE)
# set(CMAKE_STATIC_LINKER_FLAGS_RELEASE_INIT "" CACHE STRING "Value used to initialize the ``CMAKE_STATIC_LINKER_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured." FORCE)
# set(CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO_INIT "" CACHE STRING "Value used to initialize the ``CMAKE_STATIC_LINKER_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured." FORCE)

# set(CMAKE_SHARED_LINKER_FLAGS_INIT "${STRIP_SHARED}" CACHE STRING "Value used to initialize the ``CMAKE_SHARED_LINKER_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured." FORCE)
# set(CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT "" CACHE STRING "Value used to initialize the ``CMAKE_SHARED_LINKER_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured." FORCE)
# set(CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL_INIT "" CACHE STRING "Value used to initialize the ``CMAKE_SHARED_LINKER_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured." FORCE)
# set(CMAKE_SHARED_LINKER_FLAGS_RELEASE_INIT "" CACHE STRING "Value used to initialize the ``CMAKE_SHARED_LINKER_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured." FORCE)
# set(CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO_INIT "" CACHE STRING "Value used to initialize the ``CMAKE_SHARED_LINKER_FLAGS_<CONFIG>`` cache entry the first time a build tree is configured." FORCE)

# # Requires C++ module support (C++20 etc)...
# set(CMAKE_MODULE_LINKER_FLAGS_INIT "" CACHE STRING "Flags to be used to create static libraries." FORCE)
