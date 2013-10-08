% cell summary script
function cell_summ_play(s, cid)
	%% -- for FINDing the cells
  single_plot(s, cid);
	print('-dpng','-r600', '-noui', ['~/Desktop/cell_summ_' num2str(cid) '_' s.mouseId '.png']);
%	print('-dpng','-r600', '-noui', ['~/writing/presentations/lab meetings/2012_04_27/images/cell_summ/' num2str(cid) '_' s.mouseId '.png']);
	pause(.05);
	close;
  return;

	%% -- for FINDing the cells
	scores = [];
	ids = [];
	volids = [];

	featname = 'RetractionContactsForC2AUC';
	featname = 'ProtractionContactsForC2AUC';
	featname = 'ContactsForC2AUC';

	featname = 'MeanWhiskerAmplitudeCorr';
	featname = 'WhiskerSetpointCorr';
	for v=1:length(S)
		feat = S{v}.cellFeatures.get(featname);
		scores = [scores feat];
		ids = [ids S{v}.caTSA.ids];
		volids = [volids zeros(1,length(feat))+v];
	end
	scores (find(isnan(scores))) = 0;
	[ssc sidx] = sort(scores,'descend');
	cidxs = sidx(1:20);

	for c=1:length(cidxs)
	  single_plot(S{volids(cidxs(c))}, ids(cidxs(c)));
		print('-dpng','-r600', '-noui', ['~/writing/presentations/lab meetings/2012_03_23/images/sample_cells_2/' num2str(ids(cidxs(c))) '_' featname '.png']);
		pause(.05);
		close;
	end

function single_plot(s, cid)
	%% -- touch cell plotter
	if (0)
		fig = figure('Position', [0 0 800 800]);
		s1 = subplot('Position', [.05 .55 .3 .3]);
		s2 = subplot('Position', [.1 .1 .35 .3]);
		s3 = subplot('Position', [.5 .1 .22 .8]);
		s4 = subplot('Position', [.725 .1 .22 .8]);

		% 1) cell position
		cidx = find (s.caTSA.ids == cid);
		fovidx = s.caTSA.roiFOVidx(cidx);
		colvec = 0*s.caTSA.ids;
		colvec(cidx) = 1;
		s.plotColorRois([],[],[],[1 1 0],colvec, [0 1], s1, 0 , fovidx);
		subplot(s1);
		title(['Plane ' num2str(floor(cid/1000)+1)]);

		% 2) TSA thing [title ; trial type labels]
		vec = s.caTSA.dffTimeSeriesArray.getTimeSeriesById(cid).value;
		wvec = s.derivedDataTSA.getTimeSeriesById(10000).value;
		tsm = [s.trialIds ; s.trialStartTimes]';
		ttm = 0*tsm;
		for t=1:size(ttm,1)
			ttm(t,:) = [s.trialIds(t) min(find(s.trialTypeMat(:,t)))];
		end
		ESList = {s.whiskerBarInReachES, s.whiskerBarContactClassifiedESA.esa{1},  s.whiskerBarContactClassifiedESA.esa{2}} ;
		session.timeSeriesArray.plotTimeSeriesAsImageS(s.caTSA.dffTimeSeriesArray, cidx, ...
				 tsm, ESList, s.validTrialIds, ttm ,[], 1, gray(256),[0 10],[0 quantile(vec, .995)], ...
				 s3);
		session.timeSeriesArray.plotTimeSeriesAsImageS(s.derivedDataTSA, 1, ...
				 tsm, ESList, s.validTrialIds, ttm ,[], 1, gray(256),[0 10],[quantile(wvec,.005) quantile(wvec, .995)], ...
				 s4);
		set(s4,'YTick',[]);
		set(s3,'YTick',[]);
		subplot(s3);
%		ylabel('Err R            Err L                                                                      Hit R                                                                                  Hit L');

		% 3) triggd avg
		mv = ceil(quantile(vec,.99));
		session.session.plotEventTriggeredAverageS(s.caTSA.dffTimeSeriesArray, cidx, s.whiskerBarContactClassifiedESA.esa{1}, 1, [-2 5 -1 mv], [nan s2], [0 1 1]);
		session.session.plotEventTriggeredAverageS(s.caTSA.dffTimeSeriesArray, cidx, s.whiskerBarContactClassifiedESA.esa{2}, 1, [-2 5 -1 mv], [nan s2], [1 0 1]);
		text(0.5,-0.25, 'Retraction', 'Color', [1 0 1]);
		text(0.5,-0.75, 'Protraction', 'Color', [0 1 1]);

		subplot(s2);
		title('Touch-triggered averages');
	end

	%% -- setpoint/amp cell plotter
	if (1)
	  whTSId = 10010; % amplitude
	  whTSId = 10000; % setpoint

		fig = figure('Position', [0 0 800 800]);
		s1 = subplot('Position', [.05 .55 .3 .3]);
		s2 = subplot('Position', [.1 .1 .35 .3]);
		s3 = subplot('Position', [.5 .1 .22 .8]);
		s4 = subplot('Position', [.725 .1 .22 .8]);


		% 1) cell position
		cidx = find (s.caTSA.ids == cid);
		fovidx = s.caTSA.roiFOVidx(cidx);
		colvec = 0*s.caTSA.ids;
		colvec(cidx) = 1;
		s.plotColorRois([],[],[],[1 1 0],colvec, [0 1], s1, 0 , fovidx);
	  subplot(s1);
		title(['Plane ' num2str(floor(cid/1000)+1)]);


		% 2) TSA thing [title ; trial type labels]
		vec = s.caTSA.dffTimeSeriesArray.getTimeSeriesById(cid).value;
		wvec = s.derivedDataTSA.getTimeSeriesById(whTSId).value; 
		tsm = [s.trialIds ; s.trialStartTimes]';
		ttm = 0*tsm;
		for t=1:size(ttm,1)
			ttm(t,:) = [s.trialIds(t) min(find(s.trialTypeMat(:,t)))];
		end
		ESList = {s.whiskerBarInReachES, s.whiskerBarContactClassifiedESA.esa{1},  s.whiskerBarContactClassifiedESA.esa{2}} ;
		session.timeSeriesArray.plotTimeSeriesAsImageS(s.caTSA.dffTimeSeriesArray, cidx, ...
				 tsm, ESList, s.validTrialIds, ttm ,[], 1, gray(256),[0 10],[0 quantile(vec, .995)], ...
				 s3);
		session.timeSeriesArray.plotTimeSeriesAsImageS(s.derivedDataTSA, find(s.derivedDataTSA.ids == whTSId), ...
				 tsm, ESList, s.validTrialIds, ttm ,[], 1, gray(256),[0 10],[quantile(wvec,.005) quantile(wvec, .995)], ...
				 s4);
		set(s4,'YTick',[]);
		set(s3,'YTick',[]);
		subplot(s3);
	%	ylabel('Err R            Err L                                                                      Hit R                                                                                  Hit L');

		% 3) correlation
		session.session.plotTSCrossCorrelationS(s.caTSA.dffTimeSeriesArray, cid, s.derivedDataTSA, 10000, -20:20, s2, [], [.9 .9 0]);
		subplot(s2);
		hold on;
		session.session.plotTSCrossCorrelationS(s.caTSA.dffTimeSeriesArray, cid, s.derivedDataTSA, 10010, -20:20, s2, [], [ 0 1 0]);
	  text(-3000,0.4, 'Setpoint', 'Color', [.9 .9 0]);
		text(-3000,0.3, 'Amplitude', 'Color', [0 1 0]);
		ylabel('Correlation');
    axis([-4000 4000 -.05 .5]);

%		subplot(s2);
%		title('Time-shifted correlations');
	end


