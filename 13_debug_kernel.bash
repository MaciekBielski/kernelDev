
declare -r script_dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
declare -r kernel_dir="$script_dir/linux"
declare -r vmlinux_path="$kernel_dir/vmlinux"

cgdb -dgdb -- \
    -ex="target remote localhost:1234" \
    -ex="dir $kernel_dir"

# -ex="file $vmlinux_path" \

