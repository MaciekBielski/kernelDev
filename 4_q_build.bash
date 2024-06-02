
declare -r script_dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
declare -r qemu_dir="$script_dir/qemu"
declare -r build_dir="$script_dir/qemu/build"

make -C "$build_dir" -j$(nproc)
