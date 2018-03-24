#!/bin/sh

function get_class_comment () {
	echo "TODO"
}

function get_modified_class_comment () {
	echo "TODO"
}

function get_classes_dir() {
    BaseTemp="/Volumes/mtmpdir"
	twodirlevel=$(pwd | awk -F/ '{print $(NF-1)"/"$NF}')
    fpath=$BaseTemp/codegen/${twodirlevel}/classes
    mkdir -p $fpath
    echo $fpath
}

function get_lib_dir() {
    BaseTemp="/Volumes/mtmpdir"
	twodirlevel=$(pwd | awk -F/ '{print $(NF-1)"/"$NF}')
    fpath=$BaseTemp/codegen/${twodirlevel}/lib
    mkdir -p $fpath
    echo $fpath
}


function get_reports_dir() {
    BaseTemp="/Volumes/mtmpdir"
	twodirlevel=$(pwd | awk -F/ '{print $(NF-1)"/"$NF}')
    fpath=$BaseTemp/codegen/${twodirlevel}/reports
    mkdir -p $fpath
    echo $fpath
}


function get_instrumented_dir() {
    BaseTemp="/Volumes/mtmpdir"
	twodirlevel=$(pwd | awk -F/ '{print $(NF-1)"/"$NF}')
    fpath=$BaseTemp/codegen/${twodirlevel}/instrumented
    mkdir -p $fpath
    echo $fpath
}
