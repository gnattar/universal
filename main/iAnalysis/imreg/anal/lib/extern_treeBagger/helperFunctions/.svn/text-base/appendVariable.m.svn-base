function [new_x newNames newType ] = appendVariable (x,names,type,x_add,name_add,type_add)
%%
%--------------------------------------------------------------------------
%
% Goal : to add a new variable to x (features)
%--------------------------------------------------------------------------
%
% x, names and type:               are the variables already created
% x_add and name_add and type_add: are the variables to be added


%%
N_var_orig             = size(x,1);
N_time                 = size(x,3);
N_trials               = size(x,2);
N_var_toAdd            = length (name_add);
new_x                  = zeros(N_var_orig + N_var_toAdd,N_trials,N_time);
newType                = zeros(N_var_orig + N_var_toAdd,1);
newNames               = cell(N_var_orig + N_var_toAdd,1);

new_x(1:N_var_orig,:,:)  = x;
new_x(N_var_orig+1:N_var_orig+N_var_toAdd,:,:) = x_add;

newType(1:N_var_orig)  = type;
newType(N_var_orig+1:N_var_orig+N_var_toAdd) = type_add;

newNames(1:N_var_orig)  = names;
newNames(N_var_orig+1:N_var_orig+N_var_toAdd) = name_add;
