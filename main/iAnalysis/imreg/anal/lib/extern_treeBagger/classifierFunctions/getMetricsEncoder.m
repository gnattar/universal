function results = getMetricsEncoder (x,y,y_train,names,varTrialType,varPolePosition,minTrials,results)
%%
%--------------------------------------------------------------------------
%
% Goal : Calculates several metrics (RMSE, R, etc) of how well the model predicted the data. It will return a structure results.metrics. Besides the metrics
%        there are different normalizations and subset of data used (trial types and Go positions).
%--------------------------------------------------------------------------


% Note : The code got pretty redundant. It should be changed to be more modular. For the next round....
% ToDO : Change the code so it can cope with NaNs

%-------------------------------------------------------------------------------------------------------------------------
% Metrics used
% --------------
% RMSE         = root nanmean squared error
% RMedSE       = root median sq. error (few error could be catastrophic...specially if there are glitches in the Ca signal)
% R            = correlation between data and model (Pearson)
% RSpear       = correlation between data and model (Spearman). Non-parametric
% _time        = for each time-point during the trial (added to RMSE, RMedSE, or R)


% Normalization
%--------------
% raw          = no normalization
% norm         = normalized by the energy of the trained signal
% relative     = How much better the model does relative to assuming the response in every-trial is the PSTH

% Whether comparison is for trial-by-trial points or PSTH (average across trials)
%----------------------------------------------------------------------------------
% allPoints    = for each point irrespective of its time
% psth         = error computed only for psth (it disregards trial to trial variability)


% For which trials
% ------------------
% allTrials    = all the trials
% trialType    = by trial type
% multipleGo   = by Go position

%%
idxVar                 = find(ismember (names,varTrialType));
N_time                 = size(x,3);
N_trials               = size(x,2);
N                      = size(results.y_predict,2);
listN                  = results.parameters.neuronsList;
for i=1:4,
    trialsType{i}  = find(squeeze(x(idxVar,:,1))==i);
end

% If your experiments do not have different GO positions, then call with varPolePosition = '';
if ~isempty (varPolePosition)
    idxPos  = find(ismember (names,varPolePosition));
    cat = unique(squeeze(x(idxPos,:,1)));
    N_cat = length(cat);
    for i=1:N_cat,
        trialsMultipleGo{i} = find(squeeze(x(idxPos,:,1))==cat(i));
    end
end

for i=1:N,
    %%
    %------------
    % Time-pooled : It gives a single value for all the data-set. It can obscure good and bad prediction instants.
    %------------
    idx = listN(i);
    squaredError        = (y_train(:,idx) - results.y_predict(:,i)).^2;
    squaredErrorPSTH    = (results.psth.data.all(i,:) - results.psth.model.all(i,:)).^2;
    squaredSignal       = y_train(:,idx).^2;
    squaredPSTHSignal   = results.psth.data.all(i,:).^2;  
    squaredRelativePSTHData  = reshape((squeeze(y(idx,:,:)) - repmat(results.psth.data.all(i,:),N_trials,1)).^2,1,N_time*N_trials);
    squaredRelativePSTHModel = reshape((squeeze(results.y_predict_trial(i,:,:)) - repmat(results.psth.data.all(i,:),N_trials,1)).^2,1,N_time*N_trials);
    y_model  = results.y_predict(:,i);
    y_data   = y_train(:,idx);
    y_psth   = repmat(results.psth.data.all(i,:)',N_trials,1);
    
    % Raw
    results.metrics.RMSE.raw.allPoints.allTrials(i)             =  nanmean(squaredError)^.5;
    results.metrics.RMSE.raw.psth.allTrials(i)                  =  nanmean(squaredErrorPSTH)^.5;
    results.metrics.RMedSE.raw.allPoints.allTrials(i)           =  nanmedian(squaredError)^.5;
    results.metrics.RMedSE.raw.psth.allTrials(i)                =  nanmedian(squaredErrorPSTH)^.5;
    
    % Normalized
    results.metrics.RMSE.norm.allPoints.allTrials(i)            =  (nanmean(squaredError)/nanmean(squaredSignal))^.5;
    results.metrics.RMedSE.norm.allPoints.allTrials(i)          =  (nanmedian(squaredError)/nanmedian(squaredSignal))^.5;
    results.metrics.RMSE.norm.psth.allTrials(i)                 =  (nanmean(squaredErrorPSTH)/nanmean(squaredPSTHSignal))^.5;
    results.metrics.RMedSE.norm.psth.allTrials(i)               =  (nanmedian(squaredErrorPSTH)/nanmedian(squaredPSTHSignal))^.5;
    
    % Relative
    results.metrics.RMSE.relative.psth.allTrials(i)             =  (nanmean(squaredRelativePSTHModel)/nanmean(squaredRelativePSTHData))^.5;
    results.metrics.RMedSE.relative.psth.allTrials(i)           =  (nanmedian(squaredRelativePSTHModel)/nanmedian(squaredRelativePSTHData))^.5;
    
    % Correlation
    results.metrics.R.raw.allPoints.allTrials(i)                =  nancorr (y_model, y_data,'type','Pearson');
    results.metrics.RSpear.raw.allPoints.allTrials(i)           =  nancorr (y_model, y_data,'type','Spearman');
    results.metrics.R.relative.psth.allTrials(i)                =  nancorr (y_model, y_data,'type','Pearson')/nancorr(y_psth,y_data,'type','Pearson'); 
    results.metrics.RSpear.relative.psth.allTrials(i)           =  nancorr (y_model, y_data,'type','Spearman')/nancorr(y_psth,y_data,'type','Spearman'); 
    
    %%
    %------------
    % per Time point in the trial : A value per each time in the trial. It will highlight when the model fails more. 
    %------------
    squaredError        = (squeeze(y(idx,:,:)) - squeeze(results.y_predict_trial(i,:,:))).^2;   % Trial by Time
    squaredErrorPSTH    = (results.psth.data.all(i,:) - results.psth.model.all(i,:)).^2; % This is already the error by time
    squaredSignal       = squeeze(y(idx,:,:)).^2;
    squaredPSTHSignal   = results.psth.data.all(i,:).^2;  
    squaredRelativePSTHData  = (squeeze(y(idx,:,:)) - repmat(results.psth.data.all(i,:),N_trials,1)).^2;
    squaredRelativePSTHModel = (squeeze(results.y_predict_trial(i,:,:)) - repmat(results.psth.data.all(i,:),N_trials,1)).^2;
    y_model  = squeeze(results.y_predict_trial(i,:,:));
    y_data   = squeeze(y(idx,:,:));
    y_psth   = repmat(results.psth.data.all(i,:),N_trials,1);

   % Raw
    results.metrics.RMSE_time.raw.allPoints.allTrials(i,:)             =  nanmean(squaredError,1).^.5;                  
    results.metrics.RMSE_time.raw.psth.allTrials(i,:)                  =  nanmean(squaredErrorPSTH,1).^.5;
    results.metrics.RMedSE_time.raw.allPoints.allTrials(i,:)           =  nanmedian(squaredError,1).^.5;
    results.metrics.RMedSE_time.raw.psth.allTrials(i,:)                =  nanmedian(squaredErrorPSTH,1).^.5;
    
    % Normalized
    results.metrics.RMSE_time.norm.allPoints.allTrials(i,:)            =  (nanmean(squaredError,1)./nanmean(squaredSignal,1)).^.5;
    results.metrics.RMedSE_time.norm.allPoints.allTrials(i,:)          =  (nanmedian(squaredError,1)./nanmedian(squaredSignal,1)).^.5;
    results.metrics.RMSE_time.norm.psth.allTrials(i,:)                 =  (squaredErrorPSTH./squaredPSTHSignal).^.5;
    
    % Relative
    results.metrics.RMSE_time.relative.psth.allTrials(i,:)             =  (nanmean(squaredRelativePSTHModel,1)./nanmean(squaredRelativePSTHData,1)).^.5;
    results.metrics.RMedSE_time.relative.psth.allTrials(i,:)           =  (nanmedian(squaredRelativePSTHModel,1)/nanmedian(squaredRelativePSTHData,1)).^.5;
    
    % Correlation
    for m=1:N_time
        results.metrics.R_time.raw.allPoints.allTrials(i,m)                =  nancorr (y_model(:,m), y_data(:,m),'type','Pearson');
        results.metrics.RSpear_time.raw.allPoints.allTrials(i,m)           =  nancorr (y_model(:,m), y_data(:,m),'type','Spearman');
        results.metrics.R_time.relative.psth.allTrials(i,m)                =  nancorr (y_model(:,m), y_data(:,m),'type','Pearson')/nancorr(y_psth(:,m),y_data(:,m),'type','Pearson');
        results.metrics.RSpear_time.relative.psth.allTrials(i,m)           =  nancorr (y_model(:,m), y_data(:,m),'type','Spearman')/nancorr(y_psth(:,m),y_data(:,m),'type','Spearman');
    end
    
    %%
    %---------------
    % By trial-type
    %---------------
    for j=1:4,
        if length(trialsType{j}) > minTrials
            y_2            = squeeze(y(idx,trialsType{j},:));
            ypred_2        = squeeze(results.y_predict_trial(i,trialsType{j},:));
            N_trials_2     = length(trialsType{j}); 
            y_train_2      = reshape(y_2',N_time*N_trials_2,1);
            y_pred_train_2 = reshape(ypred_2',N_time*N_trials_2,1);

            squaredError        = (y_train_2 - y_pred_train_2).^2;
            squaredErrorPSTH    = (results.psth.data.trialType{j}(i,:) - results.psth.model.trialType{j}(i,:)).^2;
            squaredSignal       = y_train_2.^2;
            squaredPSTHSignal   = results.psth.data.trialType{j}(i,:).^2;

            squaredRelativePSTHData  = reshape((y_2 - repmat(results.psth.data.trialType{j}(i,:),N_trials_2,1)).^2,1,N_time*N_trials_2);
            squaredRelativePSTHModel = reshape((ypred_2 - repmat(results.psth.data.trialType{j}(i,:),N_trials_2,1)).^2,1,N_time*N_trials_2);

            y_model  = y_pred_train_2;
            y_data   = y_train_2;
            y_psth   = repmat(results.psth.data.trialType{j}(i,:)',N_trials_2,1);

            %------------
            % Time-pooled : It gives a single value for all the data-set. It can obscure good and bad prediction instants.
            %------------

             % Raw
            results.metrics.RMSE.raw.allPoints.trialType{j}(i)             =  nanmean(squaredError)^.5;
            results.metrics.RMSE.raw.psth.trialType{j}(i)                  =  nanmean(squaredErrorPSTH)^.5;
            results.metrics.RMedSE.raw.allPoints.trialType{j}(i)           =  nanmedian(squaredError)^.5;
            results.metrics.RMedSE.raw.psth.trialType{j}(i)                =  nanmedian(squaredErrorPSTH)^.5;

            % Normalized
            results.metrics.RMSE.norm.allPoints.trialType{j}(i)            =  (nanmean(squaredError)/nanmean(squaredSignal))^.5;
            results.metrics.RMedSE.norm.allPoints.trialType{j}(i)          =  (nanmedian(squaredError)/nanmedian(squaredSignal))^.5;
            results.metrics.RMSE.norm.psth.trialType{j}(i)                 =  (nanmean(squaredErrorPSTH)/nanmean(squaredPSTHSignal))^.5;
            results.metrics.RMedSE.norm.psth.trialType{j}(i)               =  (nanmedian(squaredErrorPSTH)/nanmedian(squaredPSTHSignal))^.5;

            % Relative
            results.metrics.RMSE.relative.psth.trialType{j}(i)             =  (nanmean(squaredRelativePSTHModel)/nanmean(squaredRelativePSTHData))^.5;
            results.metrics.RMedSE.relative.psth.trialType{j}(i)           =  (nanmedian(squaredRelativePSTHModel)/nanmedian(squaredRelativePSTHData))^.5;

            % Correlation
            results.metrics.R.raw.allPoints.trialType{j}(i)                =  nancorr (y_model, y_data,'type','Pearson');
            results.metrics.RSpear.raw.allPoints.trialType{j}(i)           =  nancorr (y_model, y_data,'type','Spearman');
            results.metrics.R.relative.psth.trialType{j}(i)                =  nancorr (y_model, y_data,'type','Pearson')/nancorr(y_psth,y_data,'type','Pearson'); 
            results.metrics.RSpear.relative.psth.trialType{j}(i)           =  nancorr (y_model, y_data,'type','Spearman')/nancorr(y_psth,y_data,'type','Spearman'); 


            %------------
            % per Time point in the trial : A value per each time in the trial. It will highlight when the model fails more. 
            %------------
            squaredError        = (y_2 - ypred_2).^2;   % Trial by Time
            squaredErrorPSTH    = (results.psth.data.trialType{j}(i,:) - results.psth.model.trialType{j}(i,:)).^2; % This is already the error by time
            squaredSignal       = y_2.^2;
            squaredPSTHSignal   = results.psth.data.trialType{j}(i,:).^2;  
            squaredRelativePSTHData  = (y_2 - repmat(results.psth.data.trialType{j}(i,:),N_trials_2,1)).^2;
            squaredRelativePSTHModel = (ypred_2 - repmat(results.psth.data.trialType{j}(i,:),N_trials_2,1)).^2;
            y_model  = ypred_2;
            y_data   = y_2;
            y_psth   = repmat(results.psth.data.trialType{j}(i,:),N_trials_2,1);


            % Raw
            results.metrics.RMSE_time.raw.allPoints.trialType{j}(i,:)             =  nanmean(squaredError,1).^.5;                  
            results.metrics.RMSE_time.raw.psth.trialType{j}(i,:)                  =  nanmean(squaredErrorPSTH,1).^.5;
            results.metrics.RMedSE_time.raw.allPoints.trialType{j}(i,:)           =  nanmedian(squaredError,1).^.5;
            results.metrics.RMedSE_time.raw.psth.trialType{j}(i,:)                =  nanmedian(squaredErrorPSTH,1).^.5;

            % Normalized
            results.metrics.RMSE_time.norm.allPoints.trialType{j}(i,:)            =  (nanmean(squaredError,1)./nanmean(squaredSignal,1)).^.5;
            results.metrics.RMedSE_time.norm.allPoints.trialType{j}(i,:)          =  (nanmedian(squaredError,1)./nanmedian(squaredSignal,1)).^.5;
            results.metrics.RMSE_time.norm.psth.trialType{j}(i,:)                 =  (squaredErrorPSTH./squaredPSTHSignal).^.5;

            % Relative
            results.metrics.RMSE_time.relative.psth.trialType{j}(i,:)             =  (nanmean(squaredRelativePSTHModel,1)./nanmean(squaredRelativePSTHData,1)).^.5;
            results.metrics.RMedSE_time.relative.psth.trialType{j}(i,:)           =  (nanmedian(squaredRelativePSTHModel,1)/nanmedian(squaredRelativePSTHData,1)).^.5;

            % Correlation
            for m=1:N_time
                results.metrics.R_time.raw.allPoints.trialType{j}(i,m)                =  nancorr (y_model(:,m), y_data(:,m),'type','Pearson');
                results.metrics.RSpear_time.raw.allPoints.trialType{j}(i,m)           =  nancorr (y_model(:,m), y_data(:,m),'type','Spearman');
                results.metrics.R_time.relative.psth.trialType{j}(i,m)                =  nancorr (y_model(:,m), y_data(:,m),'type','Pearson')/nancorr(y_psth(:,m),y_data(:,m),'type','Pearson');
                results.metrics.RSpear_time.relative.psth.trialType{j}(i,m)           =  nancorr (y_model(:,m), y_data(:,m),'type','Spearman')/nancorr(y_psth(:,m),y_data(:,m),'type','Spearman');
            end

        end
    end
    
    %%
    %---------------
    % By Go Position
    %---------------
    
    % If your experiments do not have different GO positions, then call with varPolePosition = '';
    if ~isempty (varPolePosition)
        for j=1:N_cat,
            if length(trialsMultipleGo{j}) > minTrials
                y_2            = squeeze(y(idx,trialsMultipleGo{j},:));
                ypred_2        = squeeze(results.y_predict_trial(i,trialsMultipleGo{j},:));
                N_trials_2     = length(trialsMultipleGo{j}); 
                y_train_2      = reshape(y_2',N_time*N_trials_2,1);
                y_pred_train_2 = reshape(ypred_2',N_time*N_trials_2,1);

                squaredError        = (y_train_2 - y_pred_train_2).^2;
                squaredErrorPSTH    = (results.psth.data.multipleGo{j}(i,:) - results.psth.model.multipleGo{j}(i,:)).^2;
                squaredSignal       = y_train_2.^2;
                squaredPSTHSignal   = results.psth.data.multipleGo{j}(i,:).^2;

                squaredRelativePSTHData  = reshape((y_2 - repmat(results.psth.data.multipleGo{j}(i,:),N_trials_2,1)).^2,1,N_time*N_trials_2);
                squaredRelativePSTHModel = reshape((ypred_2 - repmat(results.psth.data.multipleGo(i,:),N_trials_2,1)).^2,1,N_time*N_trials_2);

                y_model  = y_pred_train_2;
                y_data   = y_train_2;
                y_psth   = repmat(results.psth.data.multipleGo{j}(i,:)',N_trials_2,1);

                %------------
                % Time-pooled : It gives a single value for all the data-set. It can obscure good and bad prediction instants.
                %------------

                 % Raw
                results.metrics.RMSE.raw.allPoints.multipleGo{j}(i)             =  nanmean(squaredError)^.5;
                results.metrics.RMSE.raw.psth.multipleGo{j}(i)                  =  nanmean(squaredErrorPSTH)^.5;
                results.metrics.RMedSE.raw.allPoints.multipleGo{j}(i)           =  nanmedian(squaredError)^.5;
                results.metrics.RMedSE.raw.psth.multipleGo{j}(i)                =  nanmedian(squaredErrorPSTH)^.5;

                % Normalized
                results.metrics.RMSE.norm.allPoints.multipleGo{j}(i)            =  (nanmean(squaredError)/nanmean(squaredSignal))^.5;
                results.metrics.RMedSE.norm.allPoints.multipleGo{j}(i)          =  (nanmedian(squaredError)/nanmedian(squaredSignal))^.5;
                results.metrics.RMSE.norm.psth.multipleGo{j}(i)                 =  (nanmean(squaredErrorPSTH)/nanmean(squaredPSTHSignal))^.5;
                results.metrics.RMedSE.norm.psth.multipleGo{j}(i)               =  (nanmedian(squaredErrorPSTH)/nanmedian(squaredPSTHSignal))^.5;

                % Relative
                results.metrics.RMSE.relative.psth.multipleGo{j}(i)             =  (nanmean(squaredRelativePSTHModel)/nanmean(squaredRelativePSTHData))^.5;
                results.metrics.RMedSE.relative.psth.multipleGo{j}(i)           =  (nanmedian(squaredRelativePSTHModel)/nanmedian(squaredRelativePSTHData))^.5;

                % Correlation
                results.metrics.R.raw.allPoints.multipleGo{j}(i)                =  nancorr (y_model, y_data,'type','Pearson');
                results.metrics.RSpear.raw.allPoints.multipleGo{j}(i)           =  nancorr (y_model, y_data,'type','Spearman');
                results.metrics.R.relative.psth.multipleGo{j}(i)                =  nancorr (y_model, y_data,'type','Pearson')/nancorr(y_psth,y_data,'type','Pearson'); 
                results.metrics.RSpear.relative.psth.multipleGo{j}(i)           =  nancorr (y_model, y_data,'type','Spearman')/nancorr(y_psth,y_data,'type','Spearman'); 


                %------------
                % per Time point in the trial : A value per each time in the trial. It will highlight when the model fails more. 
                %------------
                squaredError        = (y_2 - ypred_2).^2;   % Trial by Time
                squaredErrorPSTH    = (results.psth.data.multipleGo{j}(i,:) - results.psth.model.multipleGo{j}(i,:)).^2; % This is already the error by time
                squaredSignal       = y_2.^2;
                squaredPSTHSignal   = results.psth.data.multipleGo{j}(i,:).^2;  
                squaredRelativePSTHData  = (y_2 - repmat(results.psth.data.multipleGo{j}(i,:),N_trials_2,1)).^2;
                squaredRelativePSTHModel = (ypred_2 - repmat(results.psth.data.multipleGo{j}(i,:),N_trials_2,1)).^2;
                y_model  = ypred_2;
                y_data   = y_2;
                y_psth   = repmat(results.psth.data.multipleGo{j}(i,:)',N_trials_2,1);


                % Raw
                results.metrics.RMSE_time.raw.allPoints.multipleGo{j}(i,:)             =  nanmean(squaredError,1).^.5;                  
                results.metrics.RMSE_time.raw.psth.multipleGo{j}(i,:)                  =  nanmean(squaredErrorPSTH,1).^.5;
                results.metrics.RMedSE_time.raw.allPoints.multipleGo{j}(i,:)           =  nanmedian(squaredError,1).^.5;
                results.metrics.RMedSE_time.raw.psth.multipleGo{j}(i,:)                =  nanmedian(squaredErrorPSTH,1).^.5;

                % Normalized
                results.metrics.RMSE_time.norm.allPoints.multipleGo{j}(i,:)            =  (nanmean(squaredError,1)./nanmean(squaredSignal,1)).^.5;
                results.metrics.RMedSE_time.norm.allPoints.multipleGo{j}(i,:)          =  (nanmedian(squaredError,1)./nanmedian(squaredSignal,1)).^.5;
                results.metrics.RMSE_time.norm.psth.multipleGo{j}(i,:)                 =  (squaredErrorPSTH./squaredPSTHSignal).^.5;

                % Relative
                results.metrics.RMSE_time.relative.psth.multipleGo{j}(i,:)             =  (nanmean(squaredRelativePSTHModel,1)./nanmean(squaredRelativePSTHData,1)).^.5;
                results.metrics.RMedSE_time.relative.psth.multipleGo{j}(i,:)           =  (nanmedian(squaredRelativePSTHModel,1)/nanmedian(squaredRelativePSTHData,1)).^.5;

                % Correlation
                for m=1:N_time
                    results.metrics.R_time.raw.allPoints.multipleGo{j}(i,m)                =  nancorr (y_model(:,m), y_data(:,m),'type','Pearson');
                    results.metrics.RSpear_time.raw.allPoints.multipleGo{j}(i,m)           =  nancorr (y_model(:,m), y_data(:,m),'type','Spearman');
                    results.metrics.R_time.relative.psth.multipleGo{j}(i,m)                =  nancorr (y_model(:,m), y_data(:,m),'type','Pearson')/nancorr(y_psth(:,m),y_data(:,m),'type','Pearson');
                    results.metrics.RSpear_time.relative.psth.multipleGo{j}(i,m)           =  nancorr (y_model(:,m), y_data(:,m),'type','Spearman')/nancorr(y_psth(:,m),y_data(:,m),'type','Spearman');
                end


            end
        end
    end
 
end