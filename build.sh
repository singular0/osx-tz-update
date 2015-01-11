#!/bin/sh

case $1 in
""|10.6)
	OS_VER="10.6"
	ICU="ICU-400.42"
	DAT="icudt40l.dat"
	;;
*)
	echo "Unknown OS version specified: '$1'"
	exit 1
	;;
esac

echo "Building for Mac OS X $OS_VER"

WDIR=`mktemp -d -t tzupdate`
SDIR=`pwd`

cd $WDIR

curl -O -R ftp://ftp.iana.org/tz/tzdata-latest.tar.gz
curl -O -R ftp://ftp.iana.org/tz/tzcode-latest.tar.gz
curl -O -R http://opensource.apple.com/tarballs/ICU/$ICU.tar.gz

[ -d $ICU ] && rm -rf $ICU

tar -zxvf $ICU.tar.gz
rm $ICU/icuSources/tools/tzcode/*
tar -C $ICU/icuSources/tools/tzcode/ -xzvf tzcode-latest.tar.gz
tar -C $ICU/icuSources/tools/tzcode/ -xzvf tzdata-latest.tar.gz
mv $ICU/icuSources/tools/tzcode/Makefile $ICU/icuSources/tools/tzcode/Makefile.in

TZ_VER=`awk '/^VERSION=/ { print $2 }' $ICU/icuSources/tools/tzcode/Makefile.in`

echo "Timezone info version is $TZ_VER"
echo $TZ_VER >+VERSION

cd $ICU/icuSources
./runConfigureICU MacOSX
gnumake
cd ../..

tar -czvf $SDIR/tzupdate-$OS_VER-$TZ_VER.tar.gz +VERSION tzdata-latest.tar.gz -C $ICU/icuSources/data/out/tmp $DAT

rm -rf $WDIR
