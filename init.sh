#!/bin/bash

usage()
{
cat << EOF
usage:
    ./init.sh Core-3288J
EOF

exit 0

}

if [ $# -ne  1 ] ; then
   usage
fi

sed -i "s,Firefly-Board,$1,g" README.md
sed -i "s,Firefly-Board,$1,g" en/conf.py
sed -i "s,Firefly-Board,$1,g" zh_CN/conf.py

cp en/share/index.demo.rst en/index.rst
sed -i "s,Firefly-Board,$1,g" en/index.rst
sed -i "s,Firefly-Board,$1,g" en/share/index.demo.rst
ln -s share/markdown-cheatsheet.mdpp en/
ln -s share/mdpp-demo.mdpp en/

touch zh_CN/index.rst
