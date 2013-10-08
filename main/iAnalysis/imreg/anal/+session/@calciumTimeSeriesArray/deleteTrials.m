% 
% Removes datapoints for which trialIndices is trialIds.
%
% USAGE:
%  
%   caTSA.deleteTrials(trialIds, dontRedoDffEv)
%
% ARGUMENTS
%
%   trialIds: Ids of trials to remove
%   dontRedoDffEv: (optional) - if set to 1, will not runBestPracticesDffAnd..
%
% (C) Feb 2012 S Peron
%
function obj = deleteTrials(obj, trialIds, dontRedoDffEv)
  if (nargin < 2)
	  help('session.calciumTimeSeriesArray.deleteTrials');
		return;
	end
	if (nargin < 3) ; dontRedoDffEv = 0; end

  % --- first delete locally

	% determine valids		  delIdx = find(ismember(obj.trialIndices, trialIds));
  delIdx = find(ismember(obj.trialIndices, trialIds));
	keepIdx = setdiff(1:length(obj.time), delIdx); % logic needed in case trialIndices blank
	obj.valueMatrix = obj.valueMatrix(:,keepIdx);

	if (length(obj.triggerOffsetForTrialInMS) > 0) ; obj.triggerOffsetForTrialInMS = obj.triggerOffsetForTrialInMS(keepIdx); end
	for f=1:obj.numFOVs
	  if (length(obj.fileFrameIdx{f} ) > 0) ; obj.fileFrameIdx{f}= obj.fileFrameIdx{f}(:,keepIdx); end
	end

	% sub TSAs/ESAs
	if (isobject(obj.dffTimeSeriesArray)) ; obj.dffTimeSeriesArray.deleteTrials(trialIds) ; end
	if (isobject(obj.caPeakEventSeriesArray)) ; obj.caPeakEventSeriesArray.deleteTrials(trialIds); end
	if (isobject(obj.caPeakTimeSeriesArray)) ; obj.caPeakTimeSeriesArray.deleteTrials(trialIds); end
	if (isobject(obj.eventBasedDffTimeSeriesArray)) ; obj.eventBasedDffTimeSeriesArray.deleteTrials(trialIds); end
	for f=1:obj.numFOVs
		if (length(obj.antiRoiFluoTS) > 0 && isobject(obj.antiRoiFluoTS{f})) 
			obj.antiRoiFluoTS{f}.time = obj.antiRoiFluoTS{f}.time(keepIdx); 
			obj.antiRoiFluoTS{f}.value = obj.antiRoiFluoTS{f}.value(keepIdx); 
		end
		if (length(obj.antiRoiDffTS) > 0&& isobject(obj.antiRoiDffTS{f}))
			obj.antiRoiDffTS{f}.time = obj.antiRoiDffTS{f}.time(keepIdx); 
			obj.antiRoiDffTS{f}.value = obj.antiRoiDffTS{f}.value(keepIdx); 
		end
	end
  
  % set these HERE because it propagates to daughters, so above arrays
  % would have been affected
	obj.time = obj.time(keepIdx);
	obj.trialIndices = obj.trialIndices(keepIdx);

  
	% rerun dff etc.
	if (isobject(obj.dffTimeSeriesArray) & isobject(obj.caPeakEventSeriesArray))
	  if (~dontRedoDffEv) ;  obj.runBestPracticesDffAndEvdet(); end
  end

  
