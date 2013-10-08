%
% D Huber Mar 2010
%
% This will save an ROI structure specified by roi to an ephus-compatible
%  format.
%
% roi: the structure
% savepath: FULL path of where to save
%

function extern_roi2rtrk(roi, savepath)

	% grab aspect ratio OF IMAGE
	global glovars;
  im_size = size(glovars.fluo_display.display_im);
	aspectRatio=[im_size(1) im_size(2)]; %we coudl add this a option

	version=0.25; %this is fix


	for i=1:length(roi)
    annotations(i).pixels=roi(i).indices;
    annotations(i).boundary(:,1)=roi(i).corners(2,:)';
    annotations(i).boundary(:,2)=roi(i).corners(1,:)';
    annotations(i).guid=0.123+i; %make up an ID
	end

	save(savepath, 'annotations', 'version', 'aspectRatio');
	disp(['extern_roi2rtrk::saved... ' savepath]);
