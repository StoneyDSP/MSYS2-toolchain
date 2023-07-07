set(CMAKE_C_OUTPUT_EXTENSION .obj) # Necessary override from CMakeCInformation system module

include(Compiler/MSYSTEM-GNU)
__compiler_msystem_gnu(C)


if((NOT DEFINED CMAKE_DEPENDS_USE_COMPILER OR CMAKE_DEPENDS_USE_COMPILER) AND CMAKE_GENERATOR MATCHES "Makefiles|WMake|MINGW64MAKE" AND CMAKE_DEPFILE_FLAGS_C)
    # dependencies are computed by the compiler itself
    set(CMAKE_C_DEPFILE_FORMAT gcc)
    set(CMAKE_C_DEPENDS_USE_COMPILER TRUE)
endif()

set(CMAKE_C_COMPILE_OPTIONS_EXPLICIT_LANGUAGE -x c)

if (NOT CMAKE_C_COMPILER_VERSION VERSION_LESS 4.5)
    set(CMAKE_C90_STANDARD_COMPILE_OPTION "-std=c90")
    set(CMAKE_C90_EXTENSION_COMPILE_OPTION "-std=gnu90")
elseif (NOT CMAKE_C_COMPILER_VERSION VERSION_LESS 3.4)
    set(CMAKE_C90_STANDARD_COMPILE_OPTION "-std=c89")
    set(CMAKE_C90_EXTENSION_COMPILE_OPTION "-std=gnu89")
endif()

if (NOT CMAKE_C_COMPILER_VERSION VERSION_LESS 3.4)
    set(CMAKE_C90_STANDARD__HAS_FULL_SUPPORT ON)
    set(CMAKE_C99_STANDARD_COMPILE_OPTION "-std=c99")
    set(CMAKE_C99_EXTENSION_COMPILE_OPTION "-std=gnu99")
    set(CMAKE_C99_STANDARD__HAS_FULL_SUPPORT ON)
endif()

if (NOT CMAKE_C_COMPILER_VERSION VERSION_LESS 4.7)
    set(CMAKE_C11_STANDARD_COMPILE_OPTION "-std=c11")
    set(CMAKE_C11_EXTENSION_COMPILE_OPTION "-std=gnu11")
    set(CMAKE_C11_STANDARD__HAS_FULL_SUPPORT ON)
elseif (NOT CMAKE_C_COMPILER_VERSION VERSION_LESS 4.6)
    set(CMAKE_C11_STANDARD_COMPILE_OPTION "-std=c1x")
    set(CMAKE_C11_EXTENSION_COMPILE_OPTION "-std=gnu1x")
endif()

if(CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 8.1)
    set(CMAKE_C17_STANDARD_COMPILE_OPTION "-std=c17")
    set(CMAKE_C17_EXTENSION_COMPILE_OPTION "-std=gnu17")
endif()

if(CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 9.1)
    set(CMAKE_C23_STANDARD_COMPILE_OPTION "-std=c2x")
    set(CMAKE_C23_EXTENSION_COMPILE_OPTION "-std=gnu2x")
endif()

__compiler_check_default_language_standard(C 3.4 90 5.0 11 8.1 17)

include(Compiler/GNU-C)

#[===[
{
	"kind" : "toolchains",
	"toolchains" :
	[
        "language" : "C",
        "compiler" :
			{
				"id" : "MINGW64",
				"implicit" :
				{
					"includeDirectories" :
					[
						"C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/13.1.0/include",
						"C:/msys64/mingw64/include",
						"C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/13.1.0/include-fixed"
					],
					"linkDirectories" :
					[
						"C:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/13.1.0",
						"C:/msys64/mingw64/lib/gcc",
						"C:/msys64/mingw64/x86_64-w64-mingw32/lib",
						"C:/msys64/mingw64/lib"
					],
					"linkFrameworkDirectories" : [],
					"linkLibraries" :
					[
						"mingw32",
						"gcc",
						"moldname",
						"mingwex",
						"kernel32",
						"pthread",
						"advapi32",
						"shell32",
						"user32",
						"kernel32",
						"mingw32",
						"gcc",
						"moldname",
						"mingwex",
						"kernel32"
					]
				},
				"path" : "C:/msys64/mingw64/bin/x86_64-w64-mingw32-gcc.exe",
				"target" : "x86_64-w64-mingw32",
				"version" : ""
			},
            "sourceFileExtensions" :
			[
				"c"
			]
		}
    ]
]
]===]
