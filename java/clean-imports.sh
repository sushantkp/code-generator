#!/bin/sh

SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/../common/common-functions.sh
. $SCRIPT_DIR/../java/common-java-functions.sh

cname=$1
cfname=${cname}.java

if ! grep -q 'import' "$cfname"; then
	exit 0
fi

temp_before_imports=$(get_temp_file temp_before_imports)
temp_imports=$(get_temp_file temp_imports)
temp_after_imports=$(get_temp_file temp_after_imports)

before_imports=true
begin_imports=false
end_imports=false

IFS=''
cat $cfname | \
    while read line
    do
		if [ $begin_imports == true -a  $end_imports == false -a "${line/[:space:]/ }" == "" ]; then
			continue # ignore empty lines
		fi
		if [ $end_imports == false -a "$(echo $line | awk '{print $1}')" == "import" ]; then
            begin_imports=true
		fi
        if [ $begin_imports == false ]; then 
            echo "$line" >> $temp_before_imports
        fi
	
        if [ $begin_imports == true -a "$(echo $line | awk '{print $1}')" != "import" ]; then 
			end_imports=true
		fi

		if [ $begin_imports == true -a $end_imports == false ]; then
			echo "$line" >> $temp_imports
		fi

		if [ $end_imports == true ]; then 
			echo "$line" >> $temp_after_imports
		fi
	done

save-last-copy.sh $cfname
> $cfname
[ -f $temp_before_imports ] && cat $temp_before_imports >> $cfname && rm $temp_before_imports


imports=$(cat $temp_imports | grep "^import java\." | sort | uniq)
[[ ! -z $imports ]] && echo "$imports" >> $cfname && echo >> $cfname
imports=$(cat $temp_imports | grep "^import javax\." | sort | uniq)
[[ ! -z $imports ]] && echo "$imports" >> $cfname && echo >> $cfname
imports=$(cat $temp_imports | grep "^import org\." | sort | uniq)
[[ ! -z $imports ]] && echo "$imports" >> $cfname && echo >> $cfname
imports=$(cat $temp_imports | grep "^import com\." | sort | uniq)
[[ ! -z $imports ]] && echo "$imports" >> $cfname && echo >> $cfname
imports=$(cat $temp_imports | grep -v "^import java\." | grep -v "^import org" | grep -v "^import com" | grep -v "^import javax\." | sort | uniq)
[[ ! -z $imports ]] && echo "$imports" >> $cfname && echo >> $cfname

[ -f $temp_imports ] && rm $temp_imports

[ -f $temp_after_imports ] && cat $temp_after_imports >> $cfname && rm $temp_after_imports


