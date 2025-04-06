
declare -r script_dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
declare -r kernel_src="$script_dir/linux"
declare -r kernel_build="$script_dir/build/linux"

mkdir -p "$kernel_build"
# vscode extension make clutter the src directory
ARCH=x86_64 make -C "$kernel_src" mrproper
ARCH=x86_64 make O="$kernel_build" -C "$kernel_src" x86_64_defconfig

