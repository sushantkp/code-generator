#!/bin/sh

SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/../common/common-functions.sh
. $SCRIPT_DIR/../java/common-java-functions.sh

#
# Usage: find-bugs.sh A.java B.java C.java
#

srcfiles="$@"
clean-classes.sh
javac.sh $srcfiles
CLASSESDIR=$(get_classes_dir)
classes=$(ls $CLASSESDIR/*.class)
REPORTSDIR=$(get_reports_dir)
LIBDIR=$(get_lib_dir)

#
# -low 		generate low, medium and high priority bugs. default is medium and higher
# -html		xslts available  -html:fancy.xsl, -html:plain.xsl and -html:fancy-hist.xsl.
#

# Required dependency
# asm-debug-all-5.0.2.jar
# bcel-6.0-SNAPSHOT.jar
# commons-lang-2.6.jar
# dom4j-1.6.1.jar
# findbugs.jar
# jFormatString.jar
# jaxen-1.1.6.jar
# jsr305.jar
# 

# TODO add temp in file name

java.sh \
	-Xdock:name=FindBugs -Xdock:icon=$LIBDIR/buggy.icns \
	-Dapple.laf.useScreenMenuBar=true \
	-Duser.language=en \
	edu.umd.cs.findbugs.FindBugs2 \
	-html:fancy.xsl -output /${REPORTSDIR}/findbugs-report.html \
	-sourcepath . \
	-progress \
	-low \
	$classes 
open /${REPORTSDIR}/findbugs-report.html	

