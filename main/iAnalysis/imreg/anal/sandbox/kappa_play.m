cn = 1;
roi = 42;

WI = [1 1 2 2 3 3];
WCI = [1 2 3 4 5 6];
%WI = [1 2 3];
%WCI = [1 2 3];

for w=1:length(WI);
	wi = WI(w);
	wci = WCI(w);
	ies = s.whiskerBarContactClassifiedESA.esa{wci};

  xi = setdiff(WCI,wci);
	xetimes = [];
	for x=1:length(xi)
	  %xetimes = [xetimes s.whiskerBarContactESA.esa{xi(x)}.eventTimes];
	  xetimes = [xetimes s.whiskerBarContactClassifiedESA.esa{xi(x)}.eventTimes];
	end

	etimes =[];
	for c=1:length(cn)
		[tetimes tetrials] = ies.getNthEventByTrialWrapper(cn(c));
		etimes = [etimes tetimes];
	end

	TS = s.caTSA.dffTimeSeriesArray.tsa{roi};
	[idxMat timeMat timeVec] = session.timeSeries.getIndexWindowsAroundEventsS(TS.time, TS.timeUnit, [0 2.5], 2, etimes, ies.timeUnit, [-2 4], xetimes, ies.timeUnit);
	valIdx = find(~isnan(idxMat));
	valMat = nan*idxMat;
	valMat(valIdx) = TS.value(idxMat(valIdx));

	mdff = max(valMat');

	TS = s.whiskerCurvatureChangeTSA.tsa{wi};
	[idxMat timeMat timeVec] = session.timeSeries.getIndexWindowsAroundEventsS(TS.time, TS.timeUnit, [-0.25 0.5], 2, etimes, ies.timeUnit, [-2 4], xetimes, ies.timeUnit);
	valIdx = find(~isnan(idxMat));
	valMat = nan*idxMat;
	valMat(valIdx) = TS.value(idxMat(valIdx));
  valMat = medfilt1(valMat')';
	MK = max(valMat');
	mK = min(valMat');
	neg = find(abs(mK) > MK);
	MK(neg) = mK(neg);

	ML = nanmean(valMat');
  
	% filter
	if ( 1 == 0)
		maxDff = max(mdff);
		% reject bottom 20%
		val = find(mdff > 0.2*maxDff);
		
		% reject near zero
		maxK = max(abs(MK));
		val = intersect(val,find(abs(MK) > 0.2*maxK));

    S = length(val)/length(mdff);
     
		mdff = mdff(val);
		MK = MK(val);
	end

  if (1)
	  mumax = nanmean(mdff);
		disp(['wi: ' num2str(wi) ' wci: ' num2str(wci) ' mean max: ' num2str(mumax)]);
	end

	if (1 & length(MK) > 0)
		figure
		plot(MK,mdff,'rx')
		C = corr(abs(MK'),mdff');
    S = C;
		title(['wi: ' num2str(wi) ' wci: ' num2str(wci) ' corr: ' num2str(S)]);
	end
end
