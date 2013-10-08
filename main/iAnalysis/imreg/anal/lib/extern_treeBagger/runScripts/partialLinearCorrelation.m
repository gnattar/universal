%%
%-------------------------------------------------------------------------------------------------------------
%    Example : partial Linear Correlation
%
%-------------------------------------------------------------------------------------------------------------



%% Configuration file to run encoding-decoding in Daniel's data
optionsTree = getDefaultOptionsTreeDaniel;       % Default configuration
danielFileNames;                                 % List of animals and sessions

%% For every animal and session
N_files = length(fileList);
warning ('off');
for idx = 10%:N_files,
    %%
    clear x names type orig_x y y_cad orig_names resultsFull resultsSingleFeature resultsSingleCategory resultsPairCategory;
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


    %% Which variables
    % names = {'deltaKappa', 'amplitude','peak_amplitude' ,'setpoint', 'lick_rate','touch_kappa','pos_touch_kappa','neg_touch_kappa','abs_touch_kappa','diff_deltaKappa','diff_amplitude','diff_setpoint','pole_in_reach','water_valve','trial_type','trial_class'};

    bidirecShift = [-2 -1 1 2];
    sensoryShift = [1 2];
    motorShift   = [-2 -1];
%     [x names type ]  = appendShifted (orig_x,orig_names,type,'deltaKappa',sensoryShift,0);
    [x names type ]  = appendShifted (orig_x,orig_names,type,'amplitude',bidirecShift,0);
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
%     [x names type ]  = appendShifted (x,names,type,'water_valve',sensoryShift,1);
    [x names type ]  = removeVariable (x,names,type,{'trial_type','trial_class','deltaKappa','water_valve'}); % In the model we do not want to use the trial type or class

    %% Which Groups
    % Here we are going to set-up the different groupings to re-test the trees with fewer features
    nameGroups = { 'amplitude' 'peak_amplitude' 'setpoint' 'lick_rate' 'touch_kappa' 'pos_touch_kappa' 'neg_touch_kappa' 'abs_touch_kappa' 'diff_deltaKappa' 'diff_amplitude' 'diff_setpoint' 'pole_in_reach' };
    reGroupName{1} = {'touch_kappa' 'pos_touch_kappa' 'neg_touch_kappa' 'abs_touch_kappa' 'diff_deltaKappa'}; %Contact signals
    reGroupName{2} = {'amplitude' 'peak_amplitude' 'setpoint' 'diff_amplitude' 'diff_setpoint'};                           %Whisking signals
    reGroupName{3} = {'lick_rate'};
%     reGroupName{4} = {'water_valve'};
    reGroupName{4} = {'pole_in_reach'};
    reGroupCategory = {'Contact' 'Whisking' 'Lick' 'Task'};

    groups     = getGroups (names,nameGroups);
    regroups   = getReGroups (nameGroups,groups,reGroupName);
    N_groups   = length(groups);
    N_regroups = length(regroups);
    
    %% Behavioral regression part
    [x_train y_train] = getTrainingFormat (x(:,:,1:12),y(:,:,1:12),[]);
    Nfeat             = size(x_train,2);
    resid_x           = zeros(size(x_train));
    resid_y           = zeros(N_goodNeurons,size(y_train,1),N_regroups);
    R                 = zeros(N_goodNeurons,N_regroups);
    for feat=1:Nfeat,
        feat
        var = x_train(:,feat);
%         for l=1:length(groups),
%             if ~isempty(find(ismember(feat,groups{l})))
%                 groupIdx = l;
%             end
%         end
        covariates = [];
        for l=1:length(regroups),
            if isempty(find(ismember(feat,regroups{l})))
                covariates = [covariates regroups{l}];
            end
        end
        x_cov = x_train(:,covariates);
        [a b] = find(isnan(x_cov));
        ii = sub2ind(size(x_cov),a,b);
        x_cov(ii) = 0;
        var(find(isnan(var))) = 0;
        [b bint] = regress (var,[ones(size(x_cov,1),1) x_cov]);
        b(find (bint(:,1).*bint(:,2)<0)) = 0;
        resid_x(:,feat) = var - (b(1) + x_cov*b(2:end));
    end
    for feat=1:N_regroups,
        feat
        indepVar   = regroups{feat};
        x_indepVar = resid_x(:,indepVar);
        covariates = [];
        for l=1:length(regroups),
            if isempty(find(ismember(feat,regroups{l})))
                covariates = [covariates regroups{l}];
            end
        end
        for k = 1:N_goodNeurons,
            k
            nIdx = neurons(k);
            var  = y_train(:,nIdx);
            x_cov = x_train(:,covariates);
            [a b] = find(isnan(x_cov));
            ii = sub2ind(size(x_cov),a,b);
            x_cov(ii) = 0;
            var(find(isnan(var))) = 0;
            [b bint]= regress (var,[ones(size(x_cov,1),1) x_cov]);
            b(find (bint(:,1).*bint(:,2)<0)) = 0;

            resid_y(k,:,feat) = var - (b(1) + x_cov*b(2:end));          
            [b bint]= regress (squeeze(resid_y(k,:,feat))',[ones(size(x_indepVar,1),1) x_indepVar]);
            b(find (bint(:,1).*bint(:,2)<0)) = 0;

            R(k,feat) = corr(squeeze(resid_y(k,:,feat))',(b(1) + x_indepVar*b(2:end)));
        end
        
    end

end
warning ('on');