#!/bin/sh

case $1 in
10.5)
	OS_VER="10.5"
	ICU="ICU-8.11.4"
	DAT="icudt36l.dat"
	;;
""|10.6)
	OS_VER="10.6"
	ICU="ICU-400.42"
	DAT="icudt40l.dat"
	;;
10.7)
	OS_VER="10.7"
	ICU="ICU-461.18"
	DAT="icudt46l.dat"
	;;
10.8)
	OS_VER="10.8"
	ICU="ICU-491.11.3"
	DAT="icudt49l.dat"
	;;
10.9)
	OS_VER="10.9"
	ICU="ICU-511.35"
	DAT="icudt51l.dat"
	;;
10.10)
	OS_VER="10.10"
	ICU="ICU-531.48"
	DAT="icudt53l.dat"
	;;
*)
	echo "Unsupported OS version specified: '$1'"
	exit 1
	;;
esac

echo "Building for Mac OS X $OS_VER ($ICU)"

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
