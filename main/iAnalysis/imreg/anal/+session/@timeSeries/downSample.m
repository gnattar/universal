%
% SP Dec 2010
%
% Downsamples the data.
%
% USAGE:
%
%  ts.downSample(method, downSampleFactor, newTime)
%
%    method: 1: mean of interval (default)
%            2: max
%            3: median
%    downSampleFactor: if provided, will use min(time):downSampleFactor:max(time) as timing vector 
%    newTime: alternatively, use the provided vector.  Takes precedence over downSampleFactor.
%
function obj = downSample(obj, method, downSampleFactor, newTime)

  % --- sanity
  if (nargin < 3)
	  disp('downSample::must provide at leaset the method & downSampleFactor');
		return;
	end
	uniformDt = 0;
  if (nargin < 4)
	  newTime = min(obj.time):downSampleFactor:max(obj.time);
		uniformDt = 1;
		dt = downSampleFactor;
	end

  % --- uniform?
	if (~uniformDt)
	  dtv = diff(newTime);
		if (range(dtv) == 0) 
		  dt = max(dtv);
			dt = dt(1);
			uniformDt = 1;
		end
	end

	% --- value determine ...
	newValue = nan*newTime;
	diffTime = diff(newTime);

  if (uniformDt) % MUCH Faster -- uniform timing vector
	  L = length(obj.time);
	  for i=1:length(newTime)
		  i1 = max(0,round((i-0.5)*dt));
		  i2 = min(L,round((i+0.5)*dt));
 
      switch method
			  case 1 % mean
					newValue(i) = nanmean(obj.value(i1:i2));
				case 2 % max
					newValue(i) = max(obj.value(i1:i2));
				case 3 % median
					newValue(i) = nanmedian(obj.value(i1:i2));
			end
		end
    

	else % MUCH slower -- nonuniform timing vector so we must bound appropriately
	  disp('downSample::your time vector is non-uniform (dt changes over newTime) ; this is REALLY slow.  Make it uniform and it will be fast.');
		newValue(1) = process(obj, min(newTime)-.001, newTime(1)+diffTime(1)/2, method);

		% for (some) speed do loops inside siwtch instead of vice versa
		switch method
			case 1
				for t=2:length(newTime)-1
					mt = newTime(t)-diffTime(t-1)/2;
					Mt = newTime(t)+diffTime(t)/2;
					idx = find(obj.time > mt & obj.time <= Mt);
					if (length(idx) > 0)
						newValue(t) = nanmean(obj.value(idx));
					end
					disp([num2str(t) ' ' num2str(length(newTime))]);
				end
			case 2
				for t=2:length(newTime)-1
					mt = newTime(t)-diffTime(t-1)/2;
					Mt = newTime(t)+diffTime(t)/2;
					idx = find(obj.time > mt & obj.time <= Mt);
					if (length(idx) > 0)
						newValue(t) = max(obj.value(idx));
					end
					disp([num2str(t) ' ' num2str(length(newTime))]);
				end
			case 3
				for t=2:length(newTime)-1
					mt = newTime(t)-diffTime(t-1)/2;
					Mt = newTime(t)+diffTime(t)/2;
					idx = find(obj.time > mt & obj.time <= Mt);
					if (length(idx) > 0)
						newValue(t) = max(obj.value(idx));
					end
					disp([num2str(t) ' ' num2str(length(newTime))]);
				end
		end

		newValue(length(newTime)) = process(obj, newTime(length(newTime))-diffTime(length(newTime)-1)/2, ...
			max(newTime), method);
  end

	% --- assign
	obj.value = newValue;
	obj.time = newTime;

%
% for efficiency ...
%
function nv = process(obj, mt, Mt, method)
	idx = find(obj.time > mt & obj.time <= Mt);
	nv = nan;

	% update ...
	if (length(idx) > 0)
		switch method
			case 1 % mean
				nv = nanmean(obj.value(idx));
			case 2 % max
				nv = max(obj.value(idx));
			case 3 % median
				nv = median(obj.value(idx));
		end
	end

