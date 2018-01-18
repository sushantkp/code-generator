srcfiles="$@"
#JACOCO_PROP_FILE=jacoco-agent.properties // use default property instead

clean-classes.sh
javac.sh $srcfiles

# check and get required jar files 
# get latest zip from here 
# https://oss.sonatype.org/content/repositories/snapshots/org/jacoco/jacoco/0.7.10-SNAPSHOT/jacoco-0.7.10-20171117.002725-75.zip
[[ ! -f .lib/jacocoagent.jar ]] && \
    echo "missing jar jacocoagent.jar" # add-jar.sh 
[[ ! -f .lib/jacococli.jar ]] && \
    echo "missing jar jacococli.jar" # add-jar.sh 

# instrument each class file passed on commandline
for var in $(ls .classes)
do
    if [ -z $(echo $var | grep -E "[a-zA-Z0-9]+Test.class") ]; then
        java.sh org.jacoco.cli.internal.Main instrument .classes/$var --dest .instrumented
    else
        # the test files also have to be instrumented
        java.sh org.jacoco.cli.internal.Main instrument .classes/$var --dest .test
    fi
done

# add property file to class path
#cp $JACOCO_PROP_FILE .instrumented

# run the test cases using instrumented files
junit5.sh .instrumented .test

# clean up instrumented class code folder
rm -rf .instrumented .test


srcclasses=$(echo $srcfiles | sed -E -e 's/([^ ]*.)(java)/\1class/g' -e 's/[^ ]+Test.class//g')
# --classfiles required for each path/file for e.g. --classfiles A.java --classfiles B.java
cfpaths=$(echo $srcclasses | sed -E -e 's/[^ ]*.class/--classfiles .classes\/& /g')
echo $cfpaths

# build report based on the generated exec file
# Pass non-instrumented classes
java.sh org.jacoco.cli.internal.Main report jacoco.exec $cfpaths --sourcefiles . --html /tmp/cocoreport #--csv report.csv 

# remove .exec files generated
rm jacoco.exec

open /tmp/cocoreport/default/index.html

