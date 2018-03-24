#!/bin/sh
echo $1 |  awk '{ print tolower(substr($0, 1, 1)) substr($0, 2) }'
