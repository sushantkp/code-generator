LIBDIR=.lib
ls $LIBDIR | grep jar$ | \
    while read line
    do
       rm ${LIBDIR}/$line
   done
 

