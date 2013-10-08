fl = dir('*vol*sess.mat');

nrois = 20000;
feat_value = [];

ri = 1;
%for f=1:length(fl)
for f=4
  u_idx = find(fl(f).name == '_');
	vol(f) = str2num(fl(f).name(u_idx(2)+1:u_idx(3)-1));
	load(fl(f).name) ; 

	feat_value = [feat_value s.cellFeatures.get(feat_name)];
end
