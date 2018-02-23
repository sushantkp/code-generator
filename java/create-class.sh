#!/bin/sh
# create-class.sh Myclass MyInterface
className=$1
class_descr=$2
classTemp="/**
 *<p>$class_descr
 *
 * @author $USER
 * @version 1.0
 */
public class $className {
	
	/**
     * Default constructor
	 */
    public $className() {

    }
}"

echo "$classTemp" > "$className.java"
echo "Created class $className"

