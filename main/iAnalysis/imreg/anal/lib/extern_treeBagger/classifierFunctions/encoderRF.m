function results = encoderRF (x_trial,y_trial,type,neurons,optionsTree)
%%
%--------------------------------------------------------------------------
%
% Goal : to train a random forest with features (x_trial) to predict (y_trial) with trial cross-validation. 
%--------------------------------------------------------------------------
% x_trial:     Feature matrix N_features x N_trials x N_time
% y_trial:     Feature matrix N_neurons x N_trials x N_time
% neurons:     empty ([]) vector for all the neurons, or a vector list of the neurons to compute the encoder
% optionsTree:       
%              featureAll     = 1, to get the feature importance for the full model (all trials used)
%              featureCross   = 1, to get the feature importance for each N Fold cross-valdation set
%              verbose        = 1, show partial results 
%              nFold          = How many sets of training-test
%              minLeaf        = minLeaf parameter of the bagging trees
%              storeTree      = store a compact version of the tree (only the full model)
%              zscore         = 1, Z-score x and y
%              save           = 'none'               : no saving
%                             = 'all'                : saves all the results structure
%                             = 'perNeuron'          : saves a different file per neuron (if trees are stored, it will save them too, otherwise no tree will be saved) 
%                             = 'perNeuronAndTree'   : same as perNeuron but will save tree (whether or not storeTree is = 1)
%                             = 'separateTree'       : saves a different file per neuron with predictions and another file only the tree
%                             = 'separateAllNeuronTree' : saves in a file all the results for all the neurons in one file except the trees that each one is saved in separate files
%                             = 'onlyTree'              : only saves the tree
%              path           = The path to save the results
%              baseFilename   = The name shared by all the files
%
% results:
%          features.all
%          features.cross
%          y_predict
%          y_predict_trial
%          y_zscore_predict
%          y_zscore_predict_trial
%          bagTree
%          parameters
% TO ADD: 
%         - Trial and time- shuffled controls on the calcium signal. (this should not be in this script)
%
%%


N_neurons = size(y_trial,1);
N_trial   = size(x_trial,2);
N_time    = size(x_trial,3);
N_feat    = size(x_trial,1);
[x_train y_train] = getTrainingFormat(x_trial,y_trial,[]);
if isempty (neurons)
    N     = N_neurons;
    listN = [1:N];
else
    N     = length(neurons);
    listN = neurons;    
end

y_predict       = zeros(N_trial*N_time,N);
y_predict_trial = zeros(N,N_trial,N_time);
categoricalVars = find(type==1);
if optionsTree.zscore == 1   % Standarize values. Here I standarize even the categorical vales, but then for the tree we leave them as they are
%     results.zscore.x.mean = nanmean(x_train,2);
%     results.zscore.x.std  = nanstd(x_train,2);
%     results.zscore.y.mean = nanmean(y_train,2);
%     results.zscore.y.std  = nanstd(y_train,2); 
    % We re-name x_train and y_train
    [xz_train results.zscore.x.mean results.zscore.x.std  ] = zscoreNaN(x_train);
    [yz_train results.zscore.y.mean results.zscore.y.std ]  = zscoreNaN(y_train);
    xz_train(:,categoricalVars) = x_train(:,categoricalVars);     % Categorical variables are not z-scored
    % Reshape in trial format
    xz_trial = permute(reshape(xz_train',N_feat,N_time,N_trial),[1 3 2]);
    yz_trial = permute(reshape(yz_train',N_neurons,N_time,N_trial),[1 3 2]);
    
end


if optionsTree.featuresAll == 1;    % For the tree with all the data
    results.features.all  = zeros(N_feat,N);
end
if optionsTree.featuresCross == 1;  % For cross-validation (partial training data), so for each fold we will get different features importances
    results.features.cross  = zeros(optionsTree.nFold,N_feat,N);
end

[testTrials trainingTrials] = nFoldCrossValidation(N_trial,optionsTree.nFold);
results.parameters.neuronsList = listN;
results.parameters.nNeurons    = N;
results.parameters.nTrials     = N_trial;
results.parameters.nTime       = N_time;
results.parameters.nFeatures   = N_feat;
results.parameters.testTrials  = testTrials;
results.parameters.trainingTrials  = trainingTrials;
results.parameters.optionsTree     = optionsTree;

statset('TreeBagger');
options = statset('UseParallel','always');
for i=1:N,
    actualNeuron = listN(i);
    if optionsTree.verbose == 1
        disp(sprintf('%s%s%d',optionsTree.textVerbose,'   ---  Neuron: ',listN(i)));
    end
    for j=1:optionsTree.nFold,
        % Training set
        if optionsTree.zscore == 1
            [x_subset_train y_subset_train] = getTrainingFormat(xz_trial,yz_trial,trainingTrials{j});            
            aux_x                           = xz_trial(:,testTrials{j},:);
        else
            [x_subset_train y_subset_train] = getTrainingFormat(x_trial,y_trial,trainingTrials{j});
            aux_x                           = x_trial(:,testTrials{j},:);
        end
        varY                            = y_subset_train(:,actualNeuron); % The particular neuron to fit
        x_subset_test                   = reshape(permute(aux_x,[1 3 2]),size(aux_x,1),[])';

        if optionsTree.featuresCross == 1   % Get the feature Importance for each of the cross-validations
            bagTree                       = TreeBagger(optionsTree.N_bagging,x_subset_train,varY,'method','r','oobvarimp','on','cat',find(type==1),'minleaf',optionsTree.minLeaf,'Options',options);
            results.features.cross(j,:,i) = bagTree.OOBPermutedVarDeltaError;
        else
            bagTree        = TreeBagger(optionsTree.N_bagging,x_subset_train,varY,'method','r','cat',find(type==1),'minleaf',optionsTree.minLeaf,'Options',options);
        end
        % Test set
        aux_pred                           = predict (bagTree,x_subset_test);   % Prediction for test trials (never seen by the trees before)
        y_predict_trial(i,testTrials{j},:) = reshape(aux_pred,N_time,[])';  

    end
    if (optionsTree.storeTree == 1 || optionsTree.featuresAll == 1 || strcmp(optionsTree.save,'separateTree') || strcmp(optionsTree.save,'separateAllNeuronTree') || strcmp(optionsTree.save,'perNeuronAndTree') || strcmp(optionsTree.save,'onlyTree') )
        % We have to train the Tree with all the trials
        if optionsTree.featuresAll == 1
            if optionsTree.zscore == 1
                varY                       = yz_train(:,actualNeuron); % The particular neuron to fit
                bagTree                    = TreeBagger(optionsTree.N_bagging,xz_train,varY,'method','r','oobvarimp','on','cat',find(type==1),'minleaf',optionsTree.minLeaf,'Options',options);
            else
                varY                       = y_train(:,actualNeuron); % The particular neuron to fit
                bagTree                    = TreeBagger(optionsTree.N_bagging,x_train,varY,'method','r','oobvarimp','on','cat',find(type==1),'minleaf',optionsTree.minLeaf,'Options',options);
            end
            results.features.all(:,i)     = bagTree.OOBPermutedVarDeltaError;
        else  % Only to store the tree (but using all the trials)
            if optionsTree.zscore == 1
                varY            = yz_train(:,actualNeuron); % The particular neuron to fit
                bagTree         = TreeBagger(optionsTree.N_bagging,xz_train,varY,'method','r','cat',find(type==1),'minleaf',optionsTree.minLeaf,'Options',options);
            else
                varY           = y_train(:,actualNeuron); % The particular neuron to fit
                bagTree        = TreeBagger(optionsTree.N_bagging,x_train,varY,'method','r','cat',find(type==1),'minleaf',optionsTree.minLeaf,'Options',options);
            end
        end
        if optionsTree.storeTree == 1
            results.bagTree{i} = compact(bagTree);
        end
       
    end
 
    if optionsTree.verbose == 1
        auxy            = reshape(permute(y_predict_trial,[1 3 2]),size(y_predict_trial,1),[])';  % Future: change so only the actual neuron is taken
        % Get y_predict in training format ( (Ntrials * NTime), neurons)
        y_predict(:,i)  = auxy(:,i);
        if optionsTree.zscore == 1
            varY            = yz_train(:,actualNeuron);
        else
            varY            = y_train(:,actualNeuron);
        end
        R               = corr(varY(find(~isnan(varY))),y_predict(find(~isnan(varY)),i));
        disp (sprintf('%s%.2f\n','  R: ',R));
    end
    if strcmp(optionsTree.save, 'perNeuron') || strcmp(optionsTree.save, 'separateTree') || strcmp(optionsTree.save, 'perNeuronAndTree')
        saveRFPerNeuron(results,i,actualNeuron,y_predict,y_predict_trial,compact(bagTree),optionsTree); % bagTree is valid only if 'separateTree', 'separateNeuronTree' or 'perNeuron' with storeTrees=1;
    elseif ( strcmp(optionsTree.save, 'separateAllNeuronTree') || strcmp(optionsTree.save, 'onlyTree') ) 
        % Here only save trees in separate files, then save everything except trees at the end
        fileName = sprintf('%s%s%s%.3d',optionsTree.path,optionsTree.baseFilename,'_onlyTree_',actualNeuron);
        randomForest = compact(bagTree);
        save (fileName,'randomForest');
    end
end

if optionsTree.verbose == 0
    y_predict = reshape(permute(y_predict_trial,[1 3 2]),size(y_predict_trial,1),[])'; 
end

if optionsTree.zscore == 1
    results.y_zscore_predict       = y_predict;
    results.y_zscore_predict_trial = y_predict_trial;
    % In y_predict it is the real 'y', not the normalized. 
    results.y_predict              = y_predict .* repmat(results.zscore.y.std(listN),size(y_predict,1),1) + repmat(results.zscore.y.mean(listN),size(y_predict,1),1); 
    results.y_predict_trial        = permute(reshape(results.y_predict',N,N_time,N_trial),[1 3 2]);
else
    results.y_predict       = y_predict;
    results.y_predict_trial = y_predict_trial;
end

if strcmp(optionsTree.save,'all')
    fileName = sprintf('%s%s',optionsTree.path,optionsTree.baseFilename);
    save (fileName,'results');
elseif strcmp(optionsTree.save, 'separateAllNeuronTree')
    if optionsTree.storeTree == 1  % the trees are stored in results...
        resultOrig = results;
        rmfield (results,'bagTree');
        fileName = sprintf('%s%s%s',optionsTree.path,optionsTree.baseFilename,'_allNeurons');
        save (fileName,'results');
        results = resultOrig;  % Restore the name results to be returned
    else
        fileName = sprintf('%s%s%s',optionsTree.path,optionsTree.baseFilename,'_allNeurons');
        save (fileName,'results');
    end
end
