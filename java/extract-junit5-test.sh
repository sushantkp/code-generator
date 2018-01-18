extract-test-class.sh $@

cname=$1                   
cfname=${cname}.java       
ctname=${cname}Test        
ctfname=${ctname}.java     

IFS=''
echo "import org.junit.jupiter.api.Test;" >> temp
cat $ctfname | \
    while read line
    do
        [[ "$(echo $line | awk '{print substr($2,1,4)}')" == 'test' ]] && \
            echo "    @Test" >> temp
        echo "$line" >> temp
    done
mv temp $ctfname
