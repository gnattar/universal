%%
%-------------------------------------------------------------------------------------------------------------
%    Example : deconvDaniel_1
%
%              - This example runs and save the deconvoluted calcium trace
%-------------------------------------------------------------------------------------------------------------



%% Configuration file to run encoding-decoding in Daniel's data
optionsTree = getDefaultOptionsTreeDaniel;       % Default configuration
danielFileNames;                                 % List of animals and sessions

%% For every animal and session
N_files = length(fileList);
warning ('off');
for idx = 7:N_files,
    %%
    idx
    clear x names type orig_x y y_cad orig_names resultsFull resultsSingleFeature resultsSingleCategory resultsPairCategory;
    actualAnimal  = animalId(idx);
    actualSession = sessionId(idx);
    actualFile    = fileList{idx};
    baseFileName  = sprintf('%s%s%d',animalName{idx},'_session_',actualSession);
    optionsTree.baseFilename            = baseFileName;
    fileToLoad                          = sprintf('%s%s',pathDirData,actualFile);
    [orig_x y y_cad orig_names type]    = getDataDaniel (fileToLoad);
    N_neurons                           = size(y,1);
    y_ev                                = zeros(size(y));
    y_conv                              = y_ev;
    flagSignal                          = ones(N_neurons,1);
    for i=1:N_neurons,
        i
        
        y_train = reshape(squeeze(y(i,:,:))',[],1);
        if sum(y_train.^2)<1e-3;
            n_best = zeros(length(y_train),1);
            C_best = zeros(length(y_train),1); 
            flagSignal (i) = 0;
        else
            [n_best P_best V_best C_best] = oopsi_deconv (y_train,4,1.5,1,0.005);
            if mean(n_best) < 0.002
                n_best = zeros(length(y_train),1);
                C_best = zeros(length(y_train),1);    
                flagSignal (i) = 0;
            end
        end
        y_ev(i,:,:)   = reshape(n_best,size(y,3),[])';
        y_conv(i,:,:) = reshape(C_best,size(y,3),[])';        
    end
    save(fileToLoad,'y_ev','y_conv','flagSignal','-append');
end
warning ('on');