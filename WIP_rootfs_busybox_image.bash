
declare -r script_dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
declare -r bbox_dir="$script_dir/busybox"
declare -r bbox_install_dir="$bbox_dir/_install"
declare -r bbox_img="$script_dir/busybox.cpio.gz"
declare -r bbox_mnt="$script_dir/busybox_mnt"
declare -r bbox_cpio="$script_dir/busybox.cpio.gz"

sudo umount "$bbox_mnt" || true

# empty file of size 8MB
dd if=/dev/zero of="$bbox_img" bs=4096 count=$(bc <<< '256 * 8') status=progress conv=sync
# filesystem
mkfs.ext4 -F "$bbox_img"

# mount as a loop device
sudo mount -o loop "$bbox_img" "$bbox_mnt"
sudo cp -rP "$bbox_install_dir/*" "$bbox_mnt/"
sync
sudo umount "$bbox_mnt"

# Old example:
################################################################################
##              A tiny rootfs drive from busybox                               #
################################################################################
## Uses binaries from distribution repo for convenience

#rootfs_img		=	busybox.img
#rootfs_qcow2	=	busybox.qcow2
#rootfs_mnt		=	loop_tmp

#.PHONY: rootfs
#rootfs:
#	rm -f $(rootfs_img) $(rootfs_qcow2)
#	sudo umount $(rootfs_mnt) || true
#	qemu-img create -f raw $(rootfs_img) 128M
#	sudo mkfs.ext4 -F busybox.img
#	mkdir -p $(rootfs_mnt)
#	sudo mount -o loop $(rootfs_img) $(rootfs_mnt)
#	sudo cp -rP $(b_install_dir)/* $(rootfs_mnt)/
#	\
#	sudo cp -P $(xsysroot)/lib/libc-$(glibc_ver).so $(rootfs_mnt)/lib64/
#	sudo cp -P $(xsysroot)/lib/libc.so.6 $(rootfs_mnt)/lib64/
#	\
#	sudo cp -P $(xsysroot)/lib/libm-$(glibc_ver).so $(rootfs_mnt)/lib64/
#	sudo cp -P $(xsysroot)/lib/libm.so.6 $(rootfs_mnt)/lib64/
#	\
#	sudo cp -P $(xsysroot)/lib/librt-$(glibc_ver).so $(rootfs_mnt)/lib64/
#	sudo cp -P $(xsysroot)/lib/librt.so.1 $(rootfs_mnt)/lib64/
#	\
#	sudo cp -P $(xsysroot)/lib/libpthread-$(glibc_ver).so $(rootfs_mnt)/lib64/
#	sudo cp -P $(xsysroot)/lib/libpthread.so.0 $(rootfs_mnt)/lib64/
#	\
#	sudo cp -P $(xsysroot)/lib/ld-$(glibc_ver).so $(rootfs_mnt)/lib64/
#	sudo cp -P $(xsysroot)/lib/ld-linux-aarch64.so.1 $(rootfs_mnt)/lib64/
#	\
#	sync & sudo umount $(rootfs_mnt)
#	qemu-img convert -O qcow2 $(rootfs_img) $(rootfs_qcow2)
