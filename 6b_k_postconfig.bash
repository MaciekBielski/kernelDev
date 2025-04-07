
declare -r script_dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
declare -r kernel_src="$script_dir/linux"
declare -r kernel_build="$script_dir/build/linux"

if [[ -f "$kernel_build/.config" ]]; then
# vscode extension make clutter the src directory
ARCH=x86_64 make -C "$kernel_src" mrproper
ARCH=x86_64 make O="$kernel_build" -C "$kernel_src" olddefconfig

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
./scripts/config --file "$kernel_build/.config" --set-str CONFIG_SYSTEM_TRUSTED_KEYS ""
# ./scripts/config --file "$kernel_build/.config" --set-str LOCALVERSION "my_build"
# for debugging
./scripts/config --file "$kernel_build/.config" --disable CONFIG_ARCH_HAS_STRICT_KERNEL_RWX
./scripts/config --file "$kernel_build/.config" --disable CONFIG_ARCH_HAS_STRICT_MODULE_RWX
./scripts/config --file "$kernel_build/.config" --disable CONFIG_STRICT_KERNEL_RWX
./scripts/config --file "$kernel_build/.config" --disable CONFIG_STRICT_MODULE_RWX

./scripts/config --file "$kernel_build/.config" --enable CONFIG_KGDB
./scripts/config --file "$kernel_build/.config" --enable CONFIG_KGDB_HONOUR_BLOCKLIST
./scripts/config --file "$kernel_build/.config" --enable CONFIG_KGDB_LOW_LEVEL_TRAP
./scripts/config --file "$kernel_build/.config" --disable CONFIG_KGDB_TESTS
./scripts/config --file "$kernel_build/.config" --disable CONFIG_KGDB_KDB

./scripts/config --file "$kernel_build/.config" --enable CONFIG_DEBUG_INFO
./scripts/config --file "$kernel_build/.config" --enable CONFIG_FRAME_POINTER
./scripts/config --file "$kernel_build/.config" --enable CONFIG_KGDB_SERIAL_CONSOLE
./scripts/config --file "$kernel_build/.config" --enable CONFIG_SERIAL_KGDB_NMI
popd

fi
