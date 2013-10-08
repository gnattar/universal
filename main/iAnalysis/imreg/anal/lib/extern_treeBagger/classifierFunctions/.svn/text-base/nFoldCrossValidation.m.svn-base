function [testTrials trainingTrials] = nFoldCrossValidation (N_trial,nFold)
%%
%--------------------------------------------------------------------------
%
% Goal : to obtain a set of trials for training a classifier and a non-overlapping set of trials to test its performance (i.e. generalization) 
%--------------------------------------------------------------------------
% N_trial:     Number of trials
% nFold:       The number of groups that the trials will be divided. All the groups except one are using for training and the remaining for test
%%
fractionValidate = 1/nFold;
allTrials = randperm(N_trial);
NTrialsPerValidate = floor (fractionValidate *N_trial);
testTrials = cell(nFold,1);
trainingTrials = cell(nFold,1);
for i=1:nFold,
    if i==nFold
        testTrials{i} = allTrials([(i-1)*NTrialsPerValidate+1:N_trial]);
    else
        testTrials{i} = allTrials([(i-1)*NTrialsPerValidate+1:i*NTrialsPerValidate]);
    end
    trainingTrials{i} = setdiff(allTrials,testTrials{i});
end
