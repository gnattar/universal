%
% SP May 2011
%
% Sets raw fluo for trial-roi combo to nan.  After doing this, you need to rerun 
%  updateDff and updateEvents.
%
% USAGE:
%
%   caTSA.blankTrials(roiId, trialIds)
%
function obj = blankTrials(obj, roiId, trialIds)
  ri = find(obj.ids == roiId);
	blankTrialIdx = [];
	for t=1:length(trialIds)
	  blankTrialIdx = union(blankTrialIdx, find(obj.trialIndices == trialIds(t)));
	end

	obj.valueMatrix(ri, blankTrialIdx) = nan;
