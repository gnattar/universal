%
% plots a ROI's evolution across days
%
%  roiId: # of roi to use
%  flist: list of files, where flist(f).name is a mat file (return fomr dir/ls)
%
function plot_multiday_roi (roiId, flist)

  border = 0;
	fill = 0;

  N = length(flist); % how many total

	% row and column counters etc.
  nr = ceil(sqrt(N));
	nc = ceil(sqrt(N));
	c = 1;
	r = 1;

  % and the ploter ...
  figure('Position', [ 100 100 nc*110 nr*110])
  for f=1:length(flist);
	  load (flist(f).name);
	  im = obj.generateZoomedRoiImage(roiId, border, fill, 10);
   
		subplot('Position', [(c-(1/2))/(nc+1) (nr-r)/nr 1/(nc+2) 1/nr]);
		imshow(im);
		title(['Day ' num2str(f)]);
		c = c+1;
		if (c > nc) ; c = 1; r = r+1 ; end
	end

