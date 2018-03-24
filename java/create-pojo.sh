#!/bin/sh

SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/../common/common-functions.sh
. $SCRIPT_DIR/../java/common-java-functions.sh

#
# usage:  create-pojo.sh Pi <options-literal> String:name int:brown java.util.Queue boolean:activate:protected
# options-literal: ie    (immutable with equals and hashcode)
#    i: immutable
#    m: mutable
#    e: equals and hashcode
#    s: static builder   

temp_attrib_def=$(get_temp_file temp_attrib_def)
temp_builder_methods=$(get_temp_file temp_builder_methods)
temp_equals_body=$(get_temp_file temp_equals_body)
temp_getter=$(get_temp_file temp_getter)
temp_imports=$(get_temp_file temp_imports)
temp_setter=$(get_temp_file temp_setter)
temp_tostring_body=$(get_temp_file temp_tostring_body)
temp_constr_body=$(get_temp_file temp_constr_body)

gen_getter() {
    attrib=$1
    type=$2
    echo 
    echo "    public $type get$(capitalize.sh $attrib)() {"
    echo "        return this.$attrib;"
    echo "    }"
}

gen_builder_methods() {
    attrib=$1
    type=$2
    echo 
    echo "        public ${cname}.Builder ${attrib}($type ${attrib}In) {"
    echo "            this.$attrib = ${attrib}In;"
    echo "            return this;"
    echo "        }"
}

gen_setter() {
    attrib=$1
    type=$2
    echo 
    echo "    public void set$(capitalize.sh $attrib)($type ${attrib}In) {"
    echo "        this.$attrib = ${attrib}In;"
    echo "    }"
}

cname=$1
cfname=${cname}.java
cnamevar=$(lower-camel-case.sh $cname)

save-last-copy.sh $cfname
> $cfname    # delete old contents

options=$2
[[ ! -z $(echo $options | grep m) ]] && immutable=false
[[ ! -z $(echo $options | grep i) ]] && immutable=true
[[ ! -z $(echo $options | grep e) ]] && generate_equals_hashcode=true
[[ ! -z $(echo $options | grep s) ]] && generate_static_builder=true

attribs=${@:3}
first=true

# Used for creating equals
[[ $generate_equals_hashcode == true ]] && echo "import java.util.Objects;" >> $temp_imports  

for attrib in $attribs
do
    echo $attrib
    #echo $attrib | sed -E -e 's/([a-zA-Z_$][a-zA-Z0-9_$]*):?/\1/'
    attrib=(${attrib//:/ })
    type=$(echo ${attrib[0]} | sed -E -e  's/.*\.//')
    [[ ! -z $(echo ${attrib[0]} | grep \\.) ]] && \
        echo "import ${attrib[0]};" >> $temp_imports

    if [[ ! -z ${attrib[1]} ]]; then
        varname="${attrib[1]}"
    else
        varname=$(lower-camel-case.sh $type)
    fi
    if [[ ! -z ${attrib[2]} ]]; then
        access="${attrib[2]}"
    else
        access="private"
    fi

    if [[ $immutable = true ]]; then
        echo "    $access final $type $varname;" >> $temp_attrib_def
    else
        echo "    $access $type $varname;" >> $temp_attrib_def
    fi
    gen_getter $varname $type >> $temp_getter
    gen_builder_methods $varname $type >> $temp_builder_methods
    [[ $immutable == false ]] && gen_setter $varname $type >> $temp_setter

    [[ $first == false ]] && constr_param="${constr_param}, "
    constr_param="${constr_param}$type ${varname}In"
    echo "        this.${varname} = ${varname}In;" >> $temp_constr_body

    if [[ $type == 'String' ]];then
        tostring_append="append(\"$varname=\\\'\").append(this.${varname}).append(\"\\\'\");"
    else
        tostring_append="append(\"$varname=\").append(this.${varname});"
    fi
    if [[ $first == false ]]; then 
        #echo "        sb.append(\", \").append(\"$varname=\").append(this.${varname});" >> $temp_tostring_body
        echo "        sb.append(\", \").$tostring_append" >> $temp_tostring_body
    else
        echo "        sb.$tostring_append" >> $temp_tostring_body
    fi

    # Generate equals body
	# Assume type starting with Capital letter is an object
	if [[ ! -z $(echo ${type} | grep "^[a-z]") ]]; then
		equals_comparison="$varname == ${cnamevar}.$varname"
	else 
		equals_comparison="Objects.equals($varname, ${cnamevar}.$varname)"
	fi
     
    if [[ $first == false ]]; then 
        echo " &&" >> $temp_equals_body
        printf "            $equals_comparison" >> $temp_equals_body
    else 
        printf "        return $equals_comparison" >> $temp_equals_body
    fi

    # generate hashcode body
    if [[ $first == false ]]; then 
        hashcode_body="${hashcode_body}, $varname"
    else
        hashcode_body="$varname"
    fi

    first=false
done

# TODO use clean-imports instead

imports=$(cat $temp_imports | grep "^import java\." | sort | uniq)
echo "$imports" >> $cfname
[[ ! -z $imports ]] && echo >> $cfname
imports=$(cat $temp_imports | grep "^import javax\." | sort | uniq)
[[ ! -z $imports ]] && echo "$imports" >> $cfname && echo >> $cfname
imports=$(cat $temp_imports | grep "^import org\." | sort | uniq)
[[ ! -z $imports ]] && echo "$imports" >> $cfname && echo >> $cfname
imports=$(cat $temp_imports | grep "^import com\." | sort | uniq)
[[ ! -z $imports ]] && echo "$imports" >> $cfname && echo >> $cfname
imports=$(cat $temp_imports | grep -v "^import java\." | grep -v "^import org" | grep -v "^import com" | sort | uniq)
[[ ! -z $imports ]] && echo "$imports" >> $cfname && echo >> $cfname

echo "public class $cname {" >> $cfname
cat $temp_attrib_def >> $cfname
echo >> $cfname
[[ "$immutable" == true ]] && echo "    public static class Builder {" >> $cfname
[[ "$immutable" == true ]] && cat $temp_attrib_def | awk '{print "        "$1" "$3" "$4}' >> $cfname
[[ "$immutable" == true ]] && echo "
        public Builder() {
        }" >> $cfname
[[ "$immutable" == true ]] && cat $temp_builder_methods >> $cfname
[[ "$immutable" == true ]] && echo "
        public $cname build() {
            return new Person(this);
		}
    }
" >> $cfname
 
if [[ "$immutable" == false ]]; then
	echo "    public $cname(${constr_param}) {" >> $cfname
	cat $temp_constr_body >> $cfname
else 
	echo "    private $cname(${cname}.Builder builder) {" >> $cfname
	cat $temp_attrib_def | awk '{print "        this."substr($4, 0, (length($4) - 1))" = builder."$4}' >> $cfname
fi
echo "    }" >> $cfname
cat $temp_getter >> $cfname
[[ "$immutable" == false ]] && cat $temp_setter >> $cfname

echo >> $cfname
echo "    @Override" >> $cfname
echo "    public String toString() {" >> $cfname
echo "        final StringBuilder sb = new StringBuilder(\"$cname{\");" >> $cfname
cat $temp_tostring_body >> $cfname
echo "        sb.append('}');" >> $cfname
echo "        return sb.toString();" >> $cfname
echo "    }" >> $cfname

if [[ $generate_equals_hashcode == true ]]; then
echo >> $cfname
echo "    @Override" >> $cfname
echo "    public boolean equals(Object o) {" >> $cfname
echo "        if (this == o) return true;" >> $cfname
echo "        if (o == null || getClass() != o.getClass()) return false;" >> $cfname
echo "        $cname $cnamevar = ($cname) o;" >> $cfname
cat $temp_equals_body >> $cfname
echo ";" >> $cfname
echo "    }" >> $cfname


echo >> $cfname
echo "    @Override" >> $cfname
echo "    public int hashCode() {" >> $cfname
echo "        return Objects.hash($hashcode_body);" >> $cfname
echo "    }" >> $cfname
fi

echo "}" >> $cfname



rm $temp_attrib_def $temp_getter $temp_constr_body $temp_tostring_body $temp_equals_body $temp_imports
[[ -f $temp_setter ]] && rm $temp_setter
[[ -f $temp_builder_methods ]] && rm $temp_builder_methods

exit 0
