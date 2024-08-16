
declare -r script_dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
declare -r kernel_src="$script_dir/linux_src"
declare -r kernel_build="$script_dir/linux_build"

ARCH=x86_64 make O="$kernel_build" -C "$kernel_src" bzImage -j$(nproc)

# Creates Module.symvers
ARCH=x86_64 make O="$kernel_build" -C "$kernel_src" modules -j$(nproc)



