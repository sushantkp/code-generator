LIBDIR=.lib
# check and get required jar files                   
[[ ! -f .lib/junit-platform-console-standalone-1.0.2.jar ]] && \                 
    add-jar.sh https://repo1.maven.org/maven2/org/junit/platform/junit-platform-console-standalone/1.0.2/junit-platform-console-standalone-1.0.2.jar    

first=true
for path in "$@"
do
    [[ $first == false ]] && printf ":" >> temp
    printf $path >> temp
    first=false
done
if [ -d $LIBDIR ]; then
    ls $LIBDIR |\
        while read line
        do
            printf ":${LIBDIR}/${line}" >> temp
        done
fi
classpath=$(cat temp)
rm temp
echo $classpath
/usr/bin/java -cp $classpath org.junit.platform.console.ConsoleLauncher \
    --cp $classpath\
    --scan-class-path
