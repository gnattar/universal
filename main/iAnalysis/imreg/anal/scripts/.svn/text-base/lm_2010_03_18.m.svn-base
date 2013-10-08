if (~exist('sA'))
  cd ('~/data/an38596/session2');
	load ('goodDayArray');
end
root_out = '~/Desktop/lmplots/';
printon =1;

recompute = 0;
colorRange = [0 1];
params = [];

% maxdff settigns:
if ( 1 ) 
params.method = 'max_dff_mad';
params.touchWindow = [0 1];
colorRange = [0 5];
params.trialTouchNumber = 1;
end

% Frac RF settings
if (0)
params.method = 'Frac_RF';
end

if (1) % plot conditional probability for day
  day_idx = 3;
	fh = figure;

	for a=1:4; ai(a) = subplot(2,2,a) ; end

	if (recompute | length(sA.sessions{day_idx}.touchIndex) == 0)
		sA.sessions{day_idx}.computeRoiTouchIndex(params);
	end

	plotParams = [];
	plotParams.showColorbar = 1;
	plotParams.axRef = ai;
	plotParams.colorRange = colorRange;
	sA.sessions{day_idx}.plotRoiTouchIndex(plotParams);

  outFile = [root_out char(sA.mouseId) '_' strrep(char(sA.dateStr(day_idx)),':','') ...
	           '_condprob_' condimeth '_oneday.eps'];
	outFile=strrep(outFile,' ','_');
  if(printon);	print(fh, '-depsc2', '-noui', '-r300', outFile); end
end

if (1) % plot conditional probability for several days
  day_idx = [1 3 5 7 11 17 19];
	whiskers = {'c1', 'c2', 'c3'};
	nwhiskers = length(whiskers);
	fh = figure;

	for d=1:length(day_idx)
	  ai = [];
    for w=1:nwhiskers
	    wi = find(strcmp(lower(sA.sessions{day_idx(d)}.whiskerTag), lower(whiskers{w})));
		  nd = length(day_idx);
	    ai(wi) = subplot(nwhiskers,nd, d + (w-1)*nd);
		end
		ai = [ai nan nan nan];
  
		if (recompute | length(sA.sessions{day_idx(d)}.touchIndex) == 0)
			sA.sessions{day_idx(d)}.computeRoiTouchIndex(params);
		end

		plotParams = [];
		plotParams.showColorbar = 0;
		plotParams.axRef = ai;
		plotParams.colorRange = colorRange;
		sA.sessions{day_idx(d)}.plotRoiTouchIndex(plotParams);
		title(sA.dateStr{day_idx(d)});
	end

  outFile = [root_out char(sA.mouseId) '_' strrep(char(sA.dateStr(day_idx(d))),':','') ...
	           '_condprob_' condimeth '_keydays.eps'];
	outFile=strrep(outFile,' ','_');
	if (printon) ; print(fh, '-depsc2', '-noui', '-r300', outFile); end
end


if (1) % plot conditional probability for all days, one whisker @ time
  day_idx = 1:20;
	nr = 4;
	nc = 5;
	whiskers = {'c1', 'c2', 'c3'};
	nwhiskers = length(whiskers);

  for w=1:nwhiskers
	  fh = figure;
		for d=1:length(day_idx)
	    wi = find(strcmp(lower(sA.sessions{day_idx(d)}.whiskerTag), lower(whiskers{w})));
			if (~isempty(wi))
				aiw = subplot(nr, nc, d);
				ai = nan*ones(1,10);
				ai(wi) = aiw;
			
				if ((recompute | length(sA.sessions{day_idx(d)}.touchIndex) == 0) && w == 1)
					sA.sessions{day_idx(d)}.computeRoiTouchIndex(params);
				end

				plotParams = [];
				plotParams.showColorbar = 0;
				plotParams.axRef = ai;
				plotParams.colorRange = colorRange;
				sA.sessions{day_idx(d)}.plotRoiTouchIndex(plotParams);
				title([whiskers{w} ' ' sA.dateStr{day_idx(d)}]);
			end
		end
		outFile = [root_out char(sA.mouseId) '_' strrep(char(sA.dateStr(day_idx(d))),':','') ...
							 '_condprob_' condimeth '_alldays_whisker_' whiskers{w} '.eps'];
		outFile=strrep(outFile,' ','_');
		if (printon) ; print(fh, '-depsc2', '-noui', '-r300', outFile); end
	end
end


if (1) % plot whisker RF for several cells across ALL days
  day_idx = 1:20;
	nr = 4;
	nc = 5;
	whiskers = {'c1', 'c2', 'c3'};
	nwhiskers = length(whiskers);

  for roiId=[42 67 187 38 17 79 19];
		fh = figure;
		for d=1:length(day_idx)
			ai = subplot(nr, nc, d);
			plotParams = [];
			plotParams.showLabels = 1;
			plotParams.axRef = ai;
			plotParams.valueRange = 2*colorRange;
			sA.sessions{day_idx(d)}.plotRoiTouchScoreAcrossWhiskers(roiId, whiskers, plotParams);
			title(sA.dateStr{day_idx(d)});
		end
		outFile = [root_out char(sA.mouseId) '_' strrep(char(sA.dateStr(day_idx(d))),':','') ...
							 '_' condimeth '_condprob_bar_alldays_roi_' num2str(roiId) '.eps'];
		outFile=strrep(outFile,' ','_');
		if (printon) ; print(fh, '-depsc2', '-noui', '-r300', outFile); end
	end
end
