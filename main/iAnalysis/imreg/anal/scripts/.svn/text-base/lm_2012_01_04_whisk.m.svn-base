%
% Computes:
%
%   behavioral variables
%
% Pass: session array
%
function lm_2012_01_04 (sA)
  plotOn = [1 1 1 1];
	plotOn = [1 1 0 0 0];
	plotOn = [0 0 0 1 0];
  % === training and performance 

  %% training for two guys over time
	if (plotOn(1))
	  sA.plotPerformance();
	end

  % === whisking

  % pull dataset
	if (strcmp(sA.mouseId, 'an147333'))
		s = sA.sessions{13};
		disp(['Using ' s.mouseId ' ' s.dateStr]);
		% generate contact properties hashes if not done ...
		if (s.whiskerBarContactClassifiedESA.esa{1}.eventPropertiesHash.length < 2)
			s.generateContactPropertiesHashes();
		end
		sPlot = [9 10 11 12 13 14];
	else 
	  sPlot = [8 9 10];
	end
		
	%% plot performance in trials w/ & w/o contact
	if (plotOn(2))  
	  if (strcmp(sA.mouseId, 'an147333')); plotPerformanceVsTouch(s); end
		for si=sPlot; sA.sessions{si}.plotPerformance(); end
	end

  %% theta/kappa-at-touch vs. stimulus position ; color pro/re
	%  also, histograms for theta, kappa across whiskers
	%  finally, kappa vs theta plot
	if (plotOn(3))
		whStr = {'c1','c2','c3'};
		fh(1) = figure('Position',[0 0 1000 800]);
		fh(2) = figure('Position',[0 0 1000 800]);
		fh(3) = figure('Position',[0 0 600 800]);
		for w=1:length(whStr)
			plotTouchStats(s,s.whiskerBarContactClassifiedESA, whStr{w}, w, fh);
		end
	end

  %% plot whisking angle, kappa image *raw* with contacts, (licks?)
  %  plot whisking angle, kappa image with trials sorted by stim pos
	if (plotOn(4))
		esb = s.whiskerBarInReachES.copy();
		esb.color = [1 1 1];
		eslick = s.behavESA.esa{2}.copy();
		eslick.color = [0 0 1 ];

		sortByType = 1;
    % type-sorted, with licks ; no pos sortr
	  ESs = { esb, eslick, s.behavESA.esa{1}};
    plotWhiskerHeatmaps (s, ESs, s.whiskerAngleTSA, sortByType, [1 0]);
    plotWhiskerHeatmaps (s, ESs, s.whiskerCurvatureChangeTSA, sortByType, [1 0]);

		% type-sorted, with touches ; no pos sort
	  ESs = {s.whiskerBarContactClassifiedESA.esa{3}, s.whiskerBarContactClassifiedESA.esa{4}, ...
				 esb};
    plotWhiskerHeatmaps (s, ESs, s.whiskerAngleTSA, sortByType, [1 0]);
    plotWhiskerHeatmaps (s, ESs, s.whiskerCurvatureChangeTSA, sortByType, [1 0]);

		sortByType = 0;
		% type, pos sorted with touches
	  ESs = {s.whiskerBarContactClassifiedESA.esa{3}, s.whiskerBarContactClassifiedESA.esa{4}, ...
				 esb};
    plotWhiskerHeatmaps (s, ESs, s.whiskerAngleTSA, sortByType, [0 1]);
    plotWhiskerHeatmaps (s, ESs, s.whiskerCurvatureChangeTSA, sortByType, [0 1]);

		% type, pos sorted raw
		ESs = {esb};
    plotWhiskerHeatmaps (s, ESs, s.whiskerAngleTSA, sortByType, [0 1]);
    plotWhiskerHeatmaps (s, ESs, s.whiskerCurvatureChangeTSA, sortByType, [0 1]);
	end

  % === lick timing
	if (plotOn(5))
	  % collect data for cross-day average . . .
		poleRMeans = zeros(length(sA.sessions),71);
		poleLMeans = zeros(length(sA.sessions),71);
		ansRMeans = zeros(length(sA.sessions),71);
		ansLMeans = zeros(length(sA.sessions),71);
	  for si=1:length(sA.sessions)
	%  for si=length(sA.sessions)
		  s = sA.sessions{si};
			% generate derived time series for licking ... on both sides
			mt = min(min(s.behavESA.esa{1}.eventTimes),min(s.behavESA.esa{2}.eventTimes));
			Mt = max(max(s.behavESA.esa{1}.eventTimes),max(s.behavESA.esa{2}.eventTimes));
			timeVec = (mt-20000:100:Mt+20000);
			lickRateR = s.behavESA.esa{1}.deriveRateTimeSeries(timeVec,1);
			lickRateR.reSample(3, [], timeVec);
			lickRateR.value = lickRateR.value*1000; % to Hz
			lickRateL = s.behavESA.esa{2}.deriveRateTimeSeries(timeVec,1);
			lickRateL.reSample(3, [], timeVec);
			lickRateL.value = lickRateL.value*1000; % to Hz

			%% heat map over single day
			% relative pole movement
			ies = s.behavESA.esa{3}.getStartTimes();
      [valueMatR timeMat idxMat timeVec ieIdxVec] = ...
			  lickRateR.getValuesAroundEvents(ies, [-2 5], 2, 1);
      [valueMatL timeMat idxMat timeVec ieIdxVec] = ...
			  lickRateL.getValuesAroundEvents(ies, [-2 5], 2, 1);
			disp([s.dateStr ' r: ' num2str(size(valueMatR)) ' L: ' num2str(size(valueMatL))]);
			poleRMeans(si,:) = nanmean(valueMatR);
			poleLMeans(si,:) = nanmean(valueMatL);

			%% plot heat map for last day -- pole aligned
			if (si == length(sA.sessions))
        figure('Position',[0 0 800 800]);
		    ax = subplot('Position', [0.05 0.1 0.4 0.8]);
				image(valueMatL*5, 'Parent', ax); 
				hold on;
				title('L Lick');
				A = axis;
				plot ([20 20], [A(3) A(4)], 'k-', 'LineWidth', 3);
				plot ([42 42], [A(3) A(4)], 'k-', 'LineWidth', 3);
				plot ([49 49], [A(3) A(4)], 'w-', 'LineWidth', 3);
				set(gca, 'TickDir','out', 'YTick', [], 'XTick', 10:10:70, 'XTickLabel', {'1','2','3','4','5','6','7'});

		    ax = subplot('Position', [0.5 0.1 0.4 0.8]);
				image(valueMatR*5, 'Parent', ax); 
				hold on;
				title('R Lick');
				A = axis;
				plot ([20 20], [A(3) A(4)], 'k-', 'LineWidth', 3);
				plot ([42 42], [A(3) A(4)], 'k-', 'LineWidth', 3);
				plot ([49 49], [A(3) A(4)], 'w-', 'LineWidth', 3);
				set(gca, 'TickDir','out', 'YTick',[], 'XTick', 10:10:70, 'XTickLabel', {'1','2','3','4','5','6','7'});

				figure
		    ax = subplot('Position', [0.5 0.1 0.4 0.8]);
				image(valueMatL*5, 'Parent', ax); 
				colorbar;
			end

			% relative answer time
			ansTimes = s.behavESA.esa{3}.getEndTimes() + ...
										s.trial{1}.behavParams.get('PoleRetractTime')*1000 + ...
										s.trial{1}.behavParams.get('PreAnswerTime')*1000;
			[valueMatR timeMat idxMat timeVec ieIdxVec] = ...
				lickRateR.getValuesAroundEvents(ansTimes, [-5 2], 2, 1);
			[valueMatL timeMat idxMat timeVec ieIdxVec] = ...
				lickRateL.getValuesAroundEvents(ansTimes, [-5 2], 2, 1);
			disp([s.dateStr ' r: ' num2str(size(valueMatR)) ' L: ' num2str(size(valueMatL))]);
			ansRMeans(si,:) = nanmean(valueMatR);
			ansLMeans(si,:) = nanmean(valueMatL);
		end

		%% heat map over learning relative pole time, relative reward epoch
		%  same, but separate by pole position
    figure('Position',[0 0 800 800]);
		ax = subplot(2,2,1);
		image(poleLMeans*10, 'Parent', ax);
		hold on ;
		title ('L lick, aligned to pole move');
		A = axis;
		plot ([42 42], [A(3) A(4)], 'k-', 'LineWidth', 3);
		plot ([20 20], [A(3) A(4)], 'k-', 'LineWidth', 3);
		set(gca, 'TickDir','out', 'XTick',[]);
		ylabel('session (day)');

	  ax = subplot(2,2,2);
		image(poleRMeans*10, 'Parent', ax);
		hold on ;
		title ('R lick, aligned to pole move');
		A = axis;
		plot ([42 42], [A(3) A(4)], 'k-', 'LineWidth', 3);
		plot ([20 20], [A(3) A(4)], 'k-', 'LineWidth', 3);
		set(gca, 'TickDir','out', 'XTick',[]);

		ax = subplot(2,2,3);
		image(ansLMeans*10, 'Parent', ax);
		hold on ;
		title ('L lick, aligned to answer epocj');
		A = axis;
		plot ([50 50], [A(3) A(4)], 'w-', 'LineWidth', 3);
		set(gca, 'TickDir','out', 'XTick', 10:10:70, 'XTickLabel', {'1','2','3','4','5','6','7'});
		xlabel('time (s)');
		ylabel('session (day)');

	  ax = subplot(2,2,4);
		image(ansRMeans*10, 'Parent', ax);
		hold on ;
		title ('R lick, aligned to answer epoch');
		A = axis;
		plot ([50 50], [A(3) A(4)], 'w-', 'LineWidth', 3);
		set(gca, 'TickDir','out', 'XTick', 10:10:70, 'XTickLabel', {'1','2','3','4','5','6','7'});

    figure('Position',[0 0 800 800]);
		ax = subplot(2,2,1);
		image(poleLMeans*10, 'Parent', ax);
		colorbar;


	end

function plotWhiskerHeatmaps (s, ESs, tsa, sortByType, plotsDone)
	% colormap blue-to-red
	cmap = zeros(256,3);
	cmap(1:128,3) = linspace(1,0,128);
	cmap(129:256,1) = linspace(0,1,128);
	cmap = gray(256);
 
	% setup for plotter
	tstm = [s.trialIds ; s.trialStartTimes]';
	ttm = 0*tstm;
	for t=1:size(ttm,1)
		ttm(t,:) = [s.trialIds(t) min(find(s.trialTypeMat(:,t)))];
	end

%	valueRange = [-60 60];
	tsIdx = 2;
	colorMap = cmap;
	xAxisBounds = [0 7.5];
	Mabs = quantile(abs(tsa.valueMatrix(tsIdx,:)),.995);
	valueRange = [-1 1]*Mabs;

	%% base plot time sorted
	if (plotsDone(1))
		figure('Position',[0 0 400 800]);
		ax = subplot('Position', [0 0 1 1]);
		session.timeSeriesArray.plotTimeSeriesAsImageS(tsa, tsIdx, tstm, ESs, ...
			 s.validTrialIds, ttm, [], sortByType, colorMap, xAxisBounds, ...
			 valueRange, ax, []);
	end

	%% sort by position

	% sort validTrialIds
	vts = s.validTrialIds;
	sp = zeros(1,length(vts));
	for vi=1:length(vts)
		ti = find(s.trialIds == vts(vi));
		sp(vi) = s.trial{ti}.behavParams.get('stimulus');
	end
	[irr sidx] = sort(sp);
	nvts = vts(sidx);

	% plot
	if (plotsDone(2))
		figure('Position',[0 0 400 800]);
		ax = subplot('Position', [0 0 1 1]);
		session.timeSeriesArray.plotTimeSeriesAsImageS(tsa, tsIdx, tstm, ESs, ...
			 nvts, ttm, [], sortByType, colorMap, xAxisBounds, ...
			 valueRange, ax, []);
	end



function plotTouchStats(obj, esa, whStr, w, fh)
  proES = esa.getEventSeriesByIdStr(['Protraction contacts for ' whStr]);
  reES = esa.getEventSeriesByIdStr(['Retraction contacts for ' whStr]);

  % get stimulus position for each contact
	proPos = proES.eventTrials*0;
	retPos = reES.eventTrials*0;
	ut = unique(proES.eventTrials);
	for t=ut
	  tiPos = find(proES.eventTrials == t);
    tiTrial = find(obj.trialIds == t);
		proPos(tiPos) = obj.trial{tiTrial}.behavParams.get('stimulus');
	end
	ut = unique(reES.eventTrials);
	for t=ut
	  tiPos = find(reES.eventTrials == t);
    tiTrial = find(obj.trialIds == t);
		rePos(tiPos) = obj.trial{tiTrial}.behavParams.get('stimulus');
	end

  % --- 
	figure(fh(1));
  subplot(3,2,(w*2)-1);
	% kappa
	plot(proPos, proES.eventPropertiesHash.get('kappaMaxAbsOverTouch'), '.', 'Color', [0 1 1]);
	hold on;
	plot(rePos, reES.eventPropertiesHash.get('kappaMaxAbsOverTouch'), '.', 'Color', [1 0 1]);
	ax=axis; axis([0 200000 ax(3) ax(4)]);
	if (w == 1) ; title('kappa'); end
	ylabel(whStr);
	if (w == 3) ; xlabel('zaber position'); end

  subplot(3,2,(w*2));

	% theta
	plot(proPos, proES.eventPropertiesHash.get('thetaMeanOverTouch'), '.', 'Color', [0 1 1]);
	hold on;
	plot(rePos, reES.eventPropertiesHash.get('thetaMeanOverTouch'), '.', 'Color', [1 0 1]);
	axis([0 200000 -60 60]);
	if (w == 1) ; legend('Protraction' ,'Retraction','Location','SouthEast'); title('theta'); end

  % --- histos
	figure(fh(2));
	subplot(3,4,(w*4)-3);
	hist( proES.eventPropertiesHash.get('kappaMaxAbsOverTouch'));
	ylabel(whStr); 
	if (w == 1) ; title('kappa pro');end

	subplot(3,4,(w*4)-2);
	hist( reES.eventPropertiesHash.get('kappaMaxAbsOverTouch'));
	if (w == 1) ; title('kappa ret');end
	
	subplot(3,4,(w*4)-1);
	hist(proES.eventPropertiesHash.get('thetaMeanOverTouch'),-60:5:60);
	ax=axis; axis([-60 60 0 ax(4)]);
	if (w == 1) ; title('theta pro');end
	
	subplot(3,4,(w*4));
	hist( reES.eventPropertiesHash.get('thetaMeanOverTouch'),-60:5:60);
	ax=axis; axis([-60 60 0 ax(4)]);
	if (w == 1) ; title('theta ret');end

	% -- kappa v theta
	figure(fh(3));
  subplot(3,1,w);
	% pro 
	plot(proES.eventPropertiesHash.get('thetaMeanOverTouch'), proES.eventPropertiesHash.get('kappaMaxAbsOverTouch'), '.', 'Color', [0 1 1]);
	hold on;
	plot(reES.eventPropertiesHash.get('thetaMeanOverTouch'), reES.eventPropertiesHash.get('kappaMaxAbsOverTouch'), '.', 'Color', [1 0 1]);
	ax=axis; axis([-60 60 ax(3) ax(4)]);
	if (w == 3) ; xlabel('theta') ;end
	ylabel([whStr ' kappa']);
	if (w == 1) ; legend('Protraction' ,'Retraction','Location','SouthEast'); title('theta'); end




function plotPerformanceVsTouch(obj)
  figure('Position',[0 0 800 600]);
	ovtid = obj.validTrialIds;
	sp1 =  subplot('Position', [0.1 0.55 0.8 0.4]); hold on ; 
	sp2 = subplot('Position', [0.1 0.1 0.8 0.4]); hold on ;

	% base -- ALL
	plotPerfVPos(obj, sp1, sp2, [0 0 0], 0);

  % touch ONLY
	valTrials = [];
	for e=1:length(obj.whiskerBarContactClassifiedESA)
	  valTrials = union(obj.whiskerBarContactClassifiedESA.esa{e}.eventTrials, valTrials);
	end
	obj.validTrialIds = valTrials;
	plotPerfVPos(obj, sp1, sp2, [1 0 0], 500);

  % pro touch ONLY
	valTrials = [];
	for e=1:2:length(obj.whiskerBarContactClassifiedESA)
	  valTrials = union(obj.whiskerBarContactClassifiedESA.esa{e}.eventTrials, valTrials);
	end
	obj.validTrialIds = valTrials;
	plotPerfVPos(obj, sp1, sp2, [0 1 1], -500);

  % ret touch ONLY
	valTrials = [];
	for e=2:2:length(obj.whiskerBarContactClassifiedESA)
	  valTrials = union(obj.whiskerBarContactClassifiedESA.esa{e}.eventTrials, valTrials);
	end
	obj.validTrialIds = valTrials;
	plotPerfVPos(obj, sp1, sp2, [1 0 1], -1000);

  % legends etc
	axes(sp1);  
	legend({'All trials', 'All touches', 'Protractions' ,'Retractions'});
  axes(sp1); cax = axis ; plot([100000 100000], [cax(3) cax(4)], 'r-', 'LineWidth', 3);
  axes(sp2); cax = axis ; plot([100000 100000], [cax(3) cax(4)], 'r-', 'LineWidth', 3);
	obj.validTrialIds = ovtid;

function plotPerfVPos(obj, sp1, sp2, col, xoffs);
	posBinSize = 10000;

  % definition -- what class constitutes what?
  hitL = find(strcmp(obj.trialTypeStr,'HitL'));
  errL = find(strcmp(obj.trialTypeStr,'ErrL'));
  nolickL = find(strcmp(obj.trialTypeStr,'NoLickL'));
  hitR = find(strcmp(obj.trialTypeStr,'HitR'));
  errR = find(strcmp(obj.trialTypeStr,'ErrR'));
  nolickR = find(strcmp(obj.trialTypeStr,'NoLickR'));

  % --- gather everything
  % pull out data -- based on class
	autoTrainMode = {};
	class= zeros(1,length(obj.validTrialIds));
	lickportPos = zeros(1,length(obj.validTrialIds));
	wvtL = zeros(1,length(obj.validTrialIds));
	wvtR = zeros(1,length(obj.validTrialIds));
	stimPos = zeros(1,length(obj.validTrialIds));

	for t=1:length(obj.validTrialIds)
	  ti = find(obj.trialIds == obj.validTrialIds(t));

	  class(t) = obj.trial{ti}.typeIds(1); 

		% pull from behavParams
		wvtL(t) = obj.trial{ti}.behavParams.get('LWaterValveTime');
		wvtR(t) = obj.trial{ti}.behavParams.get('RWaterValveTime');
		lickportPos(t) = obj.trial{ti}.behavParams.get('lickport');
	  autoTrainMode{t} = obj.trial{ti}.behavParams.get('AutoTrainMode');
		stimPos(t) = obj.trial{ti}.behavParams.get('stimulus');
	end


  % --- plot
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

  axes(sp1);
  plot(posBin(1:end-1)+posBinSize/2+xoffs, trialCount,'o', 'Color', col, 'MarkerFaceColor', col)
	set(gca,'TickDir','out', 'XTick', []);
	ylabel('trial count');
	cax = axis;
	axis([-10000 190000 0 cax(4)]);

  axes(sp2);
  plot(posBin(1:end-1)+posBinSize/2 + xoffs, pctCorrect,'o', 'Color', col, 'MarkerFaceColor', col);
	axis([-10000 190000 0 1]);
	hold on;
	plot([-10000 190000], [0.5 0.5], 'k:');

	xlabel('zaber position');
	ylabel('% correct');
	set(gca,'TickDir','out');


