
declare -r script_dir=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
declare -r qemu_dir="$script_dir/qemu"
declare -r build_dir="$script_dir/qemu/build"

mkdir -p "$build_dir"
pushd "$build_dir"
"$qemu_dir/configure" \
    --target-list="x86_64-softmmu" \
    --enable-debug \
    --disable-brlapi \
    --disable-gtk \
    --disable-kvm \
    --disable-xen \
    --disable-libiscsi \
    --disable-libusb \
    --disable-numa \
    --disable-opengl \
    --disable-sdl \
    --disable-seccomp \
    --disable-spice \
    --disable-vde \
    --disable-vnc-sasl
popd
