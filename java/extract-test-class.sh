#!/bin/sh

SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/../common/common-functions.sh
. $SCRIPT_DIR/../java/common-java-functions.sh

cname=$1
cfname=${cname}.java
ctname=${cname}Test
ctfname=${ctname}.java
cvarname=$(lower-camel-case.sh $cname)
ctvarname=$(lower-camel-case.sh $ctname)

create-class.sh $ctname
remove-last-line.sh $ctname
echo >> $ctfname

temp_class_file=$(get_temp_file temp_class_file)  # everything before main
temp_main=$(get_temp_file temp_main)
temp_after_main=$(get_temp_file temp_after_main)
temp_test_file_import=$(get_temp_file temp_test_file_import)

in_main_body=false
end_main=false
IFS=''
cat $cfname | \
    while read line
    do
        if [ $end_main == true ]; then 
            echo "$line" >> $temp_after_main
        fi

		if [ $end_main == false -a $in_main_body == true ]; then
			echo $line | sed -E -e "s/${cname}/${ctname}/g" -e "s/$cvarname/$ctvarname/g" >> $temp_main
		fi
        if [ "$(echo $line | awk '{print substr($4, 1, 4)}')" == "main" ]; then
            in_main_body=true
			echo $line >> $temp_main
        fi
        if [ $in_main_body == true -a "$(echo $line | awk '{print $1}')" == '}' -a $end_main == false ]; then
            end_main=true
        fi
        if [ $in_main_body == false ]; then
            # Filter out hamcrest from Impl class
            [[ -z "$(echo $line | grep hamcrest)" ]] && echo "$line" >> $temp_class_file
            # Get all the imports for the Test class
            [[ ! -z "$(echo $line | grep import)" ]] && echo "$line" >> $temp_test_file_import
        fi
    done
echo "}" >> $temp_class_file

save-last-copy.sh $cfname
mv $temp_class_file $cfname 

save-last-copy.sh $ctfname
echo >> $temp_test_file_import
temp=$(get_temp_file temp_test_file)
cat $temp_test_file_import | cat - $ctfname | cat - $temp_main | cat - $temp_after_main > $temp && mv $temp $ctfname && rm $temp_test_file_import && rm $temp_after_main && rm $temp_main
#cat $temp_after_main >> $ctfname && rm $temp_after_main
clean-imports.sh $ctname
