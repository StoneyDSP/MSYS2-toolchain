# <AR>
find_program(AR
    ar
    #   ${CYGWIN_INSTALL_PATH}/bin
    ${Z_MSYS_ROOT_DIR}/usr/bin
    DOC "The full path to the <AR> archiving utility."
)
mark_as_advanced(
    AR
)
include(${CMAKE_CURRENT_LIST_DIR}/FindPackageHandleStandardArgs.cmake)
find_package_handle_standard_args(UnixCommands
    REQUIRED_VARS AR
)