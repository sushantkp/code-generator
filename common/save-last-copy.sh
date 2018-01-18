file=$1
BASEDIR=.
archive_dir=${BASEDIR}/.last/
mkdir -p $archive_dir
cp $file $archive_dir
