classes="$@"

java.sh com.puppycrawl.tools.checkstyle.Main -c .lib/google_checks.xml \
	-o /tmp/checkstyle-report.txt $classes &&\
	 vim /tmp/checkstyle-report.txt

