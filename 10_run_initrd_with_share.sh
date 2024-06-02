
declare -r script_dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
declare -r qemu_dir="$script_dir/qemu"
declare -r qemu_exe="$qemu_dir/build/qemu-system-x86_64"
declare -r k_image="$script_dir/linux/arch/x86/boot/bzImage"
declare -r k_args="earlyprintk console=ttyS0 root=/dev/vda rw loglevel=8 rdinit=/sbin/init"
declare -r bbox_ramfs_img="$script_dir/busybox.cpio.gz"
declare -r shared_dir="$script_dir/shared"

mkdir -p "$shared_dir"

"$qemu_exe" \
    -machine q35 \
    -accel tcg,thread=multi \
    -smp 4 \
    -m 512 \
    -kernel "$k_image" \
    -append "$k_args" \
    -initrd "$bbox_ramfs_img" \
    -fsdev local,id=fsdev1,path="$shared_dir",security_model=none \
    -device virtio-9p-pci,id=fs1,fsdev=fsdev1,mount_tag=hostshare \
    -nographic

