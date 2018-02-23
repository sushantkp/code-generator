#!/bin/sh

cname=$1
cfname=${cname}.java

if ! grep -q 'import' "$cfname"; then
	exit 0
fi

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
            echo "$line" >> temp-before-imports
        fi
	
        if [ $begin_imports == true -a "$(echo $line | awk '{print $1}')" != "import" ]; then 
			end_imports=true
		fi

		if [ $begin_imports == true -a $end_imports == false ]; then
			echo "$line" >> temp-imports
		fi

		if [ $end_imports == true ]; then 
			echo "$line" >> temp-after-imports
		fi
	done

save-last-copy.sh $cfname
> $cfname
[ -f temp-before-imports ] && cat temp-before-imports >> $cfname && rm temp-before-imports


imports=$(cat temp-imports | grep "^import java\." | sort | uniq)
[[ ! -z $imports ]] && echo "$imports" >> $cfname && echo >> $cfname
imports=$(cat temp-imports | grep "^import javax\." | sort | uniq)
[[ ! -z $imports ]] && echo "$imports" >> $cfname && echo >> $cfname
imports=$(cat temp-imports | grep "^import org\." | sort | uniq)
[[ ! -z $imports ]] && echo "$imports" >> $cfname && echo >> $cfname
imports=$(cat temp-imports | grep "^import com\." | sort | uniq)
[[ ! -z $imports ]] && echo "$imports" >> $cfname && echo >> $cfname
imports=$(cat temp-imports | grep -v "^import java\." | grep -v "^import org" | grep -v "^import com" | grep -v "^import javax\." | sort | uniq)
[[ ! -z $imports ]] && echo "$imports" >> $cfname && echo >> $cfname

[ -f temp-imports ] && rm temp-imports

[ -f temp-after-imports ] && cat temp-after-imports >> $cfname && rm temp-after-imports


