%
% SP Apr 2011
%
% This will return the Ids of the ROIs in the object calling this function
%  that differ from ROIs with same IDs in the passed object.  Will also return
%  IDs of ROIs present in this object and not other object.
%
% USAGE:
%
%   [diffRoiIds absentRoiIds] = rA.getChangedRoiIds(rB)
%
%     diffRoiIds: IDs of rois that are different from same id roi in rB OR 
%                 that are not present in rB but in calling object
%     absentRoiIds: Ids of rois that are present in rB but NOT in calling object.
%
function [diffRoiIds absentRoiIds] = getChangedRoiIds(obj, rB)
  diffRoiIds = [];
	absentRoiIds = [];

  % --- sanity check
	if (nargin < 2 || ~isobject(rB))
	  help roi.roiArray.getChangedRoiIds;
	  return;
	end

	% --- loop thru & find different rois
	diffRoiIdx = 0*obj.roiIds;
	for r=1:length(obj.roiIds)
	  roiA = obj.rois{r};
		roiB = rB.getRoiById(roiA.id);
		if (length(roiB) == 0)
		  diffRoiIdx(r) = 1;
		else % compare ...
		  if (~ roiA.isEqual(roiB)) ; diffRoiIdx(r) = 1; end
		end
	end
	diffRoiIds = obj.roiIds(find(diffRoiIdx));

	% --- find rois present in rB but not obj
	absentRoiIdx = 0*rB.roiIds;
	for r=1:length(rB.roiIds)
	  roiB = rB.rois{r};
		roiA = obj.getRoiById(roiB.id);
		if (length(roiA) == 0)
		  absentRoiIdx(r) = 1;
		end
	end
	absentRoiIds = rB.roiIds(find(absentRoiIdx));
