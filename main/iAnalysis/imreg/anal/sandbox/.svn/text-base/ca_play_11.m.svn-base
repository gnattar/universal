% For fixing dff


if (1)
  clear actParams;
	clear fParams;
 
	actParams.cofThresh = 0.15;
	actParams.nabThresh = 0.005;
	actParams.forceRedo = 1;

	fParams.timeUnit = session.timeSeries.millisecond;
	fParams.filterType = 'quantile';
	fParams.filterSize = 60;
	fParams.actParams = actParams;

	s.caTSA.dffOpts = fParams;
	s.caTSA.updateDff();

end


if (0)
	actParams.cofThresh = 0.25;
	actParams.cofThresh = 0.15;
	actParams.nabThresh = 0.005;
	actParams.forceRedo = 1;

	s.caTSA.getRoiActivityStatistics(actParams);

	hyperactiveIdx = s.caTSA.roiActivityStatsHash.get('hyperactiveIdx');
	activeIdx = s.caTSA.roiActivityStatsHash.get('activeIdx');
	inactiveIdx = s.caTSA.roiActivityStatsHash.get('inactiveIdx');
	quantileThresh = 0.5*ones(1,size(valueMatrix,1));
	quantileThresh(activeIdx) = 0.1;
	quantileThresh(hyperactiveIdx) = 0.05;


	fParams.timeUnit = session.timeSeries.millisecond;
	fParams.filterType = 'quantile';
	fParams.filterSize = 60; % ORIGINALLY
fParams.filterSize = 30;
	fParams.quantileThresh = quantileThresh;

	%valueMatrix = valueMatrix(1:50,:);
	%fParams.quantileThresh = quantileThresh(1:50);
	newValueMatrix = session.timeSeries.filterS(time,valueMatrix,fParams);

	figure;
	for i=1:size(newValueMatrix,1)
		hold on ;
		plot(valueMatrix(i,:),'k-');
		plot(newValueMatrix(i,:),'r-');
		pause;
		cla;
	end
end
if (0)

	nab = s.caTSA.roiActivityStatsHash.get('numAboveCutoff');
	cof = s.caTSA.roiActivityStatsHash.get('cutoffToMaxRatio');

	figure;
	for i=1:size(s.caTSA.valueMatrix,1) ; 
	subplot(2,1,1) ; 
	plot(s.caTSA.valueMatrix(i,:),'k-') ;
	subplot(2,1,2) ; 
	title(['nab: ' num2str(nab(i)) ' cof: ' num2str(cof(i))]);
	plot(s.caTSA.dffTimeSeriesArray.valueMatrix(i,:), 'r-') ; 
	hold on ; 
	a=axis ; 
	plot([a(1) a(2)], [0 0], 'k-');
	axis([a(1) a(2) -1 5]); 
	pause ; 
	cla ; 
	end


end
