%
% S Peron 2010 Aug
%
% This function will return the indices of all pixels *not* in a ROI.
%
% PARAMS:
%
%   useBorderOrIndices: 1(default): uses border, not indices, to determine ROI
%                       2: uses ROI indices, ignoring border
%   dilateBy: (default = 2): dilate ROI indices by disk of this radius so as to
%             ensure that points that are part of a ROI are definitely not included.
%
% RETURNS:
%
%   antiRoiIdx: all pixel indices in reshaped image matrix that are in/near a ROI
%
% USAGE:
%
%   antiRoiIdx = obj.getAntiRoiIndices(useBorderOrIndices, dilateBy)
%
%
function antiRoiIdx = getAntiRoiIndices(obj, useBorderOrIndices, dilateBy)

  % --- defaults & input process
	if (nargin == 1)
	  useBorderOrIndices = 1;
		dilateBy = 2;
	elseif (nargin == 2)
	  dilateBy = 2;
	end

	% --- create the a binary matrix with 1 = ROI-occupied
	allRois = zeros(obj.imageBounds(1), obj.imageBounds(2));
	if (useBorderOrIndices == 1) % use borders
	  for r=1:length(obj.roiIds)
		  oldIndices = obj.rois{r}.indices;
			obj.fillToBorder(obj.roiIds(r));
			allRois(obj.rois{r}.indices) = 1;
			obj.rois{r}.indices = oldIndices;
		end
	else % simply use indices ...
	  for r=1:length(obj.roiIds)
			allRois(obj.rois{r}.indices) = 1;
		end
	end

	% --- dilate?
	if (dilateBy > 0)
	  % construct morphological operator
		s1 = obj.imageBounds(1)/min(obj.imageBounds);
		s2 = obj.imageBounds(2)/min(obj.imageBounds);
		cg = customdisk([2*round(dilateBy*s2)+1 2*round(dilateBy*s1)+1], ...
			[round(dilateBy*s2) round(dilateBy*s1)], [round(dilateBy*s2) round(dilateBy*s1)]+1, 0);

		% and do it
		allRois = imdilate(allRois,cg);
	end

	% --- return ...
	antiRoiIdx = find(allRois == 0);
 
