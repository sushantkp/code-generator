#!/bin/sh
#
# Usage: implement-interface.sh <interface-name> <impl-class-name>
#

SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/../common/common-functions.sh
. $SCRIPT_DIR/../java/common-java-functions.sh

iname=$1
fname="$iname.java"
if [ "$#" -eq 2 ]
then
	cname=$2
else
	cname="${iname}Impl"
fi
cfname="$cname.java"

> "$cfname"
classTemp="/**
 * <p>
 */
public class $cname implements $iname {      
	/**
     * Default constructor
	 */
    public $cname() {
    	
    }"

echo "$classTemp" > "$cfname"  
echo "Created class $cname implementing interface $iname"

temp=$(create_temp_file temp)

# Add hamcrest imports
if [ ! -z $TEST_FRAMEWORK ]; then
	echo "import static org.hamcrest.MatcherAssert.assertThat;" >> $temp
	echo "import static org.hamcrest.Matchers.*;" >> $temp
fi

# Add imports from Interface
cat $fname | grep ^import | \
    while read line
    do 
        echo $line >> $temp
    done
echo >> $temp
cat $cfname >> $temp && mv $temp $cfname


# Add methods
cat $fname | grep public | grep -v interface | \
while read line
            do 
                echo >> $cfname
                echo "    @Override" >> $cfname
                echo "    ${line::${#line} - 1} {" >> $cfname
                if [ "$(echo $line | awk '{print $2}')" == 'void' ]; then
                    echo "    " >> $cfname
                else
                    echo "        return null;" >> $cfname
                fi
                echo "    }" >> $cfname
            done

    
# Add maim
echo >> $cfname
echo "    public static void main(String [] args) {" >> $cfname
instance_name=$(echo $cname | awk '{ print tolower(substr($0, 1, 1)) substr($0, 2) }')
echo "        $cname $instance_name = new ${cname}();" >> $cfname
#echo "        ${}();"        >> $cfname
cat $fname | grep public | grep -v interface | \
while read line
            do 
                mname=$(echo $line | awk '{print $3}'| sed 's/(.*//' | awk '{ print toupper(substr($0, 1, 1)) substr($0, 2) }')
                testmname="test${mname}" 
                echo "        ${instance_name}.${testmname}();"        >> $cfname
            done
echo "    }" >> $cfname


cat $fname | grep public | grep -v interface | \
while read line
            do 
                echo                                >> $cfname
                mname=$(echo $line | awk '{print $3}'| sed 's/(.*//' | awk '{ print toupper(substr($0, 1, 1)) substr($0, 2) }')
                testmname="test${mname}"
                echo "    void $testmname() {"        >> $cfname
                echo "    "                        >> $cfname
                echo "    }"                       >> $cfname
            done

echo "}" >> $cfname
clean-imports.sh $cname
