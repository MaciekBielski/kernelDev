
declare -r script_dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
declare -r kernel_src="$script_dir/linux"
declare -r kernel_build="$script_dir/build/linux"

# make -C "$kernel_build" bzImage -j$(nproc)
# ARCH=x86_64 make -C "$kernel_build" vmlinux -j$(nproc)
ARCH=x86_64 make O="$kernel_build" -C "$kernel_src" vmlinux -j$(nproc)

# Optional
# ARCH=x86_64 make O="$kernel_build" -C "$kernel_src" bindeb-pkg -j$(nproc)

# Creates Module.symvers
# make -C "$kernel_build" modules -j$(nproc)



