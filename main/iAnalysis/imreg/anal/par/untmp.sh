#!/bin/sh

for i in `ls *.tmp`
do
  new_name=`echo $i|sed -e "s/\.tmp//g"`
  mv $i $new_name
done


