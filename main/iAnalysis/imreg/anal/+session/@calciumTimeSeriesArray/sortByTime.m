% 
% SP Feb 2011
%
% Sorts the class and subordinate objects (dffTimeSeriesArray, etc.) by time.
%  For many methods, this must be run so that they work right.  Reason being thta
%  if the sorted assumption can be made, many things can be MUCH faster.
%
% USAGE:
%  
%   caTSA.sortByTime()
%
function obj = sortByTime(obj)
	% make sure not subclass
	if (strcmp(class(obj),'session.calciumTimeSeriesArray'))
		% sort it (and value)
		[irr sidx] = sort(obj.time, 'ascend');
		% if lengths differ, this will break, but this means something is wrong so OK

		% vectors -- set methods assure these propagate down to sub TSAs
		obj.time = obj.time(sidx);
		if (length(obj.trialIndices) > 0) ; obj.trialIndices = obj.trialIndices(sidx); end
		if (length(obj.triggerOffsetForTrialInMS) > 0) ; obj.triggerOffsetForTrialInMS = obj.triggerOffsetForTrialInMS(sidx); end
		for f=1:obj.numFOVs
		  if (length(obj.fileFrameIdx{f}) > 0) ; obj.fileFrameIdx{f} = obj.fileFrameIdx{f}(:,sidx); end
		end

		% for valueMatrices, we have to go do subTSAs/TSs
		if (length(obj.valueMatrix) > 0)
			obj.valueMatrix = obj.valueMatrix(:,sidx); 
			if (isobject(obj.dffTimeSeriesArray)) ; obj.dffTimeSeriesArray.valueMatrix = obj.dffTimeSeriesArray.valueMatrix(:,sidx); end
			if (isobject(obj.eventBasedDffTimeSeriesArray)) ; obj.eventBasedDffTimeSeriesArray.valueMatrix = obj.eventBasedDffTimeSeriesArray.valueMatrix(:,sidx); end
			for f=1:obj.numFOVs
				if (length(obj.antiRoiFluoTS) > 0 && isobject(obj.antiRoiFluoTS{f})) ; obj.antiRoiFluoTS{f}.value = obj.antiRoiFluoTS{f}.value(sidx); end
				if (length(obj.antiRoiDffTS) > 0 && isobject(obj.antiRoiDffTS{f})) ; obj.antiRoiDffTS{f}.value = obj.antiRoiDffTS{f}.value(sidx); end
			end
		end
	end

