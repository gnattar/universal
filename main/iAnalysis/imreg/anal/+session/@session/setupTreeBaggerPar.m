%
% Generates files directing cluster execution of Bagging Tree analysis.
%
% Wrapper for parallelized treebagger_ based execution.  This will allow you
%  to feed a set of data that consists of cell responses and stimuli, then 
%  designate exactly how bagging tree (see MATLAB's TreeBagger) should be used
%  to determine how stimuli encode cell responses as well as how cell responses
%  decode stimuli.
%
% After this is run, you will need to use par_execute on the specified par 
%  directory (rootParDir and its subdirectories).  This in turn will invoke
%  treebagger_par_execute. 
%
% To use this properly, 
%
%   1) put your session class files, including all associated files, onto the
%      cluster file system. 
%   2) (some kind of matgen script)
%   3) (tree_pargen)
%   4) (execution of step 3 output)
%
% USAGE:
%
%   obj.setupTreeBaggerPar(rootParDir, treeBaggerParams, cellResponseTSA, stimulusFeatureTSA)
%
% PARAMETERS:
%
%   rootParDir: root directory for par files (where they are placed)
%   cellResponseTSA: what is considered a response? usually 
%                    caTSA.caPeakTimeSeriesArray
%   stimulusFeatureTSA: what is considered stimulus response? the data in this
%     timeSeriesArray must be matched in time to cellResponseTSA.  Run 
%     timeSeries.reSample on individual timeSeries objects if not -- generally,
%     derivedDataTSA is used.
%
%   treeBaggerParams: a structure with a bunch of fields dictating execution:
%
%     runModes: Vector of 1/0 - 1 to run, 0 to not run, withe runModes(x) being:
%             (1): encoder, all features x single neurons
%             (2): encoder, single feature x single neurons
%             (3): encoder, feature groups (categories) x single neurons
%             (4): decoder, single feature x all neurons
%             (5): decoder, single feature x single neuron
%             (6): double decoder, single feature x all neurons
%             (7): double decoder, single feature x single neuron
%       Default is [1 1 1 1 1 0 0].  Double decoder should be done separately from
%       the rest.
%
%     typeVec: default is to treat all variable as continuous (FEATURES).  
%       Pass this and set values to 1 if you want them to be treated as categories.
%   
%     typeVec2Step: same as typeVec but for 2 step double-decoder ; one value
%      per featureIdList2Step (below).
%
%     temporalShifts: what temporal shifts to use?  The feature data will be 
%       shifted by this relative the neuronal data, so for motor variables 
%       you should use (-) values and for sensory variables, (+) values.  
%       Default is 0:4 -- sensory.
%       
%     outputFileTemplate: Can contain the tags <%mode%> <%featureName%> and 
%       <%roiId%>.  The tree data will be output to the file with that particular
%       name.  If you omit a field, it will dump multiple things to a single
%       file.  For instance, <%mode%>_<%featureName%>_<%roiId%> would output
%       encoder_All_00500.mat for all features x all neurons mode for cell 500.
%
%     excludeStimulusFeatureWC: stimulus features with any of these strings in 
%       the name are EXCLUDED from stimulusFeatureTSA.
%
%     roiIdList: Restrict to these roiIDs; default is cellResponseTSA.ids.  Note 
%            that you will need this to recover IDs from output (see NOTES).
%    
%     featureIdList: Restrict to features with these ID #s.  Default is to use
%       all features (stimulusFeatureTSA.ids).
%
%     featureIdList2Step: If you are doing double decoder, pass this, whic his
%       a cell array of 2 vectors.  The first vector is predicted directly by
%       neurons.  Then, the prediction is used to predict the second vector.
%
%     zScoreDff: If set to 1, dff will be z-score normalized prior to running. 
%       This is good for certain cross-neuron comparisons.  Default 0.
%
%     filePerCell: If set to 1, it will output a single file PER cell and it
%       will make a directory per feature.  So far only for mode 5 (decoder).
%
%  NOTES:
%
%  - session.validTrialIds is respected.  If you want to restrict to a specific
%    trial range, just assign validTrialIds accordingly before calling this.
%
%  EXAMPLE:
%  
%    Setup bagger on loaded session, s, in /data/an160508/partest for first 10
%      cells, regardless of IDs, and minimal features:
%    
%       treeBaggerParams.roiIdList = s.caTSA.ids(1:10);
%       treeBaggerParams.featureIdList = [10000 10010 20001 30001 40000];
%       s.setupTreeBaggerPar ('/data/an160508/partest',treeBaggerParams);
%
% (C) SP 2012 Apr
%
function setupTreeBaggerPar(obj, rootParDir,  treeBaggerParams,  cellResponseTSA, stimulusFeatureTSA)

	%% --- input process
	if (nargin < 2)
	  help session.session.setupTreeBaggerPar;
	  disp('setupTreeBaggerPar::must at least specify rootParDir');
	  return;
	end
	if (nargin < 5 || length(stimulusFeatureTSA)  == 0) 
		stimulusFeatureTSA = obj.derivedDataTSA;
	end
	if (nargin < 4 || length(cellResponseTSA) == 0)
		cellResponseTSA = obj.caTSA.caPeakTimeSeriesArray;
  end

	% any inf values should be set to nan
	infidx = find(isinf(cellResponseTSA.valueMatrix));
	if (length(infidx) > 0)
	  disp(['setupTreeBaggerPar::detected ' num2str(length(infidx)) ' inf values in cellResponseTSA; nan-ing.']);
		cellResponseTSA.valueMatrix(infidx) = nan;
	end
	
	infidx = find(isinf(stimulusFeatureTSA.valueMatrix));
	if (length(infidx) > 0)
	  disp(['setupTreeBaggerPar::detected ' num2str(length(infidx)) ' inf values in stimulusFeatureTSA; nan-ing.']);
		stimulusFeatureTSA.valueMatrix(infidx) = nan;
	end

	if (length(obj.validTrialIds) == 0)
	  disp('setupTreeBaggerPar::validTrialIds is empty; skipping this dataset.');
		return;
  end
  disp('setupTreeBaggerPar::validTrialIds is NOT RESPECTEd.  WARNING!!!');
  
  if (rootParDir(end) == filesep ) ; rootParDir = rootParDir(1:end-1); end

	% -- treeBaggerParams ...

	% defaults
	temporalShifts = 0:4; % how many frames to shift sensory data by ?
	excludeStimulusFeaturesWC = {'NO EXCLUSION'}; % stimulus variables with this in their idStr are excluded from analysis
	runModes = [1 1 1 1 1 0 0]; % encoder all feat all nrns ; encoder sing feat ; encoder groups ; decoder pop; decoder sing neurons ; double decoder pop ; double decoder sing
	outputFileTemplate = '<%mode%>_feat_<%featureName%>_roi_<%roiId%>_trees.mat'; % no additional thing for output name
	roiIdList = cellResponseTSA.ids;
	featureIdList = stimulusFeatureTSA.ids;
	featureIdList2Step = [];
	zScoreDff = 0;
	typeVec = [];
	typeVec2Step = [];
	filePerCell = 0;

  % user passed
	if (nargin >= 3 && isstruct(treeBaggerParams))
    eval(assign_vars_from_struct(treeBaggerParams, 'treeBaggerParams'));
% 	  if (isfield(treeBaggerParams, 'temporalShifts')) ; temporalShifts = treeBaggerParams.temporalShifts;  end
% 	  if (isfield(treeBaggerParams, 'excludeStimulusFeaturesWC')) ; excludeStimulusFeaturesWC = treeBaggerParams.excludeStimulusFeaturesWC;  end
% 	  if (isfield(treeBaggerParams, 'runModes')) ; runModes = treeBaggerParams.runModes;  end
% 	  if (isfield(treeBaggerParams, 'outputFileTemplate')) ; outputFileTemplate = treeBaggerParams.outputFileTemplate;  end
% 	  if (isfield(treeBaggerParams, 'roiIdList')) ; roiIdList = treeBaggerParams.roiIdList;  end
% 	  if (isfield(treeBaggerParams, 'featureIdList')) ; featureIdList = treeBaggerParams.featureIdList;  end
% 	  if (isfield(treeBaggerParams, 'featureIdList2Step')) ; featureIdList2Step = treeBaggerParams.featureIdList2Step;  end
% 	  if (isfield(treeBaggerParams, 'zScoreDff')) ; zScoreDff = treeBaggerParams.zScoreDff;  end
% 	  if (isfield(treeBaggerParams, 'typeVec')) ; typeVec = treeBaggerParams.typeVec;  end
% 	  if (isfield(treeBaggerParams, 'typeVec2Step')) ; typeVec2Step = treeBaggerParams.typeVec2Step;  end
	end

	% assign everything so it can be stored
	treeBaggerParams.roiIdList = roiIdList;
	treeBaggerParams.featureIdList = featureIdList;
	treeBaggerParams.featureIdList2Step = featureIdList2Step;
	treeBaggerParams.zScoreDff = zScoreDff;
	treeBaggerParams.temporalShifts = temporalShifts;
	treeBaggerParams.excludeStimulusFeaturesWC = excludeStimulusFeaturesWC;
	treeBaggerParams.runModes = runModes;
	treeBaggerParams.outputFileTemplate = outputFileTemplate;
	treeBaggerParams.typeVec = typeVec;
	treeBaggerParams.typeVec2Step = typeVec2Step;
 
  % -- additional variables

	% directories
  outputFilesDir = [rootParDir filesep 'output_files'];
  parfilesDir = [rootParDir filesep 'parfiles'];

	% the data matrices
  roiIdList = sort(roiIdList); % so that find(ismemmber call works
	featureIdList = sort(featureIdList); % for find(ismember

	% remove missing features
	presentFeats = find(ismember(featureIdList, stimulusFeatureTSA.ids));
	excludedFeats = setdiff(1:length(featureIdList), presentFeats);
	for i=1:length(excludedFeats)
	  disp(['setupTreeBaggerPar::removing missing feature ' num2str(featureIdList(excludedFeats(i)))]);
	end
	featureIdList = featureIdList(presentFeats);


  % more matrix construction
	featIdx = find(ismember(stimulusFeatureTSA.ids, featureIdList));
	stimulusFeatures = stimulusFeatureTSA.valueMatrix(featIdx,:);
	featureNames = stimulusFeatureTSA.idStrs(featIdx);

	if (iscell(featureIdList2Step))
		featureIdList2Step{1} = sort(featureIdList2Step{1}); % for find(ismember
		featureIdList2Step{2} = sort(featureIdList2Step{2}); % for find(ismember
		featIdx2Step{1} = find(ismember(stimulusFeatureTSA.ids, featureIdList2Step{1}));
		featIdx2Step{2} = find(ismember(stimulusFeatureTSA.ids, featureIdList2Step{2}));
		stimulusFeatures2Step{1} = stimulusFeatureTSA.valueMatrix(featIdx2Step{1},:);
		stimulusFeatures2Step{2} = stimulusFeatureTSA.valueMatrix(featIdx2Step{2},:);
		featureNames2Step{1} = stimulusFeatureTSA.idStrs(featIdx2Step{1});
		featureNames2Step{2} = stimulusFeatureTSA.idStrs(featIdx2Step{2});
	end

	cellIdx = find(ismember(cellResponseTSA.ids, roiIdList));
	cellResponses = cellResponseTSA.valueMatrix(cellIdx,:);

	% strip whitespace from feature names
	for f=1:length(featureNames)
	  featureNames{f} = strrep(featureNames{f},' ', '_');
	end
	if (iscell(featureIdList2Step))
		for f=1:length(featureNames2Step{1})
			featureNames2Step{1}{f} = strrep(featureNames2Step{1}{f},' ', '_');
		end
		for f=1:length(featureNames2Step{2})
			featureNames2Step{2}{f} = strrep(featureNames2Step{2}{f},' ', '_');
		end
	end

  %% ---------------------------------------------------------------------------
	%% --- Setup 

  %% --- Variable prep

	% get some tags
	animalName = obj.mouseId;
	sessionIdStr = strrep(strrep(strrep(obj.dateStr,'-','_'),' ', '_'), ':', '.');

  % type vector (assign default if not passed)
  % 0: regression ; 1: classification (binary) ; for now all regression
	if (length(typeVec) == 0) ; typeVec = 0*(1:length(featureNames)); end
	if (length(typeVec2Step) == 0 && iscell(featureIdList2Step))
	  typeVec2Step{1} = 0*(1:length(featureIdList2Step{1}));
	  typeVec2Step{2} = 0*(1:length(featureIdList2Step{2}));
	end
  
	%% --- Create directories
  if (~ exist(rootParDir,'dir'))
	  disp(['setupTreeBaggerPar::' rootParDir ' does not exist; creating all with subordinates.']);
		[baseDir newDir] = fileparts(rootParDir);
		mkdir (baseDir, newDir);
  end
  if (~ exist(outputFilesDir,'dir'))
		[baseDir newDir] = fileparts(outputFilesDir);
		mkdir (rootParDir, newDir);
  end
  if (~ exist(parfilesDir,'dir'))
		[baseDir newDir] = fileparts(parfilesDir);
		mkdir (rootParDir, newDir);
  end

  if (~ exist(outputFilesDir,'dir'))
	  disp(['setupTreeBaggerPar::requires output target ' rootParDir filesep 'output_files directory ; create it and relaunch.']);
		return;
	end
  if (~ exist(parfilesDir,'dir'))
	  disp(['setupTreeBaggerPar::requires parfile ' rootParDir filesep 'parfiles directory ; create it and relaunch.']);
		return;
	end


	%% --- Combo-groups - groups that basically constitute variables with same basic meaning 
	useGroup = [1 1 1 1 1];
	groupName = {'Contact', 'Whisking', 'Licking' ,'Reward', 'Pole_Sound'};
	groupFeatIdx = cell(1,length(groupName));

	for f=1:length(featureNames)
	  % Contact variables
		if (length(strfind(featureNames{f}, 'kappa')) > 0); groupFeatIdx{1} = union(groupFeatIdx{1}, f) ; end
		if (length(strfind(featureNames{f},'at_touch')) > 0) ; groupFeatIdx{1} = union(groupFeatIdx{1}, f) ; end

		% Whisking variables
		if (length(strfind(featureNames{f},'Whisker')) > 0); groupFeatIdx{2} = union(groupFeatIdx{2}, f) ; end
		if (length(strfind(featureNames{f},'whisker')) > 0); groupFeatIdx{2} = union(groupFeatIdx{2}, f) ; end

		% Likcing variables
		if (length(strfind(featureNames{f},'Beam_Breaks')) > 0); groupFeatIdx{3} = union(groupFeatIdx{3}, f) ; end

		% Reward variables
		if (length(strfind(featureNames{f},'Reward')) > 0); groupFeatIdx{4} = union(groupFeatIdx{4}, f) ; end

		% Pole sound variables
		if (length(strfind(featureNames{f},'Pole_Move')) > 0); groupFeatIdx{5} = union(groupFeatIdx{5}, f) ; end
	end 

	
  %% ---------------------------------------------------------------------------
	%% --- now generate the various par files
	params = '';

	%% --- 1) encoder all features, all neurons - process neurons individually, then
	%        reassemble
	if (runModes(1))
	  disp('============== encoder: starting generation for all feature x single neurons ==============');
		% unique timestamp to do filedep
		ustr = datestr(now,'yyyymmddHHMMSSFFF'); 
		modeStr = 'encoder';

		% loop thru neurons
		for n=1:length(roiIdList)
		  clear params;

		  % the following are just variables that go to treebagger_call ; see it for deets
			params.X = stimulusFeatures;
		  params.Y = cellResponses(n,:);
			params.is_category_X = typeVec;
			params.is_category_Y = 0; % neuron so clearly not categorical

			params.params.temporal_shifts = temporalShifts; 
			params.params.nfold_cross_validation = 5;
			params.params.cross_validation_trial_vec = cellResponseTSA.trialIndices;
			params.params.z_score = [zScoreDff 0];
			params.params.zero_nans = [0 2]; % strip NaN values in dff
			params.params.do_grouped = 1;
			params.params.do_individual= 0;

			% other things

      % things you save to make analysis later easier
			params.save_vars.feat_idx = featIdx;
			params.save_vars.feat_name_list = featureNames;
			params.save_vars.feat_id_list = featureIdList;
			params.save_vars.cell_idx = cellIdx(n);
			params.save_vars.cell_id_list = roiIdList(n);
			params.save_vars.run_mode = 1;

			% output filename
			outPath = strrep(outputFileTemplate, '<%mode%>', modeStr);
			outPath = strrep(outPath, '<%featureName%>', 'grouped_all');
			outPath = strrep(outPath, '<%roiId%>', sprintf('%06d', roiIdList(n)));
			params.output_path = [outputFilesDir filesep outPath];

      % output parfile
			parfileName = [parfilesDir filesep 'parfile_' ustr '_'  sprintf('%06d', n) '.mat'];
			par_generate('treebagger_par_execute', '', params, parfileName); 
		end
	end

	%% --- 2) encoder single features, all neurons
	if (runModes(2))
	  disp('============== encoder: starting generation for single feature x all neurons ==============');
		% unique timestamp to do filedep
		ustr = datestr(now,'yyyymmddHHMMSSFFF'); 
		modeStr = 'encoder';

		% loop thru neurons
		for n=1:length(roiIdList)
		  clear params;

		  % the following are just variables that go to treebagger_call ; see it for deets
			params.X = stimulusFeatures;
		  params.Y = cellResponses(n,:);
			params.is_category_X = typeVec;
			params.is_category_Y = 0; % neurons are not categorical

			params.params.temporal_shifts = temporalShifts; 
			params.params.nfold_cross_validation = 5;
			params.params.cross_validation_trial_vec = cellResponseTSA.trialIndices;
			params.params.z_score = [zScoreDff 0];
			params.params.zero_nans = [0 2]; % strip NaN values in dff
			params.params.do_grouped = 0;
			params.params.do_individual= 1;

			% other things

      % things you save to make analysis later easier
			params.save_vars.feat_idx = featIdx;
			params.save_vars.cell_idx = cellIdx(n);
			params.save_vars.feat_name_list = featureNames;
			params.save_vars.feat_id_list = featureIdList;
			params.save_vars.cell_id_list = roiIdList(n);
			params.save_vars.run_mode = 2;

			% output filename
			outPath = strrep(outputFileTemplate, '<%mode%>', modeStr);
			outPath = strrep(outPath, '<%featureName%>', 'individual_all');
			outPath = strrep(outPath, '<%roiId%>', sprintf('%06d', roiIdList(n)));
			params.output_path = [outputFilesDir filesep outPath];

      % output parfile
			parfileName = [parfilesDir filesep 'parfile_' ustr '_'  sprintf('%06d', n) '.mat'];
			par_generate('treebagger_par_execute', '', params, parfileName); 
		end
	end


	%% --- 3) encoder grouped features, all neurons (one neuron @ a time)
	if (runModes(3))
	  disp('============== encoder: starting generation for feature group x all neurons ==============');
		% unique timestamp to do filedep
		ustr = datestr(now,'yyyymmddHHMMSSFFF'); 
		modeStr = 'encoder';

	  % loop over groups
		for g=1:length(groupName)
		  % loop thru neurons
			for n=1:length(roiIdList)
		    clear params;

				% the following are just variables that go to treebagger_call ; see it for deets
				params.X = stimulusFeatures(groupFeatIdx{g},:);
				params.Y = cellResponses(n,:);
				params.is_category_X = typeVec(groupFeatIdx{g});
				params.is_category_Y = 0; % cells not cat

				params.params.temporal_shifts = temporalShifts; 
				params.params.nfold_cross_validation = 5;
				params.params.cross_validation_trial_vec = cellResponseTSA.trialIndices;
				params.params.z_score = [zScoreDff 0];
			  params.params.zero_nans = [0 2]; % strip NaN values in dff
				params.params.do_grouped = 1;
				params.params.do_individual= 0;

				% other things

				% things you save to make analysis later easier
				params.save_vars.group_name = groupName{g};
				params.save_vars.feat_idx = groupFeatIdx{g};
				params.save_vars.cell_idx = cellIdx(n);
			  params.save_vars.feat_name_list = featureNames(groupFeatIdx{g});
			  params.save_vars.feat_id_list = featureIdList(groupFeatIdx{g});
			  params.save_vars.cell_id_list = roiIdList(n);
				
				params.save_vars.run_mode = 3;

				% output filename
				outPath = strrep(outputFileTemplate, '<%mode%>', modeStr);
				outPath = strrep(outPath, '<%featureName%>', ['grouped_' groupName{g}]);
				outPath = strrep(outPath, '<%roiId%>', sprintf('%06d', roiIdList(n)));
				params.output_path = [outputFilesDir filesep outPath];

				% output parfile
				parfileName = [parfilesDir filesep 'parfile_' ustr '_'  sprintf('%06d', g)  sprintf('%06d', n) '.mat'];
				par_generate('treebagger_par_execute', '', params, parfileName); 
			end
		end
	end

	%% --- 4) decoder: all features, all neurons (one feature @ a time) [population]
	if (runModes(4))
	  disp('============== decoder: starting generation for single feature x population ==============');
		% unique timestamp to do filedep
		ustr = datestr(now,'yyyymmddHHMMSSFFF'); 
		modeStr = 'decoder';

		% loop thru neurons
		for f=1:length(featureIdList)
		  clear params;

		  % the following are just variables that go to treebagger_call ; see it for deets
		  params.X = cellResponses;
			params.Y = stimulusFeatures(f,:);
			params.is_category_X = 0; % all are cells so definitely continuous
			params.is_category_Y = typeVec(f); 

			params.params.temporal_shifts = 0-temporalShifts;  % do opposite temporal shifts
			params.params.nfold_cross_validation = 5;
			params.params.cross_validation_trial_vec = cellResponseTSA.trialIndices;
			params.params.z_score = [zScoreDff 0];
			params.params.zero_nans = [0 2]; % strip NaN values in stimulus
			params.params.do_grouped = 1;
			params.params.do_individual= 0;

			% other things

			% things you save to make analysis later easier
			params.save_vars.feat_idx = featIdx(f);
			params.save_vars.cell_idx = cellIdx;
			params.save_vars.feat_name_list = featureNames{f};
			params.save_vars.feat_id_list = featureIdList(f);
			params.save_vars.cell_id_list = roiIdList;
      
			params.save_vars.run_mode = 4;

			% output filename
			outPath = strrep(outputFileTemplate, '<%mode%>', modeStr);
			outPath = strrep(outPath, '<%featureName%>', featureNames{f});
			outPath = strrep(outPath, '<%roiId%>', 'grouped_all');
			params.output_path = [outputFilesDir filesep outPath];

      % output parfile
			parfileName = [parfilesDir filesep 'parfile_' ustr '_'  sprintf('%06d', f) '.mat'];
			par_generate('treebagger_par_execute', '', params, parfileName); 
		end
	end

	%% --- 5) decoder: all features, single neurons (one feature @ a time) [single cells]
	if (runModes(5))
	  disp('============== decoder: starting generation for single feature x single neurons ==============');
		% unique timestamp to do filedep
		ustr = datestr(now,'yyyymmddHHMMSSFFF'); 
		modeStr = 'decoder';

		% loop thru neurons
		for f=1:length(featureIdList)
		  clear params;

		  % the following are just variables that go to treebagger_call ; see it for deets
		  params.X = cellResponses;
			params.Y = stimulusFeatures(f,:);
			params.is_category_X = 0; % all are cells so definitely continuous
			params.is_category_Y = typeVec(f);

			params.params.temporal_shifts = 0-temporalShifts;  % do opposite temporal shifts
			params.params.nfold_cross_validation = 5;
			params.params.cross_validation_trial_vec = cellResponseTSA.trialIndices;
			params.params.z_score = [zScoreDff 0];
			params.params.zero_nans = [0 2]; % strip NaN values in stimulus
			params.params.do_grouped = 0;
			params.params.do_individual= 1;

			% other things

			% things you save to make analysis later easier
			params.save_vars.feat_idx = featIdx(f);
			params.save_vars.cell_idx = cellIdx;
			params.save_vars.feat_name_list = featureNames{f};
			params.save_vars.feat_id_list = featureIdList(f);
			params.save_vars.cell_id_list = roiIdList;
			params.save_vars.run_mode = 5;

      % file-per-cell output?
			if (filePerCell)
				% output filename
				outPath = strrep(outputFileTemplate, '<%mode%>', modeStr);
				outPath = strrep(outPath, '<%featureName%>', featureNames{f});
%				outPath = strrep(outPath, '<%roiId%>', 'individual_all');
				params.output_path = [outputFilesDir filesep filesep featureNames{f} filesep outPath];

        % make output directory in this case
				mkdir(fileparts(params.output_path)); 

        % used by treebagger_par
				params.save_vars.file_per_cell = 1;
			else
				% output filename
				outPath = strrep(outputFileTemplate, '<%mode%>', modeStr);
				outPath = strrep(outPath, '<%featureName%>', featureNames{f});
				outPath = strrep(outPath, '<%roiId%>', 'individual_all');
				params.output_path = [outputFilesDir filesep outPath];
			end

      % output parfile
			parfileName = [parfilesDir filesep 'parfile_' ustr '_'  sprintf('%06d', f) '.mat'];
			par_generate('treebagger_par_execute', '', params, parfileName); 
		end
	end

	%% --- 6) double decoder: all features, all neurons (one feature @ a time) [population]
	if (runModes(6))
	  disp('============== double decoder: starting generation for single feature x population ==============');
		% unique timestamp to do filedep
		ustr = datestr(now,'yyyymmddHHMMSSFFF'); 
		modeStr = 'double_decoder';

		% loop thru neurons
		for f=1:length(featureIdList2Step{2})
		  clear params;

		  % first step
		  params.X = cellResponses;
			params.Y = stimulusFeatures2Step{1};
			params.Y2 = stimulusFeatures2Step{2}(f,:);
			params.is_category_X = 0; % all are cells so definitely continuous
			params.is_category_Y = typeVec2Step{1}; 
			params.is_category_Y2 = typeVec2Step{2}(f); 

			params.params.temporal_shifts = 0-temporalShifts;  % do opposite temporal shifts
			params.params.nfold_cross_validation = 5;
			params.params.cross_validation_trial_vec = cellResponseTSA.trialIndices;
			params.params.z_score = [zScoreDff 0];
			params.params.zero_nans = [0 2]; % strip NaN values in stimulus
			params.params.do_grouped = 1;
			params.params.do_individual= 0;

			% other things

			% things you save to make analysis later easier
			params.save_vars.feat_idx = featIdx2Step{2}(f);
			params.save_vars.cell_idx = cellIdx;
			params.save_vars.feat_name_list = featureNames2Step{2}{f};
			params.save_vars.feat_id_list = featureIdList2Step{2}(f);
			params.save_vars.cell_id_list = roiIdList;
      
			params.save_vars.run_mode = 6;

			% output filename
			outPath = strrep(outputFileTemplate, '<%mode%>', modeStr);
			outPath = strrep(outPath, '<%featureName%>', featureNames2Step{2}{f});
			outPath = strrep(outPath, '<%roiId%>', 'grouped_all');
			params.output_path = [outputFilesDir filesep outPath];

      % output parfile
			parfileName = [parfilesDir filesep 'parfile_' ustr '_'  sprintf('%06d', f) '.mat'];
			par_generate('treebagger_par_execute', '', params, parfileName); 
		end
	end

	%% --- 7) double decoder: all features, single neurons (one feature @ a time) [single cells]
	if (runModes(7))
	  disp('============== double decoder: starting generation for single feature x single neurons ==============');
		% unique timestamp to do filedep
		ustr = datestr(now,'yyyymmddHHMMSSFFF'); 
		modeStr = 'double_decoder';

		% loop thru neurons
		for n=1:length(roiIdList)
			for f=1:length(featureIdList2Step{2})
				clear params;

				% the following are just variables that go to treebagger_call ; see it for deets
				params.X = cellResponses(n,:);
				params.Y = stimulusFeatures2Step{1};
				params.Y2 = stimulusFeatures2Step{2}(f,:);
				params.is_category_X = 0; % all are cells so definitely continuous
				params.is_category_Y = typeVec2Step{1};
				params.is_category_Y2 = typeVec2Step{2}(f);

				params.params.temporal_shifts = 0-temporalShifts;  % do opposite temporal shifts
				params.params.nfold_cross_validation = 5;
				params.params.cross_validation_trial_vec = cellResponseTSA.trialIndices;
				params.params.z_score = [zScoreDff 0];
				params.params.zero_nans = [0 2]; % strip NaN values in stimulus
				params.params.do_grouped = 0;
				params.params.do_individual= 1;

				% other things

				% things you save to make analysis later easier
				params.save_vars.feat_idx = featIdx2Step{2}(f);
				params.save_vars.cell_idx = cellIdx(n);
				params.save_vars.feat_name_list = featureNames2Step{2}{f};
				params.save_vars.feat_id_list = featureIdList2Step{2}(f);
				params.save_vars.cell_id_list = roiIdList(n);
				params.save_vars.run_mode = 7;

				% output filename
				outPath = strrep(outputFileTemplate, '<%mode%>', modeStr);
				outPath = strrep(outPath, '<%featureName%>', featureNames2Step{2}{f});
				outPath = strrep(outPath, '<%roiId%>', num2str(roiIdList(n)));
				params.output_path = [outputFilesDir filesep outPath];

				% output parfile
				parfileName = [parfilesDir filesep 'parfile_' ustr '_'  sprintf('%06d%06d', f,n) '.mat'];
				par_generate('treebagger_par_execute', '', params, parfileName); 
			end
		end
	end

