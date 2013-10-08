%
% S PEron MAy 2010
%
% This will erode the specified rois' indices.
%
%  numPixels: by how many pixels?
%  roiIndices: which ROIs to do this to
%
function obj = erodeRoiIndices(obj, numPixels, roiIds)
  % --- sanity/arguments
	if (nargin == 2)
    roiIds= obj.roiIds;
	end
	if (obj.imageBounds(1) == 0 | obj.imageBounds(2) == 0)
	  return;
	end

  % --- construct morphological operator
	s1 = obj.imageBounds(1)/min(obj.imageBounds);
	s2 = obj.imageBounds(2)/min(obj.imageBounds);
	cg = customdisk([2*round(numPixels*s2)+1 2*round(numPixels*s1)+1], ...
	  [round(numPixels*s2) round(numPixels*s1)], [round(numPixels*s2) round(numPixels*s1)]+1, 0);

	% --- loop thru rois and apply
  
	% for each one, erode
	base_im = zeros(obj.imageBounds(1), obj.imageBounds(2));
	for r=1:length(roiIds)
	  idx = find(obj.roiIds == roiIds(r));
	  roi = obj.rois{idx};

	  % erode it
		base_im = 0*base_im;
		base_im(roi.indices) = 1;
		f_im = imerode(base_im,cg);
		roi.indices = find(f_im == 1);

    % Don't mess with border since this is erode
	end


