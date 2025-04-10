declare -r script_dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
declare -r kernel_src="$script_dir/linux"
declare -r kernel_build="$script_dir/build/linux"

mkdir -p "$kernel_build"

if [[ ! -f "$kernel_build/.config" ]]; then
ARCH=x86_64 make O="$kernel_build" -C "$kernel_src" x86_64_defconfig
echo '[+] Configured x86_64_defconfig'
fi

ARCH=x86_64 make O="$kernel_build" -C "$kernel_src" olddefconfig

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

./scripts/config --file "$kernel_build/.config" --disable CONFIG_DEBUG_INFO_NONE
./scripts/config --file "$kernel_build/.config" --disable CONFIG_DEBUG_INFO_REDUCED
./scripts/config --file "$kernel_build/.config" --enable CONFIG_DEBUG_INFO
./scripts/config --file "$kernel_build/.config" --enable CONFIG_DEBUG_INFO_DWARF5
./scripts/config --file "$kernel_build/.config" --enable CONFIG_FRAME_POINTER
./scripts/config --file "$kernel_build/.config" --enable CONFIG_KGDB_SERIAL_CONSOLE
./scripts/config --file "$kernel_build/.config" --enable CONFIG_SERIAL_KGDB_NMI

popd

echo '[+] Configured custom flags'
