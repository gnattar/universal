function fix_double_whiskers
 fl = dir('WDBP*mat');
 parfor f=1:length(fl) 
	 fn= fl(f).name
   subfuna(fn);
 end
	
function subfuna(fname)
  load(fname) ; 	
	owrp = fileparts(wt.matFilePath);
	wt.updatePaths(owrp, [pwd filesep]);
	if (wt.consolidateDoubleWhiskers(1)) ; 
	  save(fname, 'wt');
	end
