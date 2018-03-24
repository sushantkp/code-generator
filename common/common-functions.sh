#! /bin/sh

function lower_camel_case() {
	echo $1 |  awk '{ print tolower(substr($0, 1, 1)) substr($0, 2) }'
}

function save_last_copy() {
	file=$1
	BASEDIR=.
	archive_dir=${BASEDIR}/.last/
	mkdir -p $archive_dir
	cp $file $archive_dir
}

function remove_last_line() {
	cname=$1
	fname="${cname}.java"

	sed -i '' -e '$ d' $fname
}

function delete_first_line() {
	sed -i.bak '1d' "$1"
}

function capitalize() {
	echo $1 |  awk '{ print toupper(substr($0, 1, 1)) substr($0, 2) }'
}

function get_temp_file() {
    BaseTemp="/Volumes/mtmpdir"
	twodirlevel=$(pwd | awk -F/ '{print $(NF-1)"/"$NF}')
    fpath=$BaseTemp/codegen/${twodirlevel}/temp
    mkdir -p $fpath
    file_suffix="$(basename $0)"
	[[ ! -z $1 ]] && file_suffix="${file_suffix}.$1"
    echo $(mktemp ${fpath}/${file_suffix}.XXXXXX)
}

function get_temp_dir() {
    BaseTemp="/Volumes/mtmpdir"
	twodirlevel=$(pwd | awk -F/ '{print $(NF-1)"/"$NF}')
    fpath=$BaseTemp/codegen/${twodirlevel}
	[[ ! -z $1 ]] && fpath="${fpath}/$1"
    mkdir -p $fpath
    echo $(mktemp -d ${fpath}/XXXXXX)
}

# store a backup of source file being updated
function get_last_dir() {
    BaseTemp="/Volumes/mtmpdir"
	twodirlevel=$(pwd | awk -F/ '{print $(NF-1)"/"$NF}')
    fpath=$BaseTemp/codegen/${twodirlevel}/last
    mkdir -p $fpath
    echo $fpath
}
