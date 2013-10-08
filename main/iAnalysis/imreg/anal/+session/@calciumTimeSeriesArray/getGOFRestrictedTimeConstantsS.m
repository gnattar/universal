%
% SP Apr 2011
%
% This will compute a goodness-of-fit restricted time constant for decay.  Rise
%  times are simply returned as nan's since the technically correct thing is a 
%  double exponential in this context and that is far too computationally costly
%  for something we don't really care about (yet!).  Rejected taus are returned as
%   NEGATIVE decayTimes.
%
%  USAGE:
%
%   function [riseTimes decayTimes] = getGOFRestrictedTimeConstantsS( ...
%         peakTimes, valueMatrix, timeVec, timeUnit)
%
%  PARAMS:
%
%   riseTimes: cell array of vectors with rise times; for now, simply NaN
%   decayTimes: the key stuff ; again, cell array of vectors.  Note that ALL the 
%     xxTimes cell arrays should be the same size and their constituent vectors
%     also need to be the same size.  Returned data holds to this.  Bad decay 
%     time constants (not meeting GOF criteria) are set to negative.
%
%   peakTimes: peak times of events, from which decays are measured
%   valueMatrix: as in all timeSEriesArrays 
%   timeVec: vector of times for valueMatrix
%   timeUnit: time unit for timeVec, and all other things; decayTimes
%             returned in this unit.
%
function [riseTimes decayTimes] = getGOFRestrictedTimeConstantsS(peakTimes, valueMatrix, timeVec, timeUnit)

  % params
	guess = 1000; % 1 s
	lb = 100; % 100 ms lb
	ub = 20000; % 20 s ub

	% convert to ms ; compute dt
	timeVec = session.timeSeries.convertTime(timeVec, timeUnit, 1);
	dt = mode(diff(timeVec));

	% threshold = 1 sd (gof is in units of RMSE)
	linVec = reshape(valueMatrix, [],1);
	valueSD = 1.4826*mad(linVec);

	% verify sorted timevec
	if (~issorted(timeVec))
	  disp('getGOFRestrictedTimeConstantsS::timeVec is not sorted.  Fix this.');
		return;
	end
	gofThresh = 0.5*valueSD;
%gofThresh = 4*valueSD
  % loop thru rois
  for r=1:size(valueMatrix,1)
		% assign defaults
		riseTimes{r} = nan*peakTimes{r};
		decayTimes{r} = nan*peakTimes{r};

    % verify sort
		if (~issorted(peakTimes{r}))
		  disp('getGOFRestrictedTimeConstantsS::peakTimes not sorted; skipping.');
			continue ; 
		end

		peakIdx = 0*peakTimes{r};
    for i=1:length(peakTimes{r})
		  peakIdx(i) = find(timeVec == peakTimes{r}(i));
		end

		% get decay tau for events
		[tau gofLast] = getTaus(valueMatrix(r,:), peakIdx, guess, lb, ub, dt);

		% apply GOF thresh 
		acc = find (gofLast <= gofThresh);
		acc = intersect(acc, find (tau > 250 & tau < 15000)); 
		rej = find (gofLast > gofThresh);
		rej  = intersect(rej, find (tau > 250 & tau < 15000)); 
%disp(['accepting: ' num2str(length(acc)) ' rejecting: ' num2str(length(rej))]);
		% get indexing of vals
		acceptIdx = find(ismember(peakTimes{r}, timeVec(peakIdx(acc))));
		rejectIdx = find(ismember(peakTimes{r}, timeVec(peakIdx(rej))));
		accept = find(ismember(timeVec(peakIdx), peakTimes{r}(acceptIdx)));
		reject = find(ismember(timeVec(peakIdx), peakTimes{r}(rejectIdx)));
		
		% assign output ... only ones that met criteria
		tau = session.timeSeries.convertTime(tau,1, timeUnit);
		decayTimes{r}(acceptIdx) = tau(accept);
		decayTimes{r}(rejectIdx) = -1*tau(reject); % -1 for rejections
	end


%
% Gets taus, goodness-of-fit (square distance) -- you can then use GOF to restrict
%  which of the taus you actually use.  Goodness-of-fit is measured in terms of RMSE
%  averaged across time points.  Note that to make it more sensible for *decay*, it
%  is measured only out to 5*tau time points (that is, the "tail" is not given
%  weight).
%
%  vec: single ROI's vector
%  peakIdx: indices of transient peaks
%  guessTau: one value ; guess value in units of dt
%  lb, ubTau: lower and upper bounds in units of dt for tau
%  dt: interpoint dt (unit of this determines unit of tau, etc.)
%
function [eventTau gof] = getTaus(vec, peakIdx, guessTau, lbTau, ubTau, dt)
  
	% how many ms do you want to fit GOF over following the event?  Based on the distribution
	%  of time constants, select ~5 x the mean tau.  One could in principle do this based on
	%  estimated time constant but that would bias the method to erroneous time constants -- e.g.,
	%  very short or very long.
	gofWindowMs = 2500;
	
	debug = 0;

	eventTau = nan*zeros(1,length(peakIdx));
	gof = nan*zeros(1,length(peakIdx));
	tauOpts = optimset('display','off');

	if (debug) ; f=figure ;end
	for s=1:length(peakIdx)
		% range to fit
		tauFitSi = peakIdx(s);
		tauFitEi = min(50+peakIdx(s), length(vec));
		if(s < length(peakIdx)) 
			tauFitEi = min(tauFitEi, peakIdx(s+1));
		end

		% make the vector for fitting
		tauVec = vec(tauFitSi:tauFitEi);

		% at least 20 time points to fit
		if (length(tauVec) < 20) ; continue ; end

		L2 = floor(length(tauVec)/2);
		L = length(tauVec);
		tauVec = tauVec - mean(tauVec(L2:L)); % to 0

		% is this tau fittable? otherwise -1 -- 20 points, not too big @ end
		if (tauVec(1) < 5*tauVec(length(tauVec)) | length(tauVec) < 20)
			if(debug) ; disp(['Skipping tau ' num2str(s) ' because not enuff to fit']); end
			continue;
		end

		if (length(find(isnan(tauVec))) + length(find(isinf(tauVec))) > 0)
			if(debug) ; disp(['Skipping tau ' num2str(s) ' because isnan/isinf']); end
		  continue ;
		end

		% get a REAL time vector
		timeVec = dt*(0:length(tauVec)-1);
		
		% the fit: x(1)*exp(-t/x(2)) + x(3) -- x(1): scaling factor ; x(2): tau ; (3): offset
    lb = [0.25*max(tauVec) lbTau -2];
    ub = [4*max(tauVec) ubTau 2];
    if (sum(lb == ub)  > 0) ; continue ; end
		guess = [1 guessTau 0];
		fitVals = lsqcurvefit(@tauFunLoc, guess, timeVec, tauVec, lb, ub, tauOpts);
		eventTau(s) = fitVals(2);
		tauF = fitVals(1)*exp(-1*timeVec/eventTau(s))+fitVals(3);

% normalize to peak?
%tauF = tauF/max(tauF);
%tauVec = tauVec/max(tauVec);

		% how many time points to use for GOF? 
    nGOFpts = max(find(timeVec < gofWindowMs)); % how many ms do we use for GOF?
%    nGOFpts = max(find(timeVec < 5*eventTau(s))); % ensures we don't exceed timeVec len
		if (nGOFpts == 0) % something went awry ...
		  nGOFpts = 1;
			gof(s) = inf;
		else
			% calculate GOF
			gof(s) = mean(sqrt((tauF(1:nGOFpts)-tauVec(1:nGOFpts)).^2));
		end

		% plot?
		if (debug)
		  figure(f);
			hold off;
			plot(timeVec,tauVec, 'k-');
			hold on;
			plot(timeVec,tauF, 'r-');
			text (2*max(timeVec)/5, 3*tauF(1)/5, ['tau: ' num2str(eventTau(s)) ' gof: ' num2str(gof(s))]);
			xlabel('time (ms)');
			ylabel('dF/F');
			set(gca,'TickDir','out');
			pause;
		end
	end

	if (debug) % GOF vs tau
	  figure;
    plot(eventTau, gof, 'ko', 'MarkerFaceColor', [0 0 0]);
		pause;
  end


%
% fitting function for exponential
%
function val = tauFunLoc(x,xdata)
  % val = exp(-1*xdata/x(1));
  val = x(1)*exp(-1*xdata/x(2))+x(3);

