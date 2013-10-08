#!/bin/sh

# how many daemons 
wdir="/groups/magee/mageelab/GR_dm11/imreg_on_cluster/anal/par/\%wc\{parout_imreg_\*\}/";
for (( d=1; $d <=200 ; d++ ))
do
  echo qsub -pe batch 1 -j y -o /dev/null -b y -cwd -V \"/groups/magee/mageelab/GR_dm11/imreg_on_cluster_GR/anal/par/par_execute_cluster $wdir \> /groups/magee/mageelab/GR_dm11/imreg_on_cluster_GR/logs/imreg-$d.log\"
  echo sleep 1
done
