%
% S Peron 2010 May
%
% Will color ROIs according to a specified roiGroupArray set, specified by setId.
%  setId can be numeric OR the string (setDescrStrs).
%
function obj = colorByGroupSet(obj, setId)

  % -- stirng?
	if (~ isnumeric(setId))
	  setId = find(strcmp(obj.roiGroupArray.setDescrStrs,setId));
		setId = obj.roiGroupArray.setIds(setId);
	end

  % -- check that set is valid
	groups = obj.roiGroupArray.getGroupsInSet(setId);
	R = obj.roiIds;

	% -- make sure the basal/default groups are in play
	defaultRoiGroupArray = roi.roiGroupArray.generateDefaultGroupArray();
	obj.roiGroupArray.addFromOtherGroupArray(defaultRoiGroupArray);

  % --- go and find ...
	if (length(groups) > 0)
	  for g=1:length(groups)
		  rois = obj.getRoisInGroup(groups{g}.id);
			for r=1:length(rois)
			  rois{r}.color = groups{g}.color;
        R = setdiff(R,rois{r}.id);
			end
		end
	end

	% --- blacken everyone else
	for r=1:length(R)
	  idx = find(obj.roiIds == R(r));
	  obj.rois{idx}.color = [0 0.5 1];
	end


	% --- update image
	obj.updateImage();
	


