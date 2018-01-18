#
# Usage: find-bugs.sh A.java B.java C.java
#

srcfiles="$@"
clean-classes.sh
javac.sh $srcfiles
classes=$(ls .classes/*.class)

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



java.sh \
	-Xdock:name=FindBugs -Xdock:icon=.lib/buggy.icns \
	-Dapple.laf.useScreenMenuBar=true \
	-Duser.language=en \
	edu.umd.cs.findbugs.FindBugs2 \
	-html:fancy.xsl -output /tmp/findbugs-report.html \
	-sourcepath . \
	-progress \
	-low \
	$classes 
open /tmp/findbugs-report.html	

