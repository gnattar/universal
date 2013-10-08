#!/bin/sh

# outer loop -- # of threads 
for (( i=1; $i <= 250; i++ ))
do
	wdir="/groups/svoboda/wdbp/perons/par/whisk/\*"
	echo qsub -pe batch 1 -j y -o /dev/null -b y -cwd -V \"/groups/svoboda/wdbp/perons/tree/anal/par/par_execute_cluster $wdir \> /groups/svoboda/wdbp/perons/par/logs/par_$i.log\"
	echo sleep 10
	# session loop --  OLD
#	si=1
#	for s in /groups/svoboda/wdbp/perons/par/whisk/*
#	do
#		echo qsub -pe batch 1 -j y -o /dev/null -b y -cwd -V \"/groups/svoboda/wdbp/perons/tree/anal/par/par_execute_cluster $s \> /groups/svoboda/wdbp/perons/par/logs/par_$si-$i.log\"
#		echo sleep 60

		# increment session coutn
#		si=`expr $si + 1`
#	done
done
