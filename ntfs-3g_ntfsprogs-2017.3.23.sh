#!/bin/sh -e

makepack() {
	input="$1"
	[ -d "$input" ] || exit 1

	ext=".hmod"
	name="$(basename "$input" "$ext")"
	output="$(pwd)/$name$ext.tgz"

	rm -f "$output"
	(cd "$input" && tar -cz --owner=root --group=root --numeric-owner -f "$output" * && echo ok)
}

cd "$(dirname "$0")"
SRC="$(basename "$0" .sh)"
[ -f "$SRC.tgz" ] || wget "https://tuxera.com/opensource/$SRC.tgz"
rm -rf "$SRC"
tar xf "$SRC.tgz"
cd "$SRC"
./configure --prefix=/ --host=arm-linux-gnueabihf --disable-library
DESTDIR="ntfs-3g"
rm -rf "$DESTDIR"
mkdir "$DESTDIR"
make install "DESTDIR=$(pwd)/$DESTDIR"
cat NEWS README AUTHORS CREDITS COPYING > "$DESTDIR/readme.txt"
cd "$DESTDIR"
for i in $(find . -type l); do
  name0=$(readlink "$i")
  name1=$(basename "$name0")
  if [ "$name0" != "$name1" ]; then
    echo "$i -> $name1" 
    rm -f "$i"
    ln -s -T "$name1" "$i"
  fi
done
ln -s -T "ntfs-3g" "bin/mount.ntfs"
mv sbin/* "bin/"
rm -rf "lib"
rm -rf "sbin"
rm -rf "share"
find -executable -type f -print0 | xargs -0 -n1 arm-linux-gnueabihf-strip --strip-all
cd ".."
makepack "$DESTDIR"
mv -f "$DESTDIR.hmod.tgz" "../$DESTDIR-full.hmod"
cd "$DESTDIR"
mv "bin" "sbin"
mkdir "bin"
mv "sbin/ntfs-3g" "bin/"
mv sbin/mount.nt* "bin/"
rm -rf "sbin"
cd ".."
makepack "$DESTDIR"
mv -f "$DESTDIR.hmod.tgz" "../$DESTDIR.hmod"
echo "done"
