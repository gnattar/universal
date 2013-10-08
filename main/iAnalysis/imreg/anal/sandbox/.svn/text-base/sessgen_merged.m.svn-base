function sessgen_merged(S)
  if (nargin < 1)
		fl = dir('*sess.mat')
		for f=1:length(fl) ; load(fl(f).name) ; S{f} = s ; end
	end

	vols = 1:16;

	for v=1:length(vols)
    ns = session_merge(S, vols(v));
		ns.saveToFile();
	end
	  
