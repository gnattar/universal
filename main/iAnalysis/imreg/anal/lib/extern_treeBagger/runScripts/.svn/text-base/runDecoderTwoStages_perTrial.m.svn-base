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
    idx
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
    vec_idx = [1 6 7 8 9 10];
    for l=1:6
        y_touch(:,(l-1)*6+1:l*6) = squeeze(resultsPopulation.population.x_predict_trial(vec_idx(l),:,5:10));
    end
    x = orig_x;
    touchKappa = sum(squeeze(x(9,:,5:10)),2);
    touch      = zeros(size(touchKappa));
    touch(find(abs(touchKappa)>0)) = 1;
    statset('TreeBagger');
    options = statset('UseParallel','always');

    resultsTouchTrial.bagTree = TreeBagger(optionsTree.N_bagging,y_touch,touch,'oobpred','on','method','classification','minleaf',1,'Options',options);
    resultsTouchTrial.x_predict = str2num(cell2mat(oobPredict(resultsTouchTrial.bagTree)));
    resultsTouchTrial.metric.category     = categoryError (touch,resultsTouchTrial.x_predict);
    category = resultsTouchTrial.metric.category;
    aux = sprintf('%s','Classification : --- ');
    for cat = 1:2,
        aux = sprintf ('%s%s%d%s%.2f%s%d%s%d%s',aux,'Class: ',category.names(cat),'  ',100*category.percentage.correct(cat),' %  ', category.count.model(cat),' / ',category.count.data(cat),'   ----  ');
    end
    aux = sprintf('%s%s%.2f\n',aux,'---   Total Correct: ',100*category.percentage.correctTotal);
    disp (aux);

    optionsTree.path        = sprintf('%s%s',optionsTree.rootPath,optionsTree.pathPopulation);
    fileToSave= sprintf('%s%s',optionsTree.path,optionsTree.baseFilename);
    save(fileToSave,'resultsTouchTrial');


end
warning ('on');