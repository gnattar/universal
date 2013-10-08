% nwhisker x 3 panel figure: max abs dkappa vs. peak df/f per trial ; 
%                            max (+) dkappa, max (-) dKappa

ESA = s.whiskerBarContactESA;
wTSA = s.whiskerCurvatureChangeTSA;
N = length(ESA.esa);
Np = ceil(sqrt(N));
Nw = length(wTSA.tsa);
dkMatRange = 400:1200;
dffMatRange = 6:12;

R =42;
R = [42 65 67 79 187];
R = 1:length(s.caTSA.ids);
kr = .015;

for r=1:length(R)
%  fighan(r) = figure;
end

% calcium pooled thresh
madVec = mad(s.caTSA.dffTimeSeriesArray.valueMatrix');
val = find(~isnan(madVec) & ~isinf(madVec));
pooldffthresh = 2*mean(madVec(val));

% whisker loop
scoremat = zeros(N,length(R));
for e=1:N

	% whisker TS (delta kappa)
	wTS = wTSA.tsa{e};

	% grab data
	ies = ESA.esa{e};
	trialsMatching = session.eventSeries.getTrialsByEvent(ies, [], s.validTrialIds);
	[timeMat dkMat] = session.timeSeries.getTrialMatrix(wTS.time, wTS.value, wTSA.trialIndices, trialsMatching);
	
	% median filter & restrict temporally to pole period
	dkMat = dkMat(:,dkMatRange);
%	dkMat = medfilt1(dkMat',5)';

	% create a CLEANED dkMat
	dkVec = reshape(dkMat',[],1);
%	nv = session.timeSeries.filterKsdensityStatic([],dkVec,1000,100);
%	ndkVec = (dkVec-nv);
%	ndkMat = reshape(ndkVec,  size(dkMat,2), size(dkMat,1));

	% get thresholds for dk
	dkThresh = 2*mad(dkVec);

	% compute FIRST TOUCH dk
	adkMat = abs(dkMat);
	ftdk = zeros(1,size(dkMat,2));
	for t=1:size(dkMat,2)
		ftIdx = min(find(adkMat(:,t) > dkThresh));
		if (length(ftIdx) > 0)
			timeWindow = [max(1,ftIdx-10) min(size(dkMat,1),ftIdx+10)];
			ftdk(t) = max(adkMat(timeWindow,t));
		end
	end

	% compute kappas (min max absmax)
	maxdkappa = max(dkMat');
	mindkappa = min(dkMat');
	maxabsdkappa = maxdkappa;
	neg = find(abs(mindkappa) > maxdkappa);
	pos = find(abs(mindkappa) < maxdkappa);
	maxabsdkappa(neg) = abs(mindkappa(neg));

	% kappa statistics for cutoff . . . 
	force = maxabsdkappa;
	forceVec = dkVec;
	[pdf xi] = ksdensity(forceVec);
	[irr idx] = max(pdf);
	baseforce = xi(idx);
	threshforce = baseforce + 2*mad(forceVec);

	% roi loop
	for ri=1:length(R)
	  r = R(ri);

		% calcium TS
		caTS = s.caTSA.dffTimeSeriesArray.tsa{r};

		% compute maxdff
		[timeMat dffMat] = session.timeSeries.getTrialMatrix(caTS.time, caTS.value, s.caTSA.trialIndices, trialsMatching);
	  dffMat = dffMat(:,dffMatRange);
	  dffVec = reshape(dffMat',[],1);
		maxdff = max(dffMat');

		% calcium threshold
		[pdf xi] = ksdensity(dffVec);
		[irr idx] = max(pdf);
		basedff = xi(idx);
		threshdff = basedff + 2*mad(dffVec);
threshdff = pooldffthresh;
		% compute score -- above threshold is good, below ONE but not both is bad
		n_good = length(find(maxdff > threshdff & force > threshforce));
		n_bad1 = length(find(maxdff > threshdff & force < threshforce)) ;
		n_bad2 = length(find(maxdff < threshdff & force > threshforce));
		n_bad = n_bad1 + n_bad2;
		score = (n_good-n_bad)/(n_good+n_bad); % classic directionality index A-B/A+B
		scoremat(e,ri) = score;

		% plot RFs
		if ( 0 == 1 )
%			figure(fighan(ri));
session.session.plotRF(force, maxdff,'raw');

pause;
			subplot(Np,Np,e);
			hold off;
			plot (force, maxdff, 'rx');
			hold on; 
			plot ([1 1]*threshforce, [0 1.1*max(caTS.value)], 'b-');
			plot ([0 kr], [1 1]*threshdff, 'b-');
			title(['roi ' num2str(r) ' max ' s.whiskerTag{e} ' score: ' num2str(score)]);
			axis([0 kr 0 1.1*max(caTS.value)]);
			pause;
		end
	end
end



