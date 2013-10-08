% plots of respnoses after trimming

if (~exist('sA'))
  cd ('~/data/an38596/session2');
	load ('goodDayArray');
end
root_out = '~/Desktop/lmplots/';
printon =1;

if (0) % plot 2 FOV snapshots 
  day_idx = [9 19];

	fh = figure;
  ax1 = subplot(2,2,1);
  ax2 = subplot(2,2,2);

  s = sA.sessions{day_idx(1)};
  s.plotColorRois('eventrate', [],[],[],[],[0 1], ax1, 1);
  title(['event rate ' sA.dateStr{day_idx(1)}(1:7)]);

  s = sA.sessions{day_idx(2)};
  s.plotColorRois('eventrate', [],[],[],[],[0 1], ax2, 1);
  title(['event rate ' sA.dateStr{day_idx(2)}(1:7)]);

  % event rate across cells, time ; gather
	evRateTime = zeros(length(s.caTSA.ids), length(sA.dateStr));
	for d=1:length(sA.dateStr)
		s = sA.sessions{d};
	  for r=1:length(s.caTSA.ids)
		  es = s.caTSA.caPeakEventSeriesArray.esa{r};
			evRateTime(d,r) = 4*length(es.eventTimes)/length(s.caTSA.time); % ~ Hz 
		end
	end

  outFile = [root_out char(sA.mouseId) '_FOV_evrate_preposttrim.eps'];
	outFile=strrep(outFile,' ','_');
  if(printon);	print(fh, '-depsc2', '-noui', '-r300', outFile); end

  % plot event rate across cells, time ; gather
  D = [1:9 11:20];

  subplot(3,1,3);
	plot(sA.performanceStats(D,2), 'ko', 'MarkerFaceColor', [0 0 0]);
	ylabel('performance (d-prime)');
	hold on;
  plot([0 20], [1 1], 'k:')	;
	axis([0 length(sA.dateStr)+1 -1 4]);

	for d=D
	  text(d,-0.85, sA.dateStr{d}(1:7) , 'Rotation', 90);
	end
	set (gca, 'TickDir', 'out');


  subplot(3,1,1);
	plot(evRateTime(D,:), '-o');
	axis([0 length(D)+1 0 2]);
	set (gca, 'TickDir', 'out');
	ylabel('Event rate (Hz)');

  % touch cells only
	ri = [42 65 67 79 187 17 19];
  subplot(3,1,2);
	plot(evRateTime(D,ri), '-o');
	axis([0 length(D)+1 0 2]);
	set (gca, 'TickDir', 'out');
	ylabel('Event rate (Hz)');

  outFile = [root_out char(sA.mouseId) '_singlecell_evrate_time.eps'];
	outFile=strrep(outFile,' ','_');
  if(printon);	print(fh, '-depsc2', '-noui', '-r300', outFile); end
end


if (1) % plot 4 FOVs before & after trim
  day_idx = 9;
	roiIdx = [42 65 79 50];

  % BEFORE
	fh = figure;
  ax1 = subplot(1,4,1);
  ax2 = subplot(1,4,2);
  ax3 = subplot(1,4,3);
  ax4 = subplot(1,4,4);

  s = sA.sessions{day_idx};
  ES = {s.behavESA.esa{5}, s.whiskerBarInReachES};

	tsa = s.caTSA.dffTimeSeriesArray;
  s.plotTimeSeriesAsImage(tsa, roiIdx(1), ES, 1:4, 1, [], [0 10], [0 2], ax1);  
	set(gca,'YTick',[]); ylabel('');
	title('roi 42');
  s.plotTimeSeriesAsImage(tsa, roiIdx(2), ES, 1:4, 1, [], [0 10], [0 2], ax2);  
	set(gca,'YTick',[]); ylabel('');
	title('roi 65');
  s.plotTimeSeriesAsImage(tsa, roiIdx(3), ES, 1:4, 1, [], [0 10], [0 2], ax3);  
	set(gca,'YTick',[]); ylabel('');
	title('roi 79');
  s.plotTimeSeriesAsImage(tsa, roiIdx(4), ES, 1:4, 1, [], [0 10], [0 2], ax4);  
	set(gca,'YTick',[]); ylabel('');
	title('roi 50 02/11');

  outFile = [root_out char(sA.mouseId) '_multiFOV_beforetrim_0211.eps'];
	outFile=strrep(outFile,' ','_');
  if(printon);	print(fh, '-depsc2', '-noui', '-r300', outFile); end

  % AFTER
  day_idx = 19;
	fh = figure;
  ax1 = subplot(1,4,1);
  ax2 = subplot(1,4,2);
  ax3 = subplot(1,4,3);
  ax4 = subplot(1,4,4);

  s = sA.sessions{day_idx};
  ES = {s.behavESA.esa{5}, s.whiskerBarInReachES};

  s = sA.sessions{day_idx};
	tsa = s.caTSA.dffTimeSeriesArray;
  s.plotTimeSeriesAsImage(tsa, roiIdx(1), ES, 1:4, 1, [], [0 10], [0 2], ax1);  
	set(gca,'YTick',[]); ylabel('');
	title('roi 42');
  s.plotTimeSeriesAsImage(tsa, roiIdx(2), ES, 1:4, 1, [], [0 10], [0 2], ax2);  
	set(gca,'YTick',[]); ylabel('');
	title('roi 65');
  s.plotTimeSeriesAsImage(tsa, roiIdx(3), ES, 1:4, 1, [], [0 10], [0 2], ax3);  
	set(gca,'YTick',[]); ylabel('');
	title('roi 79');
  s.plotTimeSeriesAsImage(tsa, roiIdx(4), ES, 1:4, 1, [], [0 10], [0 2], ax4);  
	set(gca,'YTick',[]); ylabel('');
	title('roi 50 03/02');

  outFile = [root_out char(sA.mouseId) '_multiFOV_aftertrim_0302.eps'];
	outFile=strrep(outFile,' ','_');
  if(printon);	print(fh, '-depsc2', '-noui', '-r300', outFile); end
end


if (0) % plot before & after for 38
  day_idx = 7;
	roiIdx = [42 65 38 50];

  % BEFORE
	fh = figure;
  ax1 = subplot(1,4,1);
  ax2 = subplot(1,4,2);
  ax3 = subplot(1,4,3);
  ax4 = subplot(1,4,4);

  s = sA.sessions{day_idx};
  ES = {s.behavESA.esa{5}, s.whiskerBarInReachES};
	tsa = s.caTSA.dffTimeSeriesArray;
  s.plotTimeSeriesAsImage(tsa, 38, ES, 1:4, 1, [], [0 10], [0 2], ax1);  
	set(gca,'YTick',[]); ylabel('');
	title('roi 38, 02/09');

  tsa = s.derivedDataTSA;
  s.plotTimeSeriesAsImage(tsa, 9, ES, 1:4, 1, [], [0 10], [], ax2);  
	set(gca,'YTick',[]); ylabel('');
	title('Max whisking amplitude');

  day_idx = 19;
  s = sA.sessions{day_idx};
  ES = {s.behavESA.esa{5}, s.whiskerBarInReachES};
	tsa = s.caTSA.dffTimeSeriesArray;
  s.plotTimeSeriesAsImage(tsa, 38, ES, 1:4, 1, [], [0 10], [0 2], ax3);  
	set(gca,'YTick',[]); ylabel('');
	title('roi 38, 03/02');

  tsa = s.derivedDataTSA;
  s.plotTimeSeriesAsImage(tsa, 9, ES, 1:4, 1, [], [0 10], [], ax4);  
	set(gca,'YTick',[]); ylabel('');
	title('Max whisking amplitude');

  outFile = [root_out char(sA.mouseId) '_whiskingCell_beforeafter.eps'];
	outFile=strrep(outFile,' ','_');
  if(printon);	print(fh, '-depsc2', '-noui', '-r300', outFile); end

end


