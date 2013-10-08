%
% SP Feb 2011
%
% Wrapper function that lets you pass raw time, data vectors and incorporate
%  them into an existing time series array object.  Note that resample is called
%  to convert the data itno the appropriate time scale.
%
% USAGE:
%
%  obj = addRawDataToArray(obj, time, data, timeUnit, idStr, reSampleMode)
% 
%   time,data: same sized vectors with tiem and data
%   timeUnit: unit of time ; default (blank or not passed) is same as TSA itself
%   idStr: identifying string
%   reSampleMode: how to resample? (default: 1 ; mean ; see
%     session.timeSeries.reSample for flags)
%
function obj = addRawDataToArray(obj, time, data, timeUnit,  idStr, reSampleMode)
  % --- argument check
	if (nargin < 3)
	  disp('addRawDataToArray::must at least give time & data.');
		return;
	end

  % timeunit
	if (nargin < 4 || length(timeUnit) == 0)
	  timeUnit = obj.timeUnit;
	end

	% id string
	if (nargin < 5 || length(idStr) == 0)
	  idStr = ['timeSeries ' num2str(max(obj.ids)+1)];
    end
    
    % resample mode
    if (nargin < 6 || length(reSampleMode) == 0)
      reSampleMode = 1;
    end

	% --- make it 
  newTS = session.timeSeries(time, timeUnit, data, max(obj.ids)+1, idStr, 0, '');
  newTS.reSample(reSampleMode,[],obj.time);
	disp('addRawDataToArray::warning - resample uses *mean*');
  obj.addTimeSeriesToArray(newTS);
