% discrimintion plots for 3/18 lab meeting

if (~exist('sA'))
  cd ('~/data/an38596/session2');
	load ('goodDayArray');
end

% grab performance
if (isempty(sA.performanceStats))
  sA.plotPerformance;
	close;
end

root_out = '~/Desktop/lmplots/';
printon =0;

params = [];

params.responseTimeWindow = [1 2.5];

if (0) % single neuron discrimination based on psth of raw data, vogel, binary; ev count; close view
  day_idx = [1 3 5 7 11 17 19];
	d = 2;
	nd = length(day_idx);
	fh = figure;

	s = sA.sessions{day_idx(d)};
	for t=1:4

		% computation parameters ...
		params.aType = [find(strcmp(s.trialTypeStr, 'Hit')) find(strcmp(s.trialTypeStr, 'Miss'))] ;
		params.bType = [find(strcmp(s.trialTypeStr, 'FA')) find(strcmp(s.trialTypeStr, 'CR'))]; 

		% compute
		params.method = 'psth_roc';
		switch t
			case 1
				params.responseTSA = s.caTSA.dffTimeSeriesArray;
				tstr = 'raw dff psth';
			case 2
				params.responseTSA = s.caTSA.eventBasedDffTimeSeriesArray;
				tstr = 'event dff psth';
			case 3
				params.responseTSA = s.caTSA.caPeakTimeSeriesArray.copy();
				vm = zeros(size(params.responseTSA.valueMatrix));
				vm(find(params.responseTSA.valueMatrix > 0)) = 1;
				params.responseTSA.valueMatrix = vm;
				tstr = 'binary psth';
			case 4
				params.method = 'evcount_roc';
				tstr = 'event count';
		end
		discrim = s.computeDiscrim(params);

		% plot
		ax = subplot(2,2,t);
		s.plotColorRois([],[],[],[],discrim,[0.5 1],ax,1);
		title([sA.dateStr{day_idx(d)}(1:11) ' ' tstr]);
	end

	outFile = [root_out 'discrim_' char(sA.mouseId) '_' strrep(char(sA.dateStr(day_idx(d))),':','') ...
						 '_FOV_sample_day.eps'];
	outFile=strrep(outFile,' ','_');
	if (printon) ; print(fh, '-depsc2', '-noui', '-r300', outFile); end
	
end

%	for d=1:length(day_idx)
%	end


if (0) % single neuron discrimination based on psth of raw data, vogel, binary; ev count; close view
  day_idx = [1 3 5 7 11 17 19];
	nd = length(day_idx);
	fh = figure;

  for d=1:length(day_idx)
		s = sA.sessions{day_idx(d)};
		for t=1:4
			% computation parameters ...
			params.aType = [find(strcmp(s.trialTypeStr, 'Hit')) find(strcmp(s.trialTypeStr, 'Miss'))] ;
			params.bType = [find(strcmp(s.trialTypeStr, 'FA')) find(strcmp(s.trialTypeStr, 'CR'))]; 

			% compute
			params.method = 'psth_roc';
			switch t
				case 1
					params.responseTSA = s.caTSA.dffTimeSeriesArray;
					tstr = 'raw dff psth';
				case 2
					params.responseTSA = s.caTSA.eventBasedDffTimeSeriesArray;
					tstr = 'event dff psth';
				case 3
					params.responseTSA = s.caTSA.caPeakTimeSeriesArray.copy();
					vm = zeros(size(params.responseTSA.valueMatrix));
					vm(find(params.responseTSA.valueMatrix > 0)) = 1;
					params.responseTSA.valueMatrix = vm;
					tstr = 'binary psth';
				case 4
					params.method = 'evcount_roc';
					tstr = 'event count';
			end
			discrim = s.computeDiscrim(params);

			% plot
			ax = subplot(4,nd,(t-1)*nd + d);
			s.plotColorRois([],[],[],[],discrim,[0.5 1],ax,1);
			title([sA.dateStr{day_idx(d)}(1:11) ' ' tstr]);
		end
	end

	outFile = [root_out 'discrim_' char(sA.mouseId) '_' strrep(char(sA.dateStr(day_idx(d))),':','') ...
						 '_FOV_keydays.eps'];
	outFile=strrep(outFile,' ','_');
	if (printon) ; print(fh, '-depsc2', '-noui', '-r300', outFile); end
	
end

% compute index for ALL cells individually on all days; plot across days w/ performance, 
%  highlight key neurons
if (1) 
	day_idx = [1:9 11:20];
	nd = length(day_idx);
	fh = figure;

  for d=1:length(day_idx)
		s = sA.sessions{day_idx(d)};
		% computation parameters ...
		params.aType = [find(strcmp(s.trialTypeStr, 'Hit')) find(strcmp(s.trialTypeStr, 'Miss'))] ;
		params.bType = [find(strcmp(s.trialTypeStr, 'FA')) find(strcmp(s.trialTypeStr, 'CR'))]; 

		% compute
		params.method = 'psth_roc';
		params.responseTSA = s.caTSA.caPeakTimeSeriesArray.copy();
		vm = zeros(size(params.responseTSA.valueMatrix));
		vm(find(params.responseTSA.valueMatrix > 0)) = 1;
		params.responseTSA.valueMatrix = vm;
		tstr = 'binary psth';

		discrim_mat(d,:) = s.computeDiscrim(params);
	end

	% plot
	fh = figure;

  subplot(3,1,1);
	plot(sA.performanceStats(day_idx,2), 'ko', 'MarkerFaceColor', [0 0 0]);
	ylabel('performance (d-prime)');
	hold on;
  plot([0 20], [1 1], 'k:')	;

  subplot(3,1,2);
	plot(discrim_mat, '-o');
	axis([0 length(day_idx)+1 0.3 1]);

  subplot(3,1,3); % key cells
	%roiIds = [17 19 42 67 79 187]; % for second step
	plot(discrim_mat(:,42), '-o', 'Color', [1 0 0], 'MarkerFaceColor', [1 0 0]);
	hold on;
	plot(discrim_mat(:,19), '-o', 'Color', [0 1 0], 'MarkerFaceColor', [0 1 0]);
	plot(discrim_mat(:,17), '-o', 'Color', [0 0 1], 'MarkerFaceColor', [0 0 1]);
	plot(discrim_mat(:,79), '-o', 'Color', [1 0 1], 'MarkerFaceColor', [1 0 1]);
	plot(discrim_mat(:,67), '-o', 'Color', [0 0 0], 'MarkerFaceColor', [0 0 0]);
	plot(discrim_mat(:,65), '-o', 'Color', [0 1 1], 'MarkerFaceColor', [0 1 1]);
	set (gca, 'TickDir', 'out');
	xlabel('time (days)');
	ylabel('ROC area');
	for d=1:length(day_idx)
	  text(d,0.35, sA.dateStr{day_idx(d)}(1:6) , 'Rotation', 90);
	end
	axis([0 length(day_idx)+1 0.3 1]);

	outFile = [root_out 'discrim_' char(sA.mouseId) '_' strrep(char(sA.dateStr(day_idx(d))),':','') ...
						 '_allday_performance.eps'];
	outFile=strrep(outFile,' ','_');
	if (printon) ; print(fh, '-depsc2', '-noui', '-r300', outFile); end
	
end



if (1) % pool touch cells, all cells ; plot vs performance
  day_idx = 1:length(sA.sessions);
	day_idx = [1:9 11:20];
	roiIds = [17 19 42 67 65 79 187]; % for second step

	clear discrim_poolall, discrim_pooltouch;

  % discrim_poolall
  for d=1:length(day_idx)
		s = sA.sessions{day_idx(d)};
		% computation parameters ...
		params.aType = [find(strcmp(s.trialTypeStr, 'Hit')) find(strcmp(s.trialTypeStr, 'Miss'))] ;
		params.bType = [find(strcmp(s.trialTypeStr, 'FA')) find(strcmp(s.trialTypeStr, 'CR'))]; 
		params.responseTSA = s.caTSA.caPeakTimeSeriesArray.copy();
		vm = zeros(size(params.responseTSA.valueMatrix));
		vm(find(params.responseTSA.valueMatrix > 0)) = 1;
		params.responseTSA.valueMatrix = vm;

		% compute
		params.method = 'psth_roc_pool';
		tic
		discrim_poolall(d) = s.computeDiscrim(params);
		toc
	end

  %  discrim_pooltouch
  for d=1:length(day_idx)
		s = sA.sessions{day_idx(d)};

		% computation parameters ...
		ri = find(ismember(s.caTSA.ids, roiIds));
		params.aType = [find(strcmp(s.trialTypeStr, 'Hit')) find(strcmp(s.trialTypeStr, 'Miss'))] ;
		params.bType = [find(strcmp(s.trialTypeStr, 'FA')) find(strcmp(s.trialTypeStr, 'CR'))]; 
		params.responseTSA = s.caTSA.caPeakTimeSeriesArray.copy();
		vm = zeros(size(params.responseTSA.valueMatrix));
		vm(find(params.responseTSA.valueMatrix > 0)) = 1;
		params.responseTSA.valueMatrix = vm(ri,:);
		params.responseTSA.ids = s.caTSA.ids(ri);

		% compute
		params.method = 'psth_roc_pool';
		tic
		discrim_pooltouch(d) = s.computeDiscrim(params);
		toc
	end

	% plot
	fh = figure;

  subplot(2,1,1);
	plot(sA.performanceStats(day_idx,2), 'ko', 'MarkerFaceColor', [0 0 0]);
	ylabel('performance (d-prime)');
	hold on;
  plot([0 20], [1 1], 'k:')	;
  subplot(2,1,2);
	plot(discrim_pooltouch, 'ro', 'MarkerFaceColor', [1 0 0]);
	hold on;
	plot(discrim_poolall, 'bo', 'MarkerFaceColor', [0 0 1]);
	set (gca, 'TickDir', 'out');
	xlabel('time (days)');
	ylabel('ROC area');
	for d=1:length(day_idx)
	  text(d,0.35, sA.dateStr{day_idx(d)}(1:6) , 'Rotation', 90);
	end
	axis([0 length(day_idx)+1 0.3 1]);

  % print
	outFile = [root_out 'discrim_' char(sA.mouseId) '_multiday_pool_cells_' ...
						 '_psthbinary.eps'];
	outFile=strrep(outFile,' ','_');
	if (printon) ; print(fh, '-depsc2', '-noui', '-r300', outFile); end

end


