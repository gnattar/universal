% cell summary script
function pos_sorted_plot_play(s, cid)
	%% -- for FINDing the cells
  single_plot(s, cid);
	print('-dpng','-r600', '-noui', ['~/writing/presentations/lab meetings/2012_04_27/images/cell_summ/pos_sorted_' s.mouseId '_cell_' num2str(cid) '.png']);
	pause(.05);
	close;
  return;

function single_plot(s, cid)
	fig = figure('Position', [0 0 400 800]);
	fig = figure('Position', [0 0 600 800]);
	s1 = subplot('Position', [.1 .1 .4 .8]);
	s2 = subplot('Position', [.55 .1 .4 .8]);

  % sort position
	pos = 0*s.validTrialIds;
	for t=1:length(s.validTrialIds)
	  ti = find(s.trialIds == s.validTrialIds(t));
	  pos(t) = s.trial{ti}.behavParams.get('stimulus');
	end

	[irr sidx] = sort(pos);
	cidx = find (s.caTSA.ids == cid);
	fovidx = s.caTSA.roiFOVidx(cidx);

	% 2) TSA thing [title ; trial type labels]
	vec = s.caTSA.dffTimeSeriesArray.getTimeSeriesById(cid).value;
	wvec = s.derivedDataTSA.getTimeSeriesById(10000).value;
	tsm = [s.trialIds ; s.trialStartTimes]';
	ttm = 0*tsm;
	for t=1:size(ttm,1)
		ttm(t,:) = [s.trialIds(t) min(find(s.trialTypeMat(:,t)))];
	end
	ESList = {s.whiskerBarInReachES};
	session.timeSeriesArray.plotTimeSeriesAsImageS(s.caTSA.dffTimeSeriesArray, cidx, ...
			 tsm, ESList, s.validTrialIds(sidx), ttm ,[], 0, gray(256),[0 10],[0 quantile(vec, .995)], ...
			 s1);
	set(s1,'YTick',[]);
	ylabel('sorted by position');

	ESList = {s.whiskerBarInReachES, s.whiskerBarContactClassifiedESA.esa{1},  s.whiskerBarContactClassifiedESA.esa{2}} ;
	session.timeSeriesArray.plotTimeSeriesAsImageS(s.caTSA.dffTimeSeriesArray, cidx, ...
			 tsm, ESList, s.validTrialIds(sidx), ttm ,[], 0, gray(256),[0 10],[0 quantile(vec, .995)], ...
			 s2);
	set(s2,'YTick',[]);
	ylabel('');
%		ylabel('Err R            Err L                                                                      Hit R                                                                                  Hit L');


