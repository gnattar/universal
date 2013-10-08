#!/bin/sh

rootdir="/data/38596w/an38596/"
for f in `ls $rootdir`
do 
  target="/groups/svoboda/wdbp/reprocessed/perons/an38596/$f/"
  cmd="cp $rootdir/$f/ba*mat $target"
  `$cmd`
done
