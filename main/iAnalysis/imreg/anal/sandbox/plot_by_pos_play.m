% plots cell responses by trial type but sorted within by position

fig = figure('Position', [0 0 800 800]);
s1 = subplot('Position', [.05 .05 .7 .9]);
s2 = subplot('Position', [.8 .05 .15 .9]);
sortByType = 0;

dt = mode(diff(s.caTSA.time));
i1 = round(1200/dt);
i2 = round(7000/dt);

for c=25:length(s.caTSA.ids)
	cid = s.caTSA.ids(c);
	cidx = find (s.caTSA.ids == cid);

	% 1) get stimulus position
	stimpos = 0*s.validTrialIds;
	for t=1:length(s.validTrialIds)
		ti = find(s.trialIds == s.validTrialIds(t));
		stimpos(t) = s.trial{ti}.behavParams.get('stimulus');
	end
	[irr sidx] = sort(stimpos,'descend');
	s.validTrialIds = s.validTrialIds(sidx);

	% 2) TSA thing [title ; trial type labels]
	vec = s.caTSA.dffTimeSeriesArray.getTimeSeriesById(cid).value;
	tsm = [s.trialIds ; s.trialStartTimes]';
	ttm = 0*tsm;
	for t=1:size(ttm,1)
		ttm(t,:) = [s.trialIds(t) min(find(s.trialTypeMat(:,t)))];
	end
	ESList = {s.whiskerBarInReachES, s.whiskerBarContactClassifiedESA.esa{1},  s.whiskerBarContactClassifiedESA.esa{2}} ;
	session.timeSeriesArray.plotTimeSeriesAsImageS(s.caTSA.dffTimeSeriesArray, cidx, ...
			 tsm, ESList, s.validTrialIds, ttm ,[], sortByType, gray(256),[0 10],[0 quantile(vec, .995)], ...
			 s1);
	set(s1,'YTick',[]);

	% 3) generate a matrix sorted by position
	ntp = 70;
	valmat = zeros(length(s.validTrialIds), ntp);
	vvec = s.caTSA.dffTimeSeriesArray.getTimeSeriesById(cid).value;
	for t=1:length(s.validTrialIds)
	  ti = find(s.caTSA.trialIndices == s.validTrialIds(t));
	  valmat(t,1:min(ntp,length(ti))) = vvec(ti(1:min(ntp,length(ti))));
	end
	rvec = max(valmat(:,i1:i2),[],2);
  	rvec = sum(valmat(:,i1:i2),2);

	axes(s2);
	plot(rvec(end:-1:1), 1:length(s.validTrialIds), 'r-','LineWidth',2);
  a = axis;
	axis([a(1) a(2) 0 length(s.validTrialIds)]);


	pause;
end
