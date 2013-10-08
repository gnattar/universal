%
% SP Mar 2011
%
% Generates a subset of this caTSA ensuring that only trials of a certain type
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
	  help ('session.calciumTimeSeriesArray.getTrialTypeRestrictedTSA');
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
  
	% ---  build returned object
  newTSA = session.calciumTimeSeriesArray();

  % basics
	newTSA.numFOVs = obj.numFOVs;
	newTSA.roiFOVidx = obj.roiFOVidx;
  newTSA.ids = obj.ids;
	newTSA.idStrs = obj.idStrs;
	newTSA.timeUnit = obj.timeUnit;

  newTSA.valueMatrix = obj.valueMatrix(:,val);
	newTSA.time = obj.time(val);
	newTSA.trialIndices = obj.trialIndices(val);

  % Ca basics
	for f=1:obj.numFOVs ; newTSA.roiArray{f} = obj.roiArray{f}.copy(); end
	newTSA.dffOpts = obj.dffOpts;
	newTSA.evdetOpts = obj.evdetOpts;

	% TS's/TS like
	for f=1:obj.numFOVs
		if (length(obj.fileFrameIdx{f}) > 0)
			newTSA.fileFrameIdx{f} = obj.fileFrameIdx{f}(:,val);
			newTSA.fileList{f} = obj.fileList{f}(unique(newTSA.fileFrameIdx{f}(1,:)));
		end
		newTSA.antiRoiFluoTS{f} = obj.antiRoiFluoTS{f}.copy();
		newTSA.antiRoiFluoTS{f}.time = 	newTSA.antiRoiFluoTS{f}.time(val);
		newTSA.antiRoiFluoTS{f}.value = 	newTSA.antiRoiFluoTS{f}.value(val);
		newTSA.antiRoiDffTS{f} = obj.antiRoiDffTS{f}.copy();
		newTSA.antiRoiDffTS{f}.time = 	newTSA.antiRoiDffTS{f}.time(val);
		newTSA.antiRoiDffTS{f}.value = 	newTSA.antiRoiDffTS{f}.value(val);
	end
  newTSA.triggerOffsetForTrialInMS = obj.triggerOffsetForTrialInMS(val);

  % TSAs
	newTSA.dffTimeSeriesArray = obj.dffTimeSeriesArray.getTrialTypeRestrictedTSA(trialIds, trialTypeMat, trialTypeRestriction);
	newTSA.caPeakTimeSeriesArray = obj.caPeakTimeSeriesArray.getTrialTypeRestrictedTSA(trialIds, trialTypeMat, trialTypeRestriction);
	newTSA.eventBasedDffTimeSeriesArray = obj.eventBasedDffTimeSeriesArray.getTrialTypeRestrictedTSA(trialIds, trialTypeMat, trialTypeRestriction);

	% caEAS
	newTSA.caPeakEventSeriesArray = obj.caPeakEventSeriesArray.getTrialTypeRestrictedESA(trialIds, trialTypeMat, trialTypeRestriction);
