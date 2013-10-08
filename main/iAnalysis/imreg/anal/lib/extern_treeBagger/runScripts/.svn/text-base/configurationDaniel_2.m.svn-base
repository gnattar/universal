%%
%-------------------------------------------------------------------------------------------------------------
%    Example : configurationDaniel_2
%
%              - This example runs the random forest encoder with all features, single features, regrouped features, and pairs of regrouped features
%              - It runs for a ALL the animals and ALL the sessions with ALL neurons
%              - It uses bidirectional and unidirectional shifts
%              - Doesnt have multiple-Go positions
%              - Trees are saved in separate files for each neuron
%              - The results of prediction, psth and metrics are saved together in a single file
%              - This example is run for raw calcium data
%              - It uses z-score for features and calcium data
%              - It organizes the results in different subdirectories
%              - It doesn't save the trees for single-features. Everything else is saved
%-------------------------------------------------------------------------------------------------------------



%% Configuration file to run encoding-decoding in Daniel's data
optionsTree = getDefaultOptionsTreeDaniel;       % Default configuration
danielFileNames;                                 % List of animals and sessions

%% For every animal and session
N_files = length(fileList);
warning ('off');
for idx = 1:N_files,
    %%
    clear x names type orig_x y y_cad orig_names resultsFull resultsSingleFeature resultsSingleCategory resultsPairCategory;
    actualAnimal  = animalId(idx);
    actualSession = sessionId(idx);
    actualFile    = fileList{idx};
    baseFileName  = sprintf('%s%s%d',animalName{idx},'_session_',actualSession);
    optionsTree.baseFilename            = baseFileName;
    fileToLoad                          = sprintf('%s%s',pathDirData,actualFile);
    [orig_x y y_cad orig_names type]    = getDataDaniel (fileToLoad);
    N_neurons                           = size(y,1);
    neurons                             = [1:N_neurons];


    %% Which variables
    % names = {'deltaKappa', 'amplitude','peak_amplitude' ,'setpoint', 'lick_rate','touch_kappa','pos_touch_kappa','neg_touch_kappa','abs_touch_kappa','diff_deltaKappa','diff_amplitude','diff_setpoint','pole_in_reach','water_valve','trial_type','trial_class'};

    bidirecShift = [-2 -1 1 2];
    sensoryShift = [1 2];
    motorShift   = [-2 -1];
    [x names type ]  = appendShifted (orig_x,orig_names,type,'deltaKappa',sensoryShift,0);
    [x names type ]  = appendShifted (x,names,type,'amplitude',bidirecShift,0);
    [x names type ]  = appendShifted (x,names,type,'peak_amplitude',bidirecShift,0);
    [x names type ]  = appendShifted (x,names,type,'setpoint',bidirecShift,0);
    [x names type ]  = appendShifted (x,names,type,'lick_rate',bidirecShift,0);
    [x names type ]  = appendShifted (x,names,type,'touch_kappa',sensoryShift,0);
    [x names type ]  = appendShifted (x,names,type,'pos_touch_kappa',sensoryShift,0);
    [x names type ]  = appendShifted (x,names,type,'neg_touch_kappa',sensoryShift,0);
    [x names type ]  = appendShifted (x,names,type,'abs_touch_kappa',sensoryShift,0);
    [x names type ]  = appendShifted (x,names,type,'diff_deltaKappa',bidirecShift,0);
    [x names type ]  = appendShifted (x,names,type,'diff_amplitude',bidirecShift,0);
    [x names type ]  = appendShifted (x,names,type,'diff_setpoint',bidirecShift,0);
    [x names type ]  = appendShifted (x,names,type,'pole_in_reach',[-1 1],0);  % Only one variable that is in 1 whenever the pole is in reach +/- 1
    [x names type ]  = appendShifted (x,names,type,'water_valve',bidirecShift,1);
    [x names type ]  = removeVariable (x,names,type,{'trial_type','trial_class'}); % In the model we do not want to use the trial type or class

    %% Which Groups
    % Here we are going to set-up the different groupings to re-test the trees with fewer features
    nameGroups = {'deltaKappa' 'amplitude' 'peak_amplitude' 'setpoint' 'lick_rate' 'touch_kappa' 'pos_touch_kappa' 'neg_touch_kappa' 'abs_touch_kappa' 'diff_deltaKappa' 'diff_amplitude' 'diff_setpoint' 'pole_in_reach' 'water_valve'};
    reGroupName{1} = {'deltaKappa' 'touch_kappa' 'pos_touch_kappa' 'neg_touch_kappa' 'abs_touch_kappa' 'diff_deltaKappa'}; %Contact signals
    reGroupName{2} = {'amplitude' 'peak_amplitude' 'setpoint' 'diff_amplitude' 'diff_setpoint'};                           %Whisking signals
    reGroupName{3} = {'lick_rate'};
    reGroupName{4} = {'water_valve'};
    reGroupName{5} = {'pole_in_reach'};
    reGroupCategory = {'Contact' 'Whisking' 'Lick' 'Reward' 'Task'};

    groups     = getGroups (names,nameGroups);
    regroups   = getReGroups (nameGroups,groups,reGroupName);
    N_groups   = length(groups);
    N_regroups = length(regroups);

    %% Run the Random Forest Encoder with all the features and calculate PSTHs and Metrics
    [x_train y_train] = getTrainingFormat (x,y,[]);
    optionsTree.baseFilename  = sprintf('%s%s%d%s',animalName{idx},'_session_',actualSession,'_AllF'); %AllF = all Features
    optionsTree.textVerbose   = sprintf('%s%s%d%s%d%s',animalName{idx},' (',actualAnimal,')  session: ',actualSession,' --- all Features');
    optionsTree.path        = sprintf('%s%s%s',optionsTree.rootPath,optionsTree.pathAllFeatures,optionsTree.pathTrees);
    resultsFull             = encoderRF (x,y,type,neurons,optionsTree);
    resultsFull             = getPSTHMultipleGo (orig_x,y,orig_names,'trial_class','',optionsTree.minTrials,resultsFull);  % No multiple - GO information
    resultsFull             = getMetricsEncoder (orig_x,y,y_train,orig_names,'trial_class','',optionsTree.minTrials,resultsFull);
    resultsFull.parameters.encoderFeature.all      = names;
    resultsFull.parameters.encoderFeature.original = orig_names;
    optionsTree.path        = sprintf('%s%s',optionsTree.rootPath,optionsTree.pathAllFeatures);
    fileToSave= sprintf('%s%s%s',optionsTree.path,optionsTree.baseFilename,'_allNeurons');
    save(fileToSave,'resultsFull');


    %% Running with subset of features
    % Checking one feature at a time
    singleGroup = [1:N_groups];
    clear resultsSingleFeature 
    for i=1:N_groups,
        optionsTree.baseFilename  = sprintf('%s%s%d%s%s',animalName{idx},'_session_',actualSession,'_SF_',nameGroups{singleGroup(i)}); %SF = single Feature
        optionsTree.textVerbose   = sprintf('%s%s%d%s%d%s%s',animalName{idx},' (',actualAnimal,')  session: ',actualSession,' --- single Feature: ',nameGroups{singleGroup(i)});
        optionsTree.save     = 'none';
        auxPath = sprintf('%s%s',optionsTree.rootPath,optionsTree.pathSingleFeatures);
        newPath = sprintf('%s%s',nameGroups{singleGroup(i)},'\');
        allPath = sprintf('%s%s',auxPath,newPath);
        optionsTree.path        = sprintf('%s%s',allPath,optionsTree.pathTrees);
        mkdir (auxPath,newPath);
        mkdir (allPath,optionsTree.pathTrees);
        
        resultsSingleFeature = getGroupFeatureTree(x,y,type,neurons,groups,singleGroup(i),optionsTree);
        resultsSingleFeature = getPSTHMultipleGo (orig_x,y,orig_names,'trial_class','',optionsTree.minTrials,resultsSingleFeature);  % No multiple - GO information
        resultsSingleFeature = getMetricsEncoder (orig_x,y,y_train,orig_names,'trial_class','',optionsTree.minTrials,resultsSingleFeature);   
        resultsSingleFeature.parameters.encoderFeatures.all            = nameGroups;
        resultsSingleFeature.parameters.encoderFeatures.groups         = groups;
        resultsSingleFeature.parameters.encoderFeatures.activeFeatures = singleGroup(i);
        fileToSave= sprintf('%s%s%s',allPath,optionsTree.baseFilename,'_allNeurons');
        save(fileToSave,'resultsSingleFeature');
        clear resultsSingleFeature;
    end

    % Checking one categorical feature at a time (Contact, whisking, lick, reward, task)
    singleReGroup = [1:N_regroups];
    clear resultsSingleCategory;
    for i=1:N_regroups,
        optionsTree.baseFilename  = sprintf('%s%s%d%s%s',animalName{idx},'_session_',actualSession,'_SC_',reGroupCategory{singleReGroup(i)}); %SC = single Category
        optionsTree.textVerbose   = sprintf('%s%s%d%s%d%s%s',animalName{idx},' (',actualAnimal,')  session: ',actualSession,' --- single Category: ',reGroupCategory{singleReGroup(i)});
        optionsTree.save      = 'onlyTree';
        auxPath = sprintf('%s%s',optionsTree.rootPath,optionsTree.pathSingleCategories);
        newPath = sprintf('%s%s',reGroupCategory{singleReGroup(i)},'\');
        allPath = sprintf('%s%s',auxPath,newPath);
        optionsTree.path        = sprintf('%s%s',allPath,optionsTree.pathTrees);
        mkdir (auxPath,newPath);
        mkdir (allPath,optionsTree.pathTrees);
        resultsSingleCategory = getGroupFeatureTree(x,y,type,neurons,regroups,singleReGroup(i),optionsTree);
        resultsSingleCategory = getPSTHMultipleGo (orig_x,y,orig_names,'trial_class','',optionsTree.minTrials,resultsSingleCategory);  % No multiple - GO information
        resultsSingleCategory = getMetricsEncoder (orig_x,y,y_train,orig_names,'trial_class','',optionsTree.minTrials,resultsSingleCategory);   
        resultsSingleCategory.parameters.encoderFeatures.all            = reGroupName;
        resultsSingleCategory.parameters.encoderFeatures.groups         = regroups;
        resultsSingleCategory.parameters.encoderFeatures.activeFeatures = singleReGroup(i);
        resultsSingleCategory.parameters.encoderFeatures.categoryNames  = reGroupCategory;
        fileToSave = sprintf('%s%s%s',allPath,optionsTree.baseFilename,'_allNeurons');
        save(fileToSave,'resultsSingleCategory');
        clear resultsSingleCategory;
    end



    % Checking  every categorical feature pair (Contact, whisking, lick, reward, task)
    pairReGroup = nchoosek ([1:N_regroups],2); % Every possible pair of features
    clear resultsPairCategory;
    for i=1:length(pairReGroup),
        optionsTree.baseFilename  = sprintf('%s%s%d%s%s%s%s',animalName{idx},'_session_',actualSession,'_PairC_',reGroupCategory{pairReGroup(i,1)},'_',reGroupCategory{pairReGroup(i,2)}); % PairF = Pair of Category features
        optionsTree.textVerbose   = sprintf('%s%s%d%s%d%s%s%s%s',animalName{idx},' (',actualAnimal,')  session: ',actualSession,' --- Pair Category: ',reGroupCategory{pairReGroup(i,1)},'  AND ',reGroupCategory{pairReGroup(i,2)});
        optionsTree.save      = 'onlyTree';
        auxPath = sprintf('%s%s',optionsTree.rootPath,optionsTree.pathPairCategories);
        newPath = sprintf('%s%s%s%s',reGroupCategory{pairReGroup(i,1)},'_AND_',reGroupCategory{pairReGroup(i,2)},'\');
        allPath = sprintf('%s%s',auxPath,newPath);
        optionsTree.path        = sprintf('%s%s',allPath,optionsTree.pathTrees);
        mkdir (auxPath,newPath);
        mkdir (allPath,optionsTree.pathTrees);
        resultsPairCategory = getGroupFeatureTree(x,y,type,neurons,regroups,pairReGroup(i,:),optionsTree);
        resultsPairCategory = getPSTHMultipleGo (orig_x,y,orig_names,'trial_class','',optionsTree.minTrials,resultsPairCategory);  % No multiple - GO information
        resultsPairCategory = getMetricsEncoder (orig_x,y,y_train,orig_names,'trial_class','',optionsTree.minTrials,resultsPairCategory);   
        resultsPairCategory.parameters.encoderFeatures.all            = reGroupName;
        resultsPairCategory.parameters.encoderFeatures.groups         = regroups;
        resultsPairCategory.parameters.encoderFeatures.activeFeatures = pairReGroup(i,:);
        resultsPairCategory.parameters.encoderFeatures.categoryNames  = reGroupCategory;
        fileToSave = sprintf('%s%s%s',allPath,optionsTree.baseFilename,'_allNeurons');
        save(fileToSave,'resultsPairCategory');
        clear resultsPairCategory;
    end
end
warning ('on');