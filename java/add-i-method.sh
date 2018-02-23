#!/bin/sh

#
# add-i-method.sh Tester createTemplate "Create template using awesome and great Foo Objects" void com.emed.Great java.util.Queue javax.ext.Awesome org.yahoo.Foo
#

# import common funciions
SCRIPT_DIR=$(dirname "$0")
. ${SCRIPT_DIR}/../common/common-functions.sh

mname=$2
iname=$1
fname="$iname.java"
visibility="public"
comment_descr=$3
rtype=$4
[ -z $rtype ] && rtype="void"

# Javadocs for all public methods
comment="
	/**
	 * <p>$comment_descr
	 * "

attribs=${@:5}
first=true

for attrib in $attribs
do
    echo $attrib
    #echo $attrib | sed -E -e 's/([a-zA-Z_$][a-zA-Z0-9_$]*):?/\1/'
    attrib=(${attrib//:/ })
    type=$(echo ${attrib[0]} | sed -E -e  's/.*\.//')
    [[ ! -z $(echo ${attrib[0]} | grep \\.) ]] && \
        add-import.sh $iname ${attrib[0]}

    if [[ ! -z ${attrib[1]} ]]; then
        varname="${attrib[1]}"
    else
        varname=$(lower-camel-case.sh $type)
    fi
    if [[ ! -z ${attrib[2]} ]]; then
        attr_descr="${attrib[2]}"
	fi
	comment="$comment
	 * @param $varname $type $attr_descr" 
	
	[[ $first == false ]] && method_param="${method_param}, "
    method_param="${method_param}$type ${varname}"
	first=false
done
clean-imports.sh $iname

[[ "$rtype" != void ]] && comment="$comment
	 * @return $rtype"

methodTemplate="
	$comment
	*/
    $visibility $rtype ${mname}(${method_param});"

remove_last_line $iname
echo "$methodTemplate" >> $fname
echo "}" >> $fname


