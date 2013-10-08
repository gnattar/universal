%
% calls moveBy for roi objects matching roiIds.  Leave roiIds blank and
%  it will do all of them.
%
function obj = moveBy (obj, dx, dy, roiIds)
  % passed params
  if (nargin == 3)
	 roiIds= obj.roiIds;
	end

	% --- the meat
	for r=1:length(roiIds)
	  idx = find(obj.roiIds == roiIds(r));
	  obj.rois{idx}.moveBy(dx,dy);
	end
