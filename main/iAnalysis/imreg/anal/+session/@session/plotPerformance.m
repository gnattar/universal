% 
% Plots performance  using a moving-average of size (2*maSize)+1.  
%
% This method plots a bunch of behavioral metrics, including positional 
%  psychometric curves, performance overall, left/right preference, etc.
%  It also returns (optionally) a particular set of behavioral statistics.
%
%  Some behavior is based on session.behavProtocolName:
%
% For protocol "pole_detect_sp":
%   - Only works if you have SINGLE typeIds for each trial. 
%
% For protocol "pole_detect_twoport_sp":
%   - Only works if you have SINGLE typeIds for each trial. 
%
% USAGE:
%  
%  performanceStats = s.plotPerformance(tOffset, progress, figHan)
%
% PARAMETERS:
% 
%   tOffset: for multisession plotting, this is how many trials you want to 
%            offset this plot by 
%   progress: for multisession plotting, 2 el vector with 1: idx 2: total #
%   figHan: figure handles to use, if passed ; good for multiDay plots
%
% RETURNS:
%
%   performanceStats{1}(1): d' with padded time excluded    
%                   {1}(2): pct correct, same epoch
%                   {2}: figure handles, sometimes ... (based on protocol) ; 
%                        for calling from array
%
% (C) S Peron 2010 Nov
%
function performanceStats =  plotPerformance(obj, tOffset, progress, figHan)
  performanceStats = {};


  % ---  params
  maSize = 30; % moving average window size PER SIDE so window is 2*this + 1
	cutoff= [0.75, 1.5]; % for % correct and d', where to draw dotted line
	criteriaDPrime = 1.5;
	criteriaFracCorrect = 0.75;
	criteriaNTrials = 100;

  % --- things that *may* be passed
  if (nargin < 2) ; tOffset = 1; end% GHETTO solution -- eventually breakup into multiple so you can plot multiple sessions
	if (nargin < 3) ; progress = [1 1]; end % eventually used for multi-session plotting
	if (nargin <4) ; figHan = []; end % figure handles

  % --- call appropriate submethod
  if (~length(obj.behavProtocolName)) ; obj.behavProtocolName = 'pole_detect_sp' ; end
	switch obj.behavProtocolName
	  case 'pole_detect_sp'
		  performanceStats = poleDetectSP(obj, maSize, cutoff, criteriaDPrime, ...
			   criteriaFracCorrect, criteriaNTrials, tOffset, progress);

		case 'pole_detect_twoport_sp'
		  performanceStats = poleDetect2PSP(obj, maSize, cutoff, criteriaDPrime, ...
			   criteriaFracCorrect, criteriaNTrials, tOffset, progress, figHan);

	end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% for pole_detect_twoport_sp protocol
%
function performanceStats = poleDetect2PSP(obj, maSize, cutoff, criteriaDPrime, ...
  criteriaFracCorrect, criteriaNTrials, tOffset, progress, figHan)
  % --- prelims
	binSize = (2*maSize)+1;
	posBinSize = 10000;
	disp(['===== binning into groups of  ' num2str(binSize) ' trials =====']);
	criteriaMet = 0;
 
  % figures ...
	if (length(figHan) == 0)
		perffig = figure('Position',[0 500 800 600]);;	
		trainparmfig = figure('Position',[0 0 800 400]);;	
		posdepfig = figure('Position',[100 100 800 800]);;	
	else
	  perffig = figHan(1);
	  trainparmfig = figHan(2);
	  posdepfig = figHan(3);
	end
  performanceStats{2} = [perffig trainparmfig posdepfig];


  % definition -- what class constitutes what?
  hitL = find(strcmp(obj.trialTypeStr,'HitL'));
  errL = find(strcmp(obj.trialTypeStr,'ErrL'));
  nolickL = find(strcmp(obj.trialTypeStr,'NoLickL'));
  hitR = find(strcmp(obj.trialTypeStr,'HitR'));
  errR = find(strcmp(obj.trialTypeStr,'ErrR'));
  nolickR = find(strcmp(obj.trialTypeStr,'NoLickR'));

  % --- gather everything
	if (length(obj.validTrialIds) == 0)
	  error('session.session.plotPerformance::must assign the validTrialIds variable in your session object first.  To use all, s.validTrialIds = s.trialIds.');
	end
	disp('plotPerformance.poleDetect2PSP::warning - using validTrialIds as constraint ; set it to trialIds to use ALL trials.');
  % pull out data -- based on class
	class= zeros(1,length(obj.validTrialIds));
	lickportPos = zeros(1,length(obj.validTrialIds));
	wvtL = zeros(1,length(obj.validTrialIds));
	wvtR = zeros(1,length(obj.validTrialIds));
	stimPos = zeros(1,length(obj.validTrialIds));
	rewardOnWrong = zeros(1,length(obj.validTrialIds));
	autoTrainMode = zeros(1,length(obj.validTrialIds));
	delayTimeMS = nan*zeros(1,length(obj.validTrialIds));
  punTrials =zeros(1,length(obj.validTrialIds));
  punTimes =zeros(1,length(obj.validTrialIds));
	lickportWithdraw = zeros(1,length(obj.validTrialIds));
	stimPosL = {};
	stimPosR = {};

  % delay
  if (length(obj.behavESA.getEventSeriesByIdStr('Pole Movement')) > 0 && ...
      length(obj.behavESA.getEventSeriesByIdStr('Reward Cue')) > 0)
    poleES = obj.behavESA.getEventSeriesByIdStr('Pole Movement');
    rewardCueES = obj.behavESA.getEventSeriesByIdStr('Reward Cue');
  end

  % punishment
  if (length(obj.behavESA.getEventSeriesByIdStr('punish')) > 0)
    punES = obj.behavESA.getEventSeriesByIdStr('punish');
    if (~iscell(punES)) ; punES = {punES}; end
    punTTrials = [];
    for e=1:length(punES)
      punTTrials = union(punTTrials, punES{e}.eventTrials);
    end
    
    punVTrials = find(ismember(obj.validTrialIds, punTTrials));
    punTrials(punVTrials) = 1;
  end
  
  
	for t=1:length(obj.validTrialIds)
	  ti = find(obj.trialIds == obj.validTrialIds(t));

	  class(t) = obj.trial{ti}.typeIds(1); 

		% pull from behavParams
		wvtL(t) = obj.trial{ti}.behavParams.get('LWaterValveTime');
		wvtR(t) = obj.trial{ti}.behavParams.get('RWaterValveTime');
    if (length(obj.trial{ti}.behavParams.get('lickport')) > 0)
    	lickportPos(t) = obj.trial{ti}.behavParams.get('lickport');
    else
      lickportPos(t) = 0;
    end
    if (strcmp(obj.trial{ti}.behavParams.get('RewardOnWrong'), 'yes'))
		  rewardOnWrong(t) = 1;
		end
		% autotrain mode
	  atm = obj.trial{ti}.behavParams.get('AutoTrainMode');
		if (strcmp(atm, 'Brutal'))
		  autoTrainMode(t) = 'b';
		elseif (strcmp(atm, 'Probabalistic'))
		  autoTrainMode(t) = 'p';
		elseif (strcmp(atm, 'Alternate'))
		  autoTrainMode(t) = 'a';
		else
		  autoTrainMode(t) = 'o';
    end
    
		% stim pos
		stimPos(t) = obj.trial{ti}.behavParams.get('stimulus');
		stimPosL{t} = obj.trial{ti}.behavParams.get('leftStimRange');
		if (~ischar(stimPosL{t})) ; stimPosL{t} = num2str(stimPosL{t}); end
		stimPosR{t} = obj.trial{ti}.behavParams.get('rightStimRange');
		if (~ischar(stimPosR{t})) ; stimPosR{t} = num2str(stimPosR{t}); end
    
    % delay
    if (length(obj.behavESA.getEventSeriesByIdStr('Pole Movement')) > 0 && ...
        length(obj.behavESA.getEventSeriesByIdStr('Reward Cue')) > 0)
      poleI = find(poleES.eventTrials == obj.trial{ti}.id);  
      rcI = find(rewardCueES.eventTrials == obj.trial{ti}.id);  
      
      if (length(poleI) > 0 & length(rcI) > 0)
          poleTime = poleES.eventTimes(max(poleI));
          cueTime = rewardCueES.eventTimes(max(rcI));
          
          delayTimeMS(t) = cueTime-poleTime;
      end
    end
    
    % lickport withdrawal
    if (sum(strcmp(obj.trial{ti}.behavParams.keys, 'withdrawLickport')) > 0)
      if (strcmp(obj.trial{ti}.behavParams.get('withdrawLickport'), 'on'))
        lickportWithdraw(t) = 1;
      elseif (strcmp(obj.trial{ti}.behavParams.get('withdrawLickport'), 'postOnly'))
        lickportWithdraw(t) = 2;
			end
    end
    
    % punishment
    if (~isempty(obj.trial{ti}.behavParams.get('punishTime')))
      punTime(t) = obj.trial{ti}.behavParams.get('punishTime');
    end
    
	end
	dominantAutoTrainMode = char(mode(double(autoTrainMode)));
  
  
	% figure out 'mode' of stim pos arrays
	ustr = unique(stimPosL);
  if (length(ustr) > 0)
    for u=1:length(ustr) ; nstr(u) = length(find(strcmp(ustr{u},stimPosL))); end
    [irr midx] = max(nstr);
    stimPosL = stimPosL{midx};
  else
    stimPosL = '???';
  end
  
  ustr = unique(stimPosR); 
  if (length(ustr) > 0)
    for u=1:length(ustr) ; nstr(u) = length(find(strcmp(ustr{u},stimPosR))); end
    [irr midx] = max(nstr);
    stimPosR = stimPosR{midx};
  else
    stimPosR = '???';
  end

  % stim pos distribution for quartile estimation
	minPos = min(stimPos);
	maxPos = max(stimPos);
	q1Pos = [minPos quantile(stimPos, 0.25)];
	q4Pos = [quantile(stimPos, 0.75) maxPos];

	% bin 
	b = 1;
	pctCorrect = [];
	ignRate = [];
	hitRateL = [];
	hitRateR = [];
	errRateL = [];
	errRateR = [];
  dPrime = [];
  dPrimeEQ = [];
	nAboveCriteria = 0;

	for t=maSize+1:length(class)-maSize
	  T = t-maSize:t+maSize;

    % NOTE: xxxR means right stimulus ; xxxL means left stim
    nHitR = length(find(class(T) == hitR)); % also 'hit' for d'
    nHitL = length(find(class(T) == hitL));
    nErrR = length(find(class(T) == errR)); 
    nErrL = length(find(class(T) == errL)); % also 'FA' for d'
    nNoLickR = length(find(class(T) == nolickR));
    nNoLickL = length(find(class(T) == nolickL));

    nConsidered = nHitR + nHitL + nErrR + nErrL;

    % pct correct and d'
    pctCorrect(b) = (nHitR+nHitL)/nConsidered;
    hitRate = nHitR/(nHitR+nErrR);
    FARate = nErrL/(nErrL+nHitL);
    hitRateL(b) = nHitL/(nHitL+nErrL);
    errRateL(b) = nErrL/(nHitL+nErrL);
    hitRateR(b) = nHitR/(nHitR+nErrR);
    errRateR(b) = nErrR/(nHitR+nErrR);
		ignRate(b) = (nNoLickR + nNoLickL) / (2*maSize + 1);
		dPrime(b) = dprime(hitRate, FARate, nHitR+nErrR, nHitL+nErrL);

		if (dPrime(b) == Inf)  ; dPrime(b) = 1; end
		if (dPrime(b) >= criteriaDPrime) ; nAboveCriteria = nAboveCriteria + 1; end

		% extreme quartile d-prime
		if (~isnan(q1Pos(1) ))
			idxQ4 = T(find(stimPos(T) >= q4Pos(1) & stimPos(T) <= q4Pos(2)));
			idxQ1 = T(find(stimPos(T) >= q1Pos(1) & stimPos(T) <= q1Pos(2)));
			if (length(idxQ4) > 1 & length(idxQ1) > 1) % at least 2 of each
				Teq = union(idxQ4,idxQ1);
				nHitReq = length(find(class(Teq) == hitR)); % also 'hit' for d'
				nHitLeq = length(find(class(Teq) == hitL));
				nErrReq = length(find(class(Teq) == errR)); 
				nErrLeq = length(find(class(Teq) == errL)); % also 'FA' for d'
				dPrimeEQ(b) = dprime(nHitReq/(nHitReq+nErrReq), nErrLeq/(nErrLeq+nHitLeq), nHitReq+nErrReq, nHitLeq+nErrLeq);
			else
				dPrimeEQ(b) = nan;
			end
		end

		% criteria test
		if (b > criteriaNTrials & ~ criteriaMet)

		  % criteria one:
		  if (nAboveCriteria >= criteriaNTrials)
				criteriaMet = 1;
			end
			if (~ criteriaMet) % look @ d' AVERAGE excluding start/end over whole session
				nExclude = maSize;
				T = nExclude+1:length(class)-nExclude;

				nHitR = length(find(class(T) == hitR)); % also 'hit' for d'
				nHitL = length(find(class(T) == hitL));
				nErrR = length(find(class(T) == errR)); 
				nErrL = length(find(class(T) == errL)); % also 'FA' for d'
				nNoLickR = length(find(class(T) == nolickR));
				nNoLickL = length(find(class(T) == nolickL));

				dp = dprime(nHitR/(nHitR+nErrR), nErrL/(nErrL+nHitL), nHitR+nErrR, nHitL+nErrL);

				if (dp > criteriaDPrime & length(T) >= criteriaNTrials) ; criteriaMet = 2; end
			end
		end

		% increment
		b = b+1;
	end

	% --- overall
	disp(['=== Summary for ' obj.mouseId ' on ' obj.dateStr ' === ']);
	if (criteriaMet == 1) ; 
	  disp (['CRITERIA MET ON THIS DAY (sliding window size +/- ' num2str(maSize) ' '  num2str(criteriaNTrials) ' trials d'' > ' num2str(criteriaDPrime) ')']); 
	end
	if (criteriaMet == 2) ; disp (['CRITERIA MET ON THIS DAY (excluding first/last ' num2str(maSize) ' trials, mean d'' > ' num2str(criteriaDPrime) ')']); end

	nExclude = 0;
	T = nExclude+1:length(class)-nExclude;
	nHitR = length(find(class(T) == hitR)); % also 'hit' for d'
	nHitL = length(find(class(T) == hitL));
	nErrR = length(find(class(T) == errR)); 
	nErrL = length(find(class(T) == errL)); % also 'FA' for d'
	nNoLickR = length(find(class(T) == nolickR));
	nNoLickL = length(find(class(T) == nolickL));
	N = nHitR + nHitL + nErrR + nErrL;
	dp = dprime(nHitR/(nHitR+nErrR), nErrL/(nErrL+nHitL), nHitR+nErrR, nHitL+nErrL);
	disp(['# trials considered (EXCLUDES nolicks): ' num2str(N)]);
	disp(['hits stim L: ' num2str(nHitL) ' R: ' num2str(nHitR) ' errors stim L: ' num2str(nErrL) ' R: ' num2str(nErrR)]);
	disp(['nolicks L: ' num2str(nNoLickL) ' R: ' num2str(nNoLickR)]);
	disp(['d-prime: ' num2str(dp)]);
	disp(['% correct: ' num2str(100*(nHitR + nHitL)/N)]);

	nExclude = maSize;
	T = nExclude+1:length(class)-nExclude;
	nHitR = length(find(class(T) == hitR)); % also 'hit' for d'
	nHitL = length(find(class(T) == hitL));
	nErrR = length(find(class(T) == errR)); 
	nErrL = length(find(class(T) == errL)); % also 'FA' for d'
	nNoLickR = length(find(class(T) == nolickR));
	nNoLickL = length(find(class(T) == nolickL));
	N = nHitR + nHitL + nErrR + nErrL;
	dp = dprime(nHitR/(nHitR+nErrR), nErrL/(nErrL+nHitL), nHitR+nErrR, nHitL+nErrL);
	disp([' ']);
	disp(['# trials considered: ' num2str(N) ' (EXCLUDING nolick and from start and end ' num2str(nExclude) ' trials)']);
	disp(['hits stim L: ' num2str(nHitL) ' R: ' num2str(nHitR) ' errors stim L: ' num2str(nErrL) ' R: ' num2str(nErrR)]);
	disp(['nolicks L: ' num2str(nNoLickL) ' R: ' num2str(nNoLickR)]);
	disp(['d-prime: ' num2str(dp)]);

	disp([' ']);
	disp(['for individual bins of size ' num2str(binSize) ':']);
	disp(['peak d-prime: ' num2str(max(dPrime))]);
	disp(['% correct: ' num2str(100*max(pctCorrect))]);
	disp([' ']);
	disp([' ']);

	performanceStats{1} = [100*(nHitR + nHitL)/N dp];

  % =============== performance plot
	figure (perffig);
	tVals = (maSize+1:length(class)-maSize) + tOffset;
	lw = 1;
	embellish = 0;

	% --- hit etc. rate
	subplot('Position', [0.1 0.5 0.9 0.4]);
	hold on;
	plot(tVals, (hitRateR+hitRateL)/2, 'o', 'Color', [0 0 1], 'MarkerFaceColor', [0 0 1], 'MarkerSize', 4);
	plot(tVals, hitRateR, 'bx')
	if(embellish); plot(tVals, hitRateL, 'bo');end
	if(embellish); plot(tVals, (errRateR+errRateL)/2, 'o', 'Color', [0 1 0], 'MarkerFaceColor', [0 1 0], 'MarkerSize', 4);end
	ivsh = find(ignRate > 0);
	plot(tVals(ivsh), ignRate(ivsh), 'o', 'Color', [0 0 0], 'MarkerFaceColor', [1 1 1], 'MarkerSize', 4);
	if(embellish); plot(tVals, errRateR, 'gx');end
	if(embellish); plot(tVals, errRateL, 'go');end

  if (progress(1) == progress(2)) % finito -- legendary
	  legend('hit rate', 'hr R',  'ignore rate');
	end

	plot([1 1]*length(class)+tOffset, [0 1], 'k-', 'LineWidth', lw);
	if (progress(1) == progress(2)) % done? draw line
		plot([0 max(tVals)], [criteriaFracCorrect criteriaFracCorrect], 'k:');
		title(obj.mouseId);
	end
	if (length(tVals) > 0)
		text(tVals(1), 0.9, dominantAutoTrainMode , 'FontSize', 14, 'FontWeight' ,'bold' ,'Color', 'w', 'BackgroundColor', 'r');
	end
	text((length(class)/5)+tOffset, 0.1 , num2str(progress(1)));
	axis([0 length(class)+tOffset 0 1]);
	ylabel('fraction');
	set(gca,'TickDir','out');
	set(gca,'XTick',[]);

	% --- d'
	subplot('Position', [0.1 0.05 0.9 0.4]);
	hold on;
	plot(tVals, dPrimeEQ, 'ro', 'MarkerFaceColor', [1 0 0] ,'MarkerSize', 4);
	plot(tVals, dPrime, 'ko', 'MarkerFaceColor', [0 0 0] ,'MarkerSize', 4);
	legend({'extreme quartile','overall'});
	plot([1 1]*length(class)+tOffset, [-3 3], 'k-', 'LineWidth', lw);
	date_y=-1;
	if (rem(progress(1),2)) ; date_y = -1.5; end
	text((length(class)/5)+tOffset, date_y, datestr(datenum(obj.dateStr),6));
	stim_y=2.5;
	if (progress(1) == progress(2)) % done? draw line
		plot([0 max(tVals)], [criteriaDPrime criteriaDPrime], 'r:');
	end
	axis([0 length(class)+tOffset -2 3]);
%	if (criteriaMet) ; plot([min(tVals) max(tVals)], [2.9 2.9], 'r-', 'LineWidth', 2); end
	ylabel('d prime');
	set(gca,'TickDir','out');
	xlabel('trial #');

  % =============== train parameters plot
	figure (trainparmfig);

  % --- lickport position

	% center around median ...
  lickportPos = lickportPos - median(lickportPos);

	tVals = (1:length(class)) + tOffset;
	subplot('Position', [0.1 0.8 0.9 0.2]);
	hold on;
	plot(tVals, lickportPos, 'k.');

	% center plot 
	lppR = quantile(lickportPos,.98) - quantile(lickportPos,.02);
  lppMin = quantile(lickportPos,.02) - 0.2*lppR;
	lppMin = floor(lppMin/5000)*5000;
  lppMax = quantile(lickportPos,.98) + 0.2*lppR;
	lppMax = ceil(lppMax/5000)*5000;
	%axis([0 length(class)+tOffset lppMin lppMax]);
  axis([0 length(class)+tOffset -20000 20000]);

	plot([1 1]*length(class)+tOffset, [-200000 200000], 'k-', 'LineWidth', lw);
	ylabel('lickport pos (ZU)');
	set(gca,'TickDir','out');
	set(gca,'XTick',[]);

	text(min(tVals), -18000, ['L: ' stimPosL], 'Color', 'k');
	text(min(tVals), -12000, ['R: ' stimPosR], 'Color', 'k');

	
	% --- stimulus (L or R?)
	subplot('Position', [0.1 0.55 0.9 0.2]);
	lStimHits = find(class == hitL);
	lStimErrs = find(class == errL);
	lStimIgs = find(class == nolickL);
	rStimHits = find(class == hitR);
	rStimErrs = find(class == errR);
	rStimIgs = find(class == nolickR);

	plot(tVals(lStimHits), ones(1,length(lStimHits)), 'g.');
	hold on;
	plot(tVals(lStimErrs), ones(1,length(lStimErrs)), 'r.');
	plot(tVals(lStimIgs), ones(1,length(lStimIgs)), 'kx');

	plot(tVals(rStimHits), 2*ones(1,length(rStimHits)), 'g.');
	plot(tVals(rStimErrs), 2*ones(1,length(rStimErrs)), 'r.');
	plot(tVals(rStimIgs), 2*ones(1,length(rStimIgs)), 'kx');

	set(gca,'TickDir','out', 'YTickLabel', {'L', 'R'}, 'YTick', [ 1 2]);
	set(gca,'XTick',[]);
	axis([0 length(class)+tOffset 0.5 2.5]);
	text(min(tVals), 1.5, ['  ATM: ' dominantAutoTrainMode ' stim L: ' stimPosL ' R: ' stimPosR], 'Color', 'k');


	% --- delay time, punishment
	subplot('Position', [0.1 0.33 0.9 0.2]);
	hold on;

  plot(tVals, delayTimeMS/1000, 'k-');
  maxDelay = ceil(max(delayTimeMS/1000));
 
  lpwdtr = find(lickportWithdraw == 1);
  if (length(lpwdtr) > 0)
    plot(tVals(lpwdtr), 0*lpwdtr, 'm.');
  	text(tOffset/10, maxDelay/5, 'LP withdrawn', 'Color', 'm');
  end
  lpwdposttr = find(lickportWithdraw == 2);
  if (length(lpwdposttr) > 0)
    plot(tVals(lpwdposttr), .25 + 0*lpwdposttr, 'g.');
  	text(tOffset/10, 2*maxDelay/5, 'LP withdrawn post', 'Color', 'g');
  end
  puntr = find(punTrials);
  if (length(puntr) > 0)
    plot(tVals(puntr), .5 + 0*puntr, '.', 'Color', [.75 .75 0]);
  	text(tOffset/10, 3*maxDelay/5, 'Punished', 'Color', [.75 .75 0]);
  end
  
  plot([1 1]*length(class)+tOffset, [0 maxDelay], 'k-', 'LineWidth', lw);

  axis([0 length(class)+tOffset 0 maxDelay]);
	xlabel('trial #');
	ylabel('delay (s)');
	set(gca,'XTick',[], 'TickDir','out');

	% --- times (water valves, punishment)
	subplot('Position', [0.1 0.1 0.9 0.2]);
	hold on;
	plot(tVals, wvtR, 'b-');
	plot(tVals, wvtL, 'c-');
  plot(tVals, punTime, 'Color', [.75 .75 0]);
	rowg = find(rewardOnWrong);
	if (length(rowg) > 0)
	  plot(tVals(rowg), 0.9*ones(1,length(rowg)), 'r.');
	end
	plot([1 1]*length(class)+tOffset, [-3 3], 'k-', 'LineWidth', lw);
	if (progress(1) == progress(2)) % done? label legends
		text(tOffset/10, .1, 'wvtR', 'Color', 'b');
		text(tOffset/10, .3, 'wvtL', 'Color', 'c');
		text(tOffset/10, .5, 'RewardOnWrong (dots)', 'Color', 'r');
		text(tOffset/10, .7, 'PunTime', 'Color', [.75 .75 0]);
	end

	axis([0 length(class)+tOffset 0 1]);
	xlabel('trial #');
	ylabel('time (s)');
	set(gca,'TickDir','out');


  % =============== positional dependent performance ; psychometrix -- ASSUMES BALANCED!!
	figure(posdepfig);

	posBin = 0:posBinSize:180000;
	posBin(end) = posBin(end)+1;
	pctCorrect = nan*ones(1,length(posBin)-1);
	fracLeft = nan*ones(1,length(posBin)-1);
	trialCount = nan*ones(1,length(posBin)-1);
	for bi=1:length(posBin)-1
	  idx = find(stimPos >= posBin(bi)  & stimPos < posBin(bi+1));
		if (length(idx) > 0)
		  nCorr = length(find(class(idx) == hitR)) + length(find(class(idx) == hitL));
			nErr = length(find(class(idx) == errR)) +  length(find(class(idx) == errL));
			nIgn = length(find(class(idx) == nolickR)) +  length(find(class(idx) == nolickL));
		  pctCorrect(bi) = nCorr/(nErr + nCorr);
		  trialCount(bi) = (nErr + nCorr + nIgn);
			fracLeft(bi) =  (length(find(class(idx) == hitL)) +  length(find(class(idx) == errR)))/(nErr+nCorr);
		end
	end

  subplot('Position', [0.075 0.55 0.4 0.4]);
	hist(stimPos, 0:posBinSize:180000);
	set(gca,'TickDir','out', 'XTick', []);
	ylabel('trial count');
	cax = axis;
	axis([-10000 190000 0 cax(4)]);

  subplot('Position', [0.075 0.1 0.4 0.4]);
  plot(posBin(1:end-1)+posBinSize/2, pctCorrect,'k.');

	axis([-10000 190000 0 1]);
	xlabel('zaber position');
	ylabel('% correct');
	set(gca,'TickDir','out');

	% psychometric curve --> stimulus vs. response -- position vs % left
  subplot('Position', [0.55 0.1 0.4 0.4]);
  plot(posBin(1:end-1)+posBinSize/2, fracLeft, 'bo', 'MarkerFaceColor', [0 0 1]);
	title(obj.dateStr);
	xlabel('zaber position');
	ylabel('% left licks');
	axis([-10000 190000 0 1]);
	set(gca,'TickDir','out');







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% for pole_detect_sp protocol
%
function performanceStats = poleDetectSP(obj, maSize, cutoff, criteriaDPrime, criteriaFracCorrect, criteriaNTrials, tOffset, progress);
  % --- prelims
	binSize = (2*maSize)+1;
	disp(['===== binning into groups of  ' num2str(binSize) ' trials =====']);
	criteriaMet = 0;

  % definition -- what class constitutes what?
  hit = find(strcmp(obj.trialTypeStr,'Hit'));
  miss = find(strcmp(obj.trialTypeStr,'Miss'));
  fa = find(strcmp(obj.trialTypeStr,'FA'));
  cr = find(strcmp(obj.trialTypeStr,'CR'));

  % --- gather everything
  % pull out data -- based on class
	for t=1:length(obj.trial)
	  class(t) = obj.trial{t}.typeIds(1); % only pull first type-id since we assume 1-4

		% is it hash or old school?
    if (~isobject(obj.trial{t}.behavParams))
			pNogo(t) = obj.trial{t}.behavParams{3};
			wvt(t) = obj.trial{t}.behavParams{1};
			tPuff(t) = obj.trial{t}.behavParams{2};
			stimPos(t) = obj.trial{t}.behavParams.stimulus;
		else
			pNogo(t) = obj.trial{t}.behavParams.get('NoGoProb');
			wvt(t) = obj.trial{t}.behavParams.get('WaterValveTime');
			tPuff(t) = obj.trial{t}.behavParams.get('AirpuffTime');
			stimPos(t) = obj.trial{t}.behavParams.get('stimulus');
		end
	end

	% bin 
	b = 1;
	pctCorrect = [];
  dPrime = [];
	hitRate = [];
	FARate = [];
	nAboveCriteria = 0;

	for t=maSize+1:length(class)-maSize
	  T = t-maSize:t+maSize;

    nHit = length(find(class(T) == hit));
    nMiss = length(find(class(T) == miss));
    nCR = length(find(class(T) == cr));
    nFA = length(find(class(T) == fa));

    % pct correct and d'
    pctCorrect(b) = (nHit+nCR)/binSize;
    hitRate(b) = nHit/(nHit+nMiss);
    FARate(b) = nFA/(nFA+nCR);
		dPrime(b) = dprime(hitRate(b), FARate(b), nHit+nMiss, nFA+nCR);

		if (dPrime(b) == Inf)  ; dPrime(b) = 1; end
		if (dPrime(b) >= criteriaDPrime) ; nAboveCriteria = nAboveCriteria + 1; end

		% criteria test
		if (b > criteriaNTrials & ~ criteriaMet)

		  % criteria one:
		  if (nAboveCriteria >= criteriaNTrials)
				criteriaMet = 1;
			end
			if (~ criteriaMet) % look @ d' AVERAGE excluding start/end
				nExclude = maSize;
				T = nExclude+1:length(class)-nExclude;
				nHit = length(find(class(T) == hit));
				nMiss = length(find(class(T) == miss));
				nCR = length(find(class(T) == cr));
				nFA = length(find(class(T) == fa));
				N_go = nHit+nMiss;
				N_nogo = nCR + nFA;
				dp = dprime(nHit/N_go, nFA/N_nogo, nHit+nMiss, nFA+nCR);

				if (dp > criteriaDPrime & length(T) >= criteriaNTrials) ; criteriaMet = 2; end
			end
		end

		% increment
		b = b+1;
	end

	% compute stimulus separation (assumes you have 2 positions only)
  [num stim] = hist(stimPos,200);
  [irr idx] = sort(num, 'descend');
	stimulusSeparation = abs(stim(idx(1)) - stim(idx(2)));

	% --- overall
	disp(['=== Summary for ' obj.mouseId ' on ' obj.dateStr ' with stim sep (turns) ' num2str(stimulusSeparation) ' === ']);
	if (criteriaMet == 1) ; 
	  disp (['CRITERIA MET ON THIS DAY (sliding window size +/- ' num2str(maSize) ' '  num2str(criteriaNTrials) ' trials d'' > ' num2str(criteriaDPrime) ')']); 
	end
	if (criteriaMet == 2) ; disp (['CRITERIA MET ON THIS DAY (excluding first/last ' num2str(maSize) ' trials, mean d'' > ' num2str(criteriaDPrime) ')']); end
	nExclude = 0;
	T = nExclude+1:length(class)-nExclude;
	nHit = length(find(class(T) == hit));
	nMiss = length(find(class(T) == miss));
	nCR = length(find(class(T) == cr));
	nFA = length(find(class(T) == fa));
	N = length(class(T));
	N_go = nHit+nMiss;
	N_nogo = nCR + nFA;
	disp(['# trials: ' num2str(N)]);
	disp(['hits: ' num2str(nHit) ' CRs: ' num2str(nCR) ' FAs: ' num2str(nFA) ' misses: ' num2str(nMiss)]);
	disp(['d-prime: ' num2str(dprime(nHit/N_go, nFA/N_nogo, nHit+nMiss, nFA+nCR))]);
	nExclude = maSize;
	T = nExclude+1:length(class)-nExclude;
	nHit = length(find(class(T) == hit));
	nMiss = length(find(class(T) == miss));
	nCR = length(find(class(T) == cr));
	nFA = length(find(class(T) == fa));
	N = length(class(T));
	N_go = nHit+nMiss;
	N_nogo = nCR + nFA;
	disp([' ']);
	disp(['# trials: ' num2str(N) ' (EXCLUDING from start and end ' num2str(nExclude) ' trials)']);
	disp(['hits: ' num2str(nHit) ' CRs: ' num2str(nCR) ' FAs: ' num2str(nFA) ' misses: ' num2str(nMiss)]);
	disp(['d-prime: ' num2str(dprime(nHit/N_go, nFA/N_nogo, nHit+nMiss, nFA+nCR))]);
	disp(['% correct: ' num2str(100*(nHit+nCR)/N)]);
	disp([' ']);
	disp(['for individual bins of size ' num2str(binSize) ':']);
	disp(['peak d-prime: ' num2str(max(dPrime))]);
	disp(['% correct: ' num2str(100*max(pctCorrect))]);
	disp([' ']);
	disp([' ']);

	performanceStats{1} = [100*(nHit+nCR)/N (dprime(nHit/N_go, nFA/N_nogo, nHit+nMiss, nFA+nCR))];

	% --- and plot
	tVals = (maSize+1:length(class)-maSize) + tOffset;
	lw = 1;
%	if (rem(progress(1),5) == 0) ; lw = 5; end

	% pct correct
	subplot('Position', [0.05 0.65 0.9 0.3]);
	hold on;
	plot(tVals, hitRate, 'bo', 'MarkerFaceColor', [0 0 1], 'MarkerSize', 4);
	plot(tVals, FARate, 'go', 'MarkerFaceColor', [0 1 0], 'MarkerSize', 4);
	plot(tVals, pctCorrect, 'ko', 'MarkerFaceColor', [0 0 0], 'MarkerSize', 4);
	plot([1 1]*length(class)+tOffset, [0 1], 'k-', 'LineWidth', lw);
	if (progress(1) == progress(2)) % done? draw line
		plot([0 max(tVals)], [criteriaFracCorrect criteriaFracCorrect], 'k:');
		title(obj.mouseId);
	end
	text((length(class)/5)+tOffset, 0.1 , num2str(progress(1)));
	axis([0 length(class)+tOffset 0 1]);
	ylabel('% correct');
	set(gca,'TickDir','out');
	set(gca,'XTick',[]);

	% d'
	subplot('Position', [0.05 0.33 0.9 0.3]);
	hold on;
	plot(tVals, dPrime, 'ko', 'MarkerFaceColor', [0 0 0] ,'MarkerSize', 4);
	plot([1 1]*length(class)+tOffset, [-3 3], 'k-', 'LineWidth', lw);
	date_y=-1;
	if (rem(progress(1),2)) ; date_y = -1.5; end
	text((length(class)/5)+tOffset, date_y, datestr(datenum(obj.dateStr),6));
	stim_y=2.5;
	text((length(class)/5)+tOffset, stim_y, sprintf('%2.1f',stimulusSeparation/10000));
	if (progress(1) == progress(2)) % done? draw line
		plot([0 max(tVals)], [criteriaDPrime criteriaDPrime], 'r:');
	end
	axis([0 length(class)+tOffset -2 3]);
	if (criteriaMet) ; plot([min(tVals) max(tVals)], [2.9 2.9], 'r-', 'LineWidth', 2); end
	ylabel('d prime');
	set(gca,'TickDir','out');
	set(gca,'XTick',[]);

	% behavioral parameters
	tVals = (1:length(class)) + tOffset;
	subplot('Position', [0.05 0.1 0.9 0.2]);
	hold on;
	plot(tVals, pNogo, 'k-');
	plot(tVals, tPuff, 'r-');
	plot(tVals, wvt, 'b-');
	plot([1 1]*length(class)+tOffset, [-3 3], 'k-', 'LineWidth', lw);
	if (progress(1) == progress(2)) % done? label legends
		text(tOffset/10, .1, 'Pnogo', 'Color', 'k');
		text(tOffset/10, .4, 'wvt', 'Color', 'b');
		text(tOffset/10, .7, 'puff', 'Color', 'r');
	end

	axis([0 length(class)+tOffset 0 1.5]);
	xlabel('trial #');
	set(gca,'TickDir','out');



