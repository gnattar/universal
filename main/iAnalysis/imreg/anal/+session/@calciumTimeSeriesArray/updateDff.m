% 
% SP Feb 2011
%
% Wrapper for generateDffFromRawFluo that populates dffTimeSeriesArray.  Uses
% caTSA.dffOpts to determine how generation is done.
%
% USAGE:
%
%  caTSA.updateDff()
%
function obj = updateDff(obj)
	% first generate antiRoi as this may be used in next step
  passedTSA = session.timeSeriesArray(obj.antiRoiFluoTS, obj.trialIndices); 
  antiDffOpts = obj.dffOpts;
	antiDffOpts.actParams = []; % no activity test -- makes no sense
	tsaTmp = session.calciumTimeSeriesArray.generateDffFromRawFluo(passedTSA, antiDffOpts);
	for f=1:obj.numFOVs
		if (length(obj.antiRoiFluoTS{f}) > 0)
			obj.antiRoiDffTS{f} = [];
			obj.antiRoiDffTS{f} = tsaTmp.getTimeSeriesByIdx(f);
		end
	end

	% and now generate all
	obj.dffTimeSeriesArray = session.calciumTimeSeriesArray.generateDffFromRawFluo(obj, obj.dffOpts);
