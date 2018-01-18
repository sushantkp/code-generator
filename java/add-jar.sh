LIBDIR=.lib
jarpath=$1

if [ ! -d $LIBDIR ]; then
    mkdir $LIBDIR
fi

wget -q -nc --directory-prefix=$LIBDIR $jarpath

