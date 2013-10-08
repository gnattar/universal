if (~exist('sA'))
  cd ('~/data/an38596/session2');
	load ('goodDayArray');
end
root_out = '~/Desktop/lmplots/';
printon =1;

if (0) % plot 3 data streams
  day_idx = 3;
	roiIdx = 42;

	fh = figure;
  ax1 = subplot(1,3,1);
  ax2 = subplot(1,3,2);
  ax3 = subplot(1,3,3);

  ES = {s.behavESA.esa{5}, s.whiskerBarInReachES};

  s = sA.sessions{day_idx};
	tsa = s.caTSA.dffTimeSeriesArray;
  s.plotTimeSeriesAsImage(tsa, roiIdx, ES, 1:4, 1, [], [0 10], [0 2], ax1);  
	tsa = s.caTSA.eventBasedDffTimeSeriesArray;
  s.plotTimeSeriesAsImage(tsa, roiIdx, ES, 1:4, 1, [], [0 10], [0 2], ax2);  
	tsa = s.caTSA.caPeakTimeSeriesArray;
  s.plotTimeSeriesAsImage(tsa, roiIdx, ES, 1:4, 1, [], [0 10], [0 2], ax3);  

  outFile = [root_out char(sA.mouseId) '_' strrep(char(sA.dateStr(day_idx)),':','') ...
	           '_vogel_datastreams_.eps'];
	outFile=strrep(outFile,' ','_');
  if(printon);	print(fh, '-depsc2', '-noui', '-r300', outFile); end
end

if (0) % plot random forest based touch index for a single day for 3 data streams, pole x all
  day_idx = 3;
	featName = 'c1_touch_max_abs_delta_kappa';
	inputTags = {'allTime_rawDff', 'allTime_eventDff', 'allTime_eventPeakDff', 'poleTime_rawDff', 'poleTime_eventDff', 'poleTime_eventPeakDff'};

  s = sA.sessions{day_idx};
	tbRootDir = strrep(s.dataSourceParams.ephusFilePath,'ephus','tree');
	plotParams = [];
	plotParams.valueRange = [0 1];
	plotParams.showColorbar = 1;

	fh = figure;
	for i=1:6 
	  ax = subplot(3,3,i); 
		s.getTreeScores(tbRootDir, char(inputTags{i}), 2, 'RSpear_time_max');
		fi = find(strcmp(s.treeFeatureList, featName));
		plotParams.axRef = ax;
		s.plotRoiByTreeScore(fi,plotParams);
		title(strrep(inputTags{i},'_',' '));
	end
		

  outFile = [root_out char(sA.mouseId) '_' strrep(char(sA.dateStr(day_idx)),':','') ...
	           'encoder_diff_streams_.eps'];
	outFile=strrep(outFile,' ','_');
  if(printon);	print(fh, '-depsc2', '-noui', '-r300', outFile); end
end

if (0) % plot random forest based touch index for a single day for 3 data streams, decoder 
  day_idx = 3;
	featName = 'c1_touch_detect';
	inputTags = {'allTime_rawDff', 'allTime_eventDff', 'allTime_eventPeakDff', 'poleTime_rawDff', 'poleTime_eventDff', 'poleTime_eventPeakDff'};

  s = sA.sessions{day_idx};
	tbRootDir = strrep(s.dataSourceParams.ephusFilePath,'ephus','tree');

	plotParams = [];
	plotParams.valueRange = [0 1];
	plotParams.showColorbar = 1;

	fh = figure;
	for i=1:6 
	  ax = subplot(3,3,i); 
		plotParams.axRef = ax;
		s.getTreeScores(tbRootDir, char(inputTags{i}), 7, 'RSpear_time_max');
		fi = find(strcmp(s.treeFeatureList, featName));
		s.plotRoiByTreeScore(fi,plotParams);
		title(strrep(inputTags{i},'_',' '));
	end
		

  outFile = [root_out char(sA.mouseId) '_' strrep(char(sA.dateStr(day_idx)),':','') ...
	           'decoder_diff_streams_.eps'];
	outFile=strrep(outFile,' ','_');
  if(printon);	print(fh, '-depsc2', '-noui', '-r300', outFile); end
end



if (0) % plot random forest poleTime eventDff encoder all 3 whiskers ; top encoder, bottom encode
  day_idx = 3;
	inputTags = {'poleTime_eventDff'}; i =1;

  s = sA.sessions{day_idx};
	tbRootDir = strrep(s.dataSourceParams.ephusFilePath,'ephus','tree');

	plotParams = [];
	plotParams.valueRange = [0 1];
	plotParams.showColorbar = 1;

	fh = figure;

	% encoder
	featNames = {'c1_touch_max_abs_delta_kappa','c2_touch_max_abs_delta_kappa','c3_touch_max_abs_delta_kappa'};
	s.getTreeScores(tbRootDir, char(inputTags{i}), 2, 'RSpear_time_max');
	for f=1:3 
	  ax = subplot(2,3,f); 
		plotParams.axRef = ax;
		fi = find(strcmp(s.treeFeatureList, featNames{f}));
		s.plotRoiByTreeScore(fi,plotParams);
		title(strrep(featNames{f},'_',' '));
		if (f == 1) ; ylabel('encoder'); end
	end

	% decoder
	featNames = {'c1_touch_detect','c2_touch_detect','c3_touch_detect'}
	s.getTreeScores(tbRootDir, char(inputTags{i}), 7, 'RSpear_time_max');
	for f=1:3 
	  ax = subplot(2,3,3+f); 
		plotParams.axRef = ax;
		fi = find(strcmp(s.treeFeatureList, featNames{f}));
		s.plotRoiByTreeScore(fi,plotParams);
		title(strrep(featNames{f},'_',' '));
		if (f == 1) ; ylabel('decoder'); end
	end


  outFile = [root_out char(sA.mouseId) '_' strrep(char(sA.dateStr(day_idx)),':','') ...
	           '_allwhiskers_' inputTags{i} '.eps'];
	outFile=strrep(outFile,' ','_');
  if(printon);	print(fh, '-depsc2', '-noui', '-r300', outFile); end
end


if (0) % plot random forest poleTime eventDff bar graphs
  day_idx = 3;
	inputTags = {'poleTime_eventDff'}; i =1;
  roiIds=[42 67 187 38 17 79 19 5 97];

  s = sA.sessions{day_idx};
	tbRootDir = strrep(s.dataSourceParams.ephusFilePath,'ephus','tree');

	plotParams = [];
	plotParams.valueRange = [0 1];


	% encoder
	fh1 = figure;
	featNames = {'c1_touch_max_abs_delta_kappa','c2_touch_max_abs_delta_kappa','c3_touch_max_abs_delta_kappa'};
	s.getTreeScores(tbRootDir, char(inputTags{i}), 2, 'RSpear_time_max');
	fi =find(ismember(s.treeFeatureList, featNames));

  for r=1:length(roiIds)
	  plotParams.showLabels = 0;
	  if (r == 1) ; plotParams.showLabels = 1; end
	  ax = subplot(3,3,r); 
	  plotParams.axRef = ax;
		s.plotRoiScoreAcrossFeatures(roiIds(r), fi,plotParams);
		title(num2str(roiIds(r)));
		if (r == 1) ; ylabel('encoder'); end
	end

  outFile = [root_out char(sA.mouseId) '_' strrep(char(sA.dateStr(day_idx)),':','') ...
	           '_whiskers_RFs_' inputTags{i} '_encoder.eps'];
	outFile=strrep(outFile,' ','_');
  if(printon);	print(fh1, '-depsc2', '-noui', '-r300', outFile); end

	% decoder
	fh2 = figure;
	featNames = {'c1_touch_detect','c2_touch_detect','c3_touch_detect'}
	s.getTreeScores(tbRootDir, char(inputTags{i}), 7, 'RSpear_time_max');
	fi =find(ismember(s.treeFeatureList, featNames));

  for r=1:length(roiIds)
	  plotParams.showLabels = 0;
	  if (r == 1) ; plotParams.showLabels = 1; end
	  ax = subplot(3,3,r); 
	  plotParams.axRef = ax;
		s.plotRoiScoreAcrossFeatures(roiIds(r), fi,plotParams);
		title(num2str(roiIds(r)));
		if (r == 1) ; ylabel('encoder'); end
	end

  outFile = [root_out char(sA.mouseId) '_' strrep(char(sA.dateStr(day_idx)),':','') ...
	           '_whiskers_RFs_' inputTags{i} '_decoder.eps'];
	outFile=strrep(outFile,' ','_');
  if(printon);	print(fh2, '-depsc2', '-noui', '-r300', outFile); end
end






if (0) % plot random forest poleTime eventDff decoder cross days, whiskers
  day_idx = [1 3 7 8 11 13 17 20];
	nd = length(day_idx);
	inputTags = {'poleTime_eventDff'}; i =1;


	plotParams = [];
	plotParams.valueRange = [0 1];
	plotParams.showColorbar = 0;

	fh = figure;

  for d=1:length(day_idx)
		s = sA.sessions{day_idx(d)};
		tbRootDir = strrep(s.dataSourceParams.ephusFilePath,'ephus','tree');

		% decoder
		featNames = {'c1_touch_detect','c2_touch_detect','c3_touch_detect'}
		s.getTreeScores(tbRootDir, char(inputTags{i}), 7, 'RSpear_time_max');
		for f=1:3 
			ax = subplot(3,nd,(f-1)*nd + d);
			plotParams.axRef = ax;
			fi = find(strcmp(s.treeFeatureList, featNames{f}));
			if (length(fi) > 0)
				s.plotRoiByTreeScore(fi,plotParams);
				if (d == 1)
  				ylabel(strrep(featNames{f},'_',' '));
				end
				if (f == 1)
				  title(strrep(char(sA.dateStr(day_idx(d))),':',''));
				end
			end
		end
	end


  outFile = [root_out char(sA.mouseId) '_multiday_' ...
	           '_allwhiskers_decode_only_' inputTags{i} '.eps'];
	outFile=strrep(outFile,' ','_');
  if(printon);	print(fh, '-depsc2', '-noui', '-r300', outFile); end
end



if (0) % plot random forest poleTime eventDff decoder single cell RF cross day
  day_idx = [1 3 7 8 11 13 17 20];
  roiIds=[42 67 187 38 17 79 19 5 97];
	nd = length(day_idx);
	nds = ceil(sqrt(nd));
	inputTags = {'poleTime_eventDff'}; i =1;


	plotParams = [];
	plotParams.valueRange = [0 1];
	plotParams.showColorbar = 0;

  for r=1:length(roiIds)
  	fh(r) = figure;
	end

  for d=1:length(day_idx)
		s = sA.sessions{day_idx(d)};
		tbRootDir = strrep(s.dataSourceParams.ephusFilePath,'ephus','tree');

		% decoder
		featNames = {'c1_touch_detect','c2_touch_detect','c3_touch_detect'}
		s.getTreeScores(tbRootDir, char(inputTags{i}), 7, 'RSpear_time_max');
	  fi =find(ismember(s.treeFeatureList, featNames));

		for r=1:length(roiIds)
			plotParams.showLabels = 0;
			if (r == 1) ; plotParams.showLabels = 1; end
			figure(fh(r));
			ax = subplot(nds,nds,d); 
			plotParams.axRef = ax;
			s.plotRoiScoreAcrossFeatures(roiIds(r), fi,plotParams);
			if (d == 1) 
			  title([num2str(roiIds(r)) ' ' strrep(char(sA.dateStr(day_idx(d))),':','')]);
			else 
			  title(strrep(char(sA.dateStr(day_idx(d))),':',''));
			end
		end

	end

  for r=1:length(roiIds)
	  outFile = [root_out char(sA.mouseId) '_multiday_' ...
							 '_allwhiskers_decode_only_' inputTags{i} '_roi_' num2str(roiIds(r)) '.eps'];
		outFile=strrep(outFile,' ','_');
		if(printon);	print(fh(r), '-depsc2', '-noui', '-r300', outFile); end
	end
end





if (0) % plot random forest poleTime eventDff decoder cross days, whiskers
  day_idx = [1 3 7 8 11 13 17 20];
  day_idx = [3 7 8 17 20];
	nd = length(day_idx);
	inputTags = {'allTime_eventDff'}; i =1;
	featNames = {'Contact', 'Lick', 'Whisking'};
	nf = length(featNames);


	plotParams = [];
	plotParams.valueRange = [0 1];
	plotParams.showColorbar = 0;

	fh = figure;

  for d=1:length(day_idx)
		s = sA.sessions{day_idx(d)};
		tbRootDir = strrep(s.dataSourceParams.ephusFilePath,'ephus','tree');

		% decoder
		s.getTreeScores(tbRootDir, char(inputTags{i}), 3, 'RSpear_time_max');
		for f=1:nf
			ax = subplot(nf,nd,(f-1)*nd + d);
			plotParams.axRef = ax;
			fi = find(strcmp(s.treeFeatureList, featNames{f}));
			if (length(fi) > 0)
				s.plotRoiByTreeScore(fi,plotParams);
				if (d == 1)
  				ylabel(strrep(featNames{f},'_',' '));
				end
				if (f == 1)
				  title(strrep(char(sA.dateStr(day_idx(d))),':',''));
				else
				  title('');
				end
			end
		end
	end


  outFile = [root_out char(sA.mouseId) '_multiday_' ...
	           '_categories_' inputTags{i} '.eps'];
	outFile=strrep(outFile,' ','_');
  if(printon);	print(fh, '-depsc2', '-noui', '-r300', outFile); end
end


if (0) % plot random bar RF for whisking cell
  day_idx = [1 3 7 8 11 13 17 20];
	roiIds = [38];
	nd = length(day_idx);
	nds = ceil(sqrt(nd));
	inputTags = {'allTime_eventDff'}; i =1;

	featNames = {'Max_whisker_amplitude','Mean_whisker_amplitude','Mean_whisker_amplitude_change','Whisker_setpoint','Whisker_setpoint_change'};

	plotParams = [];
	plotParams.valueRange = [0 1];
	plotParams.showColorbar = 0;

  for r=1:length(roiIds)
  	fh(r) = figure;
	end

  for d=1:length(day_idx)
		s = sA.sessions{day_idx(d)};
		tbRootDir = strrep(s.dataSourceParams.ephusFilePath,'ephus','tree');

		% decoder
		s.getTreeScores(tbRootDir, char(inputTags{i}), 2, 'RSpear_time_max');
	  fi =find(ismember(s.treeFeatureList, featNames));

		for r=1:length(roiIds)
			plotParams.showLabels = 0;
			if (r == 1) ; plotParams.showLabels = 1; end
			figure(fh(r));
			ax = subplot(nds,nds,d); 
			plotParams.axRef = ax;
			s.plotRoiScoreAcrossFeatures(roiIds(r), fi,plotParams);
			if (d == 1) 
			  title([num2str(roiIds(r)) ' ' strrep(char(sA.dateStr(day_idx(d))),':','')]);
			else 
			  title(strrep(char(sA.dateStr(day_idx(d))),':',''));
			end
		end

	end

  for r=1:length(roiIds)
	  outFile = [root_out char(sA.mouseId) '_multiday_' ...
							 '_whisking_cell_bar_' inputTags{i} '_roi_' num2str(roiIds(r)) '.eps'];
		outFile=strrep(outFile,' ','_');
		if(printon);	print(fh(r), '-depsc2', '-noui', '-r300', outFile); end
	end
end


if (1) % plot random bar RF for whisking cell decoder
  day_idx = [1 3 7 8 11 13 17 20];
	roiIds = [38];
	nd = length(day_idx);
	nds = ceil(sqrt(nd));
	inputTags = {'allTime_eventDff'}; i =1;

	featNames = {'Max_whisker_amplitude','Mean_whisker_amplitude','Mean_whisker_amplitude_change','Whisker_setpoint','Whisker_setpoint_change'};

	plotParams = [];
	plotParams.valueRange = [0 0.25];
	plotParams.showColorbar = 0;

  for r=1:length(roiIds)
  	fh(r) = figure;
	end

  for d=1:length(day_idx)
		s = sA.sessions{day_idx(d)};
		tbRootDir = strrep(s.dataSourceParams.ephusFilePath,'ephus','tree');

		% decoder
		s.getTreeScores(tbRootDir, char(inputTags{i}), 5, 'RSpear_time_mean');
	  fi =find(ismember(s.treeFeatureList, featNames));

		for r=1:length(roiIds)
			plotParams.showLabels = 0;
			if (r == 1) ; plotParams.showLabels = 1; end
			figure(fh(r));
			ax = subplot(nds,nds,d); 
			plotParams.axRef = ax;
			s.plotRoiScoreAcrossFeatures(roiIds(r), fi,plotParams);
			if (d == 1) 
			  title([num2str(roiIds(r)) ' ' strrep(char(sA.dateStr(day_idx(d))),':','')]);
			else 
			  title(strrep(char(sA.dateStr(day_idx(d))),':',''));
			end
		end

	end

  for r=1:length(roiIds)
	  outFile = [root_out char(sA.mouseId) '_multiday_DECODER_' ...
							 '_whisking_cell_bar_' inputTags{i} '_roi_' num2str(roiIds(r)) '.eps'];
		outFile=strrep(outFile,' ','_');
		if(printon);	print(fh(r), '-depsc2', '-noui', '-r300', outFile); end
	end
end

if (0) % for 42, plot category RF with lineplot above
  day_idx = [1 3 7 8 11 13 17 20];
	roiIds = [42];
	nd = length(day_idx);
	nds = ceil(sqrt(nd));
	inputTags = {'allTime_eventDff'}; i =1;

	featNames = {'Contact', 'Lick', 'Whisking'};

	plotParams = [];
	plotParams.valueRange = [0 1];
	plotParams.showColorbar = 0;

  for r=1:length(roiIds)
  	fh(r) = figure;
	end

  for d=1:length(day_idx)
		s = sA.sessions{day_idx(d)};
		tbRootDir = strrep(s.dataSourceParams.ephusFilePath,'ephus','tree');

		% decoder
		s.getTreeScores(tbRootDir, char(inputTags{i}), 3, 'RSpear_time_max');
	  fi =find(ismember(s.treeFeatureList, featNames));

		for r=1:length(roiIds)
			figure(fh(r));

      % line plot
			ax = subplot(4,nd,d); 
	    tsa = s.caTSA.dffTimeSeriesArray;
      s.plotTimeSeriesAsLine(tsa, roiIds(r), [], 1:4, [], [0 10 -0.5 2], [nan ax]);  

			% bagger results
			plotParams.showLabels = 0;
			if (r == 1) ; plotParams.showLabels = 1; end
			ax = subplot(4,nd,d+nd); 
			plotParams.axRef = ax;
			s.plotRoiScoreAcrossFeatures(roiIds(r), fi,plotParams);
			if (d == 1) 
			  title([num2str(roiIds(r)) ' ' strrep(char(sA.dateStr(day_idx(d))),':','')]);
			else 
			  title(strrep(char(sA.dateStr(day_idx(d))),':',''));
			end
		end

	end

  for r=1:length(roiIds)
	  outFile = [root_out char(sA.mouseId) '_multiday_' ...
							 '_whisking_plus_dff_' inputTags{i} '_roi_' num2str(roiIds(r)) '.eps'];
		outFile=strrep(outFile,' ','_');
		if(printon);	print(fh(r), '-depsc2', '-noui', '-r300', outFile); end
	end
end




