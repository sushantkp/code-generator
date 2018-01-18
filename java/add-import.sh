import=$2
cname=$1
fname="$cname.java"
importTemplate="import $import;"
echo $importTemplate | cat - $fname > temp && mv temp $fname
