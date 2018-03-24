#! /bin/sh

SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/../common/common-functions.sh
. $SCRIPT_DIR/../java/common-java-functions.sh

LIBDIR=$(get_lib_dir)
jarpath=$1

if [ ! -d $LIBDIR ]; then
    mkdir $LIBDIR
fi

# TODO check cache

wget -q -nc --directory-prefix=$LIBDIR $jarpath

