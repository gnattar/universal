%
% SP Feb 2011
%
% Basically calls getValuesAroundEvents, and for each matching row around an 
%  event, it will compute some statistic (mean, sd, etc.) specified by valueMode.
%  
% USAGE:
%
%	[valueVec ieIdxVec idxMat valueMat] = getSingleValueAroundEvents(valueType, ies, timeWindow, timeWindowUnit, ...
%		  allowOverlap, xes, xTimeWindow, ieIdxVec, idxMat, valueMat)
%
%  valueVec: value @ each matching time point
%  ieIdxVec: which event did you actually end up using for each time point?  this allows
%    to make sure that, e.g., sequential calls to this use the same events -- which
%    will NOT be the case if you have timeSeries that span different epochs.
%  idxMat, valueMat: if you want to do more postprocessing, this is raw values on
%   which valueType 'operates'.  That is, each row is a peri-event response.
%
%  valueType: most are self-explanatory, and take the non-nan measure of values:
%             'mean', 'meanabs', 'median' ,'max', 'min', 'maxabs', 'sum', 'sumabs', 
%             'duration', 'deltameam', 'deltameanabs', 'deltamax', 'deltamaxabs',
%             'deltasum', 'deltasumabs', 'first', 'summax', 'summaxabs',
%             'abssummaxabs'
%  
%             XXXabs uses absolute value. maxabs will compute max on absolute
%               value, but will return NEGATIVE if that has largest absolute value.
%             duration returns total length of non-nan values in units of
%               obj.timeUnit.
%             deltaXXX means that the operation is applied to the diff of the
%               value vector.
%             first takes the VERY FIRST nonnan value found
%             summax sums the maxes of contiguous subsets of the vector 
%               separated by nan values, and summaxabs takes the largest 
%               amplitude kappa for each touch (+/-), returning the mean of
%               these.  Finally, abssummaxabs takes the absolute value 
%               across touches before taking mean
%
%  ies - eventSeries objects used as point of reference ("included").  Can 
%        be a cell array of event Series.
%  iTimeWindow - 0 is time of event ; so [-5 5] would show +/- 5 time units
%  timeWindowUnit - in s ; 0 is time of event ; so [-5 5] would show +/- 5 secionds 
%
%  allowOverlap - if 0, events are taken as they come, and all subsequent 
%                  events are not given their own row in idxMat, timeMat. 
%                  This ensures no timepoint duplication.  If 1, all events
%                  are included, and time duplication is permitted.
%
%  xes - if provided, you will EXCLUDe if these events occur in the exclude time 
%        window.  Can be cell array.
%  xTimeWindow - same as iTimeWindow, but now if an excluded event occurs within xTimeWindow
%                of an included event, that (included) event is dropped. Same
%                timeUnit as timeWindowUnit
%
%  ieIdxVec,idxMat,valueMat  - IF PASSED, it will skip the call to getValuesAroundEvents 
%                    and go straigth with getSingleValuePerRowFromMatrix. Good
%                    if you have multiple value types you need from same events.
% 
function [valueVec ieIdxVec idxMat valueMat] = getSingleValueAroundEvents(obj, valueType, ies, timeWindow, timeWindowUnit, ...
		  allowOverlap, xes, xTimeWindow, ieIdxVec, idxMat, valueMat)
	valueVec = [];
	ieIdxVec = [];

	% --- argument parse
	if (nargin < 5) 
	  help session.timeSeries.getSingleValueAroundEvents;
		disp(' ');
		disp(' ');
		disp('=====================================================================================');
		disp('Must at least specify first 4 parameters.');
		return;
	end

	% defaults for unpassed arguments
	if (nargin < 6) ; allowOverlap = 1; end  
	if (nargin < 7) ; xes = []; end
	if (nargin < 8) ; xTimeWindow = []; end

	% --- get value matrices
	if (nargin >= 11 && length(ieIdxVec) > 0  && length(valueMat) > 0 && length(idxMat) > 0)
	  disp('getSingleValueAroundEvents::all params specified, so skipping getValuesAroundEvents');
  else
	  [valueMat timeMat idxMat timeVec ieIdxVec] = obj.getValuesAroundEvents(ies, timeWindow, timeWindowUnit, ...
		  allowOverlap, xes, xTimeWindow);
	end
  valueVec = obj.getSingleValuePerRowFromMatrix(valueType, valueMat);

