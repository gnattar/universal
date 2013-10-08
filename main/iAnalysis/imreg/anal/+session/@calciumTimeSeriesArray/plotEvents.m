% 
% SP Feb 2011
%
% Generates a simple raw test plot for event detection evaluation - plots for
%  tsa specified by tsId (should be same as ROI #)
%
% USAGE:
%
%		caTSA.plotEvents(tsId)
%
% PARAMS:
% 
%   tsId: which timeSeries to plot (pass id)
%
%
function plotEvents(obj, tsId)
	hold on;
	ts = obj.dffTimeSeriesArray.getTimeSeriesById(tsId);
	plot (obj.time-obj.time(1), ts.value, 'b-');
	if (length(obj.caPeakEventSeriesArray) == 0)
		disp('calciumTimeSeriesArray.plotEvents::event array empty.  Run event detection.');
	else
		ces = obj.caPeakEventSeriesArray.getEventSeriesById(tsId);
		for i=1:length(ces.eventTimes)
			plot(ces.eventTimes(i)*[1 1]-obj.time(1), [0.5 1], 'r-') ; 
		end
	end
