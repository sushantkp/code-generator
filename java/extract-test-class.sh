cname=$1
cfname=${cname}.java
ctname=${cname}Test
ctfname=${ctname}.java
cvarname=$(lower-camel-case.sh $cname)
ctvarname=$(lower-camel-case.sh $ctname)

create-class.sh $ctname
remove-last-line.sh $ctname
echo >> $ctfname

in_main_body=false
end_main=false
IFS=''
cat $cfname | \
    while read line
    do
        if [ $end_main == true ]; then 
            echo "$line" >> temp2
        fi

		if [ $end_main == false -a $in_main_body == true ]; then
			echo $line | sed -E -e "s/${cname}/${ctname}/g" -e "s/$cvarname/$ctvarname/g" >> temp-main
		fi
        if [ "$(echo $line | awk '{print substr($4, 1, 4)}')" == "main" ]; then
            in_main_body=true
			echo $line >> temp-main
        fi
        if [ $in_main_body == true -a "$(echo $line | awk '{print $1}')" == '}' -a $end_main == false ]; then
            end_main=true
        fi
        if [ $in_main_body == false ]; then
            # Filter out hamcrest from Impl class
            [[ -z "$(echo $line | grep hamcrest)" ]] && echo "$line" >> temp1
            # Get all the imports for the Test class
            [[ ! -z "$(echo $line | grep import)" ]] && echo "$line" >> temp2-import
        fi
    done
echo "}" >> temp1

save-last-copy.sh $cfname
mv temp1 $cfname 

save-last-copy.sh $ctfname
echo >> temp2-import
cat temp2-import | cat - $ctfname | cat - temp-main | cat - temp2 > temp && mv temp $ctfname && rm temp2-import && rm temp2 && rm temp-main
#cat temp2 >> $ctfname && rm temp2
clean-imports.sh $ctname
