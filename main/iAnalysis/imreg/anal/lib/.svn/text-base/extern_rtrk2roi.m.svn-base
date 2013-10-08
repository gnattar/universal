%
% D Huber Mar 2010
% 
% This will *load* an rtrk format file into the ROI format.
%
% loadpath - file to load
%
% roi - returned roi structure.
%
function roi=extern_rtrk2roi(loadpath)

	load(loadpath, '-mat');

	n_rois=size(annotations, 2);

	for i=1:n_rois
			roi(i).n_corners=size(annotations(i).boundary, 1);
			roi(i).corners(2,:)=round(annotations(i).boundary(:,1)');
			roi(i).corners(1,:)=round(annotations(i).boundary(:,2)');
			roi(i).color=[0 0 1];
			roi(i).indices=annotations(i).pixels;
			roi(i).groups = [];
			roi(i).raw_fluo=[]; 
	end
