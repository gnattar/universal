%
% For sessgen on 2afc data
%
function [s dsp] = sessgen5()
  % base data path
	if (strcmp(computer, 'GLNXA64'))
    basePath = '/data/';
	elseif (strcmp(computer,'MACI64'))
		basePath = '~/Desktop/behav_only/';
	else
	  disp('Unrecognized computer.');
	  return;
	end

	dsp = {};
	doAnimal = {'147333', '156299'};
	doAnimal = {'147333'};
	doAnimal = {'156299'};
	doAnimal = {'160508'};
% OLD:
%s=doOld(basePath);
%return
	% 147333
  if (sum(strcmp('147333',doAnimal)))
		dates = {'2012_01_02-1'};
		dates = {'2011_12_08-1','2011_12_09-1','2011_12_10-1','2011_12_12-1','2011_12_13-1','2011_12_14-1','2011_12_15-1', ...
		         '2011_12_16-1','2011_12_17-1','2011_12_19-1','2011_12_20-1','2011_12_21-1','2011_12_28-1','2012_01_01-1','2012_01_03-1'};
		an = '147333';
		bseDir = [basePath 'an' an filesep];
		wDir = [basePath an 'w' filesep];
		roiPre = '';
		roiPost = '';
		dsp = buildDSPAnimal (an, dates, bseDir, wDir, roiPost, roiPre,dsp);

		% date-specific mods
		for d=1:length(dates)
      %% ADD EXPLICIT CHECK :: if date is on or before 9/9/11, whiskerVideoTimeOffsetInMs is 0 ; otherwise, 100
%		  if (strcmp(dates{d}, '2011_09_12-1')) % whisker trial start at 0 so add 1
%			  dsp{d}.whiskerTrialIncrement = 1;
%	      dsp{d}.scimFileWC = 'Image_Registration_5*main*tif';
%			end
		end
	end

	% 156299
  if (sum(strcmp('156299',doAnimal)))
		dates = {'2012_01_02-1'};
		dates = {'2011_12_10-1','2011_12_12-1','2011_12_13-1','2011_12_14-1','2011_12_15-1', ...
		         '2011_12_16-1','2011_12_17-1','2011_12_19-1','2011_12_20-1','2011_12_21-1','2012_01_01-1','2012_01_03-1'};
		an = '156299';
		bseDir = [basePath 'an' an filesep];
		wDir = [basePath an 'w' filesep];
		roiPre = '';
		roiPost = '';
		dsp = buildDSPAnimal (an, dates, bseDir, wDir, roiPost, roiPre,dsp);

		% date-specific mods
		for d=1:length(dates)
      %% ADD EXPLICIT CHECK :: if date is on or before 9/9/11, whiskerVideoTimeOffsetInMs is 0 ; otherwise, 100
%		  if (strcmp(dates{d}, '2011_09_12-1')) % whisker trial start at 0 so add 1
%			  dsp{d}.whiskerTrialIncrement = 1;
%	      dsp{d}.scimFileWC = 'Image_Registration_5*main*tif';
%			end
		end
	end


	% 156299
  if (sum(strcmp('160508',doAnimal)))
		dates = {'2012_02_14-1'};
		an = '160508';
		basePath = '/media/';
		bseDir = [basePath 'an' an 'b' filesep];
		wDir = [basePath an 'w' filesep];
		roiPre = '';
		roiPost = '';
		dsp = buildDSPAnimal (an, dates, bseDir, wDir, roiPost, roiPre,dsp);

		% date-specific mods
		for d=1:length(dates)
      %% ADD EXPLICIT CHECK :: if date is on or before 9/9/11, whiskerVideoTimeOffsetInMs is 0 ; otherwise, 100
%		  if (strcmp(dates{d}, '2011_09_12-1')) % whisker trial start at 0 so add 1
%			  dsp{d}.whiskerTrialIncrement = 1;
%	      dsp{d}.scimFileWC = 'Image_Registration_5*main*tif';
%			end
		end
	end


	% call runner
  runAnimals (dsp);


function dsp = buildDSPAnimal (an, dates, bseDir, wDir, roiPost, roiPre, dsp)
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
        tdsp = buildsingleDSP(bseFullPath, bseDir, roiPre, roiPostS, dateStr, wFullPath, an);
	 		  dsp{length(dsp)+1} = tdsp;
			end
%		eness
	end

function dsp = buildsingleDSP(bseFullPath, bseDir, roiPre, roiPost, dateStr, wFullPath, an)
	% behvaior file - the one thing that is tricky
	bFileList = dir([bseFullPath filesep 'behav' filesep 'data_@pole_detect_twoport_spobj*mat']);
	for bfli=1:length(bFileList)
	  dateVal(bfli) = bFileList(bfli).datenum;
	end
	[irr behIdx] = max(dateVal);
	sessFile = [bseDir 'session' filesep 'an' an '_' dateStr '_sess.mat'];

  dsp.baseFileName = sessFile;
	dsp.ephusFilePath = [bseFullPath filesep 'ephus'];
	dsp.behavSoloFilePath = [bseFullPath filesep 'behav' filesep bFileList(behIdx).name];

  for f=1:4
	  dsp.scimFilePath{f} = [bseFullPath filesep 'scanimage' filesep 'fov_00' num2str(f) filesep 'fluo_batch_out' filesep];
	  dsp.roiArrayPath{f} = [bseDir 'rois' filesep roiPre dateStr '_fov_00' num2str(f) roiPost '.mat'];
	end
%	dsp.scimFileWC = 'Image_Registration_*main*tif';
	dsp.scimFileWC = 'Image_Registration_4*tif';
%	dsp.scimFileWC = 'Image_Registration_5*main*tif';
	
	dsp.whiskerFilePath = [wFullPath filesep];
	dsp.whiskerFileWC = 'WDBP*.mat';
	dsp.defaultBarRadius = 6.5; % pixels for me
	useBadFrameTimesLastDate = datenum('2010_04_12', 'yyyy_mm_dd');
	dsp.useBadFrameTimes = 0;
	dsp.detectContactParams.distanceThereshold = [0.2 1.4];
	dsp.detectContactParams.dToBarBoundsAllowed = [0.1 1.8];
	if (datenum(dateStr, 'yyyy_mm_dd') <= useBadFrameTimesLastDate) ; dsp.useBadFrameTimes = 1; end

  % --- behavioral stuff
	dsp.behavSoloParams{1} = {1, 1, 'Beam Breaks Left', [1 0 0], 1};
	dsp.behavSoloParams{2} = {1, 3, 'Beam Breaks Right', [1 0 1], 1};
	dsp.behavSoloParams{3} = {3, [42 43], 'Pole Movement', [0 0 0], 2}; 
	dsp.behavSoloParams{4} = {3, [48 46], 'Water Valve Left', [0 0 1], 2};
	dsp.behavSoloParams{5} = {3, [49 46], 'Water Valve Right', [0 1 1], 2};


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

	% --- ephus
	dsp.ephusDownsample = 100;
	dsp.ephusChanIdent = {'licklaser', 'pole_position', 'lickport1', 'lickport2'};
   

if ( 1 == 0) % DEBUG -- only do 10 whisker trials instead of all
	dsp.whiskerFileWC = 'WDBP*_001*.mat';
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



function s = doOld(basePath)
  s{1} = session.session();
	
	% --- behavioral stuff
	dsp.behavSoloParams{1} = {1, 1, 'Beam Breaks Left', [1 0 0], 1};
	dsp.behavSoloParams{2} = {1, 3, 'Beam Breaks Right', [1 0 1], 1};
	dsp.behavSoloParams{3} = {3, [42 43], 'Pole Movement', [0 0 0], 2}; 
	dsp.behavSoloParams{4} = {3, [48 46], 'Water Valve Left', [0 0 1], 2};
	dsp.behavSoloParams{5} = {3, [49 46], 'Water Valve Right', [0 1 1], 2};


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
   
  % --- whisker stuff

%%% BE sure to add contingency setting ; port position ; etc.

  behavSoloParams = dsp.behavSoloParams;
	trialBehavParams = dsp.trialBehavParams;

%  s{1}.generateBehavioralDataStructures([basePath 'an147333/data_@pole_detect_twoport_spobj_an147333_111220a.mat'], behavSoloParams, trialBehavParams)
%  s{1}.generateBehavioralDataStructures([basePath 'an156299/data_@pole_detect_twoport_spobj_an156299_111221a.mat'], behavSoloParams, trialBehavParams)
  s{1}.generateBehavioralDataStructures([basePath 'an147333/data_@pole_detect_twoport_spobj_an147333_120102a.mat'], behavSoloParams, trialBehavParams);
	s{2} = session.session();
  s{2}.generateBehavioralDataStructures([basePath 'an156299/data_@pole_detect_twoport_spobj_an156299_120102a.mat'], behavSoloParams, trialBehavParams);

if (0) %%% FOR TESTING NEW BEHAV STUFF ON OLD GUY
  tsi = length(s)+1;
  s{tsi} = session.session();
	dsp.behavSoloParams{1} = {1, 1, 'Beam Breaks', [1 0 1], 1};
	dsp.behavSoloParams{2} = {2, 43, 'Water Valve', [0 0 1], 2};
	dsp.behavSoloParams{3} = {2, 44, 'Drinking Allowed Period', [0 0 0.5], 2};
	dsp.behavSoloParams{4} = {2, 49, 'Airpuff', [1 0.5 0], 2};
	dsp.behavSoloParams{5} = {3, [41 50], 'Pole Movement', [0 0 0], 2}; % ME

	dsp.trialBehavParams{1}{1} = 'saved_history.ValvesSection_WaterValveTime';
	dsp.trialBehavParams{2}{1} = 'WaterValveTime';
	dsp.trialBehavParams{1}{2} = 'saved_history.ValvesSection_AirpuffTime';
	dsp.trialBehavParams{2}{2} = 'AirpuffTime';
	dsp.trialBehavParams{1}{3} = 'saved_history.TimesSection_PreTrialPauseTime';
	dsp.trialBehavParams{2}{3} = 'PreTrialPauseTime';
	dsp.trialBehavParams{1}{4} = 'saved_history.TimesSection_PoleRetractTime';
	dsp.trialBehavParams{2}{4} = 'PoleRetractTime';
	dsp.trialBehavParams{1}{5} = 'saved_history.TimesSection_PreAnswerTime';
	dsp.trialBehavParams{2}{5} = 'PreAnswerTime';
	dsp.trialBehavParams{1}{6} = 'saved_history.SidesSection_NoGoProb';
	dsp.trialBehavParams{2}{6} = 'NoGoProb';
	dsp.trialBehavParams{1}{7} = 'saved_history.SidesSection_MaxSame';
	dsp.trialBehavParams{2}{7} = 'MaxSame';
	dsp.trialBehavParams{1}{8} = 'saved_history.MotorsSection_motor_position';
	dsp.trialBehavParams{2}{8} = 'stimulus';

  behavSoloParams = dsp.behavSoloParams;
	trialBehavParams = dsp.trialBehavParams;

%  s{2}.generateBehavioralDataStructures('/data/an148378/2011_09_06/behav/data_@pole_detect_spobj_an148378_110906a.mat', behavSoloParams, trialBehavParams)
end

