% time series as image
if (1)
  cidxs = [23 2 18 3 56 34 53 21 4 32 49 20 22];
  cidxs = sidx(1:20);

  for c=1:length(cidxs)
		cidx = cidxs(c);
		uti = unique(caTSA.trialIndices);
		ntp = 0;
		for t=1:length(uti)
			ntp = max(ntp, length(find(caTSA.trialIndices == uti(t))));
		end
		
		im = zeros(length(uti),ntp);
		for t=1:length(uti)
			ti = find(caTSA.trialIndices == uti(t));
			im(t,1:length(ti)) = caTSA.dffTimeSeriesArray.valueMatrix(cidx,ti);
		end

    figure;
		imagesc(im);
		hold on; 
		plot ([10 10],[0 length(uti)], 'k-','LineWidth',2);
		plot ([25 25],[0 length(uti)], '-', 'Color', [.5 .5 .5], 'LineWidth',2);
		plot ([40 40],[0 length(uti)], 'k-','LineWidth',2);
		plot ([0 ntp],[30 30], 'w-', 'LineWidth', 2);
		set(gca,'TickDir','out');
		set(gca,'XTickLabel', {'1','2','3','4','5','6','7','8','9'});
		ylabel('Trial');
		xlabel('Time(s)');
		print('-dpng', '-noui','-r300', ['~/Desktop/l4_' num2str(cidx) '.png']);
		pause (.5);
		close;
	end

end

% event rate
if (0)
  figure ;
	ax = axes; 

  feat = 0*caTSA.ids;
  roiColors = zeros(length(caTSA.time),3);
	dtMs = mode(diff(caTSA.time));
	nTimePoints = length(caTSA.time);
	numSeconds = nTimePoints*dtMs/1000;
	M = .1;

	for i=1:length(caTSA)
		feat(i) = length(caTSA.caPeakEventSeriesArray.esa{i}.getBurstTimes(1000))/numSeconds;

    actl = feat(i)./M;
		if (actl > 1) ; actl = 1; end
		roiColors(i,:) = [0 1 1]*actl;
	end

  rA.guiHandles = [];


	rA.colorById(rA.roiIds, roiColors);
  im = rA.plotImage(0, 1, 0, [], ax);
end

