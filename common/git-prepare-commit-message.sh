#!/bin/bash
# import common funciions
SCRIPT_DIR=$(dirname "$0")
. ${SCRIPT_DIR}/../common/common-functions.sh
. ${SCRIPT_DIR}/../java/common-java-functions.sh

message_title=$1
temp=$(get_temp_file commit_message)

echo $message_title > $temp
echo >> $temp
echo "Add details ... " >> $temp
echo >> $temp

echo "Following files will be added:" >> $temp
git diff --name-only --cached --diff-filter=A | \
	while read line
	do
		echo "	${line}: $(get_class_comment $line)" >> $temp
	done

echo >> $temp

echo "Following files will be modified:" >> $temp
git diff --name-only --cached --diff-filter=M | \
	while read line
	do
		echo "	${line}: $(get_modified_class_comment $line)" >> $temp 
	done

cat $temp | vipe | sponge $temp
echo $temp


