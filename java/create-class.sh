# create-class.sh Myclass MyInterface
className=$1
interface=$2
[[ ! -z $interface ]] && implInterfaceTemp="implements ${interface} "
classTemp="public class $className $implInterfaceTemp{
    // Default constructor
    public $className() {

    }
}"

echo "$classTemp" > "$className.java"
echo "Created class $className"

