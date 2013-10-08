%%
%-------------------------------------------------------------------------------------------------------------
%    Example : configurationDaniel_3
%
%              - This example runs the random forest encoder with all features but SHUFFLING the calcium or features time points
%              - It runs for a ALL the animals and ALL the sessions with ALL neurons
%              - It uses bidirectional and unidirectional shifts
%              - Doesnt have multiple-Go positions
%              - Trees are saved in separate files for each neuron
%              - The results of prediction, psth and metrics are saved together in a single file
%              - This example is run for raw calcium data
%              - It uses z-score for features and calcium data
%-------------------------------------------------------------------------------------------------------------



%% Configuration file to run encoding-decoding in Daniel's data
optionsTree = getDefaultOptionsTree;       % Default configuration
danielFileNames;                           % List of animals and sessions
optionsTree.save               = 'none';
%% For every animal and session
N_files = length(fileList);
warning ('off');
for idx = 1:N_files,
    %%
    clear x names type orig_x y y_cad orig_names resultsFullShuffle;
    actualAnimal  = animalId(idx);
    actualSession = sessionId(idx);
    actualFile    = fileList{idx};
    baseFileName  = sprintf('%s%s%d',animalName{idx},'_session_',actualSession);
    optionsTree.baseFilename            = baseFileName;
    fileToLoad                          = sprintf('%s%s',pathDirData,actualFile);
    [orig_x y_orig y_cad orig_names type]    = getDataDaniel (fileToLoad);
    xx = orig_x;
    y  = y_orig;
    % Shuffle the times of the calcium data
    for nn=1:size(y_orig,1)
        for tt=1:size(y_orig,2)
            y(nn,tt,:) = squeeze(y_orig(nn,tt,randperm(size(y_orig,3))));
        end
    end
    % Shuffle the times of the features
    for nn=1:size(orig_x,1)
        for tt=1:size(orig_x,2)
            xx(nn,tt,:) = squeeze(orig_x(nn,tt,randperm(size(orig_x,3))));
        end
    end
    N_neurons                           = size(y,1);
    neurons                             = [1:N_neurons];
    
    
    %% Which variables
    % names = {'deltaKappa', 'amplitude','peak_amplitude' ,'setpoint', 'lick_rate','touch_kappa','pos_touch_kappa','neg_touch_kappa','abs_touch_kappa','diff_deltaKappa','diff_amplitude','diff_setpoint','pole_in_reach','water_valve','trial_type','trial_class'};

    bidirecShift = [-2 -1 1 2];
    sensoryShift = [1 2];
    motorShift   = [-2 -1];
    [x names type ]  = appendShifted (xx,orig_names,type,'deltaKappa',sensoryShift,0);
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

    

    %% Run the Random Forest Encoder with all the features and calculate PSTHs and Metrics
    [x_train y_train] = getTrainingFormat (x,y,[]);
    optionsTree.baseFilename  = sprintf('%s%s%d%s',animalName{idx},'_session_',actualSession,'_AllF_ShuffleXY'); %AllF = all Features
    optionsTree.textVerbose   = sprintf('%s%s%d%s%d%s',animalName{idx},' (',actualAnimal,')  session: ',actualSession,' --- all Features Shuffle');
    optionsTree.path        = sprintf('%s%s%s',optionsTree.rootPath,optionsTree.pathAllFeatures,optionsTree.pathTrees);
    resultsFullShuffle             = encoderRF (x,y,type,neurons,optionsTree);
    resultsFullShuffle             = getPSTHMultipleGo (orig_x,y,orig_names,'trial_class','',resultsFullShuffle);  % No multiple - GO information
    resultsFullShuffle             = getMetricsEncoder (orig_x,y,y_train,orig_names,'trial_class','',resultsFullShuffle);
    resultsFullShuffle.parameters.encoderFeature.all      = names;
    resultsFullShuffle.parameters.encoderFeature.original = orig_names;
    optionsTree.path        = sprintf('%s%s',optionsTree.rootPath,optionsTree.pathAllFeatures);
    fileToSave= sprintf('%s%s%s',optionsTree.path,optionsTree.baseFilename,'_allNeurons');
    save(fileToSave,'resultsFullShuffle');



end
warning ('on');