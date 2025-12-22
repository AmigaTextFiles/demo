#!/bin/sh

# mkipk.sh
# generates an ipkg for Virtual Kendrick

# Bill Kendrick
# bill@newbreedsoftware.com

# 2002.Jun.03 - 2002.Jun.03


VER=1.0


PACKAGE=virtual-kend
TMPDIR=tmp
CONTROL=$TMPDIR/CONTROL/control
ARCH=arm
RM=rm

echo "SETTING UP"
mkdir $TMPDIR
mkdir $TMPDIR/CONTROL


echo
echo "MAKING SURE BINARY EXISTS"
make clean
make embedded

echo 
echo "CREATING CONTROL FILE"

echo "Package: $PACKAGE" > $CONTROL
echo "Priority: optional" >> $CONTROL
echo "Version: $VER" >> $CONTROL
echo "Section: games" >> $CONTROL
echo "Architecture: $ARCH" >> $CONTROL
echo "Maintainer: Bill Kendrick (bill@newbreedsoftware.com)" >> $CONTROL
echo "Description: Virtual Bill Kendrick" >> $CONTROL

echo
echo "COPYING DATA FILES"

mkdir -p $TMPDIR/opt/QtPalmtop/share/virtual-kend
cp -R data/* $TMPDIR/opt/QtPalmtop/share/virtual-kend

echo
echo "CREATING BINARIES"

mkdir -p $TMPDIR/opt/QtPalmtop/bin/
echo "virtual-kend" > $TMPDIR/opt/QtPalmtop/bin/virtual-kend.sh
cp virtual-kend $TMPDIR/opt/QtPalmtop/bin/


echo "CREATING ICON AND DESKTOP FILE"

mkdir -p $TMPDIR/opt/QtPalmtop/pics/
cp data/images/icon.png $TMPDIR/opt/QtPalmtop/pics/virtual-kend.png

mkdir -p $TMPDIR/opt/QtPalmtop/apps/Games/
DESKTOP=$TMPDIR/opt/QtPalmtop/apps/Games/virtual-kend.desktop
echo "[Desktop Entry]" > $DESKTOP
echo "Comment=Virtual Bill Kendrick" >> $DESKTOP
echo "Exec=virtual-kend.sh" >> $DESKTOP
echo "Icon=virtual-kend" >> $DESKTOP
echo "Type=Application" >> $DESKTOP
echo "Name=Virtual Kendrick" >> $DESKTOP


echo
echo "CREATING IPK..."

ipkg-build $TMPDIR

echo
echo "CLEANING UP"

$RM -r $TMPDIR

echo

