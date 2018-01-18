cname=$1
fname="$cname.java"
methodTemplate="
    public static void main(String [] args) {

    }"
sed -i '' -e '$ d' $fname
echo "$methodTemplate" >> $fname
echo "}" >> $fname


