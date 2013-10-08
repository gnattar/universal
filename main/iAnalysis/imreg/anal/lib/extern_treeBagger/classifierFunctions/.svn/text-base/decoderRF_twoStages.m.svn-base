function results = decoderRF_twoStages (x_trial,y_trial,type,names_x,names_y,orig_names_y,featureList,neurons,N_shifts,shiftsPerFeature,optionsTree,weight)
%%
%--------------------------------------------------------------------------
%
% Goal : to train a random forest with features (y_trial : calcium data) to predict (x_trial, features) with trial cross-validation. 
%        it can compute the decoder for a population of neurons, or for single neurons
%--------------------------------------------------------------------------
% x_trial:     Feature matrix N_features x N_trials x N_time (the original one)
% y_trial:     Feature matrix (N_neurons x N_shifts) x N_trials x N_time. y_trial has all the possible shifts. Each feature will use a subset
% names_x:     Names of the variables in x_trial (N_features)
% names_y:     Names of the variables y_trial (e.g. 'Cell_001', 'Cell_023_N_Shift_2', 'Cell_023_P_Shift_1' )
% featureList: Names of features to perform the decoder
% type:        For variables with type = 1, we perform classification instead of regression. TODO: Option to balance the number of trials
% neurons:     empty ([]) vector for all the neurons, or a vector list of the neurons to compute the decoder
% N_shifts:    Number of shifts for the calcium data
% shiftsPerFeature: Each feature can use different shifts (0, negative, positives). It is an array of size featureList, with the vector of shifts
%                   per Feature
% optionsTree:       
%              featureAll     = 1, to get the feature importance for the full model (all trials used)
%              featureCross   = 1, to get the feature importance for each N Fold cross-valdation set
%              verbose        = 1, show partial results 
%              nFold          = How many sets of training-test
%              minLeaf        = minLeaf parameter of the bagging trees
%              storeTree      = store a compact version of the tree (only the full model)
%              zscore         = 1, Z-score x and y
%              saveDecoderSingle  = 'none'               : no saving
%                                    = 'all'             : saves all the results structure per Neuron
%                                                           NOTE: No saving for all the neurons (results(i) ) that has to be done out of this function
%                                    = 'onlyTree'        : one tree for each feature.
%                                    = 'allTree'         : one file with the trees of all the features
%                                    = 'separateTree'    : one file for the predictions, one file per each feature for the trees
%                                    = 'separateAllTree' : one file for the predictions, one file for the trees of ALL the feature 
%                                       
%              saveDecoderPopulation = 'none'
%                                    = 'all'
%                                    = 'onlyTree'        : one tree for each feature.
%                                    = 'allTree'         : one file with the trees of all the features
%                                    = 'separateTree'    : one file for the predictions, one file per each feature for the trees
%                                    = 'separateAllTree' : one file for the predictions, one file for the trees of ALL the feature 
%              path           = The path to save the results
%              baseFilename   = The name shared by all the files
%              decodePopulation = 1, it uses all the neurons (in the variable 'neurons') to decode each feature
%                               = 0, it decodes one neuron at a time
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

%
%%


N_neurons = size(y_trial,1)/N_shifts;
N_trial   = size(x_trial,2);
N_time    = size(x_trial,3);
N_feat    = size(x_trial,1);
N_decodeFeat = length(featureList);            % Number of features that will be decoded
N_shiftsPerFeature = zeros(N_decodeFeat,1);    % Number of shifts in each feature
N_dim     = size(y_trial,1);
for i=1:N_decodeFeat
    N_shiftsPerFeature(i) = length(shiftsPerFeature{i});
end

% Make the list of neurons
if isempty (neurons)
    N     = N_neurons;    % Number of neurons
    listN = [1:N];        % All the neurons
else
    N     = length(neurons);
    listN = neurons;    
end
N_totalDimensionsCalcium = N*N_shiftsPerFeature;    % Total number of variables that will be taken for y_trial (in the case of population decoder)


list_feat = zeros(1,N_decodeFeat); % The List of indices to 'x' corresponding to the list of features to decode
for i=1:N_decodeFeat,
    list_feat(i) = find (ismember(names_x,featureList{i}));
end



y_predict       = zeros(N_trial*N_time,N_decodeFeat);
y_predict_trial = zeros(N_decodeFeat,N_trial,N_time);
categoricalVars = find(type==1);
[x_train y_train] = getTrainingFormat(x_trial,y_trial,[]);
if optionsTree.zscore == 1   % Standarize values. Here I standarize even the categorical vales, but then for the tree we leave them as they are
    % We re-name x_train and y_train
    [xz_train results.zscore.x.mean results.zscore.x.std  ] = zscoreNaN(x_train);
    [yz_train results.zscore.y.mean results.zscore.y.std ]  = zscoreNaN(y_train);
    xz_train(:,categoricalVars) = x_train(:,categoricalVars);     % Categorical variables are not z-scored
    results.zscore.x.mean(categoricalVars) = 0;
    results.zscore.x.std(categoricalVars)  = 1;    
    % Reshape in trial format
    xz_trial = permute(reshape(xz_train',N_feat,N_time,N_trial),[1 3 2]);
    yz_trial = permute(reshape(yz_train',N_dim,N_time,N_trial),[1 3 2]);
    
end



[testTrials trainingTrials] = nFoldCrossValidation(N_trial,optionsTree.nFold);

statset('TreeBagger');
options = statset('UseParallel','always');

if optionsTree.decodePopulation == 1    % Here there is only one features.all/cross, with the number of features being the shifts x N_neurons
    if optionsTree.featuresAll == 1;    % For the tree with all the data
        results.population.features.all  = cell(N_decodeFeat,1); % each one with a vector of dim totalDimensionCalcium(fIdx) 
    end
    if optionsTree.featuresCross == 1;  % For cross-validation (partial training data), so for each fold we will get different features importances
        results.population.features.cross  = cell(N_decodeFeat,1); % each with a matrix of nFold  X N_totalDimensionsCalcium(fIdx);
    end
end

if isempty(weight)
    weight = ones(N_trial*N_time,N_decodeFeat);
end


%% run the decoder for each feature
indexNeurons = cell(N_decodeFeat,1);  % Pointers to the y_trial per each Neuron (used for single neuron decoder)
vecNeurons   = cell(N_decodeFeat,1);  % Pointers to the y_trial for all the neurons (used for the population decoder)

x_predict_trial = zeros(N_decodeFeat,N_trial,N_time);
x_predict       = zeros(N_trial*N_time,N_decodeFeat);

for fIdx = 1:N_decodeFeat,
    % Find the indices in y_trial to use for the actual feature 
   
    vecShift           = shiftsPerFeature{fIdx}; %Each feature has its own list of shifts (in the calcium data)
    vecN               = length(vecShift);
    indexNeurons{fIdx} = zeros(N,vecN);    % N_neurons x N_shifts of the fIdx feature
    vecNeurons{fIdx}   = zeros(N*vecN,1);
    cont = 0;
    for shIdx = 1:vecN,
        
        for nIdx = 1:N,
            
            if vecShift(shIdx) == 0
                aux_name =  orig_names_y{listN(nIdx)};  % This is the convention, keep it like this when decoderRF is called
            elseif vecShift(shIdx) < 0  % Negative shifts
                aux_name =  sprintf('%s%s%d',orig_names_y{listN(nIdx)},'_N_Shift_',abs(vecShift(shIdx)));  
            else                        % Postive shifts
                aux_name =  sprintf('%s%s%d',orig_names_y{listN(nIdx)},'_P_Shift_',abs(vecShift(shIdx)));  
            end
            indexNeurons{fIdx}(nIdx,shIdx) = find(ismember(names_y,aux_name));
            cont = cont + 1;
            vecNeurons{fIdx}(cont)         = indexNeurons{fIdx}(nIdx,shIdx);
            vecNeuronsName{fIdx}{cont}     = aux_name;
        end
    end
end

%%

%----------------------------------------------------------------------------------------------------------------------------
%   Decoder Population
%----------------------------------------------------------------------------------------------------------------------------
% NOTE:   We keep calling Y to calcium data and X to features. As this is the decoder script, the indepedent variables are Y (calcium) and the
%         dependet ones are the X. 
% Decode fIdx with all the cells in variable 'neurons'

if optionsTree.decodePopulation == 1
    results.parameters.neuronsList = listN;
    results.parameters.nNeurons    = N;
    results.parameters.nTrials     = N_trial;
    results.parameters.nTime       = N_time;
    results.parameters.nFeatures   = N_feat;
    results.parameters.testTrials  = testTrials;
    results.parameters.trainingTrials  = trainingTrials;
    results.parameters.optionsTree     = optionsTree;

    for fIdx = 1:N_decodeFeat,
        if type(list_feat(fIdx)) == 1
                typeTree = 'classification';
                optionsTree.minLeaf = optionsTree.minLeafClassifier;
        else
                typeTree = 'regression';
                optionsTree.minLeaf = optionsTree.minLeafRegression;
        end
        if optionsTree.verbose == 1
            disp(sprintf('%s%s%s%s',optionsTree.textVerbose,'  --- Feature: ',featureList{fIdx} ,'   ---  Neuron:  Population   '));
        end

        for j=1:optionsTree.nFold,
        % Training set
            if optionsTree.zscore == 1
                [x_subset_train y_subset_train] = getTrainingFormat(xz_trial,yz_trial,trainingTrials{j});   
                [x_subset_test  y_subset_test]  = getTrainingFormat(xz_trial,yz_trial,testTrials{j});   
            else
                [x_subset_train y_subset_train] = getTrainingFormat(x_trial,y_trial,trainingTrials{j});
                [x_subset_test  y_subset_test]  = getTrainingFormat(x_trial,y_trial,testTrials{j});   
            end
            varX                            = x_subset_train(:,list_feat(fIdx));       % The feature (i.e. lick-rate, setpoint)
            varY                            = y_subset_train(:,vecNeurons{fIdx});  % The population of neurons to be used
            testY                           = y_subset_test(:,vecNeurons{fIdx}); 
            auxW                            = reshape(weight(:,list_feat(fIdx)),N_time,[])';
            subsetWeight                    = reshape(auxW(trainingTrials{j},:)',[],1);                
            if optionsTree.featuresCross == 1   % Get the feature Importance for each of the cross-validations                
                bagTree                          = TreeBagger(optionsTree.N_bagging,varY,varX,'method',typeTree,'oobvarimp','on','minleaf',optionsTree.minLeaf,'Options',options,'weight',subsetWeight);
                results.population.features.cross{fIdx}(j,:) = bagTree.OOBPermutedVarDeltaError;
            else
                bagTree                       = TreeBagger(optionsTree.N_bagging,varY,varX,'method',typeTree,'minleaf',optionsTree.minLeaf,'Options',options,'weight',subsetWeight);
            end
            % Test set
            if strcmp(typeTree,'regression')
                aux_pred                              = predict (bagTree,testY);   % Prediction for test trials (never seen by the trees before)
            else
                aux_pred                              = str2num(char(predict(bagTree,testY)));  % Here we assume categories are numeric
            end
            x_predict_trial(fIdx,testTrials{j},:) = reshape(aux_pred,N_time,[])';  
        end
        if (optionsTree.storeTree == 1 || optionsTree.featuresAll == 1 || strcmp(optionsTree.saveDecoderPopulation,'separateTree') || strcmp(optionsTree.saveDecoderPopulation,'separateAllTree') || strcmp(optionsTree.saveDecoderPopulation,'allTree') || strcmp(optionsTree.saveDecoderPopulation,'onlyTree') )
            % We have to train the Tree with all the trials
            if optionsTree.featuresAll == 1
                if optionsTree.zscore == 1
                    varY                       = yz_train(:,vecNeurons{fIdx}); % The particular neuron to fit
                    bagTree                    = TreeBagger(optionsTree.N_bagging,varY,xz_train(:,list_feat(fIdx)),'method',typeTree,'oobvarimp','on','minleaf',optionsTree.minLeaf,'Options',options,'weight',weight(:,list_feat(fIdx)));
                else
                    varY                       = y_train(:,vecNeurons{fIdx}); % The particular neuron to fit
                    bagTree                    = TreeBagger(optionsTree.N_bagging,varY,x_train(:,list_feat(fIdx)),'method',typeTree,'oobvarimp','on','minleaf',optionsTree.minLeaf,'Options',options,'weight',weight(:,list_feat(fIdx)));
                end
                results.population.features.all{fIdx}     = bagTree.OOBPermutedVarDeltaError;
            else  % Only to store the tree (but using all the trials)
                if optionsTree.zscore == 1
                    varY            = yz_train(:,vecNeurons{fIdx}); % The particular neuron to fit
                    bagTree         = TreeBagger(optionsTree.N_bagging,varY,xz_train(:,list_feat(fIdx)),'method',typeTree,'minleaf',optionsTree.minLeaf,'Options',options,'weight',weight(:,list_feat(fIdx)));
                else
                    varY           = y_train(:,vecNeurons{fIdx}); % The particular neuron to fit
                    bagTree        = TreeBagger(optionsTree.N_bagging,varY,x_train(:,list_feat(fIdx)),'method',typeTree,'minleaf',optionsTree.minLeaf,'Options',options,'weight',weight(:,list_feat(fIdx)));
                end
            end
            if optionsTree.storeTree == 1 || strcmp(optionsTree.saveDecoderPopulation,'allTree') || strcmp(optionsTree.saveDecoderPopulation,'separateAllTree') 
                results.population.bagTree{fIdx} = compact(bagTree);
            end
        end
        if optionsTree.verbose == 1
            x_predict(:,fIdx)  = reshape(squeeze(x_predict_trial(fIdx,:,:))',[],1); 
            if optionsTree.zscore == 1
                varX            = xz_train(:,list_feat(fIdx));
            else
                varX            = x_train(:,list_feat(fIdx));
            end
            if strcmp(typeTree,'regression');
                R               = corr(varX(find(~isnan(varX))),x_predict(find(~isnan(varX)),fIdx));
                disp (sprintf('%s%.2f\n','  R: ',R));
            else   % It is categorical -> measure of classification error
                category     = categoryError (varX,x_predict(:,fIdx));
                aux = sprintf('%s','Classification : --- ');
                for cat = 1:category.N,
                    aux = sprintf ('%s%s%d%s%.2f%s%d%s%d%s',aux,'Class: ',category.names(cat),'  ',100*category.percentage.correct(cat),' %  ', category.count.model(cat),' / ',category.count.data(cat),'   ----  ');
                end
                aux = sprintf('%s%s%.2f\n',aux,'---   Total Correct: ',100*category.percentage.correctTotal);
                disp (aux);
            end
        end
        
        if ( strcmp(optionsTree.saveDecoderPopulation, 'separateTree') || strcmp(optionsTree.saveDecoderPopulation, 'onlyTree') ) 
            % Here only save trees in separate files, then save everything except trees at the end
            fileName = sprintf('%s%s%s%s',optionsTree.path,optionsTree.baseFilename,'_onlyTree_',featureList{fIdx});
            randomForest = compact(bagTree);
            save (fileName,'randomForest');
        end
    end
    if optionsTree.verbose == 0
        x_predict = reshape(permute(x_predict_trial,[1 3 2]),size(x_predict_trial,1),[])'; 
    end

    if optionsTree.zscore == 1
        results.population.x_zscore_predict       = x_predict;
        results.population.x_zscore_predict_trial = x_predict_trial;
        % In y_predict it is the real 'y', not the normalized. 
        results.population.x_predict              = x_predict .* repmat(results.zscore.x.std(list_feat),size(x_predict,1),1) + repmat(results.zscore.x.mean(list_feat),size(x_predict,1),1); 
        results.population.x_predict_trial        = permute(reshape(results.population.x_predict',N_decodeFeat,N_time,N_trial),[1 3 2]);
    else
        results.population.x_predict       = x_predict;
        results.population.x_predict_trial = x_predict_trial;
    end
end

%%
%---------------------------------------------------------------------------------------------------------
% Single Neuron Decoder       
%-----------------------------------------------------------------------------------------------------------------
if optionsTree.decodePopulation == 0
    for nIdx = 1:N,
        actualNeuron = listN(nIdx);
        x_predict_trial = zeros(N_decodeFeat,N_trial,N_time);
        x_predict       = zeros(N_trial*N_time,N_decodeFeat);
        for fIdx = 1:N_decodeFeat, 
            if type(list_feat(fIdx)) == 1
                typeTree = 'classification';
                optionsTree.minLeaf = optionsTree.minLeafClassifier;
            else
                typeTree = 'regression';
                optionsTree.minLeaf = optionsTree.minLeafRegression;
            end
            if optionsTree.verbose == 1
                disp(sprintf('%s%s%s%s%d',optionsTree.textVerbose,'  --- Feature: ',featureList{fIdx} ,'   ---  Neuron:   ',actualNeuron));
            end

            for j=1:optionsTree.nFold,
            % Training set
                if optionsTree.zscore == 1
                    [x_subset_train y_subset_train] = getTrainingFormat(xz_trial,yz_trial,trainingTrials{j});   
                    [x_subset_test  y_subset_test]  = getTrainingFormat(xz_trial,yz_trial,testTrials{j});   
                else
                    [x_subset_train y_subset_train] = getTrainingFormat(x_trial,y_trial,trainingTrials{j});
                    [x_subset_test  y_subset_test]  = getTrainingFormat(x_trial,y_trial,testTrials{j});   
                end
                varX                            = x_subset_train(:,list_feat(fIdx));       % The feature (i.e. lick-rate, setpoint)
                varY                            = y_subset_train(:,indexNeurons{fIdx}(nIdx,:)); % The neuron (and its shifted versions) to be used
                testY                           = y_subset_test(:,indexNeurons{fIdx}(nIdx,:));            
                auxW                            = reshape(weight(:,list_feat(fIdx)),N_time,[])';
                subsetWeight                    = reshape(auxW(trainingTrials{j},:)',[],1);                

                if optionsTree.featuresCross == 1   % Get the feature Importance for each of the cross-validations                
                    bagTree                          = TreeBagger(optionsTree.N_bagging,varY,varX,'method',typeTree,'oobvarimp','on','minleaf',optionsTree.minLeaf,'Options',options,'weight',subsetWeight);
                    resultsTMP(nIdx).singleNeuron.features.cross{fIdx}(j,:) = bagTree.OOBPermutedVarDeltaError;
                else
                    bagTree                       = TreeBagger(optionsTree.N_bagging,varY,varX,'method',typeTree,'minleaf',optionsTree.minLeaf,'Options',options,'weight',subsetWeight);
                end
                % Test set
                if strcmp(typeTree,'regression')
                    aux_pred                              = predict (bagTree,testY);   % Prediction for test trials (never seen by the trees before)
                else
                    aux_pred                              = str2num(char(predict (bagTree,testY)));   % Prediction for test trials (never seen by the trees before)                    
                end
                x_predict_trial(fIdx,testTrials{j},:) = reshape(aux_pred,N_time,[])';  
            end     % End cross-validation
            if (optionsTree.storeTree == 1 || optionsTree.featuresAll == 1 || strcmp(optionsTree.saveDecoderSingle,'separateTree') || strcmp(optionsTree.saveDecoderSingle,'separateAllTree') || strcmp(optionsTree.saveDecoderSingle,'allTree') || strcmp(optionsTree.saveDecoderSingle,'onlyTree') )
                % We have to train the Tree with all the trials
                if optionsTree.featuresAll == 1
                    if optionsTree.zscore == 1
                        varY                       = yz_train(:,indexNeurons{fIdx}(nIdx,:)); % The particular neuron to fit
                        bagTree                    = TreeBagger(optionsTree.N_bagging,varY,xz_train(:,list_feat(fIdx)),'method',typeTree,'oobvarimp','on','minleaf',optionsTree.minLeaf,'Options',options,'weight',weight(:,list_feat(fIdx)));
                    else
                        varY                       = y_train(:,indexNeurons{fIdx}(nIdx,:)); % The particular neuron to fit
                        bagTree                    = TreeBagger(optionsTree.N_bagging,varY,x_train(:,list_feat(fIdx)),'method',typeTree,'oobvarimp','on','minleaf',optionsTree.minLeaf,'Options',options,'weight',weight(:,list_feat(fIdx)));
                    end
                    resultsTMP(nIdx).singleNeuron.features.all{fIdx}       = bagTree.OOBPermutedVarDeltaError;
                else  % Only to store the tree (but using all the trials)
                    if optionsTree.zscore == 1
                        varY            = yz_train(:,indexNeurons{fIdx}(nIdx,:)); % The particular neuron to fit
                        bagTree         = TreeBagger(optionsTree.N_bagging,varY,xz_train(:,list_feat(fIdx)),'method',typeTree,'minleaf',optionsTree.minLeaf,'Options',options,'weight',weight(:,list_feat(fIdx)));
                    else
                        varY           = y_train(:,indexNeurons{fIdx}(nIdx,:)); % The particular neuron to fit
                        bagTree        = TreeBagger(optionsTree.N_bagging,varY,x_train(:,list_feat(fIdx)),'method',typeTree,'minleaf',optionsTree.minLeaf,'Options',options,'weight',weight(trainingTrials{j},list_feat(fIdx)));
                    end
                end
                if optionsTree.storeTree == 1 || strcmp(optionsTree.saveDecoderSingle,'allTree') || strcmp(optionsTree.saveDecoderSingle,'separateAllTree') 
                    resultsTMP(nIdx).singleNeuron.bagTree{fIdx} = compact(bagTree);
                end
            end
            if optionsTree.verbose == 1
                x_predict(:,fIdx)  = reshape(squeeze(x_predict_trial(fIdx,:,:))',[],1); 
                if optionsTree.zscore == 1
                    varX            = xz_train(:,list_feat(fIdx));
                else
                    varX            = x_train(:,list_feat(fIdx));
                end
                if strcmp(typeTree,'regression');
                    R               = corr(varX(find(~isnan(varX))),x_predict(find(~isnan(varX)),fIdx));
                    disp (sprintf('%s%.2f\n','  R: ',R));
                else   % It is categorical -> measure of classification error
                    category     = categoryError (varX,x_predict(:,fIdx));
                    aux = sprintf('%s','Classification : --- ');
                    for cat = 1:category.N,
                        aux = sprintf ('%s%s%d%s%.2f%s%d%s%d%s',aux,'Class: ',category.names(cat),'  ',100*category.percentage.correct(cat),' %  ', category.count.model(cat),' / ',category.count.data(cat),'   ----  ');
                    end
                    aux = sprintf('%s%s%.2f\n',aux,'---   Total Correct: ',100*category.percentage.correctTotal);
                    disp (aux);
                end
            end

            if ( strcmp(optionsTree.saveDecoderSingle, 'separateTree') || strcmp(optionsTree.saveDecoderSingle, 'onlyTree') ) 
                % Here only save trees in separate files, then save everything except trees at the end
                fileName = sprintf('%s%s%s%.3d%s%s',optionsTree.path,optionsTree.baseFilename,'_neuron_',actualNeuron,'_onlyTree_',featureList{fIdx});  % It saves trees per each feature
                randomForest = compact(bagTree);
                save (fileName,'randomForest');
            end
        end  % End feature
        if optionsTree.verbose == 0
            x_predict = reshape(permute(x_predict_trial,[1 3 2]),size(x_predict_trial,1),[])'; 
        end

        if optionsTree.zscore == 1
            resultsTMP(nIdx).singleNeuron.x_zscore_predict       = x_predict;
            resultsTMP(nIdx).singleNeuron.x_zscore_predict_trial = x_predict_trial;
            % In y_predict it is the real 'y', not the normalized. 
            resultsTMP(nIdx).singleNeuron.x_predict              = x_predict .* repmat(results.zscore.x.std(list_feat),size(x_predict,1),1) + repmat(results.zscore.x.mean(list_feat),size(x_predict,1),1); 
            resultsTMP(nIdx).singleNeuron.x_predict_trial        = permute(reshape(resultsTMP(nIdx).singleNeuron.x_predict',N_decodeFeat,N_time,N_trial),[1 3 2]);
        else
            resultsTMP(nIdx).singleNeuron.x_predict       = x_predict;
            resultsTMP(nIdx).singleNeuron.x_predict_trial = x_predict_trial;
        end
        resultsTMP(nIdx).parameters.neuronsList = listN;
        resultsTMP(nIdx).parameters.nNeurons    = N;
        resultsTMP(nIdx).parameters.nTrials     = N_trial;
        resultsTMP(nIdx).parameters.nTime       = N_time;
        resultsTMP(nIdx).parameters.nFeatures   = N_feat;
        resultsTMP(nIdx).parameters.testTrials  = testTrials;
        resultsTMP(nIdx).parameters.trainingTrials  = trainingTrials;
        resultsTMP(nIdx).parameters.optionsTree     = optionsTree;

        resultsTMP(nIdx).parameters.decoder.pointerToNeuronsShiftsByFeature     = indexNeurons;
        resultsTMP(nIdx).parameters.decoder.pointerToNeuronsShiftsByFeatureVec  = vecNeurons;
        resultsTMP(nIdx).parameters.decoder.pointerToNeuronsName                = vecNeuronsName;
        resultsTMP(nIdx).parameters.listFeatures  = list_feat;
        if strcmp(optionsTree.saveDecoderSingle,'all')
            results = resultsTMP(nIdx);           % The actual neuron
            fileName = sprintf('%s%s%s%.3d',optionsTree.path,optionsTree.baseFilename,'_neuron_',actualNeuron);
            save (fileName,'results');
        end
        % Save the AllTree (for all the features). Remove the .bagTree if it corresponds
        if strcmp(optionsTree.saveDecoderSingle, 'separateAllTree') || strcmp(optionsTree.saveDecoderSingle, 'allTree') 
            randomForest = resultsTMP(nIdx).singleNeuron.bagTree; 
            if optionsTree.storeTree == 0
                resultsTMP(nIdx).singleNeuron = rmfield (resultsTMP(nIdx).singleNeuron,'bagTree');  % No bagtree is stored in results
            end
            fileName = sprintf('%s%s%s%.3d%s',optionsTree.path,optionsTree.baseFilename,'_neuron_',actualNeuron,'_AllTree');
            save (fileName,'randomForest');    
        end
        % Save the results without the trees, remove .bagTree if it existed
        if strcmp(optionsTree.saveDecoderSingle, 'separateTree') || strcmp(optionsTree.saveDecoderSingle, 'separateAllTree')
            results   = resultsTMP(nIdx);
            if optionsTree.storeTree == 1  % the trees are stored in resultsTMP...
                rmfield (results.singleNeuron,'bagTree');
            end
            fileName = sprintf('%s%s%s',optionsTree.path,optionsTree.baseFilename,'_neuron_',actualNeuron);
            save (fileName,'results');
        end

    end      % End neuron
    % If we trust matlab, this is a lazy assignation, so we are not copying the structure...
    results = resultsTMP;
    clear resultsTMP;

end          % End single Neuron
%-----------------------------------------------------------------------------------------------------------
%% Save Data

if optionsTree.decodePopulation == 1
    results.parameters.decoder.pointerToNeuronsShiftsByFeature     = indexNeurons;
    results.parameters.decoder.pointerToNeuronsShiftsByFeatureVec  = vecNeurons;
    results.parameters.decoder.pointerToNeuronsName                = vecNeuronsName;
    results.parameters.listFeatures  = list_feat;

    % Save All
    if strcmp(optionsTree.saveDecoderPopulation,'all') 
        fileName = sprintf('%s%s',optionsTree.path,optionsTree.baseFilename);
        save (fileName,'results');
    end
    % Save the AllTree (for all the features). Remove the .bagTree if it corresponds
    if strcmp(optionsTree.saveDecoderPopulation, 'separateAllTree') || strcmp(optionsTree.saveDecoderPopulation, 'allTree') 
        randomForest = results.population.bagTree; 
        if optionsTree.storeTree == 0
            results.population = rmfield (results.population,'bagTree');  % No bagtree is stored in results
        end
        fileName = sprintf('%s%s%s',optionsTree.path,optionsTree.baseFilename,'_AllTree');
        save (fileName,'randomForest');    
    end
    % Save the results without the trees, remove .bagTree if it existed
    if strcmp(optionsTree.saveDecoderPopulation, 'separateTree') || strcmp(optionsTree.saveDecoderPopulation, 'separateAllTree')
        if optionsTree.storeTree == 1  % the trees are stored in results...
            resultOrig = results;
            results = rmfield (results,'bagTree');
            fileName = sprintf('%s%s%s',optionsTree.path,optionsTree.baseFilename,'_population');
            save (fileName,'results');
            results = resultOrig;  % Restore the name results to be returned
        else
            fileName = sprintf('%s%s%s',optionsTree.path,optionsTree.baseFilename,'_population');
            save (fileName,'results');
        end
    end
end

