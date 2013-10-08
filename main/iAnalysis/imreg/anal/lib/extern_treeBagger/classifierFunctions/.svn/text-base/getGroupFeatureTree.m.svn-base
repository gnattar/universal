function results = getGroupFeatureTree(x,y,type,neurons,groups,whichGroups,optionsTree)
%%
%--------------------------------------------------------------------------
%
% Goal :  Run the bagging trees with a subset of the available features
% ----
%
%--------------------------------------------------------------------------
% x:               is the original N_var x N_trials x N_time indepedent variables
% y:               is the original N_var x N_trials x N_Neurons depedent variables (i.e. calcium traces)
% N_bagging:       number of trees to grow
% minLeaf:         minLeaf parameter for the trees
% groups:          an array of vector indices. groups{i} = [...] indicates for grouped variable 'i' (corresponding to groupNames) which features from the
%                  original x are included for that particular group. 
% whichGroups:     it is a vector that selects which one of the groups are going to be used as features. whichGroups = [3 6], will use the grouped variables 3
%                  and 6. Variables '3' and '6' are grouped so there will be more features than 2.
% storeTrees:      whether to store (=1) the trees in the results structure
% results:         the structure results that is returned by the encoding algorithm


%%
% Count number of grouped variables selected
N_groups = length (whichGroups);
cont = 0;
% Count the total number of variables. 
for i = 1:N_groups,
    cont = cont + length(groups{whichGroups(i)});
end
N_Var = cont;
% create a new variable
x2     = zeros(N_Var,size(x,2),size(x,3));
type2  = zeros(N_Var,1);
start  = 1;
for i=1:N_groups
    idx = groups{whichGroups(i)};  % The indices to the features of the original 'x'
    num = length(idx);             % How many features
    x2(start:start+num-1,:,:) = x(idx,:,:);   %Copy all the features. Check that their name will get reorganized 
    type2(start:start+num-1)  = type(idx);
    start = start+num;
end
% [x_train y_train] = getTrainingFormat (x2,y,[]);
results           = encoderRF (x2,y,type2,neurons,optionsTree);

