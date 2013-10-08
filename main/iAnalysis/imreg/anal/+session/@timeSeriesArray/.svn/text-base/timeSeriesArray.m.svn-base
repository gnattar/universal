%
% SP June 2010
%
% This defines a class for dealing with arrays of timeseries
%
% ALL members must share a common time vector to be part of an array. Individual
%  timeSeries objects are discarded, but can be rebuilt by calling 
%  tsa.getTimeSeriesById(id).  
%
% CONSTRUCTOR:
%
%  session.timeSeriesArray(tsCellArray, newTrialIndices, newIds, newIdStrs, ...
%     newTime, newTimeUnit, newValueMatrix, skipSort)
%
% PARAMS:
%
%  tsCellArray: cell array of timeSeries objects that are the basis of this
%               timeSeriesArray.  
%  skipSort: set to 1 to skip intiial sortyByTime ; this is important if you 
%            are subclassing this and want to sort other stuff too.  Also if you
%            want to ADD identically ordered timeSeries objects instead of 
%            all-at-once tsCellArray passing, set to 1 and the call sortByTime
%            once you're ready to sort.
%
%  The rest are fields - look up!
%
%  You can invoke with just a cell array of timeSeries objects (i.e., just the 
%  first parameter) ; this is probably the easiest way to invoke constructor.
%  Alternatively, you can pass parameters explicitly ... The one parameter that
%  you should pass independently is trialIndices, so the "best practice" is just
%
%    session.timeSeriesArray(tsCellArray, newTrialIndices);
%
% FIELDS:
%  
%   ids = []; % stores IDs of child arrays -- you should NEVER manipulate this (!)
%		idStrs = {}; % cell array of id strings
%
%		trialIndices: what trial does each timepoint belong to? as long as time
%
%		time: common time vector.
%		timeUnit: time unit of time vector ; timeSeries.timeUnitId for deets
%		valueMatrix: matrix where valueMatrx(i,t) is values for ids(i) at time(t)
%
% 
%
classdef timeSeriesArray < handle
  % Properties
  properties 
	  % basic
    ids = []; % stores IDs of child arrays -- you should NEVER manipulate this (!)
		idStrs = {}; % cell array of id strings

		% data - externally passed
		trialIndices = []; % what trial does each timepoint belong to? as long as time

		% data - internally generated
		time = []; % common time vector.
		timeUnit = 0; % time unit of time vector ; timeSeries.timeUnitId for deets
		valueMatrix = []; % matrix where valueMatrx(i,t) is values for ids(i) at time(t)

		% internal
		loading; % set to 1 on loading ...
  end

	% Methods -- public
  methods (Access = public)
	  %
	  % Constructor
		%
    function obj = timeSeriesArray(tsCellArray, newTrialIndices, newIds, newIdStrs, newTime, ...
		  newTimeUnit, newValueMatrix, skipSort)

			obj.loading = 0;

		  % empty?
			if (nargin == 0)
			  tsCellArray = [];
			end

			if (nargin >= 2) % assign external vars only
				obj.trialIndices = newTrialIndices;
			end 

			if (nargin >= 7) % someone wants to get wild -- should not pass tsCellArray
				obj.ids = newIds;
				obj.idStrs = newIdStrs;
				obj.time = newTime;
				obj.timeUnit = newTimeUnit;
				obj.valueMatrix = newValueMatrix;
			end
			if (nargin < 8)
			  skipSort = 0;
			end

      % tsCellArray always trumps if not blank
			if (iscell(tsCellArray) & length(tsCellArray) > 0)
			  obj.generateVarsFromTSCellArray(tsCellArray); 
			end

			% sort by time
			if (~skipSort)
				obj.sortByTime();
			end
		end

		% Creates a copy of this tsa
		function newTSA = copy(obj)
			% and the whole thing
		  newTSA = session.timeSeriesArray([], obj.trialIndices, obj.ids, obj.idStrs, obj.time, obj.timeUnit, obj.valueMatrix, 1);
		end

		% merge another timeSeriesArray (oTSA -- other TSA) to this
		obj = mergeWith(obj, oTSA)

    %
		% add a/some timeseries - single objects must still be cell'd
    %
		function obj = addTimeSeriesToArray(obj, newTSs)
      if (~iscell(newTSs)) ; newTSs = {newTSs} ; end
		  T = size(obj.valueMatrix,1);
      for t=1:length(newTSs)
	  	  if (length(find(obj.ids == newTSs{t}.id)) > 0) % already in ?
					disp(['timeSeriesArray.addTimeSeriesToArray::' newTSs{t}.idStr ' already in array; skipping add.']);
				elseif (length(obj.time) ~= length(newTSs{t}.time) || sum(obj.time ~= newTSs{t}.time) > 0) %wrong length?
					disp(['timeSeriesArray.addTimeSeriesToArray::' newTSs{t}.idStr ' has a different time vector from the timeSeriesArray.']);
				else % add if all well
				  obj.valueMatrix(T+t,:) = newTSs{t}.value;
			    obj.ids(T+t) = newTSs{t}.id;
			    obj.idStrs{T+t} = newTSs{t}.idStr;
			  end
			end
		end

    %
		% length: number of timeseries
		%
		function value = length(obj)
		  value = size(obj.valueMatrix,1);
		end

    %
		% prints id # & id tag for all TSs
		%
		function listIds(obj)
		  [irr sidx] = sort(obj.ids); 
		  for t=1:length(obj.ids)
			  disp([num2str(obj.ids(sidx(t))) ': ' obj.idStrs{sidx(t)}]);
			end
		end
    
		%
		% removes all components for a specific trial(s)
		%
	  function obj = deleteTrials(obj, trialIds)
		  delIdx = find(ismember(obj.trialIndices, trialIds));
			keepIdx = setdiff(1:length(obj.time), delIdx); % logic needed in case trialIndices blank
			obj.time = obj.time(keepIdx);
			obj.valueMatrix = obj.valueMatrix(:,keepIdx);
			obj.trialIndices = obj.trialIndices(keepIdx);
	  end


		%
		% Replace a timeSeries by id -- must have same # timepoints
		%
		function replaceTimeSeriesById (obj, tsId, newTs)
		  % sanity -- same time points, valid ID?
			tsIdx = find(obj.ids == tsId);
			if (length(tsIdx) ~= 1) ; disp(['replaceTimeSeriesById::invalid replacement id ' num2str(tsId)]); return; end
      if (length(newTs.time) ~= length(obj.time)) ; disp('replaceTimeSeriesById::time vectors must be same length to replace.'); return ; end
      if (newTs.timeUnit ~= obj.timeUnit) ; disp('replaceTimeSeriesById::replacement timeSeries must have same timeUnit as timeSeriesArray.'); return ; end

			% do it
      obj.valueMatrix(tsIdx,:) = newTs.value;
			obj.idStrs{tsIdx} = newTs.idStr;
		end

		%
		% get timeSeries by id ; tsId is ID, as in the ids
		%  vector
		%
		function ts = getTimeSeriesById(obj, tsId)
		  idx = find (obj.ids == tsId);
			ts = [];
			if (length(idx) == 0)
			  disp('timeSeriesArray.getTimeSeriesById::no match to requested ID found.');
			else
		    ts = obj.getTimeSeriesByIdx( idx);
			end
		end

		%
		% get timeSeries by idx -- simply use obj.valueMatrix(idx,:)
		%  vector
		%
		function ts = getTimeSeriesByIdx(obj, tsIdx)
			ts = [];
			if (tsIdx < 1 | tsIdx > length(obj.ids))
			  disp('timeSeriesArray.getTimeSeriesByIdx::idx is not matched by number of ids.');
			else
			  if (length(obj.idStrs) < tsIdx)
				  obj.idStrs{tsIdx} = ['TS ' num2str(tsIdx)];
				end
				ts = session.timeSeries(obj.time, obj.timeUnit, obj.valueMatrix(tsIdx,:), obj.ids(tsIdx), obj.idStrs{tsIdx}, 0, '');
			end
		end

		%
		% get timeSeries by id string -- using idStrs. 
		%
		%  matchExact: if 1, uses strcmp instead of strfind (default, if 0 too)
		%  ignoreCase: default 1 ; of 0, will use case
		%
		function ts = getTimeSeriesByIdStr(obj, tsIdStr, matchExact, ignoreCase)
			ts = [];
			tsIdx = -1;
			if (nargin < 3) ; matchExact = 0 ;end
			if (nargin < 4) ; ignoreCase = 1 ;end

			if (ignoreCase) ; tsIdStr = lower(tsIdStr); end
			for i=1:length(obj.idStrs)
			  idStr = obj.idStrs{i};
			  if (ignoreCase) ; idStr = lower(idStr) ; end
			  if (matchExact)
					if(strcmp(idStr,tsIdStr)) ; tsIdx = i ; break ; end
				else
					if(length(strfind(idStr,tsIdStr)) > 0) ; tsIdx = i ; break ; end
				end
			end
			if (tsIdx < 0)
			  disp(['timeSeriesArray.getTimeSeriesByIdStrs::no match found to ' tsIdStr]);
			else
				ts = session.timeSeries(obj.time, obj.timeUnit, obj.valueMatrix(tsIdx,:), obj.ids(tsIdx), obj.idStrs{tsIdx}, 0, '');
			end
		end



		%
		% regenerates time vector, valueMatrix from an array of timeSeries objects
		%
		function obj = generateVarsFromTSCellArray(obj, tsCellArray)
      if (length(tsCellArray) == 0) 
			  disp('timeSeriesArray.generateVarsFromTSCellArray::Must assign the cell array for this to work');
				return;
			end

      % singleton?  wrap it
			if (~iscell(tsCellArray) && isobject(tsCellArray))
			  tsCellArray = {tsCellArray};
			end

      % clear old values
      obj.ids = [];
			obj.valueMatrix = [];
			obj.idStrs = {};

      if (length(tsCellArray{1}.time) > 0)
				obj.idStrs{1} = tsCellArray{1}.idStr;
				obj.time = tsCellArray{1}.time;
				obj.timeUnit = tsCellArray{1}.timeUnit;
			else
			  disp('timeSeriesArray.generateVarsFromTSCellArray::tsCellArray{1}.time is blank, so keeping old time; change explicitly if you wish.');
			end

      % loop and assign
			obj.valueMatrix = zeros(length(tsCellArray), length(tsCellArray{1}.value));
			nWrongTime = 0;
		  for t=1:length(tsCellArray)
			  obj.ids(t) = tsCellArray{t}.id;
			  obj.idStrs{t} = tsCellArray{t}.idStr;
				if (length(tsCellArray{t}.value) ~= length(tsCellArray{1}.value))
					disp(['timeSeriesArray.generateVarsFromTSCellArray::ALL timeseries must have same length to be part of same array; failed on ' tsCellArray{t}.idStr]);
				elseif (length(find(tsCellArray{t}.time ~= obj.time)) > 0)
				  nWrongTime = nWrongTime+1;
				else
				  obj.valueMatrix(t,:) = tsCellArray{t}.value;
				end
		  end
			if (nWrongTime>0)
				disp(['timeSeriesArray.generateVarsFromTSCellArray::ALL timeseries must have same time vector to be part of same array; failed on ' num2str(nWrongTime)]);
			end
		end

		% Sorts class by time
	  function obj = sortByTime(obj)
		  % make sure not subclass
			if (strcmp(class(obj),'session.timeSeriesArray'))
				% sort it (and value)
				[irr sidx] = sort(obj.time, 'ascend');
				obj.time = obj.time(sidx);
				% if lengths differ, this will break, but this means something is wrong so OK
				if (length(obj.valueMatrix) > 0)
  				obj.valueMatrix = obj.valueMatrix(:,sidx); 
				end
				if (length(obj.trialIndices) > 0) ; obj.trialIndices = obj.trialIndices(sidx); end
      end
		end


		% for a single timeseries, with time series id tsId, gets values for trials trialIDs
		function [timeMat valueMat timeVec] = getTrialMatrix(obj, tsId, trialIds, trialStartTimes, keepNanTimes)
		  timeMat = [];
			valueMat = [];
			timeVec = [];
		  tsIdx = find(obj.ids == tsId) ;
			if (length(tsIdx) > 0) % make sure it exists ...
		    ts = obj.getTimeSeriesById(tsId);
				if (nargin == 3)
					[timeMat valueMat] = ts.getTrialMatrixWrapper(obj.trialIndices, trialIds);
				elseif (nargin == 4)
					[timeMat valueMat timeVec] = ts.getTrialMatrixWrapper(obj.trialIndices, trialIds, trialStartTimes);
				elseif (nargin == 5)
					[timeMat valueMat timeVec] = ts.getTrialMatrixWrapper(obj.trialIndices, trialIds, trialStartTimes, keepNanTimes);
				end
			end
		end

		% takes raw data and creates timeseries, adding to TSA
		obj = addRawDataToArray(obj, time, data, timeUnit, idStr, reSampleMode)

    % returns a matrix with timeseries values for selected trial(s)
		[valMat trialVec timeVec] = getValuesByTrialIndices(obj, trialIndices, tsIds) 

    % returns a matrix with timeseries values for selected time range
		[valMat trialVec timeVec] = getValuesByTime(obj, timeRange, tsIds) 

		% returns vector of times *relative to trial start*, same size as time
    timeRelTrialStart = getTimeRelTrialStart(obj, trialStartTimes, trialIds)

		% Creates a copy of this TSA restricted to a specific time range in terms of trial
    newTSA = getTrialTimeRestrictedTSA(obj, trialStartTimes, trialIds, timeRange, timeRangeUnit)

		% Creates a copy of this TSA restricted to a specific trial type set
    newTSA = getTrialTypeRestrictedTSA(obj, trialIds, trialTypeMat, trialTypeRestriction);

    % computes AUC around events for all members of the TSA
    [aucRaw aucNic idxMat1 idxMat2] = computePeriEventAUC (obj, params)

		% plot method
		plot(obj)
	end

	methods (Static) % static methods 
		% this is called on load
	  function obj = loadobj(a) 
		  a.loading = 1;
			obj = a;
			obj.loading = 0;
		end

  
	  % plotter for time series as image
    plotTimeSeriesAsImageS(tsa, tsIdx, trialStartTimeMat, pESs, pTrialsPlotted, pTypeMatrix, ...
                               pTypesPlotted, pSortByType, pColorMap, pXAxisBounds, pValueRange, ...
															 pPlotAxes, pMouseClickCallback);

    % plots a time series as a line
    plotTimeSeriesAsLineS(tsa, tsIdx, trialStartTimeMat, pESs, pTrialsPlotted, pTypeMatrix, ...
                                 pTypesPlotted, pTypeStr, pTypeColor, pAxisBounds,pPlotAxes,  ...
																 pShowLegend)
  end


  % Methods -- set/get/basic variable manipulation stuff
	methods 
		% -- keep all as row vectors for consistency (time) 
		function obj = set.time(obj, newTime)
		  S = size(newTime);
			if (length(S) > 1) % blank?
			  if (S(1) > S(2))
				  newTime = newTime';
				end
			end
			obj.time= newTime;
			
			% call subclass ..
%			if (~obj.loading) ; obj.subclassSetTime(); end
			obj.subclassSetTime(); 
		end

		% -- trialIndices for subclasses
		function obj = set.trialIndices (obj, newTrialIndices)
		  obj.trialIndices = newTrialIndices;

			% subclass
%			if (~obj.loading) ; obj.subclassSetTrialIndices(); end
			obj.subclassSetTrialIndices(); 
		end

		% -- timeUnit for subclass
		function obj = set.timeUnit (obj, newTimeUnit)
		  obj.timeUnit = newTimeUnit;

			% subclass
%			if (~obj.loading) ; obj.subclassSetTimeUnit(); end
			obj.subclassSetTimeUnit();
		end

		% -- make sure first dim is value, second dim is time
		function obj = set.valueMatrix(obj, newValueMatrix)
		  S = size(newValueMatrix);
			if (length(S) > 1) % blank?
			  if (S(2) ~= length(obj.time) & S(1) == length(obj.time))
				  newValueMatrix = newValueMatrix';
				end
			end
			obj.valueMatrix = newValueMatrix;
		end


  end

	% so you can override set/get in subclasses
	methods (Access = protected)
	  function subclassSetTime(obj)
		  % NOTHING
		end
	  function subclassSetTrialIndices(obj)
		  % NOTHING
		end
	  function subclassSetTimeUnit(obj)
		  % NOTHING
		end
	end
end
