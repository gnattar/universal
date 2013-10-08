fl = dir('*vol*sess.mat');


nrois = 20000;
roi_ids = nan*zeros(nrois,1);
roi_centers = nan*zeros(nrois,2);
roi_vol = nan*zeros(nrois,2);

ri = 1;
for f=1:length(fl)
  u_idx = find(fl(f).name == '_');
	vol(f) = str2num(fl(f).name(u_idx(2)+1:u_idx(3)-1));

	load(fl(f).name) ; 
	for fi=1:s.caTSA.numFOVs
	  for r=1:length(s.caTSA.roiArray{fi}.rois)
		  cx = nanmean(s.caTSA.roiArray{fi}.rois{r}.corners(1,:));
		  cy = nanmean(s.caTSA.roiArray{fi}.rois{r}.corners(2,:));

			roi_ids(ri) = s.caTSA.roiArray{fi}.roiIds(r);
			roi_centers(ri,:) = [cx cy];
			roi_vol(ri,:) = [vol(f) fi];
			ri = ri+1;
		end
	end
end

val_idx = find(~isnan(roi_ids));
roi_ids = roi_ids(val_idx);
roi_centers = roi_centers(val_idx,:);
roi_vol = roi_vol(val_idx,:);
