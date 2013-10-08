%
% SP 2011 Sept
%
% Session generation
%
function dsp = sessgen4()
	global rootDataPath;
	rootDataPath = '/media/';
	doAnimal = {'148378'};
	dsp = {};

	% 148378
  if (sum(strcmp('148378',doAnimal)))
		dates = {'2011_09_12-1'};
		dates = {'2011_09_21-1'};
		dates = {'2011_09_14-1','2011_09_15-1','2011_09_16-1','2011_09_17-1'};
		dates = {'2011_09_14-1','2011_09_17-1'};
		dates = {'2011_09_14-1','2011_09_15-1','2011_09_16-1','2011_09_17-1'};
		dates = {'2011_09_10-1','2011_09_13-1','2011_09_20-1','2011_09_22-1','2011_09_23-1'};
		an = '148378';
		bseDir = [rootDataPath 'an' an filesep 'an' an filesep];
		wDir = [rootDataPath an 'w' filesep 'an' an filesep];
		roiPre = '';
		roiPost = '';
		dsp = buildDSPAnimal (an, dates, bseDir, wDir, roiPost, roiPre,dsp);

		% date-specific mods
		for d=1:length(dates)
      %% ADD EXPLICIT CHECK :: if date is on or before 9/9/11, whiskerVideoTimeOffsetInMs is 0 ; otherwise, 100
		  if (strcmp(dates{d}, '2011_09_12-1')) % whisker trial start at 0 so add 1
			  dsp{d}.whiskerTrialIncrement = 1;
	      dsp{d}.scimFileWC = 'Image_Registration_5*main*tif';
			end
		  if (strcmp(dates{d}, '2011_09_13-1')) ; dsp{d}.whiskerTrialIncrement = 1; end
		  if (strcmp(dates{d}, '2011_09_14-1')) ; dsp{d}.whiskerTrialIncrement = 1; end
		  if (strcmp(dates{d}, '2011_09_15-1')) ; dsp{d}.whiskerTrialIncrement = 1; end
		  if (strcmp(dates{d}, '2011_09_16-1')) ; dsp{d}.whiskerTrialIncrement = 1; end
		  if (strcmp(dates{d}, '2011_09_10-1')) ; dsp{d}.whiskerTrialIncrement = 1; end
		end
	end

	% call runner
  runAnimals (dsp);


function dsp = buildDSPAnimal (an, dates, bseDir, wDir, roiPost, roiPre, dsp)
  for d=1:length(dates)
		wFullPath = [wDir dates{d}];
		flW = dir([wFullPath filesep '*wc']);
		if (length(flW) > 0)
		  roiPostS = roiPost;
			dashIdx = find(dates{d} == '-');
			dateStr = dates{d}(1:dashIdx(1)-1);
			if (str2num(dates{d}(dashIdx(1)+1)) == 2) ; dateStr = [dateStr 'b']; end
			bseFullPath = [bseDir dateStr]
			flBSE = dir(bseFullPath);
			if (length(flBSE) >= 5) ; % .. . behav ephus scanimage
        tdsp = buildsingleDSP(bseFullPath, bseDir, roiPre, roiPostS, dateStr, wFullPath, an);
	 		  dsp{length(dsp)+1} = tdsp;
			end
		end
	end

function dsp = buildsingleDSP(bseFullPath, bseDir, roiPre, roiPost, dateStr, wFullPath, an)
	% behvaior file - the one thing that is tricky
	bFileList = dir([bseFullPath filesep 'behav' filesep 'data_@pole_detect_spobj*mat']);
	for bfli=1:length(bFileList)
	  dateVal(bfli) = bFileList(bfli).datenum;
	end
	[irr behIdx] = max(dateVal);
	if (strcmp(an,'107029')) ; behIdx = length(bFileList) ; end
	if (strcmp(an,'38596')) ; behIdx = length(bFileList) ; end
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

if ( 1 == 0) % DEBUG!!
	dsp.whiskerFileWC = 'WDBP*_001*.mat';
	dsp.scimFileWC = 'Image_Registration_4*main_01*tif';
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
