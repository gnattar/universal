%
% Will build a calciumEventSeries object by running an exponential template.
%
% This will run an event detection scheme that permits variable decay time 
%  constants as well as rise time.  It will report the rise time, decay time,
%  peak time, and peak amplitude (though NOT event length) for each event.  
%  Event time is registered as event START, not peak.  
%
%  The algorithm consists of two parts.  First, there is the thresholding 
%  that looks at the diff trace of the timeSeries and looks for large changes
%  that exceed a passed noise paramter.  Each of those is then tested by the
%  second part, which is the template fitter.  The algorithm moves forward in
%  time along the trace, and if the match to the template is good enough (the
%  criteria is that the transient, on average, exceeds noise in amplitude),
%  the cleaned up transient is "peeled" from the rest of trace, and the process
%  continues. 
%
%  This two step process (can/is?) be iterated.
%
% USAGE:
%
%  caES = session.timeSeries.getCalciumEventSeriesFromExponentialTemplateS (time, valueMatrix, params)
%
% ARGUMENTS:
%
%  time: vector with time
%  valueMatrix: each row is a signal that is processed
%
%  params: structure with a bunch of fields
%
%  params.timeUnit: time unit of time vector above
%
%  params.debug: to show a bunch of stuff.
%
%  params.nParams: structure that is passed to computeNoiseS (see for details) 
%                  to calculate signal noise ; see below for defaults.
% 
%  params.initThreshSF: the noise is in terms of SD for the initial step ; then,
%                       any diff > noise*this value will be tried.  Most get \
%                       rejected.  This is a 3 element vector, with (1) being 
%                       hyperactive, (2) for active, and (3) for the other cells
%  params.hyperActiveIdx: which rows in valueMatrix are hyperactive cells?
%  params.activeIdx: which rows in valueMatrix are active cells?
%
%  params.templateFitSF: if the mean amplitude of a (fitted) event is NOT > 
%                        templateFitSF*noise, it is rejected ; default 1.
%
%  params.tausInDt: taus tested, in multiples of dt (e.g., if dt for your time
%                   signal is 100 ms, and you make this [3 4 5], it will test 
%                   300, 400 and 500 ms.
%  params.tRiseInDt: time-to-peaks tested, in multiples of dt again.
%
%  params.minFitRawCorr: minimal correlation between "model" trace and the 
%                        actual data ; default 0.5.  0 disables.
%  params.fitResidualSDThresh: if the mean fit residual exceeds the noise 
%                              estimate by this multiple, then trace is 
%                              rejected ; default 2.  Inf disables.
%
% RETURNS:
%
%  caES: cell array of calciumEventSeries objects
%
% (C) Jul 2012 S Peron   
%
function caES = getCalciumEventSeriesFromExponentialTemplateS (time, valueMatrix, params)

  %% --- process inputs // defaults
  if (nargin < 3)
	  help('session.timeSeries.getCalciumEventSeriesFromExponentialTemplateS');
		error('Must pass all 3 input arguments');
	end

	caES = {};

  % defaults
	nParams.debug = 0;
	nParams.method = 'hfMADn';
	nParams.prefiltSizeInSeconds = 1;

  tausInDt = 3:20;
	tRiseInDt = 0:5;
	debug = 0;

	minFitRawCorr = 0.5;
	fitResidualSDThresh = 2;
  
	initThreshSF = [1.5 2 2.5]; % first # is for hyperactive, 2 for active, 3 for inactive ; good for 641 ; [2 3 4] better for 354
	templateFitSF = 1;
  
	% params struct pull
	requiredVars = {'timeUnit','hyperactiveIdx','activeIdx'};
 	eval(assign_vars_from_struct(params,'params', requiredVars));

	nParams.timeUnit = timeUnit;

	%% --- prep steps

	% get noise stats (in SD)
	noise = 1.4826*session.timeSeries.computeNoiseS(time, valueMatrix, nParams);

  % some random vars you'll need
	nVecs = size(valueMatrix,1); % matrix sizing
	candidateNoiseThresh = noise*initThreshSF(3); % noise threshold based on cell class ...
	candidateNoiseThresh(activeIdx) = noise(activeIdx)*initThreshSF(2);
	candidateNoiseThresh(hyperactiveIdx) = noise(hyperactiveIdx)*initThreshSF(1);

  tRiseNZ = setdiff(tRiseInDt,0);

	dt = mode(diff(time));

	% the template library
  taus = zeros(length(tausInDt)*length(tRiseInDt),1);
  tRises = zeros(length(tausInDt)*length(tRiseInDt),1);

	tempLibMat = nan*zeros(length(tausInDt)*length(tRiseInDt), 5*max(tausInDt) + max(tRiseInDt));
	templatePeakIdx = max(tRiseInDt)+1;
  if (templatePeakIdx <= 1) ; error ('getCalciumEventSeriesFromExponentialTemplateS::template peak idx must at LEAST be 2, so you have to have minimal tRise of 1.'); end

  ti = 1;
	for t=1:length(tausInDt)
	  for r=1:length(tRiseInDt)
			nDec = 5*(tausInDt(t));
		  tempLibMat(ti,templatePeakIdx-tRiseInDt(r):templatePeakIdx+nDec-1) = ...
			  [linspace(0,1,tRiseInDt(r)+1) exp(-1*(2:nDec)/tausInDt(t))];
      taus(ti) = tausInDt(t);
      tRises(ti) = tRiseInDt(r);
	    ti = ti+1;
    end
  end
  
  % other template library parameters we precompute for speed
  ts = size(tempLibMat,1);
  nPre(ts) = 0;
  tOffs(ts) = 0;
  L(ts) = 0; 
 	for t=1:ts
    nPre(t) = templatePeakIdx-min(find(~isnan(tempLibMat(t,:))));
    tOffs(t) = templatePeakIdx-nPre(t)-1;
		L(t) = length(find(~isnan(tempLibMat(t,:))));
  end
  
  %% --- master loop
  for v=1:nVecs
    disp(['getCalciumEventSeriesFromExponentialTemplateS::processing ' num2str(v) ' of ' num2str(nVecs)]);
    
		% step 1: get candidates
		candiIdx = getCandidateEvents(valueMatrix(v,:), candidateNoiseThresh(v), tRiseNZ);
		
		% step 2: template fitting
		[startIdx peakIdx peakAmp tau tRise tempLibIdx] = fitVecUsingTemplate(valueMatrix(v,:), ...
		   templateFitSF*noise(v), candiIdx, tempLibMat, templatePeakIdx, taus, tRises, nPre, ...
       tOffs, L);

    % some error metrics: correlation as well as mean error ; you can set 
		%  threshold criteria for both
    fvec = buildFitVector(valueMatrix(v,:), tempLibIdx, tempLibMat, templatePeakIdx, peakIdx, peakAmp, tau, tRise);

		% first correlation
		val = find(~isnan(valueMatrix(v,:)) & ~isnan(fvec));
		if (length(val) > 0)
			fitRawCorr = corr(valueMatrix(v,val)',fvec(val)');
		else
		  fitRawCorr = nan;
		end

		% now error
		meanResidual = mean(abs(valueMatrix(v,val)-fvec(val)));

		% apply rejection criteria ...
		reject = 0;
		if (fitRawCorr < minFitRawCorr)
		  disp(['getCalciumEventSeriesFromExponentialTemplateS::Rejecting trace based on correlation criteria.']);
			reject = 1;
		elseif (meanResidual > noise(v)*fitResidualSDThresh)
		  disp(['getCalciumEventSeriesFromExponentialTemplateS::Rejecting trace based on noise SD criteria:']);
		  disp(['  mean residual: ' num2str(meanResidual) ' base noise: ' num2str(noise(v)) ' noise SF: ' num2str(fitResidualSDThresh)]);
			reject = 1;
    end

    % go ahead and plot if debug is on
		if (debug) 
		  disp(['Correlation: ' num2str(fitRawCorr) ' Mean fit residual: ' num2str(meanResidual)]);
		  cla;
			plot(valueMatrix(v,:),'k-');
			hold on;
			plot(fvec,'r-');

			plot(candiIdx,valueMatrix(v,candiIdx), 'ro', 'MarkerFaceColor','r','MarkerSize',3);
			plot(peakIdx,valueMatrix(v,peakIdx), 'bo', 'MarkerFaceColor','b','MarkerSize',7);
			M = nanmax(valueMatrix(v,:));
			m = nanmin(valueMatrix(v,:));
			residVec = valueMatrix(v,:)-fvec;
			plot(residVec-ceil(M),'b-');

      axis([0 length(fvec) floor(m)-M M+1]);

			pause;
		end

		%% --- build the object
		if (reject) % reject ?
			peakIdx = [];
			startIdx = [];
			tau = [];
			tRise = [];
			peakAmp = [];
		end

    peakTimes = time(peakIdx);
		startTimes = time(startIdx);
		endTimes = [];
		decayTimes = tau*dt;
		riseTimes = tRise*dt;
		caES{v} = session.calciumEventSeries(startTimes, [], peakTimes, endTimes, ...
			      decayTimes, riseTimes, peakAmp, ...
		        timeUnit, v, '', 0, 'generated by getCalciumEventSeriesFromExponentialTemplateS');
	end

%
% Returns the indices at which events will be template-evaluated
%
function candiIdx = getCandidateEvents(vec, noiseThresh, tRise)
  % prefilter the trace (remove low-freq)
	ks = 20;
	kern = ones(1,ks);
	kern = kern/sum(kern) ; % normalize the kernel
	svec = conv(vec,kern,'same');
	cvec = vec-svec;

  % for several step sizes (tRise determined), build diff vectors - that is,
	%  see how much trace went up in 1, 2, and so on timesteps.  Then, you
	%  look for rises that exceed the threshold.  These will be your initial
	%  guess points
	dMat = zeros(length(tRise),length(cvec));
	candiIdx = [];
	for r=tRise
		cvec1 = cvec(1:end-r);
		cvec2 = cvec(r+1:end);

		dCvec = cvec2-cvec1;
		dMat(r,r+1:end) = dCvec;

		candiIdx = union(candiIdx,find(dMat(r,:) > noiseThresh));
  end

  % out of these, only keep those where preceding is rise, following is
  % drop
  dvec=diff(cvec);
  keepIdx = 0*candiIdx;
  if (length(keepIdx) > 0)
    keepIdx(1) = 1; 
    keepIdx(end) = 1;
    for p=2:length(candiIdx)-1
      if (dvec(candiIdx(p)-1) > 0 && dvec(candiIdx(p)) < 0)
        keepIdx(p) = 1;
      end
    end
  end
  candiIdx = candiIdx(find(keepIdx));
  
	% now handle points where there are several in a row ; take the one for 
	%  which the amplitude of the signal vector is the largest in such a case.
	pvec = 0*vec;
	pvec(candiIdx) = 1;
	pvec = bwlabel(pvec);
	up = unique(pvec);
	for p=1:length(up)
		pp = find(pvec == up(p));
		if (length(pp) > 1)
			[irr pmaxIdx] = max(vec(pp));
			pmaxIdx = pp(pmaxIdx);
			removeIdx = setdiff(pp,pmaxIdx);
			candiIdx = setdiff(candiIdx,removeIdx);
		end
	end

%
% performs the template matching and returns fits for a full single vector
%
function [startIdx peakIdx peakAmp tau tRise tempLibIdx] = fitVecUsingTemplate(vec, ...
    noise, evIdx, tempLibMat, templatePeakIdx, taus, tRises, nPre, tOffs, L)

  % prepare some things for speed
  startIdx = nan*vec;
	peakIdx = nan*vec;
  peakAmp = nan*vec;
	tau = nan*vec;
	tRise = nan*vec;
	tempLibIdx = nan*vec;
  nVal = 0;

  maxL = length(vec) - evIdx;
 
  % while loop thru the events
	for ei=1:length(evIdx)

		% call the single-point fitter
    [bestTemplateIdx residual] = fitSingleEventUsingTemplate(vec, evIdx(ei), ...
      tempLibMat, templatePeakIdx, nPre, tOffs, L, taus);

    % measure the error of the best single fit result
		nRemovedPostAndPeak = min(maxL(ei),5*taus(bestTemplateIdx));
    nRemovedPrePeak = min(evIdx(ei), tRises(bestTemplateIdx));

    i1 = evIdx(ei)-nRemovedPrePeak;
    Lt = nRemovedPrePeak + nRemovedPostAndPeak;
    i2 = i1 + Lt -1;

    % one day fix this ...
		if (i1 < 1 | i2 > length(vec)) ; continue ; end

    cvec = zeros(1,Lt);
    cvec(nRemovedPrePeak+1:end) = vec(evIdx(ei))*tempLibMat(bestTemplateIdx,templatePeakIdx+(0:nRemovedPostAndPeak-1));
    cvec(1:nRemovedPrePeak) = vec(evIdx(ei))*tempLibMat(bestTemplateIdx, templatePeakIdx-(nRemovedPrePeak:-1:1));

    % if it meets criteria (is above noise), store it it
    if (nanmean(cvec) > noise && ~isnan(residual(bestTemplateIdx)) && ~isinf(residual(bestTemplateIdx)))

%      disp(['NOISE : ' num2str(noise) ' resid: ' num2str(residual(bestTemplateIdx)) ...
%            ' mean gain: ' num2str(nanmean(cvec))]);

			% add event to returned vectors
      nVal = nVal+1;
      peakIdx(nVal) = evIdx(ei);
      startIdx(nVal) = evIdx(ei)-tRises(bestTemplateIdx);
			peakAmp(nVal) = vec(evIdx(ei));
			tRise(nVal) = tRises(bestTemplateIdx);
			tau(nVal) = taus(bestTemplateIdx);
			tempLibIdx(nVal) = bestTemplateIdx;

	    % subtract the fitted vector (cvec) from the raw data
			vec(i1:i2) = vec(i1:i2)-cvec;
    end
  end
  
  % trim returned vectors
  startIdx = startIdx(1:nVal);
  peakIdx = peakIdx(1:nVal);
  peakAmp = peakAmp(1:nVal);
  tRise = tRise(1:nVal);
  tau = tau(1:nVal);
  tempLibIdx = tempLibIdx(1:nVal);

%
% for fittinga single event to template ; lots of optimization here so
% apologies if this is confusing
%
function [bestIdx resid] = fitSingleEventUsingTemplate(vec, i1, tempLibMat, ...
  templatePeakIdx, nPre, tOffs, L, taus)

  %%  --- prep work to make things faster ...
  % could be moved out
	Lv = length(vec);
  cumErrIdx1 = (2*taus)-1;
  cumErrIdx2 = (5*taus)-1;
	ts1 = size(tempLibMat,1);
	ts2 = size(tempLibMat,2);
	resid = nan*zeros(ts1,1);
  
  % must be local
  maxL = Lv - i1;
  ri2 = L - nPre;

  %% --- build key matrices
  % multiply ALL templates by peak value to get 'templates'
  tempProdMat = vec(i1)*tempLibMat;
  
  % build matrix of repeating data vector from which you can subtract
  % templates (i.e., make it SAME size as the templates for speed)
  nPreMat = min(templatePeakIdx-1, i1-1);
  nPostMat = min(ts2-templatePeakIdx, maxL);
  vecMat = 0*tempLibMat;
  vecMat(:,(templatePeakIdx-nPreMat):(templatePeakIdx+nPostMat)) = repmat(vec((i1-nPreMat):(i1+nPostMat)),ts1,1);

  % compute residual matrix by subtracting template from data ; do some
  % housekeeping too
  resiMat = vecMat-tempProdMat;
  resiMat(:,templatePeakIdx) = nan;
  resiMat(find(isnan(resiMat))) = 0;  
  
  % past end of vector make error inf
	if (ts2-templatePeakIdx > maxL)
	  resiMat(:,(templatePeakIdx+maxL):end) = inf;
	end

	% absolute value residual matrix ...
  resiMatAbs = abs(resiMat);
  
  %% --- punishment 1: negative residual costly
  % make negative residual more costly.  This is to ensure that when you 
  %  the fit trace is *above* the actual trace over a long stretch, you get
  %  rejected.  
  nidx = find(resiMat < 0);
  resiMatAbs(nidx) = 10*resiMatAbs(nidx);  
  
  %% --- cumulative error
  % cumulative mean error AFTER peak -- take the minimum of this value after
  %  2 taus (0.4 * length since length is 5 taus).  What this does is that in 
  %  cases where you have a new event 2 taus or later, it does not penalize
  %  you ; otherwise, you would often have the template try to fit that event
  %  and get unusual long taus.
  
  % pre-error: always add this
  preErr = mean(abs(resiMat(:,1:(templatePeakIdx-1))),2);  
  
  % build to divide cumulative error so that it becomes MEAN
  cumErrDivMat = repmat(1:(ts2-templatePeakIdx), ts1,1);
  
  % the key step: compute cumulative error
  cumErrMat = resiMatAbs(:,(templatePeakIdx+1):end);
  cumErrMat = cumsum(cumErrMat,2);
  
  % now scale by points so it is effectively a mean at each point instead
  % of cumulative
  cumErrMat = cumErrMat./cumErrDivMat;
  
  % and restrict to relevant range (zero all outside)
  cumErrProdMat = 0*cumErrDivMat;
  for t=1:ts1
    cumErrProdMat(t,cumErrIdx1(t):cumErrIdx2(t)) = 1;
  end
  cumErrMat = cumErrMat.*cumErrProdMat;
   
  % and take min
  cumErrMat(find(cumErrMat == 0)) = inf;
  minCumErrVal = min(cumErrMat,[],2);

  %% --- compute best residual; 
  % this is is our (potential) best fit ; noise criteria in calling method
  % will determine if this is acceptable.  
  resid = minCumErrVal + preErr;
  [irr bestIdx] = nanmin(resid);
  
  %% --- one last criteria we apply:
  % if your error for first 1/5th >> last 1/5th, reject ; this ensures that
  % the later part of your fit is not 'catching' a separate, later transient 
  residRatio = mean(resiMat(bestIdx,templatePeakIdx+(1:taus(bestIdx))))/mean(resiMat(bestIdx,(templatePeakIdx+((4*taus(bestIdx)):5*taus(bestIdx))-1)));
  if (residRatio < -3) ; resid(bestIdx) = nan; end


%
% will build a full fit vector based on a series of predicted exponential events, amplitudes, templates
%
function fvec = buildFitVector(vec, tempLibIdx, tempLibMat, templatePeakIdx, peakIdx, peakAmp, tau, tRise)
	fvec = 0*vec;
	for e=1:length(peakIdx)

		% grab template
	  ti = tempLibIdx(e);
		template = tempLibMat(ti,:);
		template = template(find(~isnan(template)));
 
    % some indices we'll need
    maxL = length(vec) - peakIdx(e);
	  nRemovedPostAndPeak = min(maxL,5*tau(e));
    nRemovedPrePeak = min(peakIdx(e), tRise(e));

		i1 = peakIdx(e)-nRemovedPrePeak;
    L = nRemovedPrePeak + nRemovedPostAndPeak;
    i2 = i1 + L -1;

    % now generate the individual event
    gvec = zeros(1,L);
    gvec(nRemovedPrePeak+1:end) = peakAmp(e)*tempLibMat(tempLibIdx(e),templatePeakIdx+(0:nRemovedPostAndPeak-1));
    gvec(1:nRemovedPrePeak) = peakAmp(e)*tempLibMat(tempLibIdx(e), templatePeakIdx-(nRemovedPrePeak:-1:1));

    % add it to the final fit vector
		fvec(i1:i2) = fvec(i1:i2)+gvec;
	end

