#!/bin/sh

BaseDir=$(dirname $0)
# import common functions
. $BaseDir/../common/common-functions.sh

cname=$1
cfname=${cname}.java


# separate out constructors, main methods, methods and test methods
# assume constructors come first and everything before will be copied as is
# 


before_constructors=true
method_type=	# constructor, mein, method, test
begin_method=false
end_method=false

temp=$(get_temp_file temp)
temp_before_constructor=$(get_temp_file temp_before_constructor)
temp_constructors=$(get_temp_file temp_constructors)
temp_main=$(get_temp_file temp_main) 
temp_tests=$(get_temp_file temp_tests)
temp_methods=$(get_temp_file temp_methods)


IFS=''
cat $cfname | \
    while read line
    do
		[[ ! -z $(echo $line | grep -e "public ${cname}(" -e "private ${cname}(") ]] && begin_method=true &&  before_constructors=false && method_type='constructor'
	
		# add ( # of open curly braces - # of closed curly braces)
		[[ $before_constructors == false ]] && count_open_curly=$(( $count_open_curly +  $(( $(echo "$line" | awk -F '{' '{print NF -1}') - $(echo "$line" | awk -F '}' '{print NF -1}') )) ))

		[[ $count_open_curly == 1 && ! -z $(echo $line | grep "public ${cname}(")  ]] && begin_method=true && method_type='constructor'
		[[ $count_open_curly == 1 && ! -z $(echo $line | grep "public void test")  ]] && begin_method=true && method_type='test'
		[[ $count_open_curly == 1 && ! -z $(echo $line | grep "public static void main(")  ]] && begin_method=true && method_type='main' 
		[[ $count_open_curly == 1 && -z $method_type ]] && begin_method=true && method_type='method'

		[[ $before_constructors == true ]] && echo "$line" >> $temp_before_constructor
		[[ $begin_method == true && $method_type == 'constructor' ]] && outfile=$(echo $temp_constructors)
		[[ $begin_method == true && $method_type == 'main' ]] && outfile=$(echo $temp_main)
		[[ $begin_method == true && $method_type == 'test' ]] && outfile=$(echo $temp_tests)
		[[ $begin_method == true && $method_type == 'method' ]] && outfile=$(echo $temp_methods)

		[[ $before_constructors == false ]] && echo "$line" >> "$temp"
		
		[[ $begin_method == true && $count_open_curly == 0 ]] && begin_method=false && method_type= >> $temp && cat $temp >> $outfile && >$temp && outfile=
	done

[ -f $temp ] && rm $temp

save-last-copy.sh $cfname
> $cfname

[ -f $temp_before_constructor ] && cat $temp_before_constructor >> $cfname && rm $temp_before_constructor
[ -f $temp_constructors ] && cat $temp_constructors >> $cfname && rm $temp_constructors
[ -f $temp_methods ] && cat $temp_methods >> $cfname && rm $temp_methods
[ -f $temp_main ] && cat $temp_main >> $cfname && rm $temp_main
[ -f $temp_tests ] && cat $temp_tests >> $cfname && rm $temp_tests
echo "}" >> $cfname

exit
