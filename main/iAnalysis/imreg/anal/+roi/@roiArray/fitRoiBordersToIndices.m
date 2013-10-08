%
% S PEron MAy 2010
%
% This will fit the borders of the specified ROI(s) tightly to the indices of
%  that particular ROI.
%
%  roiIndices: which ROIs to do this to
%
function obj = fitRoiBordersToIndices(obj, roiIds)
  % --- sanity/arguments
	if (nargin == 1)
    roiIds= obj.roiIds;
	end
	if (obj.imageBounds(1) == 0 | obj.imageBounds(2) == 0)
	  return;
	end

	% --- loop thru rois and apply
	for r=1:length(roiIds)
	  idx = find(obj.roiIds == roiIds(r));
	  roi = obj.rois{idx};
		oldIndices = roi.indices;
    % new corners, keep indices
		roi.corners = roi.computeBoundingPoly();

		% build filled 
		obj.fillToBorder(roiIds(r));

    % index update .. shouldn't change but you neve know
		roi.indices = intersect(roi.indices,oldIndices);
	end


