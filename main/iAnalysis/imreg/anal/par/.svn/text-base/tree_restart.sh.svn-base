#~/bin/sh

cd /groups/svoboda/wdbp/perons/tree/par
qdel SPt_*
for s in jf* ; 
do 
	cd $s; 
	for ss in * ; 
		do 
		cd $ss/parfiles ; 
		echo `pwd` ; 
		~/untmp.sh ; 
		rm lock.m ; 
		cd ../.. ; 
		done ;
	cd .. ; 
done
cd  /groups/svoboda/wdbp/perons/tree/anal/par
./tree_pargen.sh > tree_startpar.sh
./tree_startpar.sh
