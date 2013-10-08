% nwhisker x 3 panel figure: max abs dkappa vs. peak df/f per trial ; 
%                            max (+) dkappa, max (-) dKappa

ESA = s.whiskerBarContactESA;
wTSA = s.whiskerCurvatureChangeTSA;
N = length(ESA.esa);
Nw = length(wTSA.tsa);
dkMatRange = 400:1200;
R = [42 65 67 79 187];
R =42;
% roi loop
for r=R
	% setup figure
	figure;
	Np = ceil(sqrt(N));
	kr = .015;

	% whisker loop
	for e=1:N

		% whisker TS (delta kappa)
		wTS = wTSA.tsa{e};

		% calcium TS
		caTS = s.caTSA.dffTimeSeriesArray.tsa{r};

		% grab data
		ies = ESA.esa{e};
		trialsMatching = session.eventSeries.getTrialsByEvent(ies, [], s.validTrialIds);
		[timeMat dffMat] = session.timeSeries.getTrialMatrix(caTS.time, caTS.value, s.caTSA.trialIndices, trialsMatching);
		[timeMat dkMat] = session.timeSeries.getTrialMatrix(wTS.time, wTS.value, wTSA.trialIndices, trialsMatching);
		
    % median filter & restrict temporally to pole period
		dkMat = dkMat(:,dkMatRange);
		dkMat = medfilt1(dkMat',5)';

		% create a CLEANED dkMat
		dkVec = reshape(dkMat',[],1);
    nv = session.timeSeries.filterKsdensityStatic([],dkVec,1000,100);
    ndkVec = (dkVec-nv);
		ndkMat = reshape(ndkVec,  size(dkMat,2), size(dkMat,1));

		% get thresholds for dk
		dkThresh = 2*mad(dkVec);

		% compute FIRST TOUCH dk
		andkMat = abs(ndkMat);
		ftdk = zeros(1,size(ndkMat,2));
		for t=1:size(ndkMat,2)
		  ftIdx = min(find(andkMat(:,t) > dkThresh));
			if (length(ftIdx) > 0)
			  timeWindow = [max(1,ftIdx-10) min(size(ndkMat,1),ftIdx+10)];
			  ftdk(t) = max(andkMat(timeWindow,t));
			end
		end

		% compute maxdff
		maxdff = max(dffMat');

    % compute kappas (min max absmax)
		maxdkappa = max(dkMat');
		mindkappa = min(dkMat');
		maxabsdkappa = maxdkappa;
		neg = find(abs(mindkappa) > maxdkappa);
		pos = find(abs(mindkappa) < maxdkappa);
		maxabsdkappa(neg) = abs(mindkappa(neg));

		% plot RFs
		subplot(4,Nw,e);
		plot (maxdkappa, maxdff, 'rx');
		title(['roi ' num2str(r) ' max ' s.whiskerTag{e}]);
		axis([0 kr 0 1.1*max(caTS.value)]);

		subplot(4,Nw,e+3);
		plot (mindkappa, maxdff, 'rx');
		title(['min abs ' s.whiskerTag{e}]);
		axis([-1*kr 0 0 1.1*max(caTS.value)]);

		subplot(4,Nw,e+6);
		plot (maxdkappa(pos), maxdff(pos), 'rx');
		hold on;
		plot (abs(mindkappa(neg)), maxdff(neg), 'bx');
		title(['max abs ' s.whiskerTag{e}]);
		axis([0 kr 0 1.1*max(caTS.value)]);
		disp(['roi ' num2str(r) 'max abs ' s.whiskerTag{e} ' corr spear: ' num2str(corr(maxabsdkappa',maxdff', 'type','Spearman'))]);
	%	plot(nanmean(valueMat));

		subplot(4,Nw,e+9);
		plot (ftdk, maxdff, 'rx');
		title(['dk first touch']);
		axis([0 kr 0 1.1*max(caTS.value)]);
	end
end



