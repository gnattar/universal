#!/bin/sh

# how many daemons per session?
for (( d=200; $d <=250 ; d++ )) 

	do
		# session loop
		si=0
#		for s in  /groups/svoboda/wdbp/tree/perons/an167951/tree_parfiles/*vol* \
		for s in  /groups/svoboda/wdbp/tree/perons/an160508/tree_parfiles/*vol* \
		          /groups/svoboda/wdbp/tree/perons/an171923/tree_parfiles/*vol* 
			do
				si=`expr $si + 1`
				wdir="$s/parfiles";

	# only do on unfinished directories
	#  nfiles=`ls $s/*/parfiles | grep mat | wc -l`
	#	if [ "$nfiles" -gt 10 ]; then
				echo qsub -pe batch 1 -j y -o /dev/null -b y -cwd -V \"/groups/svoboda/wdbp/perons/tree/anal/par/par_execute_cluster $wdir \> /groups/svoboda/wdbp/tree/logs/SPt_$si-$d.log\"
				qsub -pe batch 1 -j y -o /dev/null -b y -cwd -V "/groups/svoboda/wdbp/perons/tree/anal/par/par_execute_cluster $wdir > /groups/svoboda/wdbp/tree/logs/SPt_$si-$d.log"
				sleep 1
			done
	#	fi
	done 

