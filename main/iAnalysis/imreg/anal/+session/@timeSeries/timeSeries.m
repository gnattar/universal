%
% SP June 2010
%
% This defines a class for dealing with timeseries
%
% USAGE:
%   
%   ts = session.timeSeries(newTime, newTimeUnit, newValue, newId, newIdStr, 
%                           newLoadOnGet, newSourceFileRelPath)
%
%    newSourceFileRelPath: can include root path as this will be stripped
classdef timeSeries< handle
  % Properties
  properties 
	  % basic
    id = -1;
    idStr = '';
		loadOnGet = 0; % set to 1 and appropriate load is called on get
		sourceFileRelPath = ''; % source file path relative (global) basePath

		timeUnit;

		% data
		time;
		value;

		% internal
		loading; % used to avoid callign set methods on load
  end

	% static ...
	properties (Constant = true)
	  timeUnitId = [1 2 3 4 5]; % correspond to below stirngs
	  timeUnitStr = {'ms', 's', 'm', 'h', 'd'} ;  % thus, 1 = miliseconds, 2=sec, 3=min, etc

    millisecond = 1;
		second = 2;
    minute = 3;
		hour = 4;
		day = 5;
	end

	% Methods -- public
  methods (Access = public)
	  %
	  % Constructor
		%
    function obj = timeSeries(newTime, newTimeUnit, newValue, newId, newIdStr, newLoadOnGet, newSourceFileRelPath)

			obj.loading = 0;

		  % empty?
			if (nargin == 0)
			elseif(nargin == 3) % just data& time
			  obj.timeUnit = newTimeUnit;
				obj.value = newValue;
			  obj.time = newTime;

			else % everything
			  obj.timeUnit = newTimeUnit;
				obj.value = newValue;
			  obj.time = newTime;

			  obj.id = newId;
				obj.idStr = newIdStr;
				obj.loadOnGet = newLoadOnGet;
				obj.sourceFileRelPath = newSourceFileRelPath;
			end

			obj.sortByTime();
		end

		% Returns a new copy of this ts
		function newTS = copy(obj)
		  newTS = session.timeSeries(obj.time, obj.timeUnit, obj.value, obj.id, obj.idStr, obj.loadOnGet, obj.sourceFileRelPath);
		end

		% Sorts class by time
	  function obj = sortByTime(obj)
      % check for nan times
			nantime = find(isnan(obj.time));
			if (length(nantime) > 0)
				disp(['timeSeries.sortByTime::found ' num2str(length(nantime)) ' NaN time values ; these will be REMOVED.']);
				val = find(~isnan(obj.time));
				obj.time = obj.time(val);
				obj.value = obj.value(val);
			end

		  % make sure not subclass
			if (strcmp(class(obj),'session.timeSeries'))
				% sort it (and value)
				[irr sidx] = sort(obj.time, 'ascend');
				obj.time = obj.time(sidx);
				if (length(obj.value) > 0)
					obj.value = obj.value(sidx); % if lengths differ, this will break, but this means something is wrong so OK
				end
      end
    end
    
    % simple length
    function retVal = length(obj)
      retVal = length(obj.time);
    end


		% downsamples the timeSeries
		obj = downSample(obj, method, downSampleFactor, newTime)

		% resamples timeseries -- use this if possible
		obj = reSample(obj, method, reSampleFactor, newTime, interpMode)

		% simple plot
    plot (obj, color, scalingFactor, offset)

		% returns a matrix with a series of time windows of appropriate size 
		[valueMat timeMat idxMat timeVec ieIdxVec] = getValuesAroundEvents(obj, ies, timeWindow, windowTimeUnit, ...
		  allowOverlap, xes, xTimeWindow, ieIdxVec, idxMat, valueMat)

    % gets a single number for each row of valueMat based on valueType
    valueVec = getSingleValuePerRowFromMatrix(obj, valueType, valueMat)

    % wrapper that calls getTrialMatrix to  get a matrix version of data
		function [timeMat valueMat timeVec] = getTrialMatrixWrapper(obj, trialIndices, trialIds, trialStartTimes, keepNanCols)
		  if (nargin == 3)
				[timeMat valueMat timeVec] = session.timeSeries.getTrialMatrix(obj.time, obj.value, trialIndices, trialIds);
			elseif (nargin == 4)
				[timeMat valueMat timeVec] = session.timeSeries.getTrialMatrix(obj.time, obj.value, trialIndices, trialIds, trialStartTimes);
			elseif (nargin == 5)
				[timeMat valueMat timeVec] = session.timeSeries.getTrialMatrix(obj.time, obj.value, trialIndices, trialIds, trialStartTimes, keepNanCols);
			end
		end

		% returns a SINGLE value per event (at MOST) 
		[valueVec ieIdxVec idxMat valueMat] = getSingleValueAroundEvents(obj, valueType, ies, timeWindow, timeWindowUnit, ...
		  allowOverlap, xes, xTimeWindow)

		% wrapper for getInexWindowsAroundEventsS
		[idxMat timeMat timeVec ieIdxVec] = getIndexWindowsAroundEvents(obj, timeWindow, timeWindowUnit, ies, ...
		  excludeTimeWindow, xes, allowOverlap)

		%%%%%%%%%%%%%%% WRAPPERS FOR STATIC METHODS -- SEE STATIC METHOD FOR DEETS %%%%%%%%%%%%%%%%%%%%%%%
    function obj= filterKsdensity(obj, timeWindow, dt)
		  obj.value = filterKsdensityStatic(obj.time, obj.value, timeWindow, dt);
		end
		  
	end

	methods (Static) % static methods 
	  % converts a time vector across units
		convertedTime = convertTime(originalTime, originalTimeUnit, convertedTimeUnit)

		% gets an event series with MAD thresh
    es = getEventSeriesFromMADThreshS(ts, thresh, options)
    
		% computes correlations between two timeseries
		corrab = computeCorrelationS(tsA, tsB, shiftB, corrType)

		% returns a receptive field
    [stimulusVec responseVec signalIdx noiseIdx evIdxVec sIdxMat sValueMat rIdxMat rValueMat sIeIdxVec rIeIdxVec ] = ...
		   computeReceptiveFieldAroundEvents( ...
		     stimulusTS, stimulusValueType, responseTS,...
  		   responseValueType, ies, stimulusTimeWindow, ...
	  		 responseTimeWindow, timeWindowUnit, ...
			 allowOverlap, xes, xTimeWindow)

		% returns indices with specified properties
    [idxMat timeMat timeVec ieIdxVec] = getIndexWindowsAroundEventsS(time, timeUnit, timeWindow, timeWindowUnit, ...
		  includeEventTimes, ieTimeUnit, excludeTimeWindow, excludeEventTimes, eeTimeUnit, allowOverlap) 

		% takes indexMat and filters by trial
    indexMat = filterIndexWindowByTrial (indexMat, trialIndices, restrictToTrials)

		% converts the time/data vectors into trial-by-trial matrix
    [timeMat valueMat timeVec] = getTrialMatrix(time, value, trialIndices, trialIds, trialStartTimes, keepNanCols)

		% applies a ksdensity filter to the underlying data
		newValue = filterKsdensityStatic(time, value, timeWindow, dt)

		% filter kit with several filters
		newValueMatrix = filterS(time, valueMatrix, params)

		% compute noise for time series
    noise = computeNoiseS(time, valueMatrix, params)
    
		% exponential template based event detector
		caES = getCalciumEventSeriesFromExponentialTemplateS (time, valueMatrix, params)

		% plots two timeSeriers objects against eachother
    plotVersusS (ts1,ts2, tOffs, ax)

    % computes area under ROC curve around two event series for values drawn from a timeSeries
    [aucRaw aucNic idxMat1 idxMat2] = computePeriEventAUCS (params)

		% this is called on load
	  function obj = loadobj(a) 
		  a.loading = 1;
		  obj = a;
			obj.sortByTime();
			obj.loading = 0;
		end

  end

  % Methods -- set/get/basic variable manipulation stuff
	methods 
	  % -- ID ; nothing for now
	  function obj = set.id (obj, newId)
		  obj.id = newId;
		end
	  function value = get.id (obj)
		  value = obj.id;
		end

		% -- keep all as row vectors for consistency (value)
		function obj = set.value (obj, newValue)
		  S = size(newValue);
			if (length(S) > 1) % blank?
			  if (S(1) > S(2))
				  newValue = newValue';
				end
			end

			obj.value = newValue;
		end

		% -- keep all as row vectors for consistency (time) 
		function obj = set.time(obj, newTime)
		  S = size(newTime);
			if (length(S) > 1) % blank?
			  if (S(1) > S(2))
				  newTime = newTime';
				end
			end

			obj.time= newTime;
		end

    % -- idStr -- cell check ...
	  function obj = set.idStr (obj, newIdStr)
		  if (~obj.loading)
				% de-cell
				if (iscell(newIdStr))
					pstr = newIdStr;
					newIdStr = [];
					for s=1:length(pstr)
						newIdStr = [newIdStr char(pstr{s})];
					end
				end
			end
			obj.idStr = newIdStr;
		end

		% -- source file path -- should be RELATIVE to global path
    function obj = set.sourceFileRelPath (obj, newSourceFileRelPath)
		  rdp = get_root_data_path();
			if (strfind(newSourceFileRelPath, rdp) == 1)
				obj.sourceFileRelPath = strrep(newSourceFileRelPath, rdp, '<%rootDataPath%>');
			else
			  obj.sourceFileRelPath = newSourceFileRelPath;
			end
		end

		% -- returns the sourceFileRelPath -- WITH global path !
		function value = get.sourceFileRelPath(obj)
		  value = assign_root_data_path(obj.sourceFileRelPath);
		end
  end
end
