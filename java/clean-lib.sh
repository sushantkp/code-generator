#! /bin/sh

SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/../common/common-functions.sh
. $SCRIPT_DIR/../java/common-java-functions.sh

LIBDIR=$(get_lib_dir)
l $LIBDIR | grep jar$ | \
    while read line
    do
       rm ${LIBDIR}/$line
   done
 

