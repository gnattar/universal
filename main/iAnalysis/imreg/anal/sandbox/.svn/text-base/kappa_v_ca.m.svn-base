
%roi = 65;
%w = 1;


%s = sA.sessions{3};
maxdff = 0*s.validTrialIds;
maxkapp = 0*s.validTrialIds;
minkapp = 0*s.validTrialIds;
for t=1:length(s.validTrialIds)
  ti = find(s.trialIds == s.validTrialIds(t));

  tri = find(s.caTSA.dffTimeSeriesArray.trialIndices == ti);
	if (length(tri) > 0)
	  maxdff(t) = max(s.caTSA.dffTimeSeriesArray.valueMatrix(roi,tri));
	end

  tri = find(s.derivedDataTSA.trialIndices == ti);
	if (length(tri) > 0)
	  maxkapp(t) = max(s.derivedDataTSA.tsa{16}.value(tri));
	  minkapp(t) = min(s.derivedDataTSA.tsa{17}.value(tri));
	end

end
figure;
plot(maxkapp,maxdff,'rx');
hold on;
plot(minkapp,maxdff,'bx');

% more intense
maxdff = 0*s.validTrialIds;
maxkapp = 0*s.validTrialIds;
minkapp = 0*s.validTrialIds;
maxabskapp = 0*s.validTrialIds;
for t=1:length(s.validTrialIds)
  tn = s.validTrialIds(t);
  ti = find(s.whiskerCurvatureChangeTSA.trialIndices == tn);
	vv = s.whiskerCurvatureChangeTSA.valueMatrix(w,ti);
	tv = s.whiskerCurvatureChangeTSA.time(ti);
 
  % 1st pole command
	pire = find(s.behavESA.esa{5}.eventTrials == tn);
	if (length(pire) > 0)
	  pirt = s.behavESA.esa{5}.eventTimes(pire(1));

		% max d-kappa
		si = min(find(tv) > pirt);
		se = si + 1500; % 3 s period
		maxkapp(t) = max(medfilt1(vv));
		minkapp(t) = min(medfilt1(vv));

		maxabskapp(t) = maxkapp(t);
		if (maxkapp(t) < abs(minkapp(t))) ; maxabskapp(t) = minkapp(t) ; end

		% max dff
		si = min(find(s.caTSA.dffTimeSeriesArray.time > pirt));
		se = si + 11; % 3 s period after pole
		maxdff(t) = max(s.caTSA.dffTimeSeriesArray.valueMatrix(roi,si:se));
	end
end
figure;
plot(maxabskapp,maxdff, 'rx')







