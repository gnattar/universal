%
% Processes continuous lick laser trace and detects individual lick starts
%
% This function will append an ES "Lick Laser" onto behavESA.
%
% USAGE:
%
%   obj.generateLicklaserES()
%
% (C) July 2012 S Peron
%
function obj = generateLicklaserES (obj)
  %% --- very simple
	ts = obj.ephusTSA.getTimeSeriesByIdStr('licklaser');
	if (length(ts) > 0)
		licklaserES = session.timeSeries.getEventSeriesFromMADThreshS(ts,[0 3]);
		licklaserES.color = [1 0 0.5];
		licklaserES.idStr = 'Lick Laser';

		if (length(obj.behavESA.getEventSeriesByIdStr('Lick Laser')) == 0)
			licklaserES.id = length(obj.behavESA) +1;
			obj.behavESA.addEventSeriesToArray(licklaserES);
		else
		  idx = obj.behavESA.getEventSeriesIdxByIdStr('Lick Laser');
			licklaserES.id = obj.behavESA.ids(idx);
			obj.behavESA.esa{idx} = licklaserES;
		end
		obj.behavESA.updateEventSeriesFromTrialTimes();
	else
	  disp('generateLikclaserES::No timeSeries "licklaser" in ephusTSA.');
	end


