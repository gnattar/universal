function rerun_sess()
	global rootDataPath;
	rootDataPath = '/data/';
%	doAnimal = {'38596', '107029'}'
	doAnimal = {'38596'};

	% 38596
  if (sum(strcmp('38596',doAnimal)))
		dates = {'2010_02_02-1', '2010_02_03-1', '2010_02_04-1', '2010_02_05-1', '2010_02_08-1', '2010_02_09-1',  ...
			'2010_02_11-1', '2010_02_15-1', '2010_02_16-1', '2010_02_17-1', '2010_02_18-1', '2010_02_19-1', ...
			'2010_02_20-1', '2010_02_22-1', '2010_02_23-1', '2010_02_24-1', '2010_02_25-1', '2010_02_26-1',  ...
			'2010_03_01-1', '2010_03_02-1', '2010_03_03-1'}; 
%		dates = {'2010_02_18-1'};
		an = '38596';
		bseDir = [rootDataPath 'an' an filesep];
		wDir = [rootDataPath an 'w' filesep 'an' an filesep];
		roiPre = '';
		roiPost = '_cell_20100220_093_based';
		processAnimal (an, dates, bseDir, wDir, roiPost, roiPre);
	end

	% 107029
  if (sum(strcmp('107029',doAnimal)))
    dates = { '2010_08_02-1', '2010_08_02-trial', '2010_08_03-1', '2010_08_04-1', '2010_08_05-1', '2010_08_06-1',  ...
			'2010_08_09-1', '2010_08_10-1', '2010_08_11-1', '2010_08_12-1', '2010_08_13-1', '2010_08_16-1', '2010_08_17-1',  ...
			'2010_08_18-1', '2010_08_19-1', '2010_08_20-1', '2010_08_21-1', '2010_08_22-1', '2010_08_25-1', '2010_08_26-1',  ...
			'2010_08_27-1'};
		an = '107029';
		bseDir = [rootDataPath 'an' an filesep];
		wDir = [rootDataPath an 'w' filesep 'an' an filesep];
		roiPre = 'an107029_';
		roiPost = '';
		processAnimal (an, dates, bseDir, wDir, roiPost ,roiPre);
	end


function processAnimal (an, dates, bseDir, wDir, roiPost, roiPre)
	parfor d=1:length(dates)
		wFullPath = [wDir dates{d}]
		flW = dir([wFullPath filesep '*wc']);
		if (length(flW) > 0)
			dashIdx = find(dates{d} == '-');
			dateStr = dates{d}(1:dashIdx(1)-1);
	    sessFile = [bseDir 'session2' filesep 'an' an '_' dateStr '_sess.mat']

			S = load (sessFile);
			s = S.s;
			if (isobject(s.derivedDataTSA))
				s.updateWhiskerDataUsingEntireSession();
				s.computeDKappaVersusDff(); 
				s.generateDerivedDataStructures();
				s.saveToFile();
			end
		end
	end
