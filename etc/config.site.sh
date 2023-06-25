# This file is in public domain.
# Original author: Karlson2k (Evgeny Grin)
# Written for MSys2 to help running 'configure' scripts

# Defaults for MSys2/MinGW64-targeted programs

# Set proper selfname on bash and fallback to default name on other shells
test -n "${BASH_SOURCE}" 2>/dev/null && config_site_me="${BASH_SOURCE[0]##*/}" || config_site_me=config.site

# Set default 'host' to speedup configure
if test -z "$build_alias"; then
  build_alias="${MSYSTEM_CHOST}"  && \
    ${as_echo-echo} "$config_site_me:${as_lineno-$LINENO}: default build_alias set to $build_alias" >&5
fi

# Set default 'prefix'
if ( test -z "$prefix" || test "x$prefix" = "xNONE" ) && \
    ( test -z "$exec_prefix" || test "x$exec_prefix" = "xNONE" ); then
  prefix="${MSYSTEM_PREFIX}" && \
    ${as_echo-echo} "$config_site_me:${as_lineno-$LINENO}: default prefix set to $prefix" >&5
fi
