%
% SP FEb 2011
%
% This allows you to compute a receptive field as defined by two time series,
%  one being the response (e.g., Ca or spike rate), the other being the stimulus
%  (e.g., whisker curvature or light flash intensity).
%  
%  It operates by calling getSingleValueAroundEvents for both timeSeries objects
%  passed.
%
% USAGE:
%
%  [stimulusVec responseVec signalIdx noiseIdx evIdxVec sIdxMat sValueMat rIdxMat ...
%   rValueMat sIeIdxVec rIeIdxVec] =  
%   computeReceptiveFieldAroundEvents(stimulusTS, stimulusValueType, responseTS, ...
%      responseValueType, ies, stimulusTimeWindow, responseTimeWindow ...
%		   timeWindowUnit, allowOverlap, xes, xTimeWindow)
%
%  stimulusVec, responseVec: values, corresponding to one another, for stim &
%    response
%  signalIdx: indexing of stimulus and responseVec for elements that are not noise
%  noiseIdx: indexing for values that are within 2*1.4286 MADs of the mode of either
%    stimulus or response
%  evIdxVec: tells you which event stimulus and responseVec corresponds to -- some
%            events are not returned if, e.g., values do not exist for one of the series.
%            Indexing is in terms of ies. Works only if ies is a SINGLE eventSeries.
%  sIdxMat, rIdxMat: indices used, in terms of stimulusTS, responseTS for computing vals
%  sValueMat, rValueMat: correspoinding value matrices to Idx matrices
%  sIeIdxVec, rIeIdxVec: what events are the rows of s/r Idx/Val mat for?
%                        To restrict to good ones, intersect with evIdxVec
%
%  stimulusTS, responseTS: timeseries objects from which each is obtained.
%  stimulus/responseValueType: mean, max, min, maxabs, etc; see getSingleValueAroundEvent.
%  ies - eventSeries objects used as point of reference ("included").  Can 
%        be a cell array of event Series, though in that case evIdxVec will be 
%        bad.
%  stimulusTimeWindow - 0 is time of event ; so [-5 5] would show +/- 5 time units
%  responseTimeWindow - As with stimulusTimeWindow ; for both, this is the window used
%        to calculate the value of that timeSeries
%  timeWindowUnit - in s ; 0 is time of event ; so [-5 5] would show +/- 5 secionds 
%  allowOverlap - if 0, events are taken as they come, and all subsequent 
%                  events are not given their own row in idxMat, timeMat. 
%                  This ensures no timepoint duplication.  If 1, all events
%                  are included, and time duplication is permitted.
%  xes - if provided, you will EXCLUDe if these events occur in the exclude time 
%        window.  Can be cell array.
%  xTimeWindow - same as iTimeWindow, but now if an excluded event occurs within xTimeWindow
%                of an included event, that (included) event is dropped. Same
%                timeUnit as timeWindowUnit
%
function [stimulusVec responseVec signalIdx noiseIdx evIdxVec sIdxMat sValueMat rIdxMat rValueMat sIeIdxVec rIeIdxVec] = ...
  computeReceptiveFieldAroundEvents(stimulusTS, ...
    stimulusValueType, responseTS, responseValueType, ...
		ies, stimulusTimeWindow, responseTimeWindow,...
	  timeWindowUnit, allowOverlap, xes, xTimeWindow)

	% --- argument check
	if (nargin < 8) 
	  help session.timeSeries.computeReceptiveFieldAroundEvents;
	  return;
  end
  
  % degenerate conditions
  stimulusVec = [];
  responseVec = [];
  signalIdx = [];
  noiseIdx = [];
	evIdxVec = [];
	sIdxMat = [];
	sValueMat = [];
	rIdxMat = [];
	rValueMat = [];
  sIeIdxVec = [];
  rIeIdxVec = [];
  if (isempty(find(~isnan(stimulusTS.value)))); return ; end 
  if (isempty(find(~isnan(responseTS.value)))); return ; end 

  % optional arguments
	if (nargin < 9) ; allowOverlap = 1; end
	if (nargin < 10) ; xes = []; end
	if (nargin < 11) ; xTimeWindow = []; end

	% --- gather data
	[stimulusVec sIeIdxVec sIdxMat sValueMat] = stimulusTS.getSingleValueAroundEvents( ...
	           stimulusValueType, ies, stimulusTimeWindow, timeWindowUnit, ...
             allowOverlap, xes, xTimeWindow);
	[responseVec rIeIdxVec rIdxMat rValueMat] = responseTS.getSingleValueAroundEvents( ...
	           responseValueType, ies, responseTimeWindow, timeWindowUnit, ...
       		   allowOverlap, xes, xTimeWindow);

	% take only overlap
	overlapEvIdx = intersect(sIeIdxVec, rIeIdxVec);
	stimulusVec = stimulusVec(find(ismember(sIeIdxVec,overlapEvIdx)));
	responseVec = responseVec(find(ismember(rIeIdxVec,overlapEvIdx)));

	% prepare evIdxVex
	evIdxVec = overlapEvIdx;
	if (~iscell(ies))
	  if (ies.type == 2)
		  evIdxVec = (2*evIdxVec)-1;
		end
	else
	  disp('computeReceptiveFieldAroundEvents::evIdxVec will be wrong, since you used cell array as ies.');
	end

	% --- get stuff outside region of no signal
  baseStim = nanmedian(stimulusTS.value);
	threshStim = baseStim + 1.4826*[-2*mad(stimulusTS.value) 2*mad(stimulusTS.value)];

  baseResp = nanmedian(responseTS.value);
	threshResp = baseResp + 1.4826*[-2*mad(responseTS.value) 2*mad(responseTS.value)];

	% signal region means you are 2 MADs away from mode
	noiseStim = find(stimulusVec > threshStim(1) & stimulusVec < threshStim(2));
	noiseResp = find(responseVec > threshResp(1) & responseVec < threshResp(2));
  noiseIdx = union(noiseStim, noiseResp);
	signalIdx = setdiff(1:length(stimulusVec), noiseIdx);



