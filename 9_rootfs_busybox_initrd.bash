
declare -r script_dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
declare -r bbox_dir="$script_dir/busybox"
declare -r bbox_install_dir="$bbox_dir/_install"
declare -r bbox_rcs_script="$bbox_install_dir/etc/init.d/rcS"
declare -r bbox_ramfs_img="$script_dir/busybox.cpio.gz"

pushd "$bbox_dir"
rm -rf "$bbox_install_dir"
make install
popd

rm -f "$bbox_ramfs_img"

pushd "$bbox_install_dir"

mkdir -p etc/init.d
mkdir -p dev proc sys shared
cp "$script_dir/update_modules_database.sh" bin/update_modules_database
chmod a+x bin/update_modules_database

cat <<HEREDOC > "$bbox_rcs_script"
#! /bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
mount -t 9p -o trans=virtio,version=9p2000.L,rw hostshare /shared
mkdir -p /lib/modules/\$(uname -r)

while true
do
    echo "[!] Startig getty on ttyS1"
    /sbin/getty -L -n -l /bin/sh ttyS1 38400 linux
    echo "[!] Getty on ttyS1 exited"
    sleep 1
done
HEREDOC
chmod +x "$bbox_rcs_script"
find . | cpio -o --format=newc | gzip -c > "$bbox_ramfs_img"

popd

