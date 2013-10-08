%
% S Peron May 2010
%
% This will run getRoiFillingStatistics for specified rois, then color appropriately.
%  Red for filled, blue for not.
% 
% USAGE:
%
%  rA.colorByFilled(roiIds)
%
% PARAMS:
%
%  roiIds: the rois to color this way
%
function colorByFilled(obj, roiIds)

  % argument handling
	if (nargin == 1)
	  roiIds = [];
	end
	if (length(roiIds) == 0)
	  roiIds = obj.roiIds;
	end

	% pre-add necessary groups
	defaultRoiGroupArray = roi.roiGroupArray.generateDefaultGroupArray();
	obj.roiGroupArray.addFromOtherGroupArray(defaultRoiGroupArray);

	% calculate
	isFilled = obj.getRoiFillingStatistics(roiIds);

	% assign colors
	for r=1:length(obj.roiIds)
	  if (isFilled(r))
		  obj.rois{r}.addToGroup(8000);
		else
		  obj.rois{r}.addToGroup(8002);
		end
	end

	% plot
	obj.startGui();
	obj.colorByGroupSet(8000);
