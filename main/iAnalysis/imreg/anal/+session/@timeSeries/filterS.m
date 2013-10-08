%
% General fiter scheme containing several filters for time series (or arrays).
%
% USAGE:
%
%   newValueMatrix = session.timeSeries.filterS(time, valueMatrix, params)
%
% ARGUMENTS:
%
%   time: time vector
%   valueMatrix: can be either a vector or a matrix in which case each row is
%                same length as time.
%   params: a structure with all kinds of (potential) fields:
%     params.timeUnit: time unit of "time" variable
%     params.filterType: what kind of filter to apply?
%                        'quantile': will return specified quantile within window
%     params.filterSizeSeconds: in units of SECONDS
%     params.quantileThresh: default is 0.2th quantile ; if passed, pass one
%                            per row of valueMatrix (or 1 for all rows)
%
% RETURNS:
%
%   newValueMatrix: The filtered valueMatrix
%
% (C) 2012 Jul S Peron
%
function newValueMatrix = filterS(time, valueMatrix, params)

  %% --- input parsing
	if (nargin < 3)
	  help('session.timeSeries.filterS');
		error('Must pass all arguments');
	end
	quantileThresh = 0.2;
	
	eval(assign_vars_from_struct(params,'params'));

	% flip valueMatrix? ensure row-wise operation
	if (size(valueMatrix,2) == 1) ; valueMatrix = valueMatrix' ; end

	newValueMatrix = nan*valueMatrix;
  nRows = size(valueMatrix,1);

	%% --- global prelims, then main switch

  % time-sensitive variables
	dtime = diff(time);
	dt = mode(dtime);
	filterSize = session.timeSeries.convertTime(filterSizeSeconds, session.timeSeries.second, timeUnit);

	% create a filltime vector that fills large jumps in time with dtMS spaced timepoints
	bdti = find(dtime > dt);
	bigdt = dtime(bdti) - dt; % don't include last one
	i1=1;
	fillTimes = zeros(1,ceil(sum(bigdt)/dt));
	for i=1:length(bigdt)
		ntime = dt+time(bdti(i)):dt:bigdt(i)+time(bdti(i));
		i2 = length(ntime) + i1 - 1;
		fillTimes(i1:i2) = ntime;
		i1 = i2 + 1;
	end
	filledTime = sort(union(time,fillTimes)); % a time vector that is temporally dense -- no time points more than dt apart
	oTimeIdx = find(ismember(filledTime, time)); % indices of filledTime that are also in time -- i.e., in actual data

  % convenience
	fs = round(filterSize/dt);
	fs2 = ceil(fs/2);

	switch filterType
  	%% --- quantile
		case 'quantile'
      if (length(quantileThresh) < nRows)
			  quantileThresh = zeros(1,nRows) + quantileThresh;
			end
 
      disp('session.timeSeries.filterS::quantile estimation is slow ; be patient');

      % main loop
			for r=1:nRows
			  % generate filled vector with nans
				tmpVec = nan*filledTime;
				tmpVec(oTimeIdx) = valueMatrix(r,:);
				
        vidx = find(~isnan(valueMatrix(r,:)));
        if (length(vidx) > 0)
          if (quantileThresh(r) == 0.5) % median
            % filter
            tmpVec = nanmedfilt1(tmpVec,fs);
          else
            % filter initially to get rid of high freq components
            preVec = nanmedfilt1(tmpVec,7);
            L = max(oTimeIdx);

            % do quantile estimation
            for i=1:length(oTimeIdx)
              tmpVec(oTimeIdx(i)) = quantile(preVec(max(1,oTimeIdx(i)-fs2):min(L,oTimeIdx(i)+fs2)),quantileThresh(r));
            end
          end

					% reconvert to undense 
					newValueMatrix(r,vidx) = tmpVec(oTimeIdx(vidx));
        end
				disp([8 '.']);
  		end

		otherwise
		  disp(['session.timeSeries.filterS:: ' filterType ' is not a recognized filter ; doing nothing.']);
      newValueMatrix = valueMatrix;
		  
	end
