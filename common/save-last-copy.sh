#!/bin/sh

BaseDir=$(dirname $0)
# import common functions
. $BaseDir/../common/common-functions.sh

file=$1
archive_dir=$(get_last_dir)
cp $file ${archive_dir}/${file}.backup
