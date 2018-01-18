ls .classes| grep class$ | \
    while read line
    do
       rm .classes/$line
   done
 

