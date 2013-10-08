%
% SP May 2011
%
% Will return event series that contains points where a whisker contact sequence
%  took place.
%
% USAGE:
%
%  es = s.getSequentialWhiskerContactES (sequence, sequenceMaxDt, burstDt)
%
% PARAMS:
%
%  es: the eventSeries object (type 1 -- start times of the sequences)
%
%  sequence: whisker names, as cell array.  So if you want c1->c2 contacts, 
%            {'c1','c2'} should be passed.  If you want to restrict to pro/
%            retractions, preface with P or R (e.g., {'Pc1','Pc2'})
%  sequenceMaxDt: what is the maximal spacing, in seconds, between contacts
%                 for them to be part of a seuqence?
%  burstDt: if specified, will restrict to FIRST contact in a series of contacts
%           lasting burstDt.  This is very useful if you want to, e.g., restrict
%           to first contact in trial (in which case a value of 2 is a good one --
%           units seconds).
%
% EXAMPLE: get event series for the c1->c2 sequence spaced 500 ms apart using
%          start of contact in trial (pole period < 2 s)
%        
% es = s.getSequentialWhiskerContactES({'c1','c2'}, 0.5, 2);
%
%  
%
function es = getSequentialWhiskerContactES (obj, sequence, sequenceMaxDt, burstDt)
  % --- params process
	if (nargin < 3)
	  help ('session.session.getSequentialWhiskerContactES');
		es = [];
		return;
	end

	if (nargin < 4 | length(burstDt) == 0)
	  burstDt = 0;
	end

	% --- run it

	% build the event series based on sequence parameter ...
	ies = {};
	fail = 0;
	for s=1:length(sequence)
	  if (sequence{s}(1) == 'P')
			es = obj.whiskerBarContactClassifiedESA.getEventSeriesByIdStr(['Protraction contacts for ' sequence{s}(2:end)], 1);
		elseif (sequence{s}(1) == 'R')
			es = obj.whiskerBarContactClassifiedESA.getEventSeriesByIdStr(['Retraction contacts for ' sequence{s}(2:end)], 1);
		else
			es = obj.whiskerBarContactESA.getEventSeriesByIdStr(['Contacts for ' sequence{s}], 1);
		end

		% burst Dt?
    if (isobject(es) & burstDt > 0)
		  options.useStartOrEnd = 1;
			bdt = session.timeSeries.convertTime(burstDt, 2, es.timeUnit);
		  eTimes = es.getBurstTimes(bdt, options);

			% build an ES ...
			es = session.eventSeries(eTimes, [],es.timeUnit,es.id, es.idStr, 0,'','',es.color, 1);
		end

		if (~isobject(es)) ; fail = 1; break ; end

		ies{s} = es;
	end

	% did an ES fail? return nothing
	if (fail) ; return ; end

	% sequenceMaxDt must be in timeunit of first event series passed:
	masterTimeUnit = ies{1}.timeUnit;
	sequenceMaxDt = session.timeSeries.convertTime(sequenceMaxDt, 2, masterTimeUnit);

  % the call to getEventSequenceS
  es = session.eventSeries.getEventSequenceS(ies, 1:length(ies), sequenceMaxDt, ...
                   masterTimeUnit, 1, [], [], []);

	% and finally repopulate trial, etc, in returned ES
  es.updateEventSeriesFromTrialTimes(obj.behavESA.trialTimes);
  es.sortByTime();

