%
% SP June 2010
%
% This defines a class for dealing with arrays of calciumeventseries
%
% Key notes:
%  1) it still has variable esa, but now this is a cell array of 
%      calciumEventSeries objects.  
%  2) be sure in most methods to do a class check for what is passed -
%      if it is an eventSeries and not calciumEventSeries, get mad!
%
classdef calciumEventSeriesArray < session.eventSeriesArray
  % Properties
  properties 

		% data - internally generated
  end

	% Methods -- public
  methods (Access = public)
	  %
	  % Constructor
		%
    function obj = calciumEventSeriesArray(newEsa, newTrialTimes, newIds)
		  % defaults
      esa = {};
			trialTimes = [];
			ids = [];

		  % empty?
			if (nargin >= 1) % generate all from timeseries cell array 
				esa = newEsa;
			end
			if (nargin >= 2) % assign external vars only
				trialTimes= newTrialTimes;
			end
			if (nargin >= 3) % someone wants to get wild
				ids = newIds;
			end

      % call superclass constructor
			obj = obj@session.eventSeriesArray(esa, trialTimes, ids);
  
			% Assign
			obj.esa = esa;
			obj.trialTimes = trialTimes;
		end

		%
		% Returns a copy of this eventSeriesArray
		%
		function cobj = copy(obj)
		  newEsa = {};
			for e=1:length(obj.esa)
			  newEsa{e} = obj.esa{e}.copy();
			end
			cobj = session.calciumEventSeriesArray(newEsa, obj.trialTimes, obj.ids);
		end

    %
		% add a/some calciumeventseries - single objects must still be cell'd - OVERRIDE to 
		%  add other parameters
    %
		function obj = addEventSeriesToArray(obj, newEsas)
		  T = length(obj.ids);
			if (~iscell(newEsas)) ; newEsas = {newEsas} ; end % in case single
		  for t=1:length(newEsas)
%%% ADD CLASS TYPE CHECK
			  if (length(find(obj.ids == newEsas{t}.id)) > 0) % already in ?
					disp(['calciumEventSeriesArray.addEventSeriesToArray::' newEsas{t}.idStr ' already in array; skipping add.']);
				else % add if not
			    obj.ids(T+t) = newEsas{t}.id;
				  obj.esa{T+t} = newEsas{t};
          obj.updateEventSeriesFromTrialTimes(newEsas{t}.id);
			  end
			end
		end

		%
		% regenerates *Cell cellArrays and id from esa -- override parent class method
		%  since we have more cells
		%
		function obj = generateVarsFromEsa(obj)
      if (length(obj.esa) == 0) 
			  disp('calciumEventSeriesArray.generateVarsFromEsa::Must assign the esa variable for this to work');
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
		% delete set of trials
		%
		function obj = deleteTrials(obj, trialIds)
		  for e=1:length(obj.esa);
			  obj.esa{e}.deleteTrials(trialIds);
			end
		end

		% will return a TSA object with the provided time vector with the values
		%  based on ca peak
		function tsa = deriveTimeSeriesArray(obj, time, timeUnit, trialIndices)
		  for e=1:length(obj.esa)
			  ts{e} = obj.esa{e}.deriveTimeSeries(time, timeUnit);
			end
			tsa = session.timeSeriesArray(ts);
			tsa.trialIndices = trialIndices;
		end
    
		% ESA that is trial restricted
		newESA = getTrialTypeRestrictedESA(obj, trialIds, trialTypeMat, trialTypeRestriction);
	end

  % Methods -- set/get/basic variable manipulation stuff
	methods 
	  % -- Assign Esa{} 
%	  function obj = set.esa(obj, newEsa)
%			obj.esa = newEsa;
%			obj.generateVarsFromEsa();
%		end 
  end
end
