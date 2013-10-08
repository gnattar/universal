%
% SP Mar 2011
%
% Generates a subset of this TSA ensuring that only trials of a certain type
%   are kept.
%
% USAGE:
%
%   newTSA = tsa.getTrialTypeRestrictedTSA(trialIds, trialTypeMat, trialTypeRestriction)
%
% PARAMS:
%
%    trialIds: vector corresponding to trialTypeMat where trialIds(t) is represented
%              in trialTypeMat(:,t).
%    trialTypeMat: matrix where trialTypeMat(y,t) is 1 if this trial with ID
%                  trialIds(t) belongs to trial type y.
%    trialTypeRestriction: should be same size as size(trialTypeMat,1), with 1
%                          for kept types and 0 for discarded types.  For trial 
%                          types that you don't care about, but nan (match both).
%                  
function newTSA = getTrialTypeRestrictedTSA(obj, trialIds, trialTypeMat, trialTypeRestriction);
  % --- argument check
	if (nargin < 4)
	  help ('session.timeSeriesArray.getTrialTypeRestrictedTSA');
	  disp('getTrialTypeRestrictedTSA::must provide all 3 parameters.');
		return
	end

	% --- the ditty

  % match
  zeroMatch = find(trialTypeRestriction == 0);
	oneMatch = find(trialTypeRestriction == 1);

	valt = unique(trialIds);

	for i=1:length(zeroMatch)
		valt = intersect(valt, find(trialTypeMat(zeroMatch(i),:) == 0));
	end
  for i=1:length(oneMatch)
		valt = intersect(valt, find(trialTypeMat(oneMatch(i),:) == 1));
	end

  % determine where in this TSA this means we restrict
	val = find(ismember(obj.trialIndices,valt));
  
	%  build returned object
  newValueMatrix = obj.valueMatrix(:,val);
	newTime = obj.time(val);
	newTrialIndices = obj.trialIndices(val);
  newTSA= session.timeSeriesArray({}, newTrialIndices, obj.ids, obj.idStrs, newTime, ...
		  obj.timeUnit, newValueMatrix, 1);


