#!/bin/sh
#
# add-method.sh Tester createTemplate "Create template using awesome and great Foo Objects" void  public \|
#   "test1:test2" com.emed.Great java.util.Queue javax.ext.Awesome org.yahoo.Foo
# add-method.sh TestClass  findMedianSortedArrays "Find median" void private "even2:even4" int\[\]:nums1 int\[\]:nums2
# add-method.sh TestClass  findMedianSortedArrays -c "Find median" -r String -t "even2:even4" int\[\]:nums1:first int\[\]:nums2:second
#

# import common funciions
SCRIPT_DIR=$(dirname "$0")
. ${SCRIPT_DIR}/../common/common-functions.sh


# Extract optional parameters
POSITIONAL=()
while [[ $# -gt 0 ]]
do
	key="$1"

	case $key in
		-c|--comment)
		comment_descr="$2"
		shift # past argument
		shift # past value
		;;
		-r|--rtype)
		rtype="$2"
		shift # past argument
		shift # past value
		;;
		-v|--visibility)
		visibility="$2"
		shift # past argument
		shift # past value
		;;
		-t|--test)
		test_cases="$2"
		shift # past argument
		shift # past value
		;;
		--default)
		DEFAULT=YES
		shift # past argument
		;;
		*)    # unknown option
		POSITIONAL+=("$1") # save it in an array for later
		shift # past argument
		;;
	esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# Set sensible defaults
[[ -z "$rtype" ]] && rtype="void"
[[ -z "$visibility" ]] && visibility="public"

cname=$1
fname="$cname.java"
mname=$2

[[ "${mname:0:4}" == "test" ]] && isTestMethod=true
[[ -z "$test_cases" ]] && [[ "$isTestMethod" != "true" ]] && test_cases="garden"

# Javadocs for all public methods
comment="
	/**
	 * <p>$comment_descr
	 * "

attribs=${@:3}
first=true

for attrib in $attribs
do
    echo $attrib
    #echo $attrib | sed -E -e 's/([a-zA-Z_$][a-zA-Z0-9_$]*):?/\1/'
    attrib=(${attrib//:/ })
    type=$(echo ${attrib[0]} | sed -E -e  's/.*\.//')
    [[ ! -z $(echo ${attrib[0]} | grep \\.) ]] && \
        add-import.sh $cname ${attrib[0]}

    if [[ ! -z ${attrib[1]} ]]; then
        varname="${attrib[1]}"
    else
        varname=$(lower_camel_case $type)
    fi
    if [[ ! -z ${attrib[2]} ]]; then
        attr_descr="${attrib[2]}"
	fi
	comment="$comment
	 * @param $varname $type $attr_descr" 
	
	[[ $first == false ]] && method_param="${method_param}, "
    method_param="${method_param}$type ${varname}"

	[[ $first == false ]] && test_method_invoke_param="${test_method_invoke_param}, "
    test_method_invoke_param="${test_method_invoke_param}${varname}"

	# if capital chars present then type is non-primitive	
	if [[ "$type" =~ [A-Z] ]]; then  
		test_param="${test_param}$type ${varname} = null;
		"
	else
		test_param="${test_param}$type ${varname};
		"
	fi
	first=false
done
clean-imports.sh $cname

[[ "$rtype" != void ]] && comment="$comment
	 * @return $rtype"

methodTemplate="$comment
	 */
    $visibility $rtype ${mname}(${method_param}) {"

if [[ "$rtype" != void ]]; then
	if [[ "$rtype" =~ [A-Z] ]];then
		methodTemplate="$methodTemplate                                             
		$rtype result = null;"
	else 
		methodTemplate="$methodTemplate                                             
		$rtype result;"
	fi
		methodTemplate="$methodTemplate

		System.out.println(\"DEV: \" + \"${cname}.${mname} returned: \" + result);
	 	return result;"
fi	

methodTemplate="$methodTemplate
	}"

remove_last_line $cname
echo "$methodTemplate" >> $fname

class_var=$(lower_camel_case $cname)
IFS=':'        # hyphen (-) is set as delimiter
read -ra test_case_arr <<< "$test_cases"    # str is read into an array as tokens separated by IFS
for i in "${test_case_arr[@]}"; do    # access each element of array
    testname="$i"
	testTemplate="
	public void test$(capitalize $mname)_${testname}() {
		$cname $class_var = new ${cname}();
		$test_param
		"
	[[ "$rtype" != void ]] && testTemplate="${testTemplate}$rtype result = "
	testTemplate="${testTemplate}$class_var.${mname}($test_method_invoke_param);"
	testTemplate="${testTemplate}
	}"
	echo $testTemplate >> $fname
done
IFS=' '

echo "}" >> $fname


