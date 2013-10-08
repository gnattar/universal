%
% This is a wrapper for session.timeSeries.computePeriEventAUCS that works
%  across (this) time series array.
%
% USAGE:
%
%  [aucRaw aucNic idxMat1 idxMat2] = tsa.computePeriEventAUC (params)
%
% RETURNS:
%
%   aucRaw: AUC when pooling all values ; 1 per timeSeries in this TSA
%   aucNic: AUC of nicolelis distances
%   idxMat1, idxMat2: indices used for both ; in case you want to hit this
%                     many times without the most computation-intensive step
%
% PARAMETERS: params -- structure with fields (*: required):
% 
%   es1*: eventSeries 1 ; either an eventSeries or vector of times
%   es2*: eventSeries 2
%   xes: excluded event series
%   xesTimeWindow: how much to exclude around excluded? unit timeWindowUnit.
%   timeWindow: how big of a window to take? [-2 5] means 2 timeUnits before
%               upto 5 timeUnits after ; default [-2 5]
%   timeWindowUnit: session.timeSeries.timeUnitId for window timeUnit ; default
%                   2 (seconds)
%   idxMat1, idxMat2: which indices, within timeSeries.value, to use for 
%                     the eventSeries.  If these are passed, NONE OF THE ABOVE
%                     variables need to be passed (nor do they matter).
%
function  [aucRaw aucNic idxMat1 idxMat2] = computePeriEventAUC (obj, params)
  aucRaw = nan*zeros(1,length(obj.ids));
  aucNic = nan*zeros(1,length(obj.ids));

  % --- loop
	disp('000000');
	for i=1:length(obj.ids)
	  ts = obj.getTimeSeriesById (obj.ids(i));
		params.ts = ts;
		[aucRaw(i) aucNic(i) idxMat1 idxMat2] = session.timeSeries.computePeriEventAUCS (params);
		params.idxMat1 = idxMat1;
		params.idxMat2 = idxMat2;
		disp([8 8 8 8 8 8 8 sprintf('%06d',i)]);
	end



