%
% S Peron Apr 2010
%
% For use with session ; this will take a single timeseries, specified by 
%  tsi, and concatenate its value vectors into one large vector.  It will
%  also return a corresponding time vector.
%
% USAGE:
%  function [vvec tvec] = generate_single_timeseries_vector_from_trials(idx, mndp)
% 
% vvec, tvec: values and times vectors
% tivec: gives trial index that corresponds to vvec/tvec
%
% tsi: time series to use
% mndp: max # of data points to collect - in case of unusually large arrays; blank or 0
%       implies no bound
% vclass: restrict to trials of this class type
% time_range: restrict to this time range within each trial
% 
function [vvec tvec tivec] = generate_single_timeseries_vector_from_trials(tsi, mndp, vclass, time_range)
  global glospvars;

  % --- prelims
	T = 1:length(glospvars.session.trial);
	if (nargin == 1)
	  mndp = 0;
		time_range = [];
	elseif (nargin == 2)
		time_range = [];
	elseif (nargin > 2)
	  for t=T
		  tclass(t) = glospvars.session.trial(t).class;
		end
		T = [];
		for c=1:length(vclass)
			T = [T find(tclass == vclass(c))];
		end
	end

	% --- determine how big your vector will be ...
	dt = glospvars.session.trial(1).timeseries(tsi).dt; % dt; ASSUMES first trial same as rest
	dt = dt/1000/60; % ASSUMES dt is in s ; convert to ms
	len_data = 0;
	for t=T
	  if (length(time_range) == 0)
			len_data = len_data + length(glospvars.session.trial(t).timeseries(tsi).values);
		else
		  t_tvec = glospvars.session.trial(t).timeseries(tsi).time;
			L = length(find(t_tvec >= time_range(1)  & t_tvec <= time_range(2)));
		  len_data =  len_data + L;
		end
		if (mndp > 0 & len_data > mndp) 
			disp(['Cannot exceed ' num2str(mndp) ' data points ; truncating.']);
			break;
		end
	end

	% --- make your vectors
	vvec = zeros(1,len_data);
	tivec = zeros(1,len_data);
	tvec = 0:dt:dt*(len_data-1);
	ci = 1;
	for t=T
		if (length(time_range) == 0)
			sub_vec = glospvars.session.trial(t).timeseries(tsi).values;
		else
			t_tvec = glospvars.session.trial(t).timeseries(tsi).time;
			idx = find(t_tvec >= time_range(1)  & t_tvec <= time_range(2));
			sub_vec = glospvars.session.trial(t).timeseries(tsi).values(idx);
		end
		st = glospvars.session.trial(t).start_time/1000/60; % in minutes
		tvec(ci:ci+length(sub_vec)-1) = st:dt:st+dt*(length(sub_vec)-1);
		vvec(ci:ci+length(sub_vec)-1) = sub_vec;
		tivec(ci:ci+length(sub_vec)-1) = t;
		ci = ci + length(sub_vec);
	end
