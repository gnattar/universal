%
% plays with layer 5 data ...
%

rootDir = '/Volumes/an160508b/an161323/2012_02_18/';
roiDir = '/Volumes/an160508b/an161323/rois/';


if (0)
	rA = roi.roiArray;
	rA.masterImage = [rootDir filesep 'scanimage' filesep 'fov_' fovId '/fluo_batch_out/session_mean.tif'];
	rA.startGui();
end

% generator
if (0)
  fovId = '01008';
  load([roiDir '/fov_' fovId '.mat']);
  rA = obj;
	fpath = [rootDir filesep 'scanimage' filesep 'fov_' fovId '/fluo_batch_out'];
  caTSA = session.calciumTimeSeriesArray.generateCalciumTimeSeriesArray(rA, fpath ,'*main*tif');
  caTSA.runBestPracticesDffAndEvdet();
	caTSA.time = caTSA.time - min(caTSA.time);
	mt = caTSA.trialIndices(1);
  save([roiDir '/fov_' fovId '_caTSA.mat'], 'caTSA');
	baseCaTSA  = caTSA;
	
	fovIds = {'01007','01006','01005', '01004', '01003', '01002'};

	for f=1:length(fovIds)
	  fovId = fovIds{f};
		clear caTSA, rA;
		load([roiDir '/fov_' fovId '.mat']);
		rA = obj;
		fpath = [rootDir filesep 'scanimage' filesep 'fov_' fovId '/fluo_batch_out'];
		caTSA = session.calciumTimeSeriesArray.generateCalciumTimeSeriesArray(rA, fpath ,'*main*tif');
		caTSA.runBestPracticesDffAndEvdet();
		mti = min(find(caTSA.trialIndices == mt));
		caTSA.time = caTSA.time -caTSA.time(mti);
		save([roiDir '/fov_' fovId '_caTSA.mat'], 'caTSA');
	end
end

% 2,1012, 
if (1)
  cd ('/media/misc_data_1/Layer_5_Imaging/an161323/rois');
  load grp_caTSA.mat;
  ids = [2 1012 2001 3001 4001 5001 6001];
	colors = jet(7);
	offs = 0:3:21;
	figure;
	hold on;
	for i=1:length(ids);
  	caTSA.dffTimeSeriesArray.getTimeSeriesById(ids(i)).plot(colors(i,:), 1, offs(i));
		v1 = caTSA.dffTimeSeriesArray.getTimeSeriesById(ids(i)).value';
		v2 =caTSA.dffTimeSeriesArray.getTimeSeriesById(ids(1)).value';
		i1 = find(~isnan(v1));
		i2 = find(~isnan(v2));
		ii = intersect(i1,i2);
		disp([num2str(i) ' ' num2str(corr(v1(ii),v2(ii)))]);
	end;
  xlabel('time (ms)');
  ylabel('df/f');
  set(gca,'TickDir','out');

	ax = figure_tight(length(ids));
	for i=1:length(ids)
		fi = caTSA.roiFOVidx(find(caTSA.ids == ids(i)));
		im = caTSA.roiArray{fi}.masterImage;
		ri = find(caTSA.roiArray{fi}.roiIds == ids(i));
		ridx = caTSA.roiArray{fi}.rois{ri}.indices;
		cim = zeros(size(im,1), size(im,2), 3);
		im = im/1000;
		cim(:,:,1) = im;
		cim(:,:,2) = im;
		cim(:,:,3) = im;
		cim(ridx) = colors(i,1);
		cim(ridx + (prod(size(im)))) = colors(i,2);
		cim(ridx + 2*(prod(size(im)))) = colors(i,3);
		imshow(cim,'Parent', ax{i}, 'Border','tight');
	end
end

% compound generator
if (0)
	fovIds = {'01008', '01007','01006','01005', '01004', '01003', '01002'};
  clear caTSA; 
	clear rA; 
	clear fpath;

	for f=1:length(fovIds)
	  fovId = fovIds{f};
		load([roiDir '/fov_grp_' fovId '.mat']);
		rTmp = obj;
		rA{f} = rTmp;
		fpath{f} = [rootDir filesep 'scanimage' filesep 'fov_' fovId '/fluo_batch_out'];
	end

	caTSA = session.calciumTimeSeriesArray.generateCalciumTimeSeriesArray(rA, fpath ,'*main*tif');
	caTSA.runBestPracticesDffAndEvdet();
	caTSA.time = caTSA.time - min(caTSA.time);
	save([roiDir '/grp_caTSA.mat'], 'caTSA');
end 

% roiId fixer . . .
if (0)
	fovIds = {'01008', '01007','01006','01005', '01004', '01003', '01002'};
  fovBase = 0:1000:6000;
  
	for f=1:length(fovIds)
	  fovId = fovIds{f};
		clear caTSA, rA;
		load([roiDir '/fov_' fovId '.mat']);
		rA = obj;
		if (fovBase(f)> 0)
			for r=1:length(obj.roiIds)
				rA.changeRoiId(obj.roiIds(r),obj.roiIds(r)+fovBase(f));
			end
		end
		rA.roiIdRange = [fovBase(f) fovBase(f)+999];
		rA.saveToFile([roiDir '/fov_grp_' fovId '.mat']);
	end
end
% s = session.session;


if (0)
  ax = figure_tight(9, [950 950]);
  cd([rootDir filesep 'scanimage']);
  im1 = load_image('fov_01001/fluo_batch_out/*main*_04*.tif');
  im2 = load_image('fov_01002/fluo_batch_out/*main*_04*.tif');
  im3 = load_image('fov_01003/fluo_batch_out/*main*_04*.tif');
  im4 = load_image('fov_01004/fluo_batch_out/*main*_04*.tif');
  im5 = load_image('fov_01005/fluo_batch_out/*main*_04*.tif');
  im6 = load_image('fov_01006/fluo_batch_out/*main*_04*.tif');
  im7 = load_image('fov_01007/fluo_batch_out/*main*_04*.tif');
  im8 = load_image('fov_01008/fluo_batch_out/*main*_04*.tif');
end;

if (0) 
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
	s.generateBehavioralDataStructures([rootDir '/behav/autosave_an161323_20120218T162116.mat'], dsp.behavSoloParams, dsp.trialBehavParams);
	s.validTrialIds = s.trialIds;

	s.dataSourceParams.ephusChanIdent = {'lickport1','lickport2','licklaser','pole_position'};

	s.generateEphusTimeSeriesArray([rootDir filesep 'ephus'], '*xsg', 100);
end
