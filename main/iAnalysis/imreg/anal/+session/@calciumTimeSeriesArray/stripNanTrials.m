% 
% SP Feb 2011
%
% Removes datapoints for which trialIndices is nan.
%
% USAGE:
%  
%   caTSA.stripNanTrials()
%
function obj = stripNanTrials(obj)
	% determine valids
	val = find(~isnan(obj.trialIndices));

	% vectors -- set methods assure these propagate down to sub TSAs
	obj.time = obj.time(val);
	if (length(obj.trialIndices) > 0) ; obj.trialIndices = obj.trialIndices(val); end
	if (length(obj.triggerOffsetForTrialInMS) > 0) ; obj.triggerOffsetForTrialInMS = obj.triggerOffsetForTrialInMS(val); end
	for f=1:obj.numFOVs
	  if (length(obj.fileFrameIdx{f}) > 0) ; obj.fileFrameIdx{f} = obj.fileFrameIdx{f}(:,val); end
	end

	% for valueMatrices, we have to go do subTSAs/TSs
	if (length(obj.valueMatrix) > 0)
		obj.valueMatrix = obj.valueMatrix(:,val); 
		if (isobject(obj.dffTimeSeriesArray)) ; obj.dffTimeSeriesArray.valueMatrix = obj.dffTimeSeriesArray.valueMatrix(:,val); end
		if (isobject(obj.eventBasedDffTimeSeriesArray)) ; obj.eventBasedDffTimeSeriesArray.valueMatrix = obj.eventBasedDffTimeSeriesArray.valueMatrix(:,val); end

		for f=1:obj.numFOVs
			if (length(obj.antiRoiFluoTS) > 0 && isobject(obj.antiRoiFluoTS{f})) 
		    obj.antiRoiFluoTS{f}.value = obj.antiRoiFluoTS{f}.value(val);
			end
			if (length(obj.antiRoiDffTS) > 0&& isobject(obj.antiRoiDffTS{f}))
		    obj.antiRoiDffTS{f}.value = obj.antiRoiDffTS{f}.value(val); 
			end
		end

	end
