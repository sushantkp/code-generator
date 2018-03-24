#!/bin/sh

SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/../common/common-functions.sh
. $SCRIPT_DIR/../java/common-java-functions.sh

extract-test-class.sh $@

temp=$(get_temp_file temp)

cname=$1                   
cfname=${cname}.java       
ctname=${cname}Test        
ctfname=${ctname}.java     

IFS=''
echo "import org.junit.jupiter.api.Test;" >> $temp
cat $ctfname | \
    while read line
    do
        [[ "$(echo $line | awk '{print substr($2,1,4)}')" == 'test' ]] && \
            echo "    @Test" >> $temp
        echo "$line" >> $temp
    done
mv $temp $ctfname
