function [new_x newNames newType ] = removeVariable (x,names,type,varsToBeRemoved)
%%
% Goal :     to remove the variables 'varsToBeRemoved' from 'x' and 'names'   
% ----
%--------------------------------------------------------------------------
% x:                is the original N_var x N_trials x N_time indepedent variables
% names:            are the corresponding names in order
% type:             0 for continous
% varsToBeRemoved:  an array of names of variables to remove
%%

idxVar                 = ismember (names,varsToBeRemoved);
N_var_orig             = size(x,1);
N_var_toRemove         = length (varsToBeRemoved);
N_time                 = size(x,3);
N_trials               = size(x,2);
new_x                  = zeros(N_var_orig - N_var_toRemove,N_trials,N_time);
newType                = zeros(N_var_orig - N_var_toRemove,1);
newNames               = cell(N_var_orig - N_var_toRemove,1);
cont = 0;
for i=1:N_var_orig
    if ~idxVar(i)
        cont = cont + 1;
        newNames{cont}     = names{i};
        new_x (cont,:,:)   = squeeze(x(i,:,:));
        newType(cont)      = type(i);
    end
end
