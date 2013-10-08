function cellfgen (baseDir)
	fl = dir ([baseDir filesep '*vol*sess.mat']);

	parfor f=1:length(fl)
		proc_sing(fl(f).name);
	end

function proc_sing(fname)
	load(fname);
  s.generateCellFeaturesHash();
	s.saveToFile();
