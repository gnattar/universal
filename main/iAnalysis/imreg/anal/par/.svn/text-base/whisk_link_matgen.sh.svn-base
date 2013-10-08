#!/bin/sh

# session loop
si=1
#for s in /groups/svoboda/wdbp/reprocessed/perons/an94953/2010_04_01*
for s in /groups/svoboda/wdbp/reprocessed/perons/an148378/*
do
  # make parfile directory
  echo mkdir /groups/svoboda/wdbp/perons/par/whisk/$si

  # generate parfile
  echo /usr/local/matlab-2010a/bin/matlab -nojvm -nosplash -r \"path\(path,genpath\(\'/groups/svoboda/wdbp/perons/tree/anal/\'\)\)\;session.whiskerTrial.generateParFiles\(\'$s/*whiskers\',\'/groups/svoboda/wdbp/perons/par/whisk/$si\'\)\;exit\;\"

 	# increment session coutn
  si=`expr $si + 1`
done


