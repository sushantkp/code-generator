classname=$1
jar_names=${@:2}

for jar in $jar_names
do 
	echo "$jar: " 
	list-files-in-jar.sh $jar | grep $classname
	echo
done

#unzip -q -l $jar_name 
