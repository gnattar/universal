%
% SP Jan 2011
%
% Resamlpe the data. First, it samples densely in a uniform manner, then pulls
%  the desired points.  Dense sampling is done with linear interpolation. This
%  makes interval pooling for downsamplign much easier for methods 1-3.
%
% USAGE:
%
%  ts.reSample(method, reSampleFactor, newTime, interpMethod)
%
%    method: 1: mean [makes sense if DOWN sampling]
%            2: max [makes sense if DOWN sampling]
%            3: median [makes sense if DOWN sampling]
%            4: sign-sensitive max (take min, max ; if abs(min) > abs(max), min)
%            100: raw -- stores raw value
%    reSampleFactor: will compute *mode* dt, and resample *uniformly* with 
%                               dt = dt*reSampleFactor
%                    Must be integral or the inverse of integer.
%    newTime: vector to use as new time; supercedes reSampleFactor.
%             A single number implies that this will be dt.
%    interpMethod: default (if not passed) is linear ; method used to do 
%                  interpolations (See code to understand)
%
function obj = reSample(obj, method, reSampleFactor, newTime, interpMethod)

  %% --- prelims
	debug = 0;
  warning('off');
	modeDt = mode(diff(obj.time));

  % reSampleFactor checks
  if (nargin < 3)
    help('session.timeSeries.reSample');
	  error('timeSeries.reSample::must provide at leaset the method & reSampleFactor');
	end

	if (nargin < 5) ; interpMethod = 'linear' ; end

  % resample factor present?
	if (length(reSampleFactor) == 0  | reSampleFactor == 0)
	  reSampleFactor = 1;
	end

	% check that it is integral
	if ( (reSampleFactor >= 1 & reSampleFactor ~= round(reSampleFactor)) || ...
	     (reSampleFactor < 1 & 1/reSampleFactor ~= round(1/reSampleFactor)))
	  help('session.timeSeries.reSample');
  	error('timeSeries.reSample::reSampleFactor must be an integer or an inverse thereof.');
	end

	% newTime checks -- assign if not passed
  if (nargin < 4)
	  newTime = min(obj.time):modeDt*reSampleFactor:max(obj.time);
	elseif(length(newTime) == 1)  % single value
	  newTime = min(obj.time):newTime*reSampleFactor:max(obj.time);
	end
  windowSize = 0.5*mode(diff(newTime))/modeDt;
  

	disp(['timeSeries.reSample::processing ' obj.idStr]);

  % nan time check -- ELIMINATE these times
	nantime = find(isnan(obj.time));
	if (length(nantime) > 0)
	  disp(['timeSeries.reSample::found ' num2str(length(nantime)) ' NaN time values ; these will be REMOVED.']);
		val = find(~isnan(obj.time));
		obj.time = obj.time(val);
		obj.value = obj.value(val);
	end

	% duplicate time check for ORIGNAL times -- ELIMINATE these times!
	Lt = length(obj.time);
	Lut = length(unique(obj.time));
	if (Lt ~= Lut)
	  disp(['timeSeries.reSample::found ' num2str(Lt-Lut) ' repeated time values ; these will be REMOVED.']);
		[uTime uTimeIdx irr] = unique(obj.time);
		obj.time = uTime;
		obj.value = obj.value(uTimeIdx);
	end
 
  % duplicate time check for NEW times
	Lnt = length(newTime);
	Lunt = length(unique(newTime));
	if (Lnt ~= Lunt)
	  disp(['timeSeries.reSample::found ' num2str(Lnt-Lunt) ' repeated NEW time values ; these will be REMOVED.']);
		newTime = unique(newTime);
  end
  
  % check if there are any unusually close newTime time points ; take first
  removedNewTime = 0*newTime;
  for ni=1:length(newTime)-1
    if (~removedNewTime(ni) && newTime(ni+1)-newTime(ni) < mode(diff(newTime))/2)
      removedNewTime(ni+1) = 1;
    end
  end
  removedNewTime = find(removedNewTime);
  keptNewTime = setdiff(1:length(newTime), removedNewTime);
  oNewTime = newTime;
  newTime = newTime(keptNewTime);



  %% --- raw
	if (method == 100)
		newValue = interp1(obj.time, obj.value, newTime,interpMethod, nan); % fill ends with NaN
  %% ---dense-resampling dependent
	elseif (method == 1 | method == 2 | method == 3 | method == 4)
    %% --- generate dense uniform data using modal dt

    % some preliminary values we use
 		dOtime = diff(obj.time);
    
    % check for jumps > 5% of eventual span -- skip em
    ntSpan = max(obj.time)-min(obj.time);
    bigJumps = find(dOtime > 0.05*ntSpan & dOtime > 10*windowSize);
    if (length(bigJumps) >0 )
      disp('session.timeSeries.reSample::rare large temporal jumps detected ; omitting these for speed.');
    end
    
    % generate uniform vectors
%      unifTime = min(obj.time):modeDt:max(obj.time);
    if (length(bigJumps) == 0)
      unifTime = min(obj.time):modeDt:max(obj.time);
    else
      dtJump = 10*windowSize;
      bigJumps = [bigJumps length(obj.time)];
      % here we generate unifTime segment-by-segment
      unifTime = min(obj.time):modeDt:obj.time(bigJumps(1))+dtJump;
      for ji=2:length(bigJumps)
        unifTime = [unifTime (obj.time(bigJumps(ji-1)+1)-dtJump):modeDt:(obj.time(bigJumps(ji))+dtJump)];
      end
    end  
		unifValue = interp1(obj.time, obj.value, unifTime,interpMethod);

    % find where the change > modeDt, so values for UNIFORM dt vector will be nan
    otBigDtIdx = find(dOtime > modeDt);
    unifNan = 0*unifTime;
    for b=1:length(otBigDtIdx) % this is slower than old loop BUT so much less to do that its okay
      ot1 = obj.time(otBigDtIdx(b));
      ot2 = obj.time(otBigDtIdx(b)+1);
      ut1 = min(find(unifTime >= ot1));
      ut2 = min(find(unifTime >= ot2));
      unifNan(ut1:ut2) = 1;
    end
% OLD:
%     otBigDtIdx = find(dOtime > modeDt);
% 		unifNan = 0*unifTime;
%     ut1 = unifTime(1);
% 		for b=1:length(otBigDtIdx)
% 		  startNanIdx = ((obj.time(otBigDtIdx(b))-ut1)/modeDt)+1;
% 		  endNanIdx = ((obj.time(otBigDtIdx(b)+1)-ut1)/modeDt)-1;
%       if (startNanIdx < endNanIdx)
% 			  unifNan(startNanIdx:endNanIdx) = 1;
% 			end
% 		end
		% assign nan where it should be assigned -- where time point on obj.time is > modeDt away
		unifValue(find(unifNan)) = nan;

		% debug plot
		if (debug) % plots uniform resampling
			figure;
			plot(obj.time,obj.value,'b-');
			hold on ;
			plot(obj.time,obj.value,'bo');
			plot(unifTime,unifValue,'go', 'MarkerFaceColor','g');
			title(obj.idStr);

			% make true to show nan
			if (0)
				nU = find(isnan(unifValue));
				nO = find(isnan(obj.value))';
				plot(unifTime(nU),zeros(1,length(nU)),'kx');
				plot(obj.time(nO),zeros(1,length(nO)),'ko');
			end
		end

		%% --- value determine ...
		newValue = nan*newTime;
		nanTF = isnan(unifValue);
		L = length(unifTime);

		% try to do this using intersection of renormalized timing vectors --
		%  divide both by modeDt, then intersect the resulting vectors.  This
		%  gives you an easy indexing basis for fast assignment
		umt = round(unifTime/modeDt);
		nmt = round(newTime/modeDt);
		imt = intersect(nmt,umt);
	  uImtIdx = find(ismember(umt, imt));
	  nImtIdx = find(ismember(nmt, imt));
	
    % cutoff is 97.5% overlap (we discard the rest for SPEED YO!)
		if ( ((length(nmt) - length(imt))/length(nmt)) < 0.025)
		  for i=1:length(imt)
			  icen = uImtIdx(i);
				i1 = max(1,round(icen-windowSize));
				i2 = min(L,round(icen+windowSize));
		 
				 switch method
					case 1 % mean
						newValue(nImtIdx(i)) = nanmean(unifValue(i1:i2));
					case 2 % max
						if(sum(nanTF(i1:i2)) < length(i1:i2))
							newValue(nImtIdx(i)) = nanmax(unifValue(i1:i2));
						end
					case 3 % median
						newValue(nImtIdx(i)) = nanmedian(unifValue(i1:i2));
					case 4 % max by sign
						if(sum(nanTF(i1:i2)) < length(i1:i2))
							nM = nanmax(unifValue(i1:i2));
							nm = nanmin(unifValue(i1:i2));
							if (abs(nm) > abs(nM))
  							newValue(nImtIdx(i)) = nm;
							else
  							newValue(nImtIdx(i)) = nM;
							end
						end
				end
			end


		else
		  disp('timeSeries.reSample::too much nonunformity in timing vector ; slow approach.');
			% if this fails, for each newTime (the timing vector that is output), find
			%  the match in uniform timing vector -- this is slower than above method.
			for i=1:length(newTime)
				[irr icen] = min(abs(unifTime-newTime(i)));
				i1 = max(1,round(icen-windowSize));
				i2 = min(L,round(icen+windowSize));
	%disp([num2str(i) '/' num2str(length(newTime))]);
		 
				 switch method
					case 1 % mean
						newValue(i) = nanmean(unifValue(i1:i2));
					case 2 % max
						if(sum(nanTF(i1:i2)) < length(i1:i2))
							newValue(i) = nanmax(unifValue(i1:i2));
						end
					case 3 % median
						newValue(i) = nanmedian(unifValue(i1:i2));
					case 4 % max by sign
						if(sum(nanTF(i1:i2)) < length(i1:i2))
							nM = nanmax(unifValue(i1:i2));
							nm = nanmin(unifValue(i1:i2));
							if (abs(nm) > abs(nM))
  							newValue(i) = nm;
							else
  							newValue(i) = nM;
							end
						end
				end
			end
		end
  end

  %% --- final assignment
  % reinsert excised too-dense points that break interpolation
  if (length(removedNewTime) > 0)
    disp('session.timeSeries.reSample::unusually small dt detected (less than half of modal dt) ; these points were nan''d to avoid breaking interpolation.');
    newTime = oNewTime;
    nnewValue = nan*newTime;
    nnewValue(keptNewTime) = newValue;
    newValue = nnewValue;
  end
  
	% find where the change > modeDt, so you should nan since datapoitns too sparse
	dOtime = diff(obj.time);
	otBigDtIdx = find(dOtime > modeDt);
	newNan = 0*newTime;
	for b=1:length(otBigDtIdx)
		startNanIdx = min(find(newTime > obj.time(otBigDtIdx(b))+modeDt));
		endNanIdx = max(find(newTime < obj.time(otBigDtIdx(b)+1)+modeDt));
		if (startNanIdx < endNanIdx)
			newNan(startNanIdx:endNanIdx) = 1;
		end
	end
	% start and end ...
	newNan(find(newTime < min(obj.time))) = 1;
	newNan(find(newTime > max(obj.time))) = 1;
	newValue(find(newNan)) = nan;	

  % plot results if needbe
	if (debug)
	  figure;
		plot(obj.time,obj.value,'b-');
		hold on;
		plot(obj.time,obj.value,'bo');
		plot(newTime,newValue,'rx');
		title(obj.idStr);
	end

	%% --- and assign
	obj.time = newTime;
	obj.value = newValue;
