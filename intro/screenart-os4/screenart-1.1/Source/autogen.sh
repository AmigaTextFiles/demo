#!/bin/sh
#
echo "Generating build information using aclocal, automake and autoconf"
echo "This may take a while ..."

# Regenerate configuration files
aclocal
automake --foreign --include-deps
autoconf

# Run configure for this platform
#./configure $*
echo "Now you are ready to run ./configure"
