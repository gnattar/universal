%
% For sessgen of column
%
function [s dsp] = sessgen_column()
  % base data path
	if (strcmp(computer, 'GLNXA64'))
    basePath = '/media/';
	elseif (strcmp(computer,'MACI64'))
		basePath = '/Volumes/';
	else
	  disp('Unrecognized computer.');
	  return;
	end

  s = [];
	dsp = {};
	doAnimal = {'160508'};
%	doAnimal = {'160508_beh'};
%	doAnimal = {'161322_beh'};
%	doAnimal = {'163522_beh'};
	doAnimal = {'166555','166558'};
	doAnimal = {'171923','167951','160508'};
	doAnimal = {'167951'};

	% 166555
  if (sum(strcmp('166555',doAnimal)))
	basePath = '/data/';
    dates = {'2012_04_23-1'};
		an = '166555';
		bseDir = [basePath 'an' an filesep]
		outDir = [bseDir filesep 'session'];

		wDir = [basePath an 'w' filesep];
		roiPre = '';
		roiPost = '';

		doSteps = [1 1 1];

		volIds = 1;
		fovIds = [2 3 4];

		nBehav = ones(1,length(dates));
		dsp = buildDSPAnimal (an, dates, bseDir, wDir, roiPost, roiPre,dsp, outDir, doSteps, volIds, fovIds, nBehav);

		% date-specific mods
		for d=1:length(dates)
%		  if (strcmp(dates{d}, '2011_02_12-1')) % change whiskerTrialArrayParams thus:
%      	dsp{d}.whiskerTrialArrayParams.barInReachFraction = 0.4;
%      	dsp{d}.whiskerTrialArrayParams.barCenterOffset = [-2 0];
%      	dsp{d}.whiskerTrialArrayParams.barRadius = 7;
%			end
		end
	end

	% 166558
  if (sum(strcmp('166558',doAnimal)))
	basePath = '/data/';
    dates = {'2012_04_23-1'};
		an = '166558';
		bseDir = [basePath 'an' an filesep]
		outDir = [bseDir filesep 'session'];

		wDir = [basePath an 'w' filesep];
		roiPre = '';
		roiPost = '';

		doSteps = [1 1 1];

		volIds = 1;
		fovIds = [2 3 4];

		nBehav = ones(1,length(dates));
		dsp = buildDSPAnimal (an, dates, bseDir, wDir, roiPost, roiPre,dsp, outDir, doSteps, volIds, fovIds, nBehav);

		% date-specific mods
		for d=1:length(dates)
%		  if (strcmp(dates{d}, '2011_02_12-1')) % change whiskerTrialArrayParams thus:
%      	dsp{d}.whiskerTrialArrayParams.barInReachFraction = 0.4;
%      	dsp{d}.whiskerTrialArrayParams.barCenterOffset = [-2 0];
%      	dsp{d}.whiskerTrialArrayParams.barRadius = 7;
%			end
		end
	end

	% 167951
  if (sum(strcmp('167951',doAnimal)))
		dates = {'2012_04_30','2012_05_01','2012_05_02', ...
		         '2012_05_03','2012_05_04','2012_05_06', ...
             '2012_05_07','2012_05_08','2012_05_09', ...
						 '2012_05_10','2012_05_11'};
		dates = {'2012_05_07'};
%dates = dates(7:9)
		for d=1:length(dates) ; dates{d} = [dates{d} '-1']; end

%	basePath = '/data/';
%	disp('FOR NOW USING /data/ FOR SPEED');
		an = '167951';
		bseDir = ['/data/an' an 'a' filesep];
%		bseDir = [basePath 'an' an 'a' filesep];
		outDir = [bseDir filesep 'session'];

%		wDir = ['/media/' an 'w' filesep];
		wDir = [basePath an 'w' filesep];
		roiPre = 'an167951';
		roiPost = '';

		doSteps = [1 1 1];

		volIds = 1:16;
		fovIds = [2 3 4];

		nBehav = ones(1,length(dates));
%    di = find(strcmp(dates,'2012_05_09-1'));
%		if (length(di) > 0) ; nBehav(di) = 2; end
		
		dsp = buildDSPAnimal (an, dates, bseDir, wDir, roiPost, roiPre,dsp, outDir, doSteps, volIds, fovIds, nBehav);

		% date-specific mods
		for d=1:length(dates)
%		  if (strcmp(dates{d}, '2011_02_12-1')) % change whiskerTrialArrayParams thus:
%      	dsp{d}.whiskerTrialArrayParams.barInReachFraction = 0.4;
%      	dsp{d}.whiskerTrialArrayParams.barCenterOffset = [-2 0];
%      	dsp{d}.whiskerTrialArrayParams.barRadius = 7;
%			end
		end
	end

	% 171923
  if (sum(strcmp('171923',doAnimal)))
	  dates = {'2012_06_04','2012_06_05','2012_06_06','2012_06_07','2012_06_10', ...
         '2012_06_11','2012_06_12','2012_06_13','2012_06_14','2012_06_15','2012_06_16'};
	  dates = {'2012_06_04','2012_06_10', ...
         '2012_06_12','2012_06_15','2012_06_16'};

	  dates = {'2012_06_05','2012_06_06','2012_06_07', ...
         '2012_06_11','2012_06_13','2012_06_14'};

		for d=1:length(dates) ; dates{d} = [dates{d} '-1']; end

		an = '171923';
		bseDir = [basePath 'an' an 'a' filesep];
		outDir = [bseDir filesep 'session'];

		wDir = ['/media/' an 'w' filesep];
%		wDir = [basePath an 'w' filesep];
		roiPre = 'an171923';
		roiPost = '';

		doSteps = [1 1 1];

		volIds = 1:16;
		fovIds = [2 3 4];

		nBehav = ones(1,length(dates));
		dsp = buildDSPAnimal (an, dates, bseDir, wDir, roiPost, roiPre,dsp, outDir, doSteps, volIds, fovIds, nBehav);

		% date-specific mods
		for d=1:length(dates)
%		  if (strcmp(dates{d}, '2011_02_12-1')) % change whiskerTrialArrayParams thus:
%      	dsp{d}.whiskerTrialArrayParams.barInReachFraction = 0.4;
%      	dsp{d}.whiskerTrialArrayParams.barCenterOffset = [-2 0];
%      	dsp{d}.whiskerTrialArrayParams.barRadius = 7;
%			end
		end
	end

	% 160508
  if (sum(strcmp('160508',doAnimal)))
    dates = {'2012_02_09-1','2012_02_10-1','2012_02_11-1','2012_02_12-1','2012_02_13-1','2012_02_14-1', '2012_02_15-1'};
    dates = {'2012_02_09-1','2012_02_10-1','2012_02_11-1','2012_02_12-1','2012_02_13-1'};
    dates = {'2012_02_14-1', '2012_02_15-1'};
		an = '160508';
		bseDir = [basePath 'an' an 'b' filesep];
		outDir = [bseDir filesep 'session'];

		wDir = [basePath an 'w' filesep];
		roiPre = 'an160508_2012_02_10_based';
		roiPost = '';

		doSteps = [1 1 1];

		volIds = 1:11;
		fovIds = [2 3 4];

		nBehav = ones(1,length(dates));
		dsp = buildDSPAnimal (an, dates, bseDir, wDir, roiPost, roiPre,dsp, outDir, doSteps, volIds, fovIds, nBehav);

		% date-specific mods
		for d=1:length(dates)
%		  if (strcmp(dates{d}, '2011_02_12-1')) % change whiskerTrialArrayParams thus:
%      	dsp{d}.whiskerTrialArrayParams.barInReachFraction = 0.4;
%      	dsp{d}.whiskerTrialArrayParams.barCenterOffset = [-2 0];
%      	dsp{d}.whiskerTrialArrayParams.barRadius = 7;
%			end
		end
	end

	% 160508 BEH ONLY
  if (sum(strcmp('160508_beh',doAnimal)))
	  basePath = '/data/';

    dates = {'2012_01_18-1','2012_01_19-1','2012_01_20-1','2012_01_21-1','2012_01_22-1','2012_01_23-1', '2012_01_24-1', ...
		         '2012_01_25-1','2012_01_26-1','2012_01_27-1','2012_01_29-1','2012_01_30-1','2012_01_31-1', '2012_02_01-1', ...
             '2012_02_02-1','2012_02_03-1','2012_02_05-1','2012_02_06-1','2012_02_07-1','2012_02_08-1', ...
             '2012_02_09-1','2012_02_10-1','2012_02_11-1','2012_02_12-1','2012_02_13-1','2012_02_14-1', '2012_02_15-1'};
		an = '160508';
		bseDir = [basePath 'an' an filesep];
		outDir = [bseDir filesep 'session_beh'];

		wDir = [basePath an 'w' filesep];
		roiPre = 'an160508_2012_02_10_based';
		roiPost = '';

		doSteps = [0 0 0];

		nBehav = ones(1,length(dates));
		dsp = buildDSPAnimal (an, dates, bseDir, wDir, roiPost, roiPre,dsp, outDir, doSteps, volIds, fovIds, nBehav);

		% date-specific mods
		for d=1:length(dates)
%		  if (strcmp(dates{d}, '2011_02_12-1')) % change whiskerTrialArrayParams thus:
%      	dsp{d}.whiskerTrialArrayParams.barInReachFraction = 0.4;
%      	dsp{d}.whiskerTrialArrayParams.barCenterOffset = [-2 0];
%      	dsp{d}.whiskerTrialArrayParams.barRadius = 7;
%			end
		end
	end

	% call runner
  runAnimals (dsp);


function dsp = buildDSPAnimal (an, dates, bseDir, wDir, roiPost, roiPre, dsp, outDir, doSteps, volIds, fovIds, nBehav)
  for d=1:length(dates)
		wFullPath = [wDir dates{d}];
		flW = dir([wFullPath filesep '*wc']);
%		if (length(flW) > 0)
		  roiPostS = roiPost;
			dashIdx = find(dates{d} == '-');
			dateStr = dates{d}(1:dashIdx(1)-1);
			if (str2num(dates{d}(dashIdx(1)+1)) == 2) ; dateStr = [dateStr 'b']; end
			bseFullPath = [bseDir dateStr];
			flBSE = dir(bseFullPath);
			if (length(flBSE) >= 2) ; 
        tdsp = buildsingleDSP(bseFullPath, bseDir, roiPre, roiPostS, dateStr, wFullPath, an, outDir, doSteps, volIds, fovIds, nBehav(d));
	 		  dsp{length(dsp)+1} = tdsp;
			end
%		eness
	end

function dsp = buildsingleDSP(bseFullPath, bseDir, roiPre, roiPost, dateStr, wFullPath, an, outDir, doSteps, volIds, fovIds, nBehav)
	% behvaior file - the one thing that is tricky
	bFileList = dir([bseFullPath filesep 'behav' filesep 'data_@pole_detect_twoport_spobj*mat']);
	for bfli=1:length(bFileList)
	  dateVal(bfli) = bFileList(bfli).datenum;
	end

	[irr idx] = sort(dateVal, 'ascend');
	behIdx = [];
	for i=(length(dateVal)-nBehav+1):length(dateVal)
	  behIdx = [behIdx idx(i)];
	end
%  behIdx = length(dateVal);
	sessFile = [outDir filesep 'an' an '_' dateStr '_sess.mat'];
	wtaFile = [outDir filesep 'an' an '_' dateStr '_wta.mat'];

  dsp.baseFileName = sessFile;
  
  % --- behavioral stuff
	if (length(behIdx) == 1)
		dsp.behavSoloFilePath = [bseFullPath filesep 'behav' filesep bFileList(behIdx).name];
	else
	  for b=1:length(behIdx) 
			dsp.behavSoloFilePath{b} = [bseFullPath filesep 'behav' filesep bFileList(behIdx(b)).name];
		end
	end

	dsp.behavSoloParams{1} = {1, 1, 'Beam Breaks Left', [1 0 0], 1};
	dsp.behavSoloParams{2} = {1, 3, 'Beam Breaks Right', [1 0 1], 1};
	dsp.behavSoloParams{3} = {3, [42 43], 'Pole Movement', [0 0 0], 2}; 
	dsp.behavSoloParams{4} = {3, [48 53], 'Water Valve Left', [0 0 1], 2};
	dsp.behavSoloParams{5} = {3, [49 53], 'Water Valve Right', [0 1 1], 2};
	dsp.behavSoloParams{6} = {3, [51 44], 'Reward Cue', [0 1 0], 2};
	dsp.behavSoloParams{7} = {2, 58 , 'Punishment Sample', [1 1 0], 1}; 
	dsp.behavSoloParams{8} = {2, 59 , 'Punishment Preans', [1 1 0], 1}; 

	dsp.trialBehavParams{1}{1} = 'saved_history.ValvesSection_LWaterValveTime';
	dsp.trialBehavParams{2}{1} = 'LWaterValveTime';
	dsp.trialBehavParams{1}{2} = 'saved_history.ValvesSection_RWaterValveTime';
	dsp.trialBehavParams{2}{2} = 'RWaterValveTime';
	dsp.trialBehavParams{1}{3} = 'saved_history.TimesSection_PreTrialPauseTime';
	dsp.trialBehavParams{2}{3} = 'PreTrialPauseTime';
	dsp.trialBehavParams{1}{4} = 'saved_history.TimesSection_PoleRetractTime';
	dsp.trialBehavParams{2}{4} = 'PoleRetractTime';
	dsp.trialBehavParams{1}{5} = 'saved_history.TimesSection_PreAnswerTime';
	dsp.trialBehavParams{2}{5} = 'PreAnswerTime';
	dsp.trialBehavParams{1}{6} = 'saved.pole_detect_twoport_spobj_pole_position_history';
	dsp.trialBehavParams{2}{6} = 'stimulus';
	dsp.trialBehavParams{1}{7} = 'saved.pole_detect_twoport_spobj_lickport_position_history';
	dsp.trialBehavParams{2}{7} = 'lickport';
	dsp.trialBehavParams{1}{8} = 'saved_history.SidesSection_AutoTrainMode';
	dsp.trialBehavParams{2}{8} = 'AutoTrainMode';
	dsp.trialBehavParams{1}{9} = 'saved_history.SidesSection_RewardOnWrong';
	dsp.trialBehavParams{2}{9} = 'RewardOnWrong';
	dsp.trialBehavParams{1}{10} = 'saved_history.MotorsSection_left_position';
	dsp.trialBehavParams{2}{10} = 'leftStimRange';
	dsp.trialBehavParams{1}{11} = 'saved_history.MotorsSection_right_position';
	dsp.trialBehavParams{2}{11} = 'rightStimRange';
	dsp.trialBehavParams{1}{12} = 'saved_history.TimesSection_RestartPreAnsOnLick';
	dsp.trialBehavParams{2}{12} = 'restartDelayOnLick';
	dsp.trialBehavParams{1}{13} = 'saved_history.MotorsSection_LPWithdrawMode';
	dsp.trialBehavParams{2}{13} = 'withdrawLickport';
	dsp.trialBehavParams{1}{14} = 'saved_history.TimesSection_PunishTime';
	dsp.trialBehavParams{2}{14} = 'punishTime';

	% --- ephus
	if (doSteps(1))
		dsp.ephusFilePath = [bseFullPath filesep 'ephus'];

		dsp.ephusDownsample = 100;
		dsp.ephusChanIdent = {'licklaser', 'pole_position', 'lickport1', 'lickport2'};
	else
	  dsp.ephusFilePath = '';
	end

	% --- scanimage
  if (doSteps(2))
  	vi = 1;
		for v=1:length(volIds)
		  fi = 1;
			for f=1:length(fovIds)
				fovIdStr = sprintf('%02d%03d', volIds(v),fovIds(f));
				if (length(roiPre) > 0)
					roiArrPath = [bseDir 'rois' filesep roiPre '_' dateStr '_fov_' fovIdStr roiPost '.mat'];
				else
				  roiArrPath = [bseDir 'rois' filesep dateStr '_fov_' fovIdStr roiPost '.mat'];
				end
				if (exist(roiArrPath, 'file'))
					dsp.scimFilePath{vi}{fi} = [bseFullPath filesep 'scanimage' filesep 'fov_' fovIdStr filesep 'fluo_batch_out' filesep];
				  dsp.roiArrayPath{vi}{fi} = roiArrPath;
					fi = fi+1;
				else
				  disp(['Skipping nonexistent ' roiArrPath]);
				end
			end
			if (fi > 1) ; vi = vi + 1; end
		end
	%	dsp.scimFileWC = 'Image_Registration_*main*tif';
		dsp.scimFileWC = 'Image_Registration_4*tif';
	%	dsp.scimFileWC = 'Image_Registration_5*main*tif';
  else
		dsp.scimFilePath = '';
		dsp.roiArrayPath = '';
	end

  % --- whisker stuff
	if (doSteps(3))
		dsp.whiskerFilePath = [wFullPath filesep];
		dsp.whiskerFileWC = 'WDBP*.mat';
		dsp.whiskerTrialArrayBaseFileName = wtaFile;

		dsp.whiskerTrialArrayParams.barInReachFraction = 0.4;
		dsp.whiskerTrialArrayParams.barCenterOffset = [-2 0];
		dsp.whiskerTrialArrayParams.barRadius = 7;

		dsp.whiskerTrialArrayParams.detectContactsParams.inReachSteps = [1 1 1];
		dsp.whiskerTrialArrayParams.detectContactsParams.transitionSteps = [0 1 1];
		dsp.whiskerTrialArrayParams.detectContactsParams.distanceThreshold = [0.5 1.2];
		dsp.whiskerTrialArrayParams.detectContactsParams.dToBarBoundsAllowed = [0.5 1.4]; 

		if ( 1 == 0) % DEBUG -- only do 10 whisker trials instead of all
			dsp.whiskerFileWC = 'WDBP*_001*.mat';
		end
  else
	  dsp.whiskerFilePath = '';
		dsp.whiskerTrialArrayBaseFileName = '';
		dsp.whiskerTrialArrayParams = '';
	end

% runner for a cell array of dataSourcePArams
function runAnimals (dsp)
  parfor d=1:length(dsp)
	%for d=1:length(dsp)
		disp('=======================================================================');
		disp('=======================================================================');
		disp('=======================================================================');
		disp(['PROCESSING ' dsp{d}.baseFileName ' ' datestr(now) '[' num2str(d) ']']);
		disp([' ']);
		disp(['USING BEHAVIOR FILE (check this !!): ' dsp{d}.behavSoloFilePath]);

		if ( 1 == 1 ) % normal mode
			try
				s = session.session.generateSession(dsp{d});

				psave(s);
			catch me
				disp(['*****************************************************************************']);
				disp(['*****************************************************************************']);
				disp(['ID: ' dsp{d}.baseFileName]);
				disp(['ERROR: ' getReport(me, 'extended')]);
				disp(['*****************************************************************************']);
				disp(['*****************************************************************************']);
			end
		else % let problems kill you -- good for debugs
			s = session.session.generateSession(dsp{d});
			psave(s);
		end
	end

function psave(s)
	s.saveToFile();
	disp(['*****************************************************************************']);
	disp(['*****************************************************************************']);
	disp(['SAVED: ' s.baseFileName]);
	disp(['*****************************************************************************']);
	disp(['*****************************************************************************']);
%  save(fn,'s');

