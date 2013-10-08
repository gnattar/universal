% 
% SP Feb 2011
%
% Wrapper for detectEventsFromDff that populates caPeakEventSeriesArray.  Uses
%  caTSA.dffOpts to dictate how/what is done in this context and evdetOpts.
%  Note that if no dffTimeSeriesArray is present, one is created using dffOpts.
%
% USAGE:
%  
%   caTSA.updateEvents()
% 
function obj = updateEvents(obj)
  %% --- prelims
	% run generateDffFromRawFluo?
	if (isobject(obj.dffTimeSeriesArray) == 0)
		obj.updateDff();
	end

	% get stuff from roiActivityStatsHash
  obj.evdetOpts.hyperactiveIdx = obj.roiActivityStatsHash.get('hyperactiveIdx');
  obj.evdetOpts.activeIdx = obj.roiActivityStatsHash.get('activeIdx');

	% pull trialTimes if possible
	trialTimes = [];
	if (isfield(obj.evdetOpts, 'trialTimes'))
	  trialTimes = obj.evdetOpts.trialTimes;
	elseif (isobject(obj.caPeakEventSeriesArray) && size(obj.caPeakEventSeriesArray.trialTimes,1) > 0)
		trialTimes = obj.caPeakEventSeriesArray.trialTimes;
	else
		disp('updateDff::trialTimes undefined ; if you are invoking for a session object, assign caPeakEventSeriesArray.trialTimes after running this.');
	end
  
  %% --- actual event detection ...
  caES = session.timeSeries.getCalciumEventSeriesFromExponentialTemplateS(obj.time,obj.dffTimeSeriesArray.valueMatrix,obj.evdetOpts);

	% build calcium event series array
	caESA = session.calciumEventSeriesArray(caES);
 
	% assign IDs, strings
	for e=1:obj.length()
		caESA.esa{e}.id = obj.ids(e);
		caESA.esa{e}.idStr = ['Ca events for ROI ' num2str(obj.ids(e))];
	end
	caESA.ids = obj.ids;

  % bump it into the object
	obj.caPeakEventSeriesArray = caESA;

	%% --- post processing ...

	% now build the event-peak-only time series array
	obj.caPeakTimeSeriesArray = caESA.deriveTimeSeriesArray(obj.time, obj.timeUnit, obj.trialIndices);

	% now build the convolved time series array (with decays)
	ts = {};
	for e=1:caESA.length()
	  dffVec = caESA.esa{e}.getDffVectorFromEvents(obj.time, obj.timeUnit);
    ts{e} = session.timeSeries(obj.time, obj.timeUnit, dffVec, obj.ids(e), ...
      ['dff trace based on ' caESA.esa{e}.idStr], 0, '');

	end
  obj.eventBasedDffTimeSeriesArray = session.timeSeriesArray(ts);
	obj.eventBasedDffTimeSeriesArray.trialIndices = obj.trialIndices;
	
	% trialTimes reassign -- this will update trial #s, and eventTimesRelTrialStart
	if (length(trialTimes) > 0)
		obj.caPeakEventSeriesArray.trialTimes = trialTimes;
		obj.caPeakEventSeriesArray.generateVarsFromEsa();
		obj.caPeakEventSeriesArray.updateEventSeriesFromTrialTimes(obj.caPeakEventSeriesArray.ids);
	end
