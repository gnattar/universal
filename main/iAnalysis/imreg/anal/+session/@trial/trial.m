%
% SP Aug 2010
%
% This defines a class for dealing with a single trial -- more a data structure
%  than a class, as most trial-based interfacing is done via session.session.
%
% PROPERTIES:
%
%   id: the trial #
%		typeIds: the type(s) of the trial [go,nogo, etc. ; numerical, vector]
%		timeUnit: applies to the two below
%		startTime: when trial starts
%		endTime: when trial ends
%		behavParams: hash object with misc. behavioral parameters
%
% CONSTRUCTOR:
%
%  t = session.trial(newId, newTypeIds, newTimeUnit, newStartTime, newEndTime, newBehavParams)
%
classdef trial< handle
  % Properties
  properties 
	  % basic
    id = -1; % the trial #
		typeIds; % the type(s) of the trial [go,nogo, etc. ; numerical]
		timeUnit; % applies to the two below
		startTime; % when trial starts
		endTime; % when trial ends
		behavParams; % see session.trialBehavParamStr for what is in here
  end

	% Methods -- public
  methods (Access = public)
	  %
	  % Constructor
		%
    function obj = trial(newId, newTypeIds, newTimeUnit, newStartTime, newEndTime, newBehavParams)
			  obj.id = newId;
			  obj.typeIds = newTypeIds;
			  obj.timeUnit = newTimeUnit;
				obj.startTime = newStartTime;
				obj.endTime = newEndTime;
				obj.behavParams = newBehavParams;
		end

		%
		% copy
		%
		function cobj = copy(obj)
		  cobj = session.trial(obj.id, obj.typeIds, obj.timeUnit, obj.startTime, obj.endTime, obj.behavParams.copy());
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
  end

end
