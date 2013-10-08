function results = getPSTHDecoderMultipleGo (x,names,featureList,varTrialType,varPolePosition,minTrials,list_feat,results)
%%
%--------------------------------------------------------------------------
%
% Goal :  Calculate the PSTH of the data and the model for different trial types (varTrialType) or different GO positions (varPolePosition) for the features (x)  
% ----
%
% Population decoder and single neuron decoder have slightly different structures. So to keep this code the same, it has to be called with
% results.population or results(i).singleNeuron
%--------------------------------------------------------------------------
% x:               is the original N_var x N_trials x N_time indepedent variables
% featureList:     list of Features that were decoded
% varTrialType:    the name of the variable that has the trial types
% varPolePosition: the name of the variable that has the pole positions. If it is '', it will not create PSTHs for different positions
% list_feat:       The pointers to the x features that were used to calculate the decoder
% results:         the structure results that was returned by the decoding algorithm



%%
idxVar                 = find(ismember (names,varTrialType));
N_time                 = size(x,3);
N_trials               = size(x,2);

% Trials Types include hit, correct rejection, miss and false alarms. They should be provided as 0,1,2,3
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

for i=1:length(featureList),
    idx = list_feat(i);
    results.psth.data.all(i,:)        = nanmean(squeeze(x(idx,:,:)),1);
    results.psth.model.all(i,:)       = nanmean(squeeze(results.x_predict_trial(i,:,:)),1);
    results.psthSEM.data.all(i,:)     = nanstd(squeeze(x(idx,:,:)),1)/sqrt(N_trials);
    results.psthSEM.model.all(i,:)    = nanstd(squeeze(results.x_predict_trial(i,:,:)),1)/sqrt(N_trials);

    for j=1:4,
        N_trialsType(j) = length(trialsType{j});
        if length(trialsType{j}) > minTrials
            results.psth.data.trialType{j}(i,:)        = nanmean(squeeze(x(idx,trialsType{j},:)),1);        
            results.psth.model.trialType{j}(i,:)       = nanmean(squeeze(results.x_predict_trial(i,trialsType{j},:)),1);
            results.psthSEM.data.trialType{j}(i,:)     = nanstd(squeeze(x(idx,trialsType{j},:)),1)/sqrt(N_trialsType(j));        
            results.psthSEM.model.trialType{j}(i,:)    = nanstd(squeeze(results.x_predict_trial(i,trialsType{j},:)),1)/sqrt(N_trialsType(j));
        end
    end
    results.parameters.N_trialsType = N_trialsType;
    if ~isempty (varPolePosition)
        for j=1:N_cat,
            N_trialsMultipleGo(j) = length(trialsMultipleGo{j});
            if length(trialsMultipleGo{j}) > minTrials
                results.psth.data.multipleGo{j}(i,:)        = nanmean(squeeze(x(idx,trialsMultipleGo{j},:)),1);
                results.psth.model.multipleGo{j}(i,:)       = nanmean(squeeze(results.x_predict_trial(i,trialsMultipleGo{j},:)),1);
                results.psthSEM.data.multipleGo{j}(i,:)     = nanstd(squeeze(x(idx,trialsMultipleGo{j},:)),1)/sqrt(N_trialsMultipleGo(j));
                results.psthSEM.model.multipleGo{j}(i,:)    = nanstd(squeeze(results.x_predict_trial(i,trialsMultipleGo{j},:)),1)/sqrt(N_trialsMultipleGo(j));
            end
        end
        results.parameters.N_trialsMultipleGo = N_trialsMultipleGo;    
    end
end