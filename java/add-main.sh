SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/../common/common-functions.sh

cname=$1
fname="$cname.java"
instancename=$(lower_camel_case $cname)
methodTemplate="
    public static void main(String [] args) {
		$cname $instancename = new ${cname}();"

remove_last_line $cname
echo "$methodTemplate" >> $fname

cat $fname | grep "public void test" | awk '{print $3}' |\
while read line
do
	echo "		${instancename}.${line};" >> $fname
done
echo "	}" >> $fname

echo "}" >> $fname


