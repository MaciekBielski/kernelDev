
declare -r script_dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
declare -r kernel_src="$script_dir/linux"

test -d "$kernel_src" || git clone --depth 1 --branch v6.13.9 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git "$kernel_src"

