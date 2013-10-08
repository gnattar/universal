function dsp = sessgen_DH
	%Base structure for SP's classes: 
	global rootDataPath;
	rootDataPath ='/media/Copy_SP'
	base='/media/Copy_SP/'; 
	global dsp; % we want to be able to access from outside to fix stuff ...
	dsp = {};
	dspt = {};
  
	%%% jf26707
	dspt = get_jf26707(base);
  for d=1:length(dspt) ; if(isstruct(dspt{d})) ; dsp{length(dsp)+1} = dspt{d}; end ; end
	dspt = [];
	% jf27332
	dspt = get_jf27332(base);
  for d=1:length(dspt) ; if(isstruct(dspt{d})) ; dsp{length(dsp)+1} = dspt{d}; end ; end
	dspt = [];
	% jf100601
	dspt = get_jf100601(base);
  for d=1:length(dspt) ; if(isstruct(dspt{d})) ; dsp{length(dsp)+1} = dspt{d}; end ; end
	dspt = [];
	% jf25609
	dspt = get_jf25609(base);
  for d=1:length(dspt) ; if(isstruct(dspt{d})) ; dsp{length(dsp)+1} = dspt{d}; end ; end
	dspt = [];
	% jf25607
	dspt = get_jf25607(base);
  for d=1:length(dspt) ; if(isstruct(dspt{d})) ; dsp{length(dsp)+1} = dspt{d}; end ; end
%	dsp = {dspt{6}};
	dspt = [];

%  for k=20:length(dsp)
  for k=1:length(dsp)
	  if (isfield(dsp{k},'userDefinedValidTrialIds'))
			[dsp{k}.scimFileList dsp{k}.scimFileTrial]=dh_create_file_list(dsp{k}.scimFilePath,dsp{k}.userDefinedValidTrialIds, dsp{k}.scimFileWC);
			if (0) % debug
				fl = dsp{k}.scimFileList;
				for f=1:10
					newFileList{f} = dsp{k}.scimFileList{f};
				end
				dsp{k}.scimFileList = newFileList;
			end
		end
	end

	parfor k=1:length(dsp)
%	parfor k=3
	  % global settings
 %dsp{k}.scimFileWC = strrep(dsp{k}.scimFileWC, '*', '0*');
	  dsp{k}.whiskerFileType = 2; 
	  dsp{k}.defaultBarRadius = 0.25;

		dsp{k}.behavSoloParams{1} = {1, 1, 'Beam Breaks', [1 0 1], 1};
		dsp{k}.behavSoloParams{2} = {2, 43, 'Water Valve', [0 0 1], 2};
		dsp{k}.behavSoloParams{3} = {2, 44, 'Drinking Allowed Period', [0 0 0.5], 2};
		dsp{k}.behavSoloParams{4} = {2, 49, 'Airpuff', [1 0.5 0], 2};
		dsp{k}.behavSoloParams{5} = {3, [60 61], 'Pole Movement', [0 0 0], 2}; % DH



		% the call
		s = session.session.generateSession(dsp{k})%;
		s.saveToFile;
	end


function dsp = get_jf25609(base)

	%% jf25609x121409

	dsp{1}.behavSoloFilePath=[base '/DOM3_behavior/JF25609/data_@pole_detect_nx2obj_JF25609_091214a']; 
	dsp{1}.roiArrayPath = [base 'DOM3_rois/jf25609/jf25609_121409.mat']; % check if present
	dsp{1}.scimFilePath=[base 'DOM3_imaging/jf25609/jf25609_121409/fluo_batch_out/rigid/'];
	dsp{1}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_jf25609_121409*tif';
	dsp{1}.ephusFilePath=[base 'DOM3_ephys/jf25609/dh1214/zeni']; 
	dsp{1}.ephusFileWC='dh1214zeni*'; 
	dsp{1}.ephusDownsample=[]; 
	dsp{1}.whiskerFilePath = [base 'DOM3_whisker/jf25609/'];
	dsp{1}.whiskerFileWC = 'jf25609x121409_6_360_session_B.mat';
	%dsp{1}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_mini.mat';
	dsp{1}.whiskerBarInReachES=2*[365 830]; %check
	dsp{1}.whiskerTag={'C1','C2','C3'};% {'C1', 'C2'};
	dsp{1}.baseFileName=[base 'DOM3_results/jf25609/jf25609x121409_sessSP.mat'];
	dsp{1}.userDefinedValidTrialIds=[6:200]; 
	dsp{1}.defaultBarRadius = 0.25;

	%% jf25609x121509

	dsp{2}.behavSoloFilePath=[base '/DOM3_behavior/JF25609/data_@pole_detect_nx2obj_JF25609_091215a']; 
	dsp{2}.roiArrayPath = [base 'DOM3_rois/jf25609/jf25609_121509.mat']; % check if present
	dsp{2}.scimFilePath=[base 'DOM3_imaging/jf25609/jf25609_121509/fluo_batch_out/rigid/'];
	dsp{2}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_jf25609_121509*tif';
	dsp{2}.ephusFilePath=[base 'DOM3_ephys/jf25609/dh1215/zeni']; 
	dsp{2}.ephusFileWC='dh1215zeni*'; 
	dsp{2}.ephusDownsample=[]; 
	dsp{2}.whiskerFilePath = [base 'DOM3_whisker/jf25609/'];
	dsp{2}.whiskerFileWC = 'jf25609x121509_7_270_session_B.mat';
	%dsp{2}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_mini.mat';
	dsp{2}.whiskerBarInReachES=2*[611 1007]; %check
	dsp{2}.whiskerTag={'C1','C2','C3'};% {'C1', 'C2'};
	dsp{2}.baseFileName=[base 'DOM3_results/jf25609/jf25609x121509_sessSP.mat'];
	dsp{2}.userDefinedValidTrialIds=[6:200]; 
	dsp{2}.defaultBarRadius = 0.25;


	%% jf25609x121609

	dsp{3}.behavSoloFilePath=[base '/DOM3_behavior/JF25609/data_@pole_detect_nx2obj_JF25609_091216a']; 
	dsp{3}.roiArrayPath = [base 'DOM3_rois/jf25609/jf25609_121609.mat']; % check if present
	dsp{3}.scimFilePath=[base 'DOM3_imaging/jf25609/jf25609_121609/fluo_batch_out/rigid/'];
	dsp{3}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_jf25609_121609*tif';
	dsp{3}.ephusFilePath=[base 'DOM3_ephys/jf25609/dh1216/zeni']; 
	dsp{3}.ephusFileWC='dh1216zeni*'; 
	dsp{3}.ephusDownsample=[]; 
	dsp{3}.whiskerFilePath = [base 'DOM3_whisker/jf25609/'];
	dsp{3}.whiskerFileWC = 'jf25609x121609_3_373_session_B.mat';
	%dsp{3}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_mini.mat';
	dsp{3}.whiskerBarInReachES=2*[611 1007]; %check
	dsp{3}.whiskerTag={'C1','C2','C3'};% {'C1', 'C2'};
	dsp{3}.baseFileName=[base 'DOM3_results/jf25609/jf25609x121609_sessSP.mat'];
	dsp{3}.userDefinedValidTrialIds=[6:200]; 
	dsp{3}.defaultBarRadius = 0.25;


	%% jf25609x121709

	dsp{4}.behavSoloFilePath=[base '/DOM3_behavior/JF25609/data_@pole_detect_nx2obj_JF25609_091217a']; 
	dsp{4}.roiArrayPath = [base 'DOM3_rois/jf25609/jf25609_121709.mat']; % check if present
	dsp{4}.scimFilePath=[base 'DOM3_imaging/jf25609/jf25609_121709/fluo_batch_out/rigid/'];
	dsp{4}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_jf25609_121709*tif';
	dsp{4}.ephusFilePath=[base 'DOM3_ephys/jf25609/dh1217/zeni']; 
	dsp{4}.ephusFileWC='dh1217zeni*'; 
	dsp{4}.ephusDownsample=[]; 
	dsp{4}.whiskerFilePath = [base 'DOM3_whisker/jf25609/'];
	dsp{4}.whiskerFileWC = 'jf25609x121709_4_247_session_B.mat';
	%dsp{4}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_mini.mat';
	dsp{4}.baseFileName=[base 'DOM3_results/jf25609/jf25609x121709_sessSP.mat'];
	dsp{4}.defaultBarRadius = 0.25;
	dsp{4}.whiskerTag={'C1', 'C2', 'C3'};% {'C1', 'C2'};
	dsp{4}.whiskerBarInReachES=2*[611 1007]; %check
	dsp{4}.userDefinedValidTrialIds=[6:200]; 

	%% jf25609x122109

	dsp{5}.behavSoloFilePath=[base '/DOM3_behavior/JF25609/data_@pole_detect_nx2obj_JF25609_091221a']; 
	dsp{5}.roiArrayPath = [base 'DOM3_rois/jf25609/jf25609_122109.mat']; % check if present
	dsp{5}.scimFilePath=[base 'DOM3_imaging/jf25609/jf25609_122109/fluo_batch_out/rigid/'];
	dsp{5}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_jf25609_122109*tif';
	dsp{5}.ephusFilePath=[base 'DOM3_ephys/jf25609/dh1221/zeni']; 
	dsp{5}.ephusFileWC='dh1221zeni*'; 
	dsp{5}.ephusDownsample=[]; 
	dsp{5}.whiskerFilePath = [base 'DOM3_whisker/jf25609/'];
	dsp{5}.whiskerFileWC = 'jf25609x122109_4_210_session_B.mat';
	%dsp{5}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_mini.mat';
	dsp{5}.whiskerBarInReachES=4*[301 506]; %check
	dsp{5}.whiskerTag={'C1','C2','C3'};% {'C1', 'C2'};
	dsp{5}.baseFileName=[base 'DOM3_results/jf25609/jf25609x122109_sessSP.mat'];
	dsp{5}.userDefinedValidTrialIds=[6:200]; 
	dsp{5}.defaultBarRadius = 0.25;

	%% jf25609x122309

	dsp{6}.behavSoloFilePath=[base '/DOM3_behavior/JF25609/data_@pole_detect_nx2obj_JF25609_091223a']; 
	dsp{6}.roiArrayPath = [base 'DOM3_rois/jf25609/jf25609_122309.mat']; % check if present
	dsp{6}.scimFilePath=[base 'DOM3_imaging/jf25609/jf25609_122309/fluo_batch_out/rigid/'];
	dsp{6}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_jf25609_122309*tif';
	dsp{6}.ephusFilePath=[base 'DOM3_ephys/jf25609/dh1223/zeni']; 
	dsp{6}.ephusFileWC='dh1223zeni*'; 
	dsp{6}.ephusDownsample=[]; 
	dsp{6}.whiskerFilePath = [base 'DOM3_whisker/jf25609/'];
	dsp{6}.whiskerFileWC = 'jf25609x122309_3_143_session_B.mat';
	%dsp{6}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_mini.mat';
	dsp{6}.whiskerBarInReachES=4*[301 506]; %check --> FRAME #
	dsp{6}.whiskerTag={'C1','C2','C3'};% {'C1', 'C2'};
	dsp{6}.baseFileName=[base 'DOM3_results/jf25609/jf25609x122309_sessSP.mat'];
	dsp{6}.userDefinedValidTrialIds=[6:200]; 
	dsp{6}.defaultBarRadius = 0.25;

	%%

function dsp = get_jf25607(base)

	dsp{1}.behavSoloFilePath=[base '/DOM3_behavior/JF25607/data_@pole_detect_nx2obj_JF25607_091214a']; 
	dsp{1}.roiArrayPath = [base 'DOM3_rois/jf25607/jf25607_121409.mat']; % check if present
	dsp{1}.scimFilePath=[base 'DOM3_imaging/jf25607/jf25607_121409/fluo_batch_out/rigid/'];
	dsp{1}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_jf25607_121409*tif';
	dsp{1}.ephusFilePath=[base 'DOM3_ephys/jf25607/dh1214/zese']; 
	dsp{1}.ephusFileWC='dh1214zese*'; 
	dsp{1}.ephusDownsample=[]; 
	dsp{1}.whiskerFilePath = [base 'DOM3_whisker/jf25607/'];
	%dsp{1}.whiskerFileWC = 'jf25607x121409jf25607_121409_5_322_session_B.mat';
	dsp{1}.whiskerFileWC = 'jf25607x020210_4_205_session_B.mat';
	%dsp{1}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_session_B.mat';
	dsp{1}.whiskerBarInReachES=2*[381 819]; %check

	dsp{1}.whiskerTag={'C4', 'C3', 'C2', 'C1'};
	dsp{1}.baseFileName=[base 'DOM3_results/jf25607/jf25607x121409_sessSP.mat'];
	dsp{1}.userDefinedValidTrialIds=[6:200]; 

	%% jf25607x121509

	dsp{2}.behavSoloFilePath=[base '/DOM3_behavior/JF25607/data_@pole_detect_nx2obj_JF25607_091215a']; 
	dsp{2}.roiArrayPath = [base 'DOM3_rois/jf25607/jf25607_121509.mat']; % check if present
	dsp{2}.scimFilePath=[base 'DOM3_imaging/jf25607/jf25607_121509/fluo_batch_out/rigid/'];
	dsp{2}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_jf25607_121509*tif';
	dsp{2}.ephusFilePath=[base 'DOM3_ephys/jf25607/dh1215/zese']; 
	dsp{2}.ephusFileWC='dh1215zese*'; 
	dsp{2}.ephusDownsample=[]; 
	dsp{2}.whiskerFilePath = [base 'DOM3_whisker/jf25607/'];
	dsp{2}.whiskerFileWC = 'jf25607x121509_3_389_session_B.mat';

	%dsp{2}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_session_B.mat';
	dsp{2}.whiskerBarInReachES=2*[615 1006]; %check
	dsp{2}.whiskerTag={'C3', 'C2', 'C1'};
	dsp{2}.baseFileName=[base 'DOM3_results/jf25607/jf25607x121509_sessSP.mat'];
	dsp{2}.userDefinedValidTrialIds=[4:350]; 


	%% jf25607x121609

	dsp{3}.behavSoloFilePath=[base '/DOM3_behavior/JF25607/data_@pole_detect_nx2obj_JF25607_091216a']; 
	dsp{3}.roiArrayPath = [base 'DOM3_rois/jf25607/jf25607_121609.mat']; % check if present
	dsp{3}.scimFilePath=[base 'DOM3_imaging/jf25607/jf25607_121609/fluo_batch_out/rigid/'];
	dsp{3}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_jf25607_121609*tif';
	dsp{3}.ephusFilePath=[base 'DOM3_ephys/jf25607/dh1216/zese']; 
	dsp{3}.ephusFileWC='dh1216zese*'; 
	dsp{3}.ephusDownsample=[]; 
	dsp{3}.whiskerFilePath = [base 'DOM3_whisker/jf25607/'];
	dsp{3}.whiskerFileWC = 'jf25607x121609_3_329_session_B.mat';
	%dsp{3}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_session_B.mat';
	dsp{3}.whiskerBarInReachES=2*[615 1006]; %check
	dsp{3}.whiskerTag={'C3', 'C2', 'C1'};
	dsp{3}.baseFileName=[base 'DOM3_results/jf25607/jf25607x121609_sessSP.mat'];
	dsp{3}.userDefinedValidTrialIds=[4:250]; 

	%% jf25607x121709
	dsp{4}.behavSoloFilePath=[base '/DOM3_behavior/JF25607/data_@pole_detect_nx2obj_JF25607_091217a']; 
	dsp{4}.roiArrayPath = [base 'DOM3_rois/jf25607/jf25607_121709.mat']; % check if present
	dsp{4}.scimFilePath=[base 'DOM3_imaging/jf25607/jf25607_121709/fluo_batch_out/rigid/'];
	dsp{4}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_jf25607_121709*tif';
	dsp{4}.ephusFilePath=[base 'DOM3_ephys/jf25607/dh1217/zese']; 
	dsp{4}.ephusFileWC='dh1217zese*'; 
	dsp{4}.ephusDownsample=[]; 
	dsp{4}.whiskerFilePath = [base 'DOM3_whisker/jf25607/'];
	dsp{4}.whiskerFileWC = 'jf25607x121709_4_277_session_B.mat';
	%dsp{4}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_session_B.mat';
	dsp{4}.whiskerBarInReachES=2*[615 1006]; %check
	dsp{4}.whiskerTag={'C3', 'C2', 'C1'};
	dsp{4}.baseFileName=[base 'DOM3_results/jf25607/jf25607x121709_sessSP.mat'];
	dsp{4}.userDefinedValidTrialIds=[4:165]; 


	%% jf25607x122109

	dsp{5}.behavSoloFilePath=[base '/DOM3_behavior/JF25607/data_@pole_detect_nx2obj_JF25607_091221a']; 
	dsp{5}.roiArrayPath = [base 'DOM3_rois/jf25607/jf25607_122109.mat']; % check if present
	dsp{5}.scimFilePath=[base 'DOM3_imaging/jf25607/jf25607_122109/fluo_batch_out/rigid/'];
	dsp{5}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_jf25607_122109*tif';
	dsp{5}.ephusFilePath=[base 'DOM3_ephys/jf25607/dh1221/zeni']; 
	dsp{5}.ephusFileWC='dh1221zeni*'; 
	dsp{5}.ephusDownsample=[]; 
	dsp{5}.whiskerFilePath = [base 'DOM3_whisker/jf25607/'];
	dsp{5}.whiskerFileWC = 'jf25607x122109_9_232_session_B.mat';
	%dsp{5}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_session_B.mat';
	dsp{5}.whiskerBarInReachES=2*[600 1006]; %check
	dsp{5}.whiskerTag={'C3', 'C2', 'C1'};
	dsp{5}.baseFileName=[base 'DOM3_results/jf25607/jf25607x122109_sessSP.mat'];
	dsp{5}.userDefinedValidTrialIds=[3:102]; 

	%% jf25607x122309

	dsp{6}.behavSoloFilePath=[base '/DOM3_behavior/JF25607/data_@pole_detect_nx2obj_JF25607_091223a']; 
	dsp{6}.roiArrayPath = [base 'DOM3_rois/jf25607/jf25607_122309.mat']; % check if present
	dsp{6}.scimFilePath=[base 'DOM3_imaging/jf25607/jf25607_122309/fluo_batch_out/rigid/'];
	dsp{6}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_jf25607_122309*tif';
	dsp{6}.ephusFilePath=[base 'DOM3_ephys/jf25607/dh1223/zese']; 
	dsp{6}.ephusFileWC='dh1223zese*'; 
	dsp{6}.ephusDownsample=[]; 
	dsp{6}.whiskerFilePath = [base 'DOM3_whisker/jf25607/'];
	dsp{6}.whiskerFileWC = 'jf25607x122909_3_123_session_B.mat';
	%dsp{6}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_session_B.mat';
	dsp{6}.whiskerBarInReachES=2*[610 1006]; %check
	dsp{6}.whiskerTag={'C1'};
	dsp{6}.baseFileName=[base 'DOM3_results/jf25607/jf25607x122309_sessSP.mat'];
	dsp{6}.userDefinedValidTrialIds=[3:103]; 


function dsp = get_jf26707(base)
	%% jf26707 010410
	dsp{1}.behavSoloFilePath=[base '/DOM3_behavior/JF26707/data_@pole_detect_nx2obj_JF26707_100104a.mat']; 
	dsp{1}.roiArrayPath = [base 'DOM3_rois/jf26707/jf26707_010410.mat'];
	dsp{1}.scimFilePath=[base 'DOM3_imaging/jf26707/jf26707_010410/ROI1/fluo_batch_out/'];
	dsp{1}.scimFileWC = 'Image_Registration_5_jf26707_010410*tif';

	dsp{1}.ephusFilePath=[base 'DOM3_ephys/jf26707/dh0104/CelB/']; 
	dsp{1}.ephusFileWC='dh0104CelB*'; 
	dsp{1}.ephusDownsample=[]; 
	dsp{1}.whiskerFilePath = [base 'DOM3_whisker/jf26707/'];
	dsp{1}.whiskerFileWC = 'jf26707x010410_5_224_session_B.mat';
	dsp{1}.whiskerBarInReachES=2*[630 1120];
	dsp{1}.whiskerTag={'C3' 'C2' 'C1'};% {'C1', 'C2'};
	dsp{1}.baseFileName=[base 'DOM3_results/jf26707/jf26707x010410_sessSP.mat'];


	%% jf26707 010510
	dsp{2}.behavSoloFilePath=[base '/DOM3_behavior/JF26707/data_@pole_detect_nx2obj_JF26707_100105a.mat']; 
	dsp{2}.roiArrayPath = [base 'DOM3_rois/jf26707/jf26707_010510.mat'];
	dsp{2}.scimFilePath=[base 'DOM3_imaging/jf26707/jf26707_010510/ROI1/fluo_batch_out/'];
	dsp{2}.scimFileWC = 'Image_Registration_5_jf26707_010510*tif';

	dsp{2}.ephusFilePath=[base 'DOM3_ephys/jf26707/AA0105/']; 
	dsp{2}.ephusFileWC='AA0105CelA*'; %
	dsp{2}.ephusDownsample=[]; 

	dsp{2}.whiskerFilePath = [base 'DOM3_whisker/jf26707/'];
	dsp{2}.whiskerFileWC = 'jf26707x010510_5_288_session_B.mat';
	dsp{2}.whiskerBarInReachES=2*[630 1120];
	dsp{2}.whiskerTag={'C3' 'C2' 'C1'};
	dsp{2}.baseFileName=[base 'DOM3_results/jf26707/jf26707x010510_sessSP.mat'];

	%% jf26707 010610
	dsp{3}.behavSoloFilePath=[base '/DOM3_behavior/JF26707/data_@pole_detect_nx2obj_JF26707_100106a.mat'];
	dsp{3}.roiArrayPath = [base 'DOM3_rois/jf26707/jf26707_010610.mat'];
	dsp{3}.scimFilePath=[base 'DOM3_imaging/jf26707/jf26707_010610/ROI1/fluo_batch_out'];
	dsp{3}.scimFileWC = 'Image_Registration_5_jf25607_010510*tif';

	dsp{3}.ephusFilePath=[base 'DOM3_ephys/jf26707/dh0106/'];
	dsp{3}.ephusFileWC='dh0106CelB*';
	dsp{3}.ephusDownsample=[];

	dsp{3}.whiskerFilePath = [base 'DOM3_whisker/jf26707/'];
	dsp{3}.whiskerFileWC = 'jf26707x010610_5_248_session_B.mat';
	dsp{3}.whiskerBarInReachES=2*[630 1120];
	dsp{3}.whiskerTag={'C3','C2','C1'};
	dsp{3}.baseFileName=[base 'DOM3_results/jf26707/jf26707x010610_sessSP.mat'];



	%% jf26707 010810
	dsp{4}.behavSoloFilePath=[base '/DOM3_behavior/JF26707/data_@pole_detect_nx2obj_JF26707_100108a.mat']; 
	dsp{4}.roiArrayPath = [base 'DOM3_rois/jf26707/jf26707_010810.mat'];
	dsp{4}.scimFilePath=[base 'DOM3_imaging/jf26707/jf26707_010810/ROI1/fluo_batch_out/'];
	dsp{4}.scimFileWC = 'Image_Registration_5_jf26707_010810*tif';

	dsp{4}.ephusFilePath=[base 'DOM3_ephys/jf26707/dh0108/CelA']; 
	dsp{4}.ephusFileWC='dh0108CelA*'; 
	dsp{4}.ephusDownsample=[]; 
	dsp{4}.whiskerFilePath = [base 'DOM3_whisker/jf26707/'];
	dsp{4}.whiskerFileWC = 'jf26707x010810_5_208_session_B.mat';
	dsp{4}.whiskerBarInReachES=2*[630 1120];
	dsp{4}.whiskerTag={'C3','C2','C1'};
	dsp{4}.baseFileName=[base 'DOM3_results/jf26707/jf26707x010810_sessSP.mat'];

	%% jf26707 011010
	dsp{5}.behavSoloFilePath=[base '/DOM3_behavior/JF26707/data_@pole_detect_nx2obj_JF26707_100110a.mat']; 
	dsp{5}.roiArrayPath = [base 'DOM3_rois/jf26707/jf26707_011010.mat'];
	dsp{5}.scimFilePath=[base 'DOM3_imaging/jf26707/jf26707_011010/ROI1/fluo_batch_out/'];
	dsp{5}.scimFileWC = 'Image_Registration_5_jf26707_011010*tif';

	dsp{5}.ephusFilePath=[base 'DOM3_ephys/jf26707/dh0110/CelA']; 
	dsp{5}.ephusFileWC='dh0110CelA*'; 
	dsp{5}.ephusDownsample=[]; 
	dsp{5}.whiskerFilePath = [base 'DOM3_whisker/jf26707/'];
	dsp{5}.whiskerFileWC = 'jf26707x011010_5_326_session_B.mat';
	dsp{5}.whiskerBarInReachES=2*[630 1120];
	dsp{5}.whiskerTag={'C3' 'C2' 'C1'};
	dsp{5}.baseFileName=[base 'DOM3_results/jf26707/jf26707x011010_sessSP.mat'];

	%% jf26707 011210
	dsp{6}.behavSoloFilePath=[base '/DOM3_behavior/JF26707/data_@pole_detect_nx2obj_JF26707_100112a.mat']; 
	dsp{6}.roiArrayPath = [base 'DOM3_rois/jf26707/jf26707_011210.mat'];
	dsp{6}.scimFilePath=[base 'DOM3_imaging/jf26707/jf26707_011210/ROI1/fluo_batch_out/'];
	dsp{6}.scimFileWC = 'Image_Registration_5_jf26707_011210*tif';

	dsp{6}.ephusFilePath=[base 'DOM3_ephys/jf26707/dh0112/CelA']; 
	dsp{6}.ephusFileWC='dh0112CelA*'; 
	dsp{6}.ephusDownsample=[]; 
	dsp{6}.whiskerFilePath = [base 'DOM3_whisker/jf26707/'];
	dsp{6}.whiskerFileWC = 'jf26707x011210_20_299_session_B.mat';
	dsp{6}.whiskerBarInReachES=2*[630 1120];
	dsp{6}.whiskerTag={'C3' 'C2' 'C1'};
	dsp{6}.baseFileName=[base 'DOM3_results/jf26707/jf26707x011210_sessSP.mat'];


function dsp = get_jf27332(base)

	%% jf27332_010410
	dsp{1}.behavSoloFilePath=[base '/DOM3_behavior/JF27332/data_@pole_detect_nx2obj_JF27332_100104a']; 
	dsp{1}.roiArrayPath = [base 'DOM3_rois/jf27332/jf27332_010410.mat']; % check if present
	dsp{1}.scimFilePath=[base 'DOM3_imaging/jf27332/jf27332_010410/fluo_batch_out_roi2/rigid/'];
	dsp{1}.scimFileWC = 'Image_Registration_5_jf27332_010410*tif';
	dsp{1}.ephusFilePath=[base 'DOM3_ephys/jf27332/dh0104/CelA/']; 
	dsp{1}.ephusFileWC='dh0104CelA*'; 
	dsp{1}.ephusDownsample=[]; 
	dsp{1}.whiskerFilePath = [base 'DOM3_whisker/jf27332/'];
	dsp{1}.whiskerFileWC = 'jf27332x010410_9_266_session_B.mat';
	%dsp{1}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_mini.mat';
	dsp{1}.whiskerBarInReachES=2*[620 990]; 
	dsp{1}.whiskerTag={'C3', 'C2', 'C1'};
	dsp{1}.baseFileName=[base 'DOM3_results/jf27332/jf27332x010410_sessSP.mat'];
	dsp{1}.userDefinedValidTrialIds=[1:500]; 


	%% jf27332_010510

	dsp{2}.behavSoloFilePath=[base '/DOM3_behavior/JF27332/data_@pole_detect_nx2obj_JF27332_100105a']; 
	dsp{2}.roiArrayPath = [base 'DOM3_rois/jf27332/jf27332_010510.mat']; % check if present
	dsp{2}.scimFilePath=[base 'DOM3_imaging/jf27332/jf27332_010510/fluo_batch_out_roi2/rigid/'];
	dsp{2}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_4_jf27332_01051*tif';
	dsp{2}.ephusFilePath=[base 'DOM3_ephys/jf27332/dh0105/CelA/']; 
	dsp{2}.ephusFileWC='dh0105CelA*'; 
	dsp{2}.ephusDownsample=[]; 
	dsp{2}.whiskerFilePath = [base 'DOM3_whisker/jf27332/'];
	dsp{2}.whiskerFileWC = 'jf27332x010510_14_261_session_B.mat';
	%dsp{2}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_mini.mat';
	dsp{2}.whiskerBarInReachES=2*[620 990]; %check
	dsp{2}.whiskerTag={'C3', 'C2', 'C1'};
	dsp{2}.baseFileName=[base 'DOM3_results/jf27332/jf27332x010510_sessSP.mat'];
	dsp{2}.userDefinedValidTrialIds=[1:500]; 




	%% jf27332_010610

	dsp{3}.behavSoloFilePath=[base '/DOM3_behavior/JF27332/data_@pole_detect_nx2obj_JF27332_100106a']; 
	dsp{3}.roiArrayPath = [base 'DOM3_rois/jf27332/jf27332_010610.mat']; % check if present
	dsp{3}.scimFilePath=[base 'DOM3_imaging/jf27332/jf27332_010610/fluo_batch_out_roi2/rigid/'];
	dsp{3}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_4_jf25607_010510*tif';
	dsp{3}.ephusFilePath=[base 'DOM3_ephys/jf27332/dh0106/']; 
	dsp{3}.ephusFileWC='dh0106CelA*'; 
	dsp{3}.ephusDownsample=[]; 
	dsp{3}.whiskerFilePath = [base 'DOM3_whisker/jf27332/'];
	dsp{3}.whiskerFileWC = 'jf27332x010610_4_272_session_B.mat';
	%dsp{3}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_mini.mat';
	dsp{3}.whiskerBarInReachES=2*[620 990]; %check
	dsp{3}.whiskerTag={'C3', 'C2', 'C1'};
	dsp{3}.baseFileName=[base 'DOM3_results/jf27332/jf27332x010610_sessSP.mat'];
	dsp{3}.userDefinedValidTrialIds=[1:500]; 

	%% jf27332_010810

	dsp{4}.behavSoloFilePath=[base '/DOM3_behavior/JF27332/data_@pole_detect_nx2obj_JF27332_100108a']; 
	dsp{4}.roiArrayPath = [base 'DOM3_rois/jf27332/jf27332_010810.mat']; % check if present
	dsp{4}.scimFilePath=[base 'DOM3_imaging/jf27332/jf27332_010810/fluo_batch_out_roi2/rigid/'];
	dsp{4}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_4_jf27332*tif';
	dsp{4}.ephusFilePath=[base 'DOM3_ephys/jf27332/dh0108/CelA/']; 
	dsp{4}.ephusFileWC='dh0108CelA*'; 
	dsp{4}.ephusDownsample=[]; 
	dsp{4}.whiskerFilePath = [base 'DOM3_whisker/jf27332/'];
	dsp{4}.whiskerFileWC = 'jf27332x010810_4_300_session_B.mat';
	%dsp{4}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_mini.mat';
	dsp{4}.whiskerBarInReachES=2*[620 990]; %check
	dsp{4}.whiskerTag={'C3', 'C2', 'C1'};
	dsp{4}.baseFileName=[base 'DOM3_results/jf27332/jf27332x010810_sessSP.mat'];
	dsp{4}.userDefinedValidTrialIds=[1:500]; 


	%% jf27332_011010

	dsp{5}.behavSoloFilePath=[base '/DOM3_behavior/JF27332/data_@pole_detect_nx2obj_JF27332_100110a']; 
	dsp{5}.roiArrayPath = [base 'DOM3_rois/jf27332/jf27332_011010.mat']; % check if present
	dsp{5}.scimFilePath=[base 'DOM3_imaging/jf27332/jf27332_011010/fluo_batch_out_roi2/rigid/'];
	dsp{5}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_4_jf27332_011010*tif';
	dsp{5}.ephusFilePath=[base 'DOM3_ephys/jf27332/dh0110/CelA/']; 
	dsp{5}.ephusFileWC='dh0110CelA*'; 
	dsp{5}.ephusDownsample=[]; 
	dsp{5}.whiskerFilePath = [base 'DOM3_whisker/jf27332/'];
	dsp{5}.whiskerFileWC = 'jf27332x011010_4_259_session_B.mat';
	%dsp{5}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_mini.mat';
	dsp{5}.whiskerBarInReachES=2*[620 990]; %check
	dsp{5}.whiskerTag={'C3', 'C2', 'C1'};
	dsp{5}.baseFileName=[base 'DOM3_results/jf27332/jf27332x011010_sessSP.mat'];
	dsp{5}.userDefinedValidTrialIds=[1:500]; 


	% %% jf27332_011110
	% 
	% dsp{6}.behavSoloFilePath=[base '/DOM3_behavior/JF27332/data_@pole_detect_nx2obj_JF27332_100111a']; 
	% dsp{6}.roiArrayPath = [base 'DOM3_rois/jf27332/jf27332_011110.mat']; % check if present
	% dsp{6}.scimFilePath=[base 'DOM3_imaging/jf27332/jf27332_011110/fluo_batch_out_roi2/rigid/'];
	% dsp{6}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_4_jf27332_011110*tif';
	% dsp{6}.ephusFilePath=[base 'DOM3_ephys/jf27332/dh0111/CelA']; 
	% dsp{6}.ephusFileWC='dh0111CelA*'; 
	% dsp{6}.ephusDownsample=[]; 
	% dsp{6}.whiskerFilePath = [base 'DOM3_whisker/jf27332/'];
	% dsp{6}.whiskerFileWC = 'jf27332x011010jf27332_011010_4_259_mini.mat';
	% %dsp{6}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_mini.mat';
	% dsp{6}.whiskerBarInReachES=2*[620 990]; %check
	% dsp{6}.whiskerTag={'C1'};% {'C1', 'C2'};
	% dsp{6}.baseFileName=[base 'DOM3_results/jf27332/jf27332x011010_sessSP.mat'];
	% dsp{6}.userDefinedValidTrialIds=[1:500]; 


	%% jf27332_011210

	dsp{6}.behavSoloFilePath=[base '/DOM3_behavior/JF27332/data_@pole_detect_nx2obj_JF27332_100112a']; 
	dsp{6}.roiArrayPath = [base 'DOM3_rois/jf27332/jf27332_011210.mat']; % check if present
	dsp{6}.scimFilePath=[base 'DOM3_imaging/jf27332/jf27332_011210/fluo_batch_out_roi2/rigid/'];
	dsp{6}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_4_jf27332_011210*tif';
	dsp{6}.ephusFilePath=[base 'DOM3_ephys/jf27332/dh0112/CelA/']; 
	dsp{6}.ephusFileWC='dh0112CelA*'; 
	dsp{6}.ephusDownsample=[]; 
	dsp{6}.whiskerFilePath = [base 'DOM3_whisker/jf27332/'];
	dsp{6}.whiskerFileWC = 'jf27332x011210_5_200_session_B.mat';
	%dsp{6}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_mini.mat';
	dsp{6}.whiskerBarInReachES=2*[620 990]; %check
	dsp{6}.whiskerTag={'C2', 'C1'};
	dsp{6}.baseFileName=[base 'DOM3_results/jf27332/jf27332x011210_sessSP.mat'];
	dsp{6}.userDefinedValidTrialIds=[1:500]; 

	%% jf27332_011310

	dsp{7}.behavSoloFilePath=[base '/DOM3_behavior/JF27332/data_@pole_detect_nx2obj_JF27332_100113a']; 
	dsp{7}.roiArrayPath = [base 'DOM3_rois/jf27332/jf27332_011310.mat']; % check if present
	dsp{7}.scimFilePath=[base 'DOM3_imaging/jf27332/jf27332_011310/fluo_batch_out_roi2/rigid/'];
	dsp{7}.scimFileWC = 'Image_Registration_2_Post-Processing_for_ImReg_4_jf27332_011310*tif';
	dsp{7}.ephusFilePath=[base 'DOM3_ephys/jf27332/dh0113/']; 
	dsp{7}.ephusFileWC='dh0113CelA*'; 
	dsp{7}.ephusDownsample=[]; 
	dsp{7}.whiskerFilePath = [base 'DOM3_whisker/jf27332/'];
	dsp{7}.whiskerFileWC = 'jf27332x011310_4_202_session_B.mat';
	%dsp{7}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_mini.mat';
	dsp{7}.whiskerBarInReachES=2*[620 990]; %check
	dsp{7}.whiskerTag={'C2', 'C1'};
	dsp{7}.baseFileName=[base 'DOM3_results/jf27332/jf27332x011310_sessSP.mat'];
	dsp{7}.userDefinedValidTrialIds=[1:500]; 



function dsp = get_jf100601(base)
	dsp{1}.behavSoloFilePath=[base '/DOM3_behavior/JF100601/data_@pole_detect_nx2obj_JF100601_100629a.mat'];
	dsp{1}.roiArrayPath = [base 'DOM3_rois/jf100601/jf100601_062910.mat'];
	dsp{1}.scimFilePath=[base 'DOM3_imaging/jf100601/jf100601_062910/fluo_batch_out'];
	dsp{1}.scimFileWC = 'Image_Registration_5_jf100601_062910*tif';

	dsp{1}.ephusFilePath=[base 'DOM3_ephys/jf100601/dh0629/'];
	dsp{1}.ephusFileWC='dh0629zeon*';
	dsp{1}.ephusDownsample=[];


	dsp{1}.whiskerFilePath = [base 'DOM3_whisker/jf100601/'];
	dsp{1}.whiskerFileWC = '2010_06_29-1_4_384_session_B.mat';
	%dsp{1}.whiskerFileWC = '2010_06_29-1jf100601_062910_8390_9296_mini.mat';
	dsp{1}.whiskerBarInReachES=2*[720 1090];
	dsp{1}.whiskerTag={'C3' ,'C2', 'C1'};
	dsp{1}.baseFileName=[base 'DOM3_results/jf100601/jf100601x062910_sessSP.mat'];


	%% jf100601/2010_06_30-1

	dsp{2}.behavSoloFilePath=[base '/DOM3_behavior/JF100601/data_@pole_detect_nx2obj_JF100601_100630a.mat'];
	dsp{2}.roiArrayPath = [base 'DOM3_rois/jf100601/jf100601_063010.mat'];
	dsp{2}.scimFilePath=[base 'DOM3_imaging/jf100601/jf100601_063010/fluo_batch_out'];
	dsp{2}.scimFileWC = 'Image_Registration_5_jf100601_063010B*tif';

	dsp{2}.ephusFilePath=[base '/DOM3_ephys/jf100601/dh0630'];
	dsp{2}.ephusFileWC='dh0630zeoB*';
	dsp{2}.ephusDownsample=[];


	dsp{2}.whiskerFilePath = [base 'DOM3_whisker/jf100601/'];
	dsp{2}.whiskerFileWC = '2010_06_30-1_4_226_session_B.mat';
	%dsp{2}.whiskerFileWC = '2010_06_30-1jf100601_063010_4265_5015_mini.mat';
	dsp{2}.whiskerBarInReachES=2*[720 1120];
	dsp{2}.whiskerTag={'C3' 'C2' 'C1'};
	dsp{2}.baseFileName=[base 'DOM3_results/jf100601/jf100601x063010_sessSP.mat'];


	%% jf100601/2010_07_01-1

	dsp{3}.behavSoloFilePath=[base '/DOM3_behavior/JF100601/data_@pole_detect_nx2obj_JF100601_100701a.mat'];
	dsp{3}.roiArrayPath = [base 'DOM3_rois/jf100601/jf100601_070110.mat'];
	dsp{3}.scimFilePath=[base 'DOM3_imaging/jf100601/jf100601_070110/fluo_batch_out'];
	dsp{3}.scimFileWC = 'Image_Registration_5_jf100601_070110*tif';

	dsp{3}.ephusFilePath=[base '/DOM3_ephys/jf100601/dh0701'];
	dsp{3}.ephusFileWC='dh0701zeon*';
	dsp{3}.ephusDownsample=[];


	dsp{3}.whiskerFilePath = [base 'DOM3_whisker/jf100601/'];
	dsp{3}.whiskerFileWC = '2010_07_01-1_4_420_session_B.mat';
	%dsp{3}.whiskerFileWC = '2010_07_01-1jf100601_070110_5046_8953_mini.mat';
	dsp{3}.whiskerBarInReachES=2*[700 1120];
	dsp{3}.whiskerTag={'C3', 'C2', 'C1'};
	dsp{3}.baseFileName=[base 'DOM3_results/jf100601/jf100601x070110_sessSP.mat'];
dsp{3}.userDefinedValidTrialIds=[20:65 80:300];

	%% jf100601/2010_07_02-1

	dsp{4}.behavSoloFilePath=[base '/DOM3_behavior/JF100601/data_@pole_detect_nx2obj_JF100601_100702a.mat'];
	dsp{4}.roiArrayPath = [base 'DOM3_rois/jf100601/jf100601_070210.mat'];
	dsp{4}.scimFilePath=[base 'DOM3_imaging/jf100601/jf100601_070210/fluo_batch_out'];
	dsp{4}.scimFileWC = 'Image_Registration_5_jf100601_070210*tif';

	dsp{4}.ephusFilePath=[base '/DOM3_ephys/jf100601/dh0701'];
	dsp{4}.ephusFileWC='dh0701zeon*';
	dsp{4}.ephusDownsample=[];


	dsp{4}.whiskerFilePath = [base 'DOM3_whisker/jf100601/'];
	dsp{4}.whiskerFileWC = '2010_07_02-1_4_364_session_B.mat';
	%dsp{4}.whiskerFileWC = '2010_07_02-1jf100601_070210_7218_6250_mini.mat';
	dsp{4}.whiskerBarInReachES=2*[700 1120];
	dsp{4}.whiskerTag={'C1'};% {'C1', 'C2'};
	dsp{4}.baseFileName=[base 'DOM3_results/jf100601/jf100601x070210_sessSP.mat'];

	%% jf100601/2010_07_03-1

	dsp{5}.behavSoloFilePath=[base '/DOM3_behavior/JF100601/data_@pole_detect_nx2obj_JF100601_100703a.mat'];
	dsp{5}.roiArrayPath = [base 'DOM3_rois/jf100601/jf100601_070310.mat'];
	dsp{5}.scimFilePath=[base 'DOM3_imaging/jf100601/jf100601_070310/fluo_batch_out'];
	dsp{5}.scimFileWC = 'Image_Registration_5_jf100601_070310*tif';

	dsp{5}.ephusFilePath=[base '/DOM3_ephys/jf100601/dh0703'];
	dsp{5}.ephusFileWC='dh0703zeon*';
	dsp{5}.ephusDownsample=[];


	dsp{5}.whiskerFilePath = [base 'DOM3_whisker/jf100601/'];
	dsp{5}.whiskerFileWC = '2010_07_03-1_5_228_session_B.mat'; % broken
	%dsp{5}.whiskerFileWC = '2010_07_02-1jf100601_070310_7218_6250_mini.mat'; % broken
	dsp{5}.whiskerBarInReachES=2*[700 1120];
	dsp{5}.whiskerTag={'C1'};% {'C1', 'C2'};
	dsp{5}.baseFileName=[base 'DOM3_results/jf100601/jf100601x070310_sessSP.mat'];

	%% jf100601/2010_07_04-1

	dsp{6}.behavSoloFilePath=[base '/DOM3_behavior/JF100601/data_@pole_detect_nx2obj_JF100601_100704a.mat'];
	dsp{6}.roiArrayPath = [base 'DOM3_rois/jf100601/jf100601_070410.mat'];
	dsp{6}.scimFilePath=[base 'DOM3_imaging/jf100601/jf100601_070410/fluo_batch_out'];
	dsp{6}.scimFileWC = 'Image_Registration_5_jf100601_070410*tif';

	dsp{6}.ephusFilePath=[base '/DOM3_ephys/jf100601/dh0704'];
	dsp{6}.ephusFileWC='dh0704zeon*';
	dsp{6}.ephusDownsample=[];


	dsp{6}.whiskerFilePath = [base 'DOM3_whisker/jf100601/'];
	%dsp{6}.whiskerFileWC = '2010_07_02-1jf100601_070410_7218_6250_mini.mat'; % broken
	dsp{6}.whiskerFileWC = '2010_07_04-1_4_166_session_B.mat'; % broken
	dsp{6}.whiskerBarInReachES=2*[700 1120];
	dsp{6}.whiskerTag={'C1'};% {'C1', 'C2'};
	dsp{6}.baseFileName=[base 'DOM3_results/jf100601/jf100601x070410_sessSP.mat'];


	%% jf100601/2010_07_05-1

	dsp{7}.behavSoloFilePath=[base '/DOM3_behavior/JF100601/data_@pole_detect_nx2obj_JF100601_100705a.mat'];
	dsp{7}.roiArrayPath = [base 'DOM3_rois/jf100601/jf100601_070510.mat'];
	dsp{7}.scimFilePath=[base 'DOM3_imaging/jf100601/jf100601_070510/fluo_batch_out'];
	dsp{7}.scimFileWC = 'Image_Registration_5_jf100601_070510*tif';

	dsp{7}.ephusFilePath=[base '/DOM3_ephys/jf100601/dh0705'];
	dsp{7}.ephusFileWC='dh0705zeon*';
	dsp{7}.ephusDownsample=[];


	dsp{7}.whiskerFilePath = [base 'DOM3_whisker/jf100601/'];
	dsp{7}.whiskerFileWC = '2010_07_05-1_4_187_session_B.mat'; % broken
	%dsp{7}.whiskerFileWC = '2010_07_02-1jf100601_070510_7218_6250_mini.mat'; % broken
	dsp{7}.whiskerBarInReachES=2*[700 1120];
	dsp{7}.whiskerTag={'C1'};% {'C1', 'C2'};
	dsp{7}.baseFileName=[base 'DOM3_results/jf100601/jf100601x070510_sessSP.mat'];




