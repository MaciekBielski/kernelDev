
declare -r script_dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
declare -r kernel_src="$script_dir/linux_src"
declare -r kernel_build="$script_dir/linux_build"

if [[ -f "$kernel_build/.config" ]]; then
    ARCH=x86_64 make O="$kernel_build" -C "$kernel_src" olddefconfig
else
    ARCH=x86_64 make O="$kernel_build" -C "$kernel_src" x86_64_defconfig
fi

# Manipulate options in a .config file from the command line.
# Usage:
# $myname options command ...
# commands:
#         --enable|-e option   Enable option
#         --disable|-d option  Disable option
#         --module|-m option   Turn option into a module
#         --set-str option string
#                              Set option to "string"
#         --set-val option value
#                              Set option to value
#         --undefine|-u option Undefine option
#         --state|-s option    Print state of option (n,y,m,undef)
#
#         --enable-after|-E beforeopt option
#                              Enable option directly after other option
#         --disable-after|-D beforeopt option
#                              Disable option directly after other option
#         --module-after|-M beforeopt option
#                              Turn option into module directly after other option
#
#         commands can be repeated multiple times
#
# options:
#         --file config-file   .config file to change (default .config)
#         --keep-case|-k       Keep next symbols' case (dont' upper-case it)

pushd "$kernel_src"
./scripts/config --file "$kernel_build/.config" --enable CONFIG_DEBUG_FS
./scripts/config --file "$kernel_build/.config" --disable CONFIG_SYSTEM_REVOCATION_LIST
./scripts/config --file "$kernel_build/.config" --set-str CONFIG_SYSTEM_TRUSTED_KEYS
popd
