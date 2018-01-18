mname=$2
cname=$1
fname="$cname.java"
type=$4
[ -z "$type" ] && type="public"
rtype=$3
[ -z $rtype ] && rtype="void"
methodTemplate="
    $type $rtype $mname() {

    }"
sed -i '' -e '$ d' $fname
echo "$methodTemplate" >> $fname
echo "}" >> $fname


