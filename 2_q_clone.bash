
declare -r script_dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
declare -r qemu_dir="$script_dir/qemu"

test -d "$qemu_dir" || git clone --depth 1 --branch v9.0.0 https://github.com/qemu/qemu.git "$qemu_dir"

