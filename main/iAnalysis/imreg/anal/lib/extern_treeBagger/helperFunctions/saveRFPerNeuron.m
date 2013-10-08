function saveRFPerNeuron (resultOrig,idx,actualNeuron,y_predict,y_predict_trial,bagTree,optionsTree)
%%
%    Goal :            to Save the results of the RF in separate files per neuron (with separation or not of trees)
%%

results.parameters = resultOrig.parameters;
if optionsTree.zscore == 1 
    results.zscore.x.mean = resultsOrig.zscore.x.mean; 
    results.zscore.x.std  = resultsOrig.zscore.x.std;
    % for the calcium (i.e. y) only save the current neuron if save = 'perNeuron' or 'perNeuronAndTree' or 'separateTree' (that is always the case when this function is
    % called)
    results.zscore.y.mean = resultsOrig.zscore.y.mean(actualNeuron);
    results.zscore.y.std  = resultsOrig.zscore.y.std(actualNeuron);
    results.y_zscore_predict       = y_predict(:,idx);
    results.y_zscore_predict_trial = squeeze(y_predict_trial(idx,:,:));
    results.y_predict              = y_predict(:,idx) * results.zscore.y.std + results.zscore.y.mean; 
    results.y_predict_trial        = reshape (results.y_predict,results.parameters.nTime,results.parameters.nTrials)';
else
    results.y_predict       = y_predict(:,idx);
    results.y_predict_trial = squeeze(y_predict_trial(idx,:,:));
end
if strcmp(optionsTree.save,'perNeuron')
    if optionsTree.storeTree == 1
        results.bagTree = resultOrig.bagTree{idx};
    end
elseif strcmp(optionsTree.save,'perNeuronAndTree')
    results.bagTree = bagTree;
else
    % it is separateTree, so we save the tree in another file. The tree could or could NOT be stored in results
    fileName = sprintf('%s%s%s%.3d',optionsTree.path,optionsTree.baseFilename,'_onlyTree_',actualNeuron);
    randomForest = bagTree; % Already compacted
    save (fileName,'randomForest');
end
if optionsTree.featuresCross == 1
    results.features.cross   = squeeze(resultsOrig.features.cross(:,:,idx));
end
if optionsTree.featuresAll == 1
    results.features.all    = squeeze(resultsOrig.features.all(:,idx));
end
fileName = sprintf('%s%s%s%.3d',optionsTree.path,optionsTree.baseFilename,'_neuron_',actualNeuron);
save (fileName,'results');

