interfaceName=$1
interfaceTemp="public interface $interfaceName {
}"

echo "$interfaceTemp" > "$interfaceName.java"
echo "Created interface $interfaceName"

