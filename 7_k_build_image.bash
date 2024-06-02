
declare -r script_dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
declare -r kernel_dir="$script_dir/linux"

ARCH=x86_64 make -C "$kernel_dir" bzImage -j$(nproc)

# Creates Module.symvers
ARCH=x86_64 make -C "$kernel_dir" modules -j$(nproc)



