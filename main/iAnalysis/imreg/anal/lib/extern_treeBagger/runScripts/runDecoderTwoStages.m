%%
%-------------------------------------------------------------------------------------------------------------
%    Example : runDecoderTwoStages

%-------------------------------------------------------------------------------------------------------------



%% Configuration file to run encoding-decoding in Daniel's data
optionsTree = getDefaultOptionsTreeDaniel_dec;       % Default configuration
danielFileNames;                                 % List of animals and sessions

%% For every animal and session
N_files = length(fileList);
warning ('off');
for idx = 1:N_files,
    %%
    clear x names names_y type_y type orig_x y y_conv y_ca y_cad orig_names resultsPopulation flagSignal neurons y_touch;
    actualAnimal  = animalId(idx);
    actualSession = sessionId(idx);
    actualFile    = fileList{idx};
    baseFileName  = sprintf('%s%s%d',animalName{idx},'_session_',actualSession);
    optionsTree.baseFilename            = baseFileName;
    fileToLoad                          = sprintf('%s%s',pathDirData,actualFile);
    [orig_x y y_conv y_ca y_cad orig_names type flagSignal]    = getDataDaniel_dec (fileToLoad);
    N_neurons                           = size(y,1);
    N_goodNeurons                       = length(find(flagSignal==1));
    neurons                             = find(flagSignal==1);
    optionsTree.baseFilename  = sprintf('%s%s%d%s',animalName{idx},'_session_',actualSession,'_populationDecoder'); %AllF = all Features
    optionsTree.path        = sprintf('%s%s','F:\Diego\Matlab\temp\Daniel\Results\decoderRF_deconv\',optionsTree.pathPopulation);
    fileToLoad= sprintf('%s%s',optionsTree.path,optionsTree.baseFilename);
    load(fileToLoad);
    %% Prepare the variables to decode and shifts
    y_touch(1,:,:) = squeeze(resultsPopulation.population.x_predict_trial(1,:,:));
    y_touch(2,:,:) = squeeze(resultsPopulation.population.x_predict_trial(6,:,:));
    y_touch(3,:,:) = squeeze(resultsPopulation.population.x_predict_trial(7,:,:));
    y_touch(4,:,:) = squeeze(resultsPopulation.population.x_predict_trial(8,:,:));
    y_touch(5,:,:) = squeeze(resultsPopulation.population.x_predict_trial(9,:,:));
    y_touch(6,:,:) = squeeze(resultsPopulation.population.x_predict_trial(10,:,:));
    names_y = {'deltaKappa','touch_kappa','pos_touch_kappa','neg_touch_kappa','abs_touch_kappa','diff_deltaKappa'};
    orig_names_y = names_y;
    type_y = zeros(1,length(names_y));
    shiftCa   = optionsTree.decoder.calciumShifts;
    flag = 0;
    % Check if 0 is not included
    if isempty(find(optionsTree.decoder.calciumShifts == 0))
        flag = 1;
    else
        shiftCa (find(shiftCa==0)) = [];
    end

    for i=1:length(names_y),
        [y_touch names_y type_y ]  = appendShifted (y_touch,names_y,type_y,names_y{i},shiftCa,0);
        % If shift 0 is not included it has to be removed
        if flag == 1
            [y_touch names_y type_y ]  = removeVariable (y_touch,names_y,type_y,names_y{1});
        end
    end
    
    names = orig_names;
    N_names = length(names);
%     featureList = {'deltaKappa', 'amplitude','peak_amplitude' ,'setpoint', 'lick_rate','touch_kappa','pos_touch_kappa','neg_touch_kappa','abs_touch_kappa','diff_deltaKappa','diff_amplitude','diff_setpoint','touch_detect','touch_direction'};
    featureList = {'touch_detect','touch_direction'};

    names{N_names+1} = 'touch_detect';
    names{N_names+2} = 'touch_direction';    
    x = orig_x;
    touchKappa = reshape(squeeze(x(6,:,:))',[],1)';
    touch      = zeros(size(touchKappa));
    touch(find(abs(touchKappa)>0)) = 1;
    directTouch = zeros(size(touchKappa));
    directTouch(find(touchKappa>0)) = 1;
    directTouch(find(touchKappa<0)) = 2;    %Use positive values
    % This is to define the weights inverserly proportional to the ocurrence of each category

%     N_0 = length(find(abs(touchKappa)==0));
%     N_1 = length(find(abs(touchKappa)>0));
%     W_0 = 0.5*(N_0+N_1)/N_0;
%     W_1 = 0.5*(N_0+N_1)/N_1;    
%     weight(find(abs(touchKappa)==0),17)  = W_0;
%     weight(find(abs(touchKappa)>0),17)   = W_1;
%     N_0 = length(find((touchKappa)==0));
%     N_1 = length(find((touchKappa)<0));
%     N_2 = length(find((touchKappa)>0));    
%     W_0 = (N_0+N_1+N_2)/(3*N_0);
%     W_1 = (N_0+N_1+N_2)/(3*N_1);
%     W_2 = (N_0+N_1+N_2)/(3*N_2);
%     weight(find((touchKappa)==0),18)  = W_0;
%     weight(find((touchKappa)>0),18)   = W_1;
%     weight(find((touchKappa)<0),18)   = W_2;
%     
    x(N_names+1,:,:) = reshape(touch,size(x,3),[])';
    x(N_names+2,:,:) = reshape(directTouch,size(x,3),[])';    
    type = [0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1];
    N_shifts = length(optionsTree.decoder.calciumShifts);
    sensoryShiftsVariables      = [1 6 7 8 9 10 13 14];
    sensoryMotorShiftsVariables = [2 3 4 5 11 12];
    
    % The shifts are in calcium, so positive shifts moves calcium to the future. That means it predicts the behavior (i.e. motor)
    sensoryShifts        = [-2 -1 0];
    sensoryMotorShifts   = [-2 -1 0 1 2];
    for sh = 1:length(featureList),
        if ~isempty(intersect(sensoryShiftsVariables,sh))
            shiftsPerFeature{sh} = sensoryShifts;
        else
            shiftsPerFeature{sh} = sensoryMotorShifts;
        end
    end
    y_touch(:,:,[[1:4] [11:28]]) = [];
    x(:,:,[[1:4] [11:28]]) = [];
    weight = ones(size(y_touch,2)*size(y_touch,3),length(names));
    
%     %% Population decoding
    optionsTree.decodePopulation = 1;
    optionsTree.saveDecoderPopulation = 'allTree'; 
    optionsTree.saveDecoderSingle = 'allTree'; 
    optionsTree.baseFilename  = sprintf('%s%s%d%s',animalName{idx},'_session_',actualSession,'_populationDecoder'); %AllF = all Features
    optionsTree.textVerbose   = sprintf('%s%s%d%s%d%s',animalName{idx},' (',actualAnimal,')  session: ',actualSession,' --- ');
    optionsTree.path          = sprintf('%s%s%s',optionsTree.rootPath,optionsTree.pathPopulation,optionsTree.pathTrees);
    resultsPopulation         = decoderRF_twoStages (x,y_touch,type,names,names_y,orig_names_y,featureList,[],N_shifts,shiftsPerFeature,optionsTree,weight);    
    resultsPopulation.population    = getPSTHDecoderMultipleGo (x,names,featureList,'trial_class','',optionsTree.minTrials,resultsPopulation.parameters.listFeatures,resultsPopulation.population);
    resultsPopulation.population    = getMetricsDecoder (x,names,featureList,'trial_class','',optionsTree.minTrials,resultsPopulation.parameters.listFeatures,resultsPopulation.population);   
    resultsPopulation.metric.category(1)     = categoryError (reshape(squeeze(x(end-1,:,:))',[],1),resultsPopulation.population.x_predict(:,1));
    resultsPopulation.metric.category(2)     = categoryError (reshape(squeeze(x(end,:,:))',[],1),resultsPopulation.population.x_predict(:,2));    

    resultsPopulation.parameters.decoderFeature.all      = names;
    resultsPopulation.parameters.decoderFeature.original = orig_names;
    resultsPopulation.parameters.decoderFeature.selected = featureList;
    resultsPopulation.parameters.decoderFeature.shifts   = shiftsPerFeature;
    optionsTree.path        = sprintf('%s%s',optionsTree.rootPath,optionsTree.pathPopulation);
    fileToSave= sprintf('%s%s',optionsTree.path,optionsTree.baseFilename);
    save(fileToSave,'resultsPopulation');


end
warning ('on');