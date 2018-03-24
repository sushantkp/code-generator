#!/bin/sh

SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/../common/common-functions.sh
. $SCRIPT_DIR/../java/common-java-functions.sh
    
LIBDIR=$(get_lib_dir)
REPORTSDIR=$(get_reports_dir)

classes="$@"

java.sh com.puppycrawl.tools.checkstyle.Main -c ${LIBDIR}/google_checks.xml \
	-o /${REPORTSDIR}/checkstyle-report.txt $classes &&\
	 vim /${REPORTSDIR}/checkstyle-report.txt

