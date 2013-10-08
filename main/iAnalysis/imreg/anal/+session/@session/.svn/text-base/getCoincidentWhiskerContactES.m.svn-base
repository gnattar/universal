%
% SP May 2011
%
% Will return event series that contains times at which multiple whiskers touched
%  together.
%
% USAGE:
%
%  es = s.getCoincidentWhiskerContactES (contacts, coincidentDtMax)
%
% PARAMS:
%
%  es: the eventSeries object 
%
%  contacts: whisker names, as cell array.  So if you want c1 & c2 contacts, 
%            {'c1','c2'} should be passed.  If you want to restrict to pro/
%            retractions, preface with P or R (e.g., {'Pc1','Pc2'})
%  coincidentDtMax: 0 is event time, -/+ is before/after.  Must have all 
%                        cotnacts in this window.  Unit seconds.
%
function es = getCoincidentWhiskerContactES (obj, contacts, coincidentDtMax)
  % --- params process
	if (nargin < 3)
	  help ('session.session.getCoincidentWhiskerContactES');
		es = [];
		return;
	end

	% --- run it

	% build the event series based on contact parameter ...
	ies = {};
	fail = 0;
	for c=1:length(contacts)
	  if (contacts{c}(1) == 'P')
			es = obj.whiskerBarContactClassifiedESA.getEventSeriesByIdStr(['Protraction contacts for ' contacts{c}(2:end)], 1);
		elseif (contacts{c}(1) == 'R')
			es = obj.whiskerBarContactClassifiedESA.getEventSeriesByIdStr(['Retraction contacts for ' contacts{c}(2:end)], 1);
		else
			es = obj.whiskerBarContactESA.getEventSeriesByIdStr(['Contacts for ' contacts{c}], 1);
		end

		if (~isobject(es)) ; fail = 1; break ; end

		ies{c} = es;
	end

	% did an ES fail? return nothing
	if (fail) ; return ; end

  % the call to getCoincidentEventsS
  es = session.eventSeries.getCoincidentEventsS(ies, coincidentDtMax, 0,  ...
                     obj.whiskerAngleTSA.timeUnit, [], [], 2, 2); 

	% and finally repopulate trial, etc, in returned ES
  if (isobject(es))
    es.updateEventSeriesFromTrialTimes(obj.behavESA.trialTimes);
    es.sortByTime();
  end

