#unzip -q -c commons-lang-2.4.jar META-INF/MANIFEST.MF
jar_name=$1
file_name=$2

unzip -q -c $jar_name $file_name
# -q quiet
# -c send to console
