#!/bin/bash


echo "* doing a 'make clean' ..."
make clean

echo "* removing Packages dirs ..."
find . -type d -name 'Packages' -print -exec rm -rf {} \;

echo "* removing .theos dirs ..."
find . -type d -name '.theos' -print -exec rm -rf {} \;

echo "* done."
