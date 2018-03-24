#!/bin/sh

cname=$1
fname="${cname}.java"

sed -i '' -e '$ d' $fname

