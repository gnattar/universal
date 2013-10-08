%%
%-------------------------------------------------------------------------------------------------------------
%    Example : configurationSimon_1
%
%              - This example runs the random forest encoder with all features, single features, regrouped features, and pairs of regrouped features
%              - It runs for a single animal and single session with only few neurons
%              - It uses bidirectional and unidirectional shifts
%              - Doesnt have multiple-Go positions
%              - Trees are saved in separate files for each neuron
%              - The results of prediction, psth and metrics are saved together in a single file
%              - This example is run for raw calcium data
%              - It uses z-score for features and calcium data
%-------------------------------------------------------------------------------------------------------------

warning('off');
runSet = [1 0 0 0]; % all features ; single features ; categories ; category pairs -- 1 = run 0 = skip

%% Configuration file to run encoding-decoding in Simon's data
optionsTree = getDefaultOptionsTreeSimon;       % Default configuration

%% DIEGO MAGIC

% HAVE 02_04 in memory
%>> load('an38596_session_2010_02_11_AllF_onlyTree_002')
%>>  for i=1:206, xz(i,:,:) = squeeze(x(i,:,:))*resultsFull.zscore.x.std(i) + resultsFull.zscore.x.mean(i);end;
%>> yzPred = predict(randomForest,reshape(permute(xz,[1 3 2]),206,[])');
%>> corr (resultsFull.y_zscore_predict(:,2),yzPred)


%% load data
animalName = 'an38596';
actualAnimal = 'an38596';
actualSession = '2010_02_04';
if (~ exist('s','var'))
  load ('~/data/an38596/session/an38596_2010_02_11_sess');
	s.generateDerivedDataStructures();
end


%% clear since this is a script
clear orig_x y orig_names;

% determine how big orig_x will be ...
N_d = 0*s.validTrialIds;
N_c = 0*s.validTrialIds;
for t=1:length(s.validTrialIds)
  dti = find(s.derivedDataTSA.trialIndices == s.validTrialIds(t));
	cti = find(s.caTSA.dffTimeSeriesArray.trialIndices == s.validTrialIds(t));

	N_d(t) = length(dti);
	N_c(t) = length(dti);
end
num_per_trial = min(mode(N_d), mode(N_c));

%% WHERE YOU DECIDE WHO TO INCLUDE/EXCLUDE
exclude_wc = {'pro touch', 'ret touch'}; % variables with this in their name are excluded
included = ones(1,length(s.derivedDataTSA.tsa));
for d=1:length(s.derivedDataTSA.tsa)
  for e=1:length(exclude_wc)
    if (length(strfind(s.derivedDataTSA.tsa{d}.idStr, exclude_wc{e})) > 0) ; included(d) = 0 ; end
	end
end

% orig_x: feature x trial x time matrix 
valid = find(included);
orig_x = nan*ones(length(valid), length(s.validTrialIds), num_per_trial);
for f=1:length(valid)
  tsa = s.derivedDataTSA.tsa{valid(f)};
  for t=1:length(s.validTrialIds)
	  val = find(s.derivedDataTSA.trialIndices == s.validTrialIds(t));
		n = min(length(val),num_per_trial);
		orig_x(f,t,1:n) = tsa.value(val(1:n));
	end

	orig_names{f} = strrep(tsa.idStr, ' ', '_'); % to facilitate legibility later on
end

%% y: ca x trial x time matrix

% which rois to use? 
roiID = 1:length(s.caTSA.dffTimeSeriesArray); % use all
roiID= [1 5 17 19 42 38 61 67 166 2 3];
roiID= [17 42 3];
neurons = 0*roiID;

y = nan*ones(length(roiID), length(s.validTrialIds), num_per_trial);
for F=1:length(roiID);
  f = find (s.caTSA.ids == roiID(F));
  neurons(F) = F;
  tsa = s.caTSA.dffTimeSeriesArray.tsa{f};
  for t=1:length(s.validTrialIds)
	  val = find(s.caTSA.dffTimeSeriesArray.trialIndices == s.validTrialIds(t));
		n = min(length(val),num_per_trial);
		y(F,t,1:n) = tsa.value(val(1:n));
	end
end

% see what you have 
disp(['Completed generation of orig_x, y; orig_names: ']);
for o=1:length(orig_names)
  disp(['   ' char(orig_names{o})]);
end

N_neurons = size(y,1);

%% Which variables
% names = {'deltaKappa', 'amplitude','peak_amplitude' ,'setpoint', 'lick_rate','touch_kappa','pos_touch_kappa','neg_touch_kappa','abs_touch_kappa','diff_deltaKappa','diff_amplitude','diff_setpoint','pole_in_reach','water_valve','trial_type','trial_class'};

sensoryShift = 1:6;
motorShift   = [-2 -1];
bidirecShift = [motorShift sensoryShift];
type = zeros(1,length(orig_names));
[x names type ]  = appendShifted (orig_x,orig_names,type,orig_names{1},bidirecShift,0);
for o=2:length(orig_names)
  if (length(strfind(lower(orig_names{o}), 'amplitude')) | length(strfind(orig_names{o}, 'setpoint'))) % animal-controlled so bidir
	  [x names type ]  = appendShifted (x,names,type,orig_names{o},bidirecShift,0);
	else % otherwise sensory
	  [x names type ]  = appendShifted (x,names,type,orig_names{o},sensoryShift,0);
	  %[x names type ]  = appendShifted (x,names,type,orig_names{o},bidirecShift,0);
	end
end
[x names type ]  = removeVariable (x,names,type,{'trial_type','trial_class'}); % In the model we do not want to use the trial type or class

% trial_type == H M FA CR
% trial_class = G/NG
%[x names type ]  = appendShifted (orig_x,orig_names,type,'deltaKappa',sensoryShift,0);
%[x names type ]  = appendShifted (x,names,type,'amplitude',bidirecShift,0);
%[x names type ]  = appendShifted (x,names,type,'peak_amplitude',bidirecShift,0);
%[x names type ]  = appendShifted (x,names,type,'setpoint',bidirecShift,0);
%[x names type ]  = appendShifted (x,names,type,'lick_rate',bidirecShift,0);
%[x names type ]  = appendShifted (x,names,type,'touch_kappa',sensoryShift,0);
%[x names type ]  = appendShifted (x,names,type,'pos_touch_kappa',sensoryShift,0);
%[x names type ]  = appendShifted (x,names,type,'neg_touch_kappa',sensoryShift,0);
%[x names type ]  = appendShifted (x,names,type,'abs_touch_kappa',sensoryShift,0);
%[x names type ]  = appendShifted (x,names,type,'diff_deltaKappa',bidirecShift,0);
%[x names type ]  = appendShifted (x,names,type,'diff_amplitude',bidirecShift,0);
%[x names type ]  = appendShifted (x,names,type,'diff_setpoint',bidirecShift,0);
%[x names type ]  = appendShifted (x,names,type,'pole_in_reach',[-1 1],0);  % Only one variable that is in 1 whenever the pole is in reach +/- 1
%[x names type ]  = appendShifted (x,names,type,'water_valve',bidirecShift,1);

%% Which Groups
% Here we are going to set-up the different groupings to re-test the trees with fewer features
nameGroups = orig_names;
reGroupName = {{},{},{}, {}, {}};
for o=1:length(orig_names)
  % touch 
  if (length(strfind(lower(orig_names{o}), 'kappa')))
	  reGroupName{1}{length(reGroupName{1})+1} = orig_names{o};
  % amplitude, setpoint = group 2 (whisking)
  elseif (length(strfind(lower(orig_names{o}), 'amplitude')) | length(strfind(orig_names{o}, 'setpoint')))
	  reGroupName{2}{length(reGroupName{2})+1} = orig_names{o};
  % lick rate
  elseif (length(strfind(lower(orig_names{o}), 'beam')))
	  reGroupName{3}{length(reGroupName{3})+1} = orig_names{o};
  % water valve
  elseif (length(strfind(lower(orig_names{o}), 'valve')))
	  reGroupName{4}{length(reGroupName{4})+1} = orig_names{o};
  % lick rate
  elseif (length(strfind(lower(orig_names{o}), 'pole')))
	  reGroupName{5}{length(reGroupName{5})+1} = orig_names{o};
  end
end
reGroupCategory = {'Contact' 'Whisking' 'Lick' 'Reward' 'Task'};

%reGroupName{4} = {'water_valve'};
%reGroupName{5} = {'pole_in_reach'};
%reGroupCategory = {'Contact' 'Whisking' 'Lick' 'Reward' 'Task'};

groups     = getGroups (names,nameGroups);
regroups   = getReGroups (nameGroups,groups,reGroupName);
N_groups   = length(groups);
N_regroups = length(regroups);

%% Run the Random Forest Encoder with all the features and calculate PSTHs and Metrics
[x_train y_train] = getTrainingFormat (x,y,[]);
if (runSet(1))
	optionsTree.baseFilename  = sprintf('%s%s%s%s',animalName,'_session_',actualSession,'_AllF'); %AllF = all Features
	optionsTree.textVerbose   = sprintf('%s%s%s%s%s%s',animalName,' (',actualAnimal,')  session: ',actualSession,' --- all Features');
	resultsFull             = encoderRF (x,y,type,neurons,optionsTree);
	resultsFull             = getPSTHMultipleGo (orig_x,y,orig_names,'trial_class','',optionsTree.minTrials,resultsFull);  % No multiple - GO information
	warning('off');
	resultsFull             = getMetricsEncoder (orig_x,y,y_train,orig_names,'trial_class','',optionsTree.minTrials,resultsFull);
	resultsFull.parameters.encoderFeature.all      = names;
	resultsFull.parameters.encoderFeature.original = orig_names;
	fileToSave= sprintf('%s%s%s',optionsTree.path,optionsTree.baseFilename,'_allNeurons');
	save(fileToSave,'resultsFull');
end


%% Running with subset of features
% Checking one feature at a time
singleGroup = [1:N_groups];
clear resultsSingleFeature 
if (runSet(2))
	for i=1:N_groups,
			optionsTree.baseFilename  = sprintf('%s%s%s%s%s',animalName,'_session_',actualSession,'_SF_',nameGroups{singleGroup(i)}); %SF = single Feature
			optionsTree.textVerbose   = sprintf('%s%s%s%s%s%s%s',animalName,' (',actualAnimal,')  session: ',actualSession,' --- single Feature: ',nameGroups{singleGroup(i)});
			resultsSingleFeature = getGroupFeatureTree(x,y,type,neurons,groups,singleGroup(i),optionsTree);
			resultsSingleFeature = getPSTHMultipleGo (orig_x,y,orig_names,'trial_class','',optionsTree.minTrials,resultsSingleFeature);  % No multiple - GO information
			resultsSingleFeature = getMetricsEncoder (orig_x,y,y_train,orig_names,'trial_class','',optionsTree.minTrials,resultsSingleFeature);   
			resultsSingleFeature.parameters.encoderFeatures.all            = nameGroups;
			resultsSingleFeature.parameters.encoderFeatures.groups         = groups;
			resultsSingleFeature.parameters.encoderFeatures.activeFeatures = singleGroup(i);
			fileToSave= sprintf('%s%s%s',optionsTree.path,optionsTree.baseFilename,'_allNeurons');
			save(fileToSave,'resultsSingleFeature');
			clear resultsSingleFeature;
	end
end

% Checking one categorical feature at a time 
singleReGroup = [1:N_regroups];
clear resultsSingleCategory;
if (runSet(3))
	for i=1:N_regroups,
			optionsTree.baseFilename  = sprintf('%s%s%s%s%s',animalName,'_session_',actualSession,'_SC_',reGroupCategory{singleReGroup(i)}); %SC = single Category
			optionsTree.textVerbose   = sprintf('%s%s%s%s%s%s%s',animalName,' (',actualAnimal,')  session: ',actualSession,' --- single Category: ',reGroupCategory{singleReGroup(i)});
			resultsSingleCategory = getGroupFeatureTree(x,y,type,neurons,regroups,singleReGroup(i),optionsTree);
			resultsSingleCategory = getPSTHMultipleGo (orig_x,y,orig_names,'trial_class','',optionsTree.minTrials,resultsSingleCategory);  % No multiple - GO information
			resultsSingleCategory = getMetricsEncoder (orig_x,y,y_train,orig_names,'trial_class','',optionsTree.minTrials,resultsSingleCategory);   
			resultsSingleCategory.parameters.encoderFeatures.all            = reGroupName;
			resultsSingleCategory.parameters.encoderFeatures.groups         = regroups;
			resultsSingleCategory.parameters.encoderFeatures.activeFeatures = singleReGroup(i);
			resultsSingleCategory.parameters.encoderFeatures.categoryNames  = reGroupCategory;
			fileToSave = sprintf('%s%s%s',optionsTree.path,optionsTree.baseFilename,'_allNeurons');
			save(fileToSave,'resultsSingleCategory');
			clear resultsSingleCategory;
	end
end


% Checking  every categorical feature pair 
pairReGroup = nchoosek ([1:N_regroups],2); % Every possible pair of features
if (runSet(4))
	clear resultsPairCategory;
	for i=1:length(pairReGroup),
			optionsTree.baseFilename  = sprintf('%s%s%s%s%s%s%s',animalName,'_session_',actualSession,'_PairC_',reGroupCategory{pairReGroup(i,1)},'_',reGroupCategory{pairReGroup(i,2)}); % PairF = Pair of Category features
			optionsTree.textVerbose   = sprintf('%s%s%s%s%s%s%s%s%s',animalName,' (',actualAnimal,')  session: ',actualSession,' --- Pair Category: ',reGroupCategory{pairReGroup(i,1)},'  AND ',reGroupCategory{pairReGroup(i,2)});
			resultsPairCategory = getGroupFeatureTree(x,y,type,neurons,regroups,pairReGroup(i,:),optionsTree);
			resultsPairCategory = getPSTHMultipleGo (orig_x,y,orig_names,'trial_class','',optionsTree.minTrials,resultsPairCategory);  % No multiple - GO information
			resultsPairCategory = getMetricsEncoder (orig_x,y,y_train,orig_names,'trial_class','',optionsTree.minTrials,resultsPairCategory);   
			resultsPairCategory.parameters.encoderFeatures.all            = reGroupName;
			resultsPairCategory.parameters.encoderFeatures.groups         = regroups;
			resultsPairCategory.parameters.encoderFeatures.activeFeatures = pairReGroup(i,:);
			resultsPairCategory.parameters.encoderFeatures.categoryNames  = reGroupCategory;
			fileToSave = sprintf('%s%s%s',optionsTree.path,optionsTree.baseFilename,'_allNeurons');
			save(fileToSave,'resultsPairCategory');
			clear resultsPairCategory;
	end
end
