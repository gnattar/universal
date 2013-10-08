%
% SP Mar 2011
%
% Generates a subset of this ESA ensuring that only trials of a certain type
%   are kept.
%
% USAGE:
%
%   newESA = esa.getTrialTypeRestrictedESA(trialIds, trialTypeMat, trialTypeRestriction)
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
function newESA = getTrialTypeRestrictedESA(obj, trialIds, trialTypeMat, trialTypeRestriction);
  % --- argument check
	if (nargin < 4)
	  help ('session.calciumEventSeriesArray.getTrialTypeRestrictedESA');
	  disp('getTrialTypeRestrictedESA::must provide all 3 parameters.');
		return
	end

	% --- functional

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

  % loop through individual ES's and copy -> restrict
	for e=1:length(obj.esa)
	  cESA{e} = obj.esa{e}.copy();
		val = find(ismember(cESA{e}.eventTrials,valt));

		% apply restriction to ES
		if (length(cESA{e}.peakTimes) > 0) ; cESA{e}.peakTimes = cESA{e}.peakTimes(val) ; end
		if (length(cESA{e}.endTimes) > 0) ; cESA{e}.endTimes = cESA{e}.endTimes(val) ; end
		if (length(cESA{e}.decayTimeConstants) > 0) ; cESA{e}.decayTimeConstants = cESA{e}.decayTimeConstants(val) ; end
		if (length(cESA{e}.riseTimeConstants) > 0) ; cESA{e}.riseTimeConstants = cESA{e}.riseTimeConstants(val) ; end
		if (length(cESA{e}.peakValues) > 0) ; cESA{e}.peakValues = cESA{e}.peakValues(val) ; end
		if (length(cESA{e}.eventTimes) > 0) ; cESA{e}.eventTimes = cESA{e}.eventTimes(val) ; end
		if (length(cESA{e}.eventTrials) > 0) ; cESA{e}.eventTrials = cESA{e}.eventTrials(val) ; end
		if (length(cESA{e}.eventTimesRelTrialStart) > 0) ; cESA{e}.eventTimesRelTrialStart = cESA{e}.eventTimesRelTrialStart(val) ; end
	end
  
	%  build returned object
  newESA= session.eventSeriesArray(cESA, obj.trialTimes, obj.ids);


