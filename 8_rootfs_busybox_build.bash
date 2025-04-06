
declare -r script_dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
declare -r bbox_src="$script_dir/busybox"
declare -r bbox_build="$script_dir/build/busybox"

test -d "$bbox_src" || git clone --depth 1 --branch 1_37_stable https://git.busybox.net/busybox "$bbox_src"

mkdir -p "$bbox_build"
ARCH=x86_64 make O="$bbox_build" -C "$bbox_src" defconfig
sed -i -e 's@^.*CONFIG_STATIC[ =].*@CONFIG_STATIC=y@' "$bbox_build/.config"
sed -i -e 's@^.*CONFIG_TC[ =].*@# CONFIG_TC is not set@' "$bbox_build/.config"
ARCH=x86_64 make -C "$bbox_build" -j$(nproc)

