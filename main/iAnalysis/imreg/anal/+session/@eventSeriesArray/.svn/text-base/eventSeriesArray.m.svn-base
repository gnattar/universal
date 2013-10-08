%
% SP June 2010
%
% This defines a class for dealing with arrays of eventSeries objects.
%
% Probably the largest difference between event and timeSeries objects is
%  based on the fact that events store single times and timeseries store values
%  for all times.  Which one should be used is a question of what data you want
%  and also efficiency ; if you have very high event density, you may want
%  timeSeries instead.  In any case, one big consequence in terms of internal
%  data handling is that individual eventSeries objects track trial # of each
%  event, while, because each timeSeries in a timeSeries array has the same 
%  time vector, timeSeriesArrays define trial # and not timeSeries.
%
% USAGE:
%
%  ESA = session.eventSeriesArray(esa, trialTimes, ids)
%
% CLASS PROPERTIES:
%
%  esa: cell array of eventSeries objects
%  ids: id of each child array - hands off!
%  trialTimes: 3 column matrix where col 1, 2, 3 are trial #, start and end times
%
classdef eventSeriesArray < handle
  % Properties
  properties 
	  % basic
    ids; % stores IDs of child arrays -- you should NEVER manipulate this (!)
		esa; % array of eventseries objects

		% data - externally passed
		trialTimes; % 3 col matrix where (:,1) is trial #, (:,2) is start and (:,3) is end

		% internal
		loading; % set to 1 in loadobj to avoid set method calls UGH
  end

	% Methods -- public
  methods (Access = public)
	  %
	  % Constructor
		%
    function obj = eventSeriesArray(newEsa, newTrialTimes, newIds)

      obj.loading = 0;

		  % empty?
			if (nargin == 0)
			elseif (nargin == 1) % generate all from timeseries cell array 
				obj.esa = newEsa;
			elseif (nargin == 2) % assign external vars only
				obj.esa = newEsa;
				obj.trialTimes = newTrialTimes;
			elseif (nargin == 3) % someone wants to get wild
				obj.esa = newEsa;
				obj.trialTimes = newTrialTimes;
				obj.ids = newIds;
			end
		end

		%
		% Returns a copy of this eventSeriesArray
		%
		function cobj = copy(obj)
		  newEsa = {};
			for e=1:length(obj.esa)
			  newEsa{e} = obj.esa{e}.copy();
			end
			cobj = session.eventSeriesArray(newEsa, obj.trialTimes, obj.ids);
		end

		% Merge with another ESA
    obj = mergeWith (obj, oESA)
 
    %
		% add a/some eventseries - single objects must still be cell'd
    %
		function obj = addEventSeriesToArray(obj, newEsas)
		  T = length(obj.ids);
			if (~iscell(newEsas)) ; newEsas = {newEsas} ; end % in case single
		  for t=1:length(newEsas)
			  if (length(find(obj.ids == newEsas{t}.id)) > 0) % already in ?
					disp(['eventSeriesArray.addEventSeriesToArray::' newEsas{t}.idStr ' already in array; skipping add.']);
				else % add if not
			    obj.ids(T+t) = newEsas{t}.id;
					obj.esa{T+t} = newEsas{t};
          obj.updateEventSeriesFromTrialTimes(newEsas{t}.id);
			  end
			end
		end

		%
		% length: number of eventseries
		%
		function value = length(obj)
		  value = length(obj.esa);
		end

		%
		% goes thru the eventSeries specified and updates trial #s off of trialTimes 
		%
		function obj = updateEventSeriesFromTrialTimes(obj, eventSeriesIds)

      if (nargin < 2) ; eventSeriesIds = obj.ids; end % all if nothing

			if (size(obj.trialTimes,2) == 3 & size(obj.trialTimes,1) > 0)
				% loop thru event series
				for i=1:length(eventSeriesIds)
					idx = find(obj.ids == eventSeriesIds(i));
					es = obj.esa{idx};
					es.updateEventSeriesFromTrialTimes(obj.trialTimes);
				end
			else
				disp('updateEventSeriesFromTrialTimes::trialTimes undefined ; cannot determine trial for events.');
			end
		end

		%
		% delete set of trials
		%
		function obj = deleteTrials(obj, trialIds)
		  for e=1:length(obj.esa);
			  obj.esa{e}.deleteTrials(trialIds);
			end
		end

		%
		% get eventSeries by id (from esa cell array) ; esaId is ID, as in the ids
		%  vector
		%
		function es = getEventSeriesById(obj, esaId)
		  idx = find (obj.ids == esaId);
			es = [];
			if (length(idx) == 0)
			  disp('eventSeriesArray.getEventSeriesById::no match to requested ID found.');
			else
			  es = obj.esa{idx};
			end
    end
    
    %
		% get eventSeries idx by id (from esa cell array) ; esaId is ID, as in the ids
		%  vector
		%
		function esIdx = getEventSeriesIdxById(obj, esaId)
		  esIdx = find (obj.ids == esaId);
		end

		%
		%
		% get eventSeries by idStr (from esa cell array) ; esIdStr is matched using
		%  strfind, meaning any instance of esaIdStr is counted as ok.  All matching
		%  returned.  
		%
		%  matchExact: if 1, will use strcmp insteaf of strfind ; default 0
		%  ignoreCase: default 1 ; if 0, will include case
		%
		function es = getEventSeriesByIdStr(obj, esIdStr, matchExact, ignoreCase)
			es = [];
			if (nargin < 3) ; matchExact = 0 ;end
			if (nargin < 4) ; ignoreCase = 1 ;end
      
      esIdx = obj.getEventSeriesIdxByIdStr(esIdStr, matchExact, ignoreCase);

			if (length(esIdx) == 0)
			  disp(['eventSeriesArray.getEventSeriesByIdIstr::no match to "' esIdStr '" found.']);
      elseif (length(esIdx) > 1)
			  disp(['eventSeriesArray.getEventSeriesByIdIstr::multiple matches to "' esIdStr '" found.']);
			  es = obj.esa(esIdx);
			else
			  es = obj.esa{esIdx};
			end
		end

		%
		% get eventSeries idx by idStr (from esa cell array) ; esIdStr is matched using
		%  strfind, meaning any instance of esaIdStr is counted as ok.  All matches
    %  returned.
		%
		%  matchExact: if 1, will use strcmp insteaf of strfind ; default 0
		%  ignoreCase: default 1 ; if 0, will include case
		%
		function esIdx = getEventSeriesIdxByIdStr(obj, esIdStr, matchExact, ignoreCase)
			esIdx = [];
			if (nargin < 3) ; matchExact = 0 ;end
			if (nargin < 4) ; ignoreCase = 1 ;end

			if (ignoreCase) ; esIdStr = lower(esIdStr); end
			for e=1:length(obj.esa)
  		  idStr = obj.esa{e}.idStr;
			  if (ignoreCase) ; idStr = lower(idStr) ; end
			  if (matchExact)
					if(strcmp(idStr,esIdStr)) ; esIdx = [esIdx e] ; end
				else
					if(length(strfind(idStr,esIdStr)) > 0) ; esIdx = [esIdx e] ; end
				end
      end
		end


		%
		% regenerates id vector from esa{}
		%
		function obj = generateVarsFromEsa(obj)
      if (length(obj.esa) == 0) 
			  disp('eventSeriesArray.generateVarsFromEsa::Must assign the esa variable for this to work');
				return;
			end

      % clear old values
      obj.ids = [];

      % loop and assign
		  for t=1:length(obj.esa)
			  obj.ids(t) = obj.esa{t}.id;
		  end
		end

    % 
		% returns a CELL ARRAY of eventSeries that excludes the ones with excluded ids
		%
    function eventSeriesCellArray = getExcludedCellArray(obj, excludedIds)
      if (length(obj.ids) == 1 && length(excludedIds) == 1 && obj.ids(1) == excludedIds(1))
        eventSeriesCellArray{1} = obj.esa{1};
      else
        includedIds = setdiff(obj.ids, excludedIds);
			  for i=1:length(includedIds) 
			    idx = find(obj.ids == includedIds(i));
		      eventSeriesCellArray{i} = obj.esa{idx};
        end
      end

		end

    %
		% returns a subset of specified eventSeries from eventSeriesArray during which 
		%  no events from the other eventSeries occured, based on trials.  Default
		%  is to use ALL as excluders; you can specify idx to use subset.
		%
		function res = getTrialBasedExcludedEventSeries(obj, includeId, excludeIds)
		  res = [];
		  iidx = find(obj.ids == includeId);
			if (nargin == 2) ; excludeIds = setdiff(obj.ids, includeId) ; end

      res = obj.esa{iidx}.copy();
			removeTrials = [];
			for x=1:length(excludeIds)
			  xidx = find(obj.ids == excludeIds(x));
				xtrials = unique(obj.esa{xidx}.eventTrials);
        removeTrials = union(removeTrials,xtrials);
			end

			res.deleteTrials(removeTrials);
		end

		% prints id # & id tag for all ESs
		function listIds(obj)
		  for e=1:length(obj.esa)
			  disp([num2str(e) ': ' obj.esa{e}.idStr]);
			end
		end

		% wrapper for plotS
		function plot(obj, color)
		  if (nargin == 2)
				session.eventSeriesArray.plotS(obj.esa, color);
			else
				session.eventSeriesArray.plotS(obj.esa);
		  end
		end

	end

 
  % STATIC methods
  methods (Static)	
		% this is called on load
	  function obj = loadobj(a) 
		  a.loading = 1;
		  obj = a;
			obj.loading =0;
		end

	  % mass plotter
	  plotS(ESs, colors)
  end

  % Methods -- set/get/basic variable manipulation stuff
	methods 
	  % -- Assign Esa{} 
	  function obj = set.esa(obj, newEsa)
			obj.esa = newEsa;
			if (~obj.loading) ; obj.generateVarsFromEsa(); end
		end 

		% -- assigns trialTimes -- should update trial indices for events
		function obj = set.trialTimes (obj, newTrialTimes)
		  obj.trialTimes = newTrialTimes;
			if (~obj.loading) ; obj.updateEventSeriesFromTrialTimes(obj.ids);	end % update eventSeries using trial
		end

  end
end
