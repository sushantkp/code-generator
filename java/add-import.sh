# import common funciions
SCRIPT_DIR=$(dirname "$0")
. ${SCRIPT_DIR}/../common/common-functions.sh

temp=$(get_temp_file temp)

cname=$1
fname="$cname.java"

imports=${@:2}
for import in $imports
do
	importTemplate="import $import;"
	echo "adding $importTemplate" | sed 's/.$//'
	echo $importTemplate >> $temp
	#echo $importTemplate | cat - $fname > temp && mv temp $fname
done 

cat $temp | cat - $fname | sponge $fname && rm $temp
