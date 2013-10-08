ESA = s.whiskerBarContactESA;
%ESA = s.whiskerBarContactClassifiedESA;
N = length(ESA.esa);
envPredCaFrac = [];
caPredEnvFrac = [];
PcaGwh = [];
PwhGca = [];
burstDt = 500;

colors = [1 0 0 ; 0 1 0 ; 0 0 1 ; 1 0 1 ; 1 1 0 ; 0 1 1];
mode = 1;

if (mode == 1)
	figure;
	Np = ceil(sqrt(N));
	netResp = zeros(1,length(s.caTSA.ids));
	for e=1:N
		myax = subplot(Np,Np,e);

		% whisker window
		bes = ESA.esa{e};
		% build excluded
		xId = ESA.ids(e);
		xbes = ESA.getExcludedCellArray(xId);

    % P(ca|single whisker touch)
		for r=1:length(s.caTSA.ids)
		  aes{r} = s.caTSA.caPeakEventSeriesArray.esa{r}.getBurstTimes(burstDt);
			nev(r) = length(find(~isnan(aes{r})));
		end
    PcaGwh = session.eventSeries.getConditionalProbability(s.caTSA, aes, [-0.5 0], [], [], bes, [], xbes, [-2 2], [], 1, 0);
%    PcaGwh= session.eventSeries.getConditionalProbability(s.caTSA, aes, [-2 0], [], [], bes, [], [], [-2 2], [], 1, 0);

    % P(single whisker touch|ca)
		for r=1:length(s.caTSA.ids)
			PwhGca(r) = session.eventSeries.getConditionalProbability(s.caTSA, bes, [0 2], xbes, [-2 2], aes{r}, [], [], [], [], 0, 1);
			%PwhGca (r) = session.eventSeries.getConditionalProbability(s.caTSA, bes, [0 2], [], [], aes{r}, [], [], [], [], 0, 1);
		end

   resp = PwhGca.*PcaGwh;
    resp = PcaGwh;
		resp(find(nev < 10)) = 0;
    
		s.plotColorRois([],[],[],[],resp, [0 1], myax, 1); 
		title([ESA.esa{e}.idStr]);
		resp(find(isnan(resp))) = 0;
		netResp = netResp + resp;
	end
	% plot total response
	figure;myax = subplot(1,1,1);
	s.plotColorRois([],[],[],[],netResp, [0 1], myax, 1); 
	netResp = netResp + resp;
	title('net touch');
elseif (mode == 2)

	figure;
	Np = ceil(sqrt(N));
	for e=1:N
		myax = subplot(Np,Np,e);

		% whisker window
		ies = ESA.esa{e};
		% build excluded
		xesTimes = [];
		for x=setdiff(1:N, e)
%			xesTimes = union(xesTimes,ESA.esa{x}.eventTimes);
		end
		iestu = s.caTSA.timeUnit;
		[idxMat timeMat timeVec] = session.timeSeries.getIndexWindowsAroundEventsS(s.caTSA.time, s.caTSA.timeUnit, ...
			[0 1], 2, ies.eventTimes, iestu,[-2 2],xesTimes,iestu,0);
		widx = reshape(idxMat,[],1);
		widx = widx(find(~isnan(widx)));

		for r=1:length(s.caTSA.ids)
			ri = r;

			% now do index windows
			ies = s.caTSA.caPeakEventSeriesArray.esa{ri};
			iestu = s.caTSA.timeUnit;
			[idxMat timeMat timeVec] = session.timeSeries.getIndexWindowsAroundEventsS(s.caTSA.time, s.caTSA.timeUnit, ...
				[0 0], 2, ies.eventTimes, iestu,[],[],[],1);
			caidx = reshape(idxMat,[],1);
			caidx = caidx(find(~isnan(caidx)));


			ni = length(intersect(widx,caidx));

			% how reliably does this cell encode the sensory variable (FOLLOW it)?
			envPredCaFrac(r) = ni/length(caidx);

		end
		s.plotColorRois([],[],[],[],envPredCaFrac, [0 1], myax, 0); 
		title(['envpred ' ESA.esa{e}.idStr ' ' s.dateStr ' n=' num2str(length(widx))]);
	end
elseif (mode == 3) % ANY touch

	figure;
	myax = subplot(1,1,1);
	widx = [];
	for e=1:N

		% whisker window
		ies = ESA.esa{e};
		% build excluded
		xesTimes = [];
		for x=setdiff(1:N, e)
%			xesTimes = union(xesTimes,ESA.esa{x}.eventTimes);
		end
		iestu = s.caTSA.timeUnit;
		[idxMat timeMat timeVec] = session.timeSeries.getIndexWindowsAroundEventsS(s.caTSA.time, s.caTSA.timeUnit, ...
			[0 1], 2, ies.eventTimes, iestu,[-2 2],xesTimes,iestu,0);
		widxt = reshape(idxMat,[],1);
		widxt = widxt(find(~isnan(widxt)));
		widx = union(widx,widxt);
	end

	for r=1:length(s.caTSA.ids)
		ri = r;

		% now do index windows
		ies = s.caTSA.caPeakEventSeriesArray.esa{ri};
		iestu = s.caTSA.timeUnit;
		[idxMat timeMat] = session.timeSeries.getIndexWindowsAroundEventsS(s.caTSA.time, s.caTSA.timeUnit, ...
			[0 0], 2, ies.eventTimes, iestu,[],[],[],1);
		caidx = reshape(idxMat,[],1);
		caidx = caidx(find(~isnan(caidx)));


		ni = length(intersect(widx,caidx));

		% how reliably does this cell encode the sensory variable (FOLLOW it)?
		% only if you have @ least 50 ca events
		if (length(caidx) > 50)
			envPredCaFrac(r) = ni/length(caidx);
		else
			envPredCaFrac(r) = nan;
		end

	end
	s.plotColorRois([],[],[],[],envPredCaFrac, [0.1 0.6], myax, 0); 
	title(['envpred ' ESA.esa{e}.idStr ' ' s.dateStr ' n=' num2str(length(widx))]);
end


