# # <CPP>
# find_program(CPP "cc" "c++") # NO_CACHE)
# mark_as_advanced(CPP)
# set(CPP "${CPP} -E") # CACHE STRING "The full path to the pre-processor for <CC/CXX>." FORCE)
# if(NOT DEFINED CPP_FLAGS)
#     set(CPP_FLAGS "")
#     string(APPEND CPP_FLAGS "-D__USE_MINGW_ANSI_STDIO=1 ")
# endif()
# set(CPP_FLAGS "${CPP_FLAGS}") # CACHE STRING "Flags for the 'C/C++' language pre-processor utility, for all build types." FORCE)
# set(CPP_COMMAND "${CC} ${CPP_FLAGS}") # CACHE STRING "The 'C' language pre-processor utility command." FORCE)
