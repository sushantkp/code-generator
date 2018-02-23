#!/bin/sh

###
###    //sop foo curry|bar eco do|@@pi|bear|@@kite
###    System.out.println("        foo curry" + "bar eco do" + pi + "bear" + kite);
###

SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/../common/common-functions.sh

cfname=$1

file_updated=$(get_temp_file)
rm $file_updated

IFS=''
cat $cfname | \
    while read line
    do
        if [ ! -z "$(echo $line | grep '//sop')" ]; then
			params=$(echo $line | sed -E -e 's/^[ \t]*//' \
				-e 's/\/\/sop //' \
				-e 's/([^|]+)/"\1"/g' \
				-e 's/\|/ + /g' \
				-e 's/"@@([^"]+)"/\1/g')
            echo $line
            echo $params      
#            params=$(echo $line | sed -E -e 's/^[ \t]*//' \
#                -e 's/\/\/sop //' -e 's/([^\|]+)\|/"\1" + /g' \
#                -e 's/([^ ]+$)/"&"\);/' -e 's/"@@([^"]+)"/\1/g')
            space=$(echo $line | sed -E -e  's/(^[ \t]*)(.*)/\1/')
        	printf "${space}System.out.println(${params});" >> temp
            echo >> temp
			> $file_updated
        else
            echo "$line" >> temp
        fi
    done

[[ -f $file_updated ]] && save-last-copy.sh $cfname && mv temp $cfname
[[ -f temp ]] && rm temp
