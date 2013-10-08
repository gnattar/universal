%
% SP 2011 may
%
function s = sessgen_ablate()
	global rootDataPath;
	rootDataPath = '/media/misc_data_1/Ablation/';

  bseFullPath = '/media/misc_data_1/Ablation/an134968/2011_05_16/';
  
  dsp.baseFileName = [bseFullPath '2011_05_16_sess.mat'];
	dsp.ephusFilePath = [bseFullPath filesep 'ephus'];
	dsp.behavSoloFilePath = [bseFullPath filesep 'behav' filesep 'data_@puff_spobj_an134968_110516a.mat'];

	dsp.scimFilePath = [bseFullPath filesep 'scanimage' filesep 'fluo_batch_out' filesep];
	dsp.roiArrayPath = [bseFullPath '2011_05_16_roi.mat'];
	dsp.scimFileWC = 'Image_Registration_5*main*tif';
	
	dsp.whiskerFilePath = [];
	dsp.whiskerFileWC = 'WDBP*.mat';
	dsp.defaultBarRadius = 21; % pixels for me
	dsp.useBadFrameTimes = 0;

	dsp.behavSoloParams{1} = {1, 1, 'Beam Breaks', [1 0 1], 1};
	dsp.behavSoloParams{2} = {2, 43, 'Airpuff', [1 0.5 0], 2};

	s = session.session.generateSession(dsp);
