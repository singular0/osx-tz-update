#!/bin/sh

OS_VER=`sw_vers -productVersion | awk -F '.' '{ print $1 "." $2 }'`

case $OS_VER in
10.5)
	DAT="icudt36l.dat"
	;;
10.6)
	DAT="icudt40l.dat"
	;;
10.7)
	DAT="icudt46l.dat"
	;;
10.8)
	DAT="icudt49l.dat"
	;;
10.9)
	DAT="icudt51l.dat"
	;;
10.10)
	DAT="icudt53l.dat"
	;;
*)
	echo "Unsupported OS version: '$OS_VER'"
	exit 1
	;;
esac

echo "Mac OS version is '$OS_VER'"

UPD=`ls tzupdate-$OS_VER-*.tar.gz | tail -n 1`

if [ -z "$UPD" ]; then
	echo "Update files not found"
	exit 2
fi

WDIR=`mktemp -d -t tzupdate`
tar -xzvf $UPD -C $WDIR

if [ ! -e "$WDIR/$DAT" ]; then
	echo "Looks like you built for different OS version, '$DAT' is missing"
	exit 3
fi

TS=`date +%Y%m%d%H%M%S`
tar -czvf tzbackup-$TS.tar.gz -C /usr/share icu zoneinfo

ZONES="africa antarctica asia australasia backward etcetera europe factory \
northamerica pacificnew southamerica systemv"

cd $WDIR
cat +VERSION

tar -xzvf tzdata-latest.tar.gz
sudo rm -rf /usr/share/zoneinfo/*
sudo zic -p America/New_York -y yearistype.sh $ZONES

ls

sudo install -o root -g wheel -m 0444 -Sp +VERSION iso3166.tab zone.tab /usr/share/zoneinfo/
sudo install -o root -g wheel -m 0644 -Sp $DAT /usr/share/icu/

rm -rf $WDIR