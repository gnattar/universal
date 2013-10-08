% plots of autocorrelation functions

if (~exist('sA'))
  cd ('~/data/an38596/session2');
	load ('goodDayArray');
end
root_out = '~/Desktop/lmplots/';
printon =1;

if (1) % plot touch autocorr: 42, 67, 50
  day_idx = 1:17;
  
	fh=figure;
	for d=1:length(day_idx)
		s = sA.sessions{day_idx(d)};
	%plotTSCorrelationS(tsaA, tsAId, tsaB, tsBId, offsets, ax, corrType);
		tsBIdS = 'c1 max delta kappa';
		tsBIdS = 'c1 touch max abs delta kappa';
		tsBId = s.derivedDataTSA.ids(find(strcmp(s.derivedDataTSA.idStrs,tsBIdS)))
		ax = subplot(5,4,d);
		session.session.plotTSCorrelationS(s.caTSA.dffTimeSeriesArray, 42, s.derivedDataTSA, tsBId, -20:20, ax, 'Pearson');
		title([sA.dateStr{day_idx(d)}(1:6)]);
		if (d == 1) 
			title([sA.dateStr{day_idx(d)}(1:6) ' ROI 42 autocorr ' tsBIdS]);
		end
		axis([-3000 3000 -0.5 0.5]); if (d > 1) ; set(gca,'YTick', []) ; set(gca,'XTick',[]); end
		hold on ; plot([0 0], [-0.5 0.5], 'r-');
		xlabel('');
		ylabel('');
		set (gca, 'TickDir', 'out');

		outFile = [root_out char(sA.mouseId) '_autocorr_touch_42.eps'];
		outFile=strrep(outFile,' ','_');
		if(printon);	print(fh, '-depsc2', '-noui', '-r300', outFile); end
	end
  
	fh=figure;
	for d=1:length(day_idx)
		s = sA.sessions{day_idx(d)};
	%plotTSCorrelationS(tsaA, tsAId, tsaB, tsBId, offsets, ax, corrType);
		tsBIdS = 'c1 max delta kappa';
		tsBIdS = 'c1 touch max abs delta kappa';
		tsBId = s.derivedDataTSA.ids(find(strcmp(s.derivedDataTSA.idStrs,tsBIdS)))
		ax = subplot(5,4,d);
		session.session.plotTSCorrelationS(s.caTSA.dffTimeSeriesArray, 67, s.derivedDataTSA, tsBId, -20:20, ax, 'Pearson');
		title([sA.dateStr{day_idx(d)}(1:6)]);
		if (d == 1) 
			title([sA.dateStr{day_idx(d)}(1:6) ' ROI 67 autocorr ' tsBIdS]);
		end
		axis([-3000 3000 -0.5 0.5]); if (d > 1) ; set(gca,'YTick', []) ; set(gca,'XTick',[]); end
		xlabel('');
		hold on ; plot([0 0], [-0.5 0.5], 'r-');
		ylabel('');
		set (gca, 'TickDir', 'out');

		outFile = [root_out char(sA.mouseId) '_autocorr_touch_67.eps'];
		outFile=strrep(outFile,' ','_');
		if(printon);	print(fh, '-depsc2', '-noui', '-r300', outFile); end
	end
  
	fh=figure;
	for d=1:length(day_idx)
		s = sA.sessions{day_idx(d)};
	%plotTSCorrelationS(tsaA, tsAId, tsaB, tsBId, offsets, ax, corrType);
		tsBIdS = 'c1 max delta kappa';
		tsBIdS = 'c1 touch max abs delta kappa';
		tsBId = s.derivedDataTSA.ids(find(strcmp(s.derivedDataTSA.idStrs,tsBIdS)))
		ax = subplot(5,4,d);
		session.session.plotTSCorrelationS(s.caTSA.dffTimeSeriesArray, 55, s.derivedDataTSA, tsBId, -20:20, ax, 'Pearson');
		title([sA.dateStr{day_idx(d)}(1:6)]);
		if (d == 1) 
			title([sA.dateStr{day_idx(d)}(1:6) ' ROI 55 autocorr ' tsBIdS]);
		end
		axis([-3000 3000 -0.5 0.5]); if (d > 1) ; set(gca,'YTick', []) ; set(gca,'XTick',[]); end
		hold on ; plot([0 0], [-0.5 0.5], 'r-');
		xlabel('');
		ylabel('');
		set (gca, 'TickDir', 'out');

		outFile = [root_out char(sA.mouseId) '_autocorr_touch_55.eps'];
		outFile=strrep(outFile,' ','_');
		if(printon);	print(fh, '-depsc2', '-noui', '-r300', outFile); end
	end
end

if (1) % plot whisking autocorr: 42, 67, 50
  day_idx = 1:20;
  
	fh=figure;
	for d=1:length(day_idx)
		s = sA.sessions{day_idx(d)};
	%plotTSCorrelationS(tsaA, tsAId, tsaB, tsBId, offsets, ax, corrType);
		tsBIdS = 'Mean whisker amplitude';
		tsBIdS = 'Max whisker amplitude';
		tsBId = s.derivedDataTSA.ids(find(strcmp(s.derivedDataTSA.idStrs,tsBIdS)))
		ax = subplot(5,4,d);
		session.session.plotTSCorrelationS(s.caTSA.dffTimeSeriesArray, 38, s.derivedDataTSA, tsBId, -20:20, ax, 'Pearson');
		title([sA.dateStr{day_idx(d)}(1:6)]);
		if (d == 1) 
			title([sA.dateStr{day_idx(d)}(1:6) ' ROI 38 autocorr ' tsBIdS]);
		end
		axis([-3000 3000 -0.5 0.5]); if (d > 1) ; set(gca,'YTick', []) ; set(gca,'XTick',[]); end
		hold on ; plot([0 0], [-0.5 0.5], 'r-');
		xlabel('');
		ylabel('');
		set (gca, 'TickDir', 'out');

		outFile = [root_out char(sA.mouseId) '_autocorr_whisking_38.eps'];
		outFile=strrep(outFile,' ','_');
		if(printon);	print(fh, '-depsc2', '-noui', '-r300', outFile); end
	end
	fh=figure;
	for d=1:length(day_idx)
		s = sA.sessions{day_idx(d)};
	%plotTSCorrelationS(tsaA, tsAId, tsaB, tsBId, offsets, ax, corrType);
		tsBIdS = 'Mean whisker amplitude';
		tsBIdS = 'Max whisker amplitude';
		tsBId = s.derivedDataTSA.ids(find(strcmp(s.derivedDataTSA.idStrs,tsBIdS)))
		ax = subplot(5,4,d);
		session.session.plotTSCorrelationS(s.caTSA.dffTimeSeriesArray, 42, s.derivedDataTSA, tsBId, -20:20, ax, 'Pearson');
		title([sA.dateStr{day_idx(d)}(1:6)]);
		if (d == 1) 
			title([sA.dateStr{day_idx(d)}(1:6) ' ROI 42 autocorr ' tsBIdS]);
		end
		axis([-3000 3000 -0.5 0.5]); if (d > 1) ; set(gca,'YTick', []) ; set(gca,'XTick',[]); end
		hold on ; plot([0 0], [-0.5 0.5], 'r-');
		xlabel('');
		ylabel('');
		set (gca, 'TickDir', 'out');

		outFile = [root_out char(sA.mouseId) '_autocorr_whisking_42.eps'];
		outFile=strrep(outFile,' ','_');
		if(printon);	print(fh, '-depsc2', '-noui', '-r300', outFile); end
	end
	fh=figure;
	for d=1:length(day_idx)
		s = sA.sessions{day_idx(d)};
	%plotTSCorrelationS(tsaA, tsAId, tsaB, tsBId, offsets, ax, corrType);
		tsBIdS = 'Mean whisker amplitude';
		tsBIdS = 'Max whisker amplitude';
		tsBId = s.derivedDataTSA.ids(find(strcmp(s.derivedDataTSA.idStrs,tsBIdS)))
		ax = subplot(5,4,d);
		session.session.plotTSCorrelationS(s.caTSA.dffTimeSeriesArray, 55, s.derivedDataTSA, tsBId, -20:20, ax, 'Pearson');
		title([sA.dateStr{day_idx(d)}(1:6)]);
		if (d == 1) 
			title([sA.dateStr{day_idx(d)}(1:6) ' ROI 55 autocorr ' tsBIdS]);
		end
		axis([-3000 3000 -0.5 0.5]); if (d > 1) ; set(gca,'YTick', []) ; set(gca,'XTick',[]); end
		hold on ; plot([0 0], [-0.5 0.5], 'r-');
		xlabel('');
		ylabel('');
		set (gca, 'TickDir', 'out');

		outFile = [root_out char(sA.mouseId) '_autocorr_whisking_55.eps'];
		outFile=strrep(outFile,' ','_');
		if(printon);	print(fh, '-depsc2', '-noui', '-r300', outFile); end
	end
end


