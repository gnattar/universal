%
% For behavior-only generation (with ephus)
%
%  eph_path: either the path where ephus files live, or any # to autodetermine from beh_path
%
function [s dsp] = sessgen_beh(beh_path, eph_path)
  s = session.session;
	
	% base data path
  if (length(fileparts(beh_path)) == 0)
	  bseFullPath = pwd;
		bseFullPath = strrep(bseFullPath,'behav','');
	else
	  bseFullPath = fileparts(beh_path);
		bseFullPath = strrep(bseFullPath,'behav','');
	end

  % --- behavior stuff
  dsp.behavSoloFilePath = beh_path;

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
	if (nargin > 1)
    if (isnumeric (eph_path))
  		dsp.ephusFilePath = [bseFullPath filesep 'ephus'];
    else
      dsp.ephusFilePath = eph_path;
    end
		dsp.ephusFileWC = '*.xsg';

		dsp.ephusDownsample = 100;
		dsp.ephusChanIdent = {'licklaser', 'pole_position', 'lickport1', 'lickport2'};
	else
	  dsp.ephusFilePath = '';
	end

	s.dataSourceParams = dsp;
	s.sequentialSessionGenerator();

