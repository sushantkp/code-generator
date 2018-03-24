#! /bin/sh

SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/../common/common-functions.sh
. $SCRIPT_DIR/../java/common-java-functions.sh

CLASSESDIR=$(get_classes_dir)

ls $CLASSESDIR | grep class$ | \
    while read line
    do
       rm $CLASSESDIR/$line
   done
 

