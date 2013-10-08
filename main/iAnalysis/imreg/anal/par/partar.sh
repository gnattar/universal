#!/bin/sh

#	for s in /groups/magee/mageelab/GR_dm11/imreg_on_cluster_GR/anal/par/an38596*sess
for s in an*
do
  echo qsub -pe batch 1 -j y -o /dev/null -b y -cwd -V \"tar -cvf $s.tar $s\"
done 

