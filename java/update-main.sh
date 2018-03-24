#!/bin/sh

SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/../common/common-functions.sh

cname=$1
cfname="$cname.java"

temp=$(get_temp_file temp)
in_main==false;

IFS=''
cat $cfname | \
    while read line
    do	
		[[ ! -z $(echo $line | grep "public static void main(") ]] && in_main=true
		[[ "$in_main" == "true" ]] && count_open_curly=$(( $count_open_curly +  $(( $(echo "$line" | awk -F '{' '{print NF -1}') - $(echo "$line" | awk -F '}' '{print NF -1}') )) ))
		[[ "$in_main" != "true" ]] && echo "$line" >> $temp
		[[ "$in_main" == "true" ]] && [[ "$count_open_curly" == "0" ]] && in_main=false
		
	done

save-last-copy.sh $cfname
mv $temp $cfname
add-main.sh $cname
