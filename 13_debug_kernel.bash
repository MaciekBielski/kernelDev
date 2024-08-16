
declare -r script_dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
declare -r kernel_src="$script_dir/linux_src"
declare -r kernel_build="$script_dir/linux_build"
declare -r vmlinux_path="$kernel_build/vmlinux"

cgdb -dgdb -- \
    -ex="target remote localhost:1234" \
    -ex="dir $kernel_src"

# -ex="file $vmlinux_path" \

