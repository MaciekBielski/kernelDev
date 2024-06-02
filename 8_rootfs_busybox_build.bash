
declare -r script_dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
declare -r bbox_dir="$script_dir/busybox"

test -d "$bbox_dir" || git clone --depth 1 --branch 1_36_1 https://git.busybox.net/busybox "$bbox_dir"

pushd "$bbox_dir"

ARCH=x86_64 make defconfig
sed -i -e 's@^.*CONFIG_STATIC[ =].*@CONFIG_STATIC=y@' .config
make -j$(nproc)

popd

