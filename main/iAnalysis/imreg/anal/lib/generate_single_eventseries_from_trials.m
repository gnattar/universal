%
% S Peron Apr 2010
%
% For use with session ; this will take a single eventseries, specified by 
%  esi, and make one large time vector, where 0 is start of first trial.
%  If psi is speified, eventseries(esi).params(psi) is returned in pvec; 
%  otherwise, pvec is returned blank.
%
% USAGE:
%  function [pvec tvec tivec] = generate_single_eventseries_vector_from_trials(esi, psi)
% 
% pvec, tvec: params and time vectors ; params usually stores some amplitude
% tivec: trial index vector, corresponding to tvec, pvec, telling you what trial
%        each instance was in
%
% esi: time series to use
% psi: params to use ; set to 0 to NOT use it
% 
function [pvec tvec tivec] = generate_single_eventseries_from_trials(esi, psi)
  global glospvars;

  % --- prelims

	% --- determine how big your vector will be ...
	len_data = 0;
	for t=1:length(glospvars.session.trial)
		len_data = len_data + length(glospvars.session.trial(t).eventseries(esi).time);
	end

	% --- make your vectors
	tvec = zeros(1,len_data);
	pvec = zeros(1,len_data);
	tivec = zeros(1,len_data);
	ci = 1;
	for t=1:length(glospvars.session.trial)
		st = glospvars.session.trial(t).start_time; % start time for offsets
	  for e=1:length(glospvars.session.trial(t).eventseries(esi).time);
      tvec(ci) = st+glospvars.session.trial(t).eventseries(esi).time(e);
      tivec(ci) = t;
			if (psi)
			  if (length(glospvars.session.trial(t).eventseries(esi).params(psi).value) == 0)
					pvec(ci) = [];
				else 
					pvec(ci) = glospvars.session.trial(t).eventseries(esi).params(psi).value(e);
				end
			end
			ci = ci+1;
		end
	end

	if (~ psi)
	  pvec = [];
	end
