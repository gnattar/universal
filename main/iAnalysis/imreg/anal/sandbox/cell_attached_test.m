%% For model evaluation using cell attached data

% load cell attached
clear catsa;
if (0)
	cd('/Users/speron/Desktop/current/calcium_model/354_cell_attached_data');
	cd('/Users/speron/Desktop/current/calcium_model/641_cell_attached_data');
	fl = dir('*para.mat');
	activity_class = 3*ones(length(fl),1);
	for f=1:length(fl)
		load (fl(f).name);;;;
		time_vec = para.t_frame;
		time_unit = session.timeSeries.second;

		% for data, we apply Tsai-Wen's neuropil correction
		data_vec =para.fmean-0.7*para.fneuropil;

		% build timeSeries
		ts{f} = session.timeSeries(time_vec, time_unit, data_vec, f, ['Dff from ' fl(f).name], 0, []);

		% downsample
		dt = 142.9922; % in ms for my data
		dt = dt/1000;
		newTime = min(ts{f}.time):dt:max(ts{f}.time);
		tsDS{f} = ts{f}.copy();
		tsDS{f}.reSample(100, [], newTime);

		% should allow singulars but for some reason not so ...
		nts = {};
		nts{1} = tsDS{f}.copy();
		nts{2} = tsDS{f}.copy();
		catsa{f} = session.calciumTimeSeriesArray(nts);

		actParams.cofThresh = 0.05;
		actParams.nabThresh = 0.005;
%		actParams.nabThresh = 0.015;
		actParams.forceRedo = 1;
		catsa{f}.getRoiActivityStatistics(actParams);

    if(catsa{f}.roiActivityStatsHash.get('activeIdx')) ; activity_class(f) = 2; end
    if(catsa{f}.roiActivityStatsHash.get('hyperactiveIdx')) ; activity_class(f) = 1; end

		% spike ES
		peak_idx = find(para.peak);
		peak_times = para.t_ephys(peak_idx);
		spike_es{f} = session.eventSeries(peak_times, 0*peak_times+1, time_unit, f, ['Spikes from ' fl(f).name], 0, [], '', [1 0 0], 1); 
	end
end

%for f=5
for f=1:length(fl)
%	f = 6;

	% now pull dff ...
	actParams.cofThresh = 0.15;
	actParams.nabThresh = 0.005;
	actParams.forceRedo = 1;

	fParams.actParams = actParams;

	fParams.fZeroFilterParams.timeUnit = time_unit;
	fParams.fZeroFilterParams.filterType = 'quantile';
	fParams.fZeroFilterParams.filterSizeSeconds = 60;
	fParams.fZeroFilterParams.quantileThresh = .1;


	% template fitter params
	evdetOpts.timeUnit = time_unit;
	evdetOpts.hyperactiveIdx = [];
	evdetOpts.activeIdx = [];
	if (activity_class(f) == 1)
		evdetOpts.hyperactiveIdx = 1;
	elseif (activity_class(f) == 2)
		evdetOpts.activeIdx = 1;
	end
	%tauDt = (8.5*3):(8.5*30);
	tauDt = round(8.5*(3:30));
	evdetOpts.tausInDt = tauDt;
	tRises = round(8.5*(1:5));
	evdetOpts.tRiseInDt = tRises;

	evdetOpts.debug = 0;
	evdetOpts.initThreshSF = [1.5 2 2.5]; % hyperactive active and inactive thresholds

	evdetOpts.templateFitSF = 1;

  % NO rejection
	evdetOpts.minFitRawCorr = 0;
	evdetOpts.fitResidualSDThresh = Inf;

	if (0) % full sampling rate
		dffTS = session.calciumTimeSeriesArray.generateDffFromRawFluo(ts{f},fParams);
		caES = session.timeSeries.getCalciumEventSeriesFromExponentialTemplateS(dffTS.time,dffTS.value,evdetOpts);

		% plot results
		figure;
		dffTS.plot
		hold on ; 
		caES{1}.plot();
		spike_es{f}.plot([0 0 1], [0.5 1.5]);
	end


  %% DOWNSAMPLED

	% generate dff from resampled
	dffTSDS = session.calciumTimeSeriesArray.generateDffFromRawFluo(tsDS{f},fParams);

	% and redo events ...
  templateFitSF =1;
	templateFitSF = 0.1:0.1:5; 
	fpRate = 0*templateFitSF;
	tpRate = 0*templateFitSF;


	for t=1:length(templateFitSF)
		evdetOpts.tausInDt = 3:30; % ORIGINAL
		evdetOpts.tRiseInDt = 1:5; % ORIGINAL
		evdetOpts.templateFitSF = templateFitSF(t);

		caESDS = session.timeSeries.getCalciumEventSeriesFromExponentialTemplateS(dffTSDS.time,dffTSDS.value,evdetOpts);


		%% ROC (hit if within 500 ms?)
		burstDt = .500; % ms
		burstDt = dt;
		timeWindow = [-1*dt dt];

		% convert both to burst rates
		spike_bursts{f} = spike_es{f}.getBurstTimes(burstDt);
		ca_bursts{f} = caESDS{1}.getBurstTimes(burstDt);

		spikeBurstES = session.eventSeries(spike_bursts{f}, 0*spike_bursts{f}, spike_es{f}.timeUnit,0, 'spike Bursts', ...
			 0, [], [], [1 0 1], 1);
		caBurstES = session.eventSeries(ca_bursts{f}, 0*ca_bursts{f}, caESDS{1}.timeUnit,0, 'ca Bursts', ...
			 0, [], [], [1 0 1], 1);



		% plot results
		if (0)
			figure;
			dffTSDS.plot
			hold on ; 
			caESDS{1}.plot([1 0 0]);
			spike_es{f}.plot([0 0 1], [0.5 1.5]);
			spikeBurstES.plot([0 1 1], [1.5 2]);
			caBurstES.plot([1 0 1], [2 2.5]);
		end

		% now get condiprob ... predicted|actual ; convert this to hit count
		%  then hit count / num spikes = true positive rate
		%  and false positive rate is just the rest . . .
	%	truePositiveRate = session.eventSeries.getConditionalProbability(ts{f}, ca_bursts{f}, timeWindow, [], ...
	%				[], spike_bursts{f}, timeWindow, [], [], session.timeSeries.second, 0, 0);

		% false + rate
		falsePositiveCount = 0;
		truePositiveCount = 0;
		for e=1:caBurstES.length
			temporalWindow = caBurstES.eventTimes(e) + timeWindow;
			if (length(find(spikeBurstES.eventTimes > temporalWindow(1) & spikeBurstES.eventTimes < temporalWindow(2))) == 0)
				falsePositiveCount = falsePositiveCount + 1;
			else 
				truePositiveCount = truePositiveCount + 1;
			end
		end
		falsePositiveRate =falsePositiveCount/caBurstES.length();
		truePositiveRate =truePositiveCount/spikeBurstES.length();

		disp(['TP: ' num2str(truePositiveRate) ' FP: ' num2str(falsePositiveRate)]);
		tpRate(t) = truePositiveRate;
		fpRate(t) = falsePositiveRate;
	end
	figure ; plot(fpRate,tpRate,'rx-');
	axis([0 1 0 1]);
	xlabel('false positive rate');
	ylabel('hit rate');

	xvals = 0:0.1:1;
	yvals = nan*zeros(1,length(xvals)-1);
	for x=1:length(xvals)-1
		idx = find(fpRate >= xvals(x) & fpRate < xvals(x+1));
		if (length(idx) > 0)
			yvals(x) = mean(tpRate(idx));
		end
	end

	title(strrep([fl(f).name ' AUC: ' num2str(nanmedian(yvals))], '_','-'));

	 %% LOOK AT AMPLITUDE vs. SPIKE COUNT

	 %% LOOK AT REAL RATES FOR SINGLE SPIKE, TIME WINDOW = +/-dt
end


