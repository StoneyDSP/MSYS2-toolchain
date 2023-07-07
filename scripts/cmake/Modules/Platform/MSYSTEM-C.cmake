# message(WARNING "PING")
if(MSYSTEM STREQUAL "MINGW64" OR MSYSTEM STREQUAL "MINGW32")
    include(Platform/MSYSTEM-GNU-C)
elseif(MSYSTEM STREQUAL "CLANG64" OR MSYSTEM STREQUAL "CLANG32" OR MSYSTEM STREQUAL "CLANGARM64")
    include(Platform/MSYSTEM-CLANG-C)
elseif(MSYSTEM STREQUAL "MSYS2")
    include(Platform/MSYS-GNU-C)
endif()
