echo $1 |  awk '{ print toupper(substr($0, 1, 1)) substr($0, 2) }'
