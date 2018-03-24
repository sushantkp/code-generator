#!/bin/sh

interfaceName=$1
interface_descr=$2
interfaceTemp="/**
 * <p>$interface_descr
 */
public interface $interfaceName {
}"

echo "$interfaceTemp" > "$interfaceName.java"
echo "Created interface $interfaceName"

