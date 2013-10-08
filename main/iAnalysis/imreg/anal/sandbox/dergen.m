fl = dir ('*vol*sess.mat');
for f=1:length(fl)
  load(fl(f).name);
	s.generateDerivedDataStructures();
	s.saveToFile();
end
