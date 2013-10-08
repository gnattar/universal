cn = 1;
roi = 42;

WI = [1 1 2 2 3 3];
WCI = [1 2 3 4 5 6];
%WI = [1 2 3];
%WCI = [1 2 3];
R = [17 19 42];
R = s.caTSA.ids;

ESA = s.whiskerBarContactClassifiedESA;

figure;
N = ceil(sqrt(length(WI)));
ax = [];
for n=1:N*N
  ax(n) = subplot(N,N,n);
end

for w=1:length(WI);
  mumax = nan*s.caTSA.ids;
  for r=R
    roi = find(s.caTSA.ids == r);

		wi = WI(w);
		wci = WCI(w);
		ies = ESA.esa{wci};

		xi = setdiff(WCI,wci);
		xetimes = [];
		for x=1:length(xi)
			%xetimes = [xetimes s.whiskerBarContactESA.esa{xi(x)}.eventTimes];
			xetimes = [xetimes ESA.esa{xi(x)}.eventTimes];
		end

		etimes =[];
		for c=1:length(cn)
			[tetimes tetrials] = ies.getNthEventByTrialWrapper(cn(c));
			etimes = [etimes tetimes];
		end

		TS = s.caTSA.dffTimeSeriesArray.tsa{roi};
		[idxMat timeMat timeVec] = session.timeSeries.getIndexWindowsAroundEventsS(TS.time, TS.timeUnit, ...
		  [0 2], 2, etimes, ies.timeUnit, [0 2.5], xetimes, ies.timeUnit);
		valIdx = find(~isnan(idxMat));
		valMat = nan*idxMat;
		valMat(valIdx) = TS.value(idxMat(valIdx));

		mdff = max(valMat');
		baseline = median(TS.value);

	if (0)
		TS = s.whiskerCurvatureChangeTSA.tsa{wi};
		[idxMat timeMat timeVec] = session.timeSeries.getIndexWindowsAroundEventsS(TS.time, ...
		   TS.timeUnit, [-0.25 0.25], 2, etimes, ies.timeUnit, [-2 4], xetimes, ies.timeUnit);
		valIdx = find(~isnan(idxMat));
		valMat = nan*idxMat;
		valMat(valIdx) = TS.value(idxMat(valIdx));
		valMat = medfilt1(valMat')';
		MK = max(valMat');
		mK = min(valMat');
		neg = find(abs(mK) > MK);
		MK(neg) = mK(neg);

		ML = nanmedian(valMat');
	end

%		mumax(roi) = nanmean(mdff)/baseline;
		mumax(roi) = nanmean(mdff);
		disp(['roi: ' num2str(roi) ' wi: ' num2str(wi) ' wci: ' num2str(wci) ' mean max: ' num2str(mumax(roi))]);
	end
  

  s.plotColorRois([],[],[],jet(256),mumax,[0 0.5],ax(w),1);
	axes(ax(w));
  title([ies.idStr]);
end
