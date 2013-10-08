function reGroups = getReGroups (nameGroups,groups,nameReGroups)
%%
%--------------------------------------------------------------------------
%
% Goal : To regroup the features according to the array nameReGroups.   
% ----

%
%--------------------------------------------------------------------------
%
% Input
% -----
%
% nameGroups:          array of variable names
% groups:              an array from 1..N_nameGroups. groups{i} has the indices of names that are grouped by nameGroups{i}. 
%                      For instance if names = {'lick','whisk','lick_shift','whisk_shift1', 'whisk_shift2'} and
%                      nameGroups = {'lick', 'whisk'}. groups{1} = [1 3]. groups{2} = [2 4 5]. First use getGroups then run this function.
% nameReGroups:        array of grouped names. These array will be compared to 'names' to find the strings that match. 
%
% Output
% ------
%
% reGroups:           Same format as groups but with the all the original features that correspond to the set of nameReGroups 
%
%%


N_regroups = length(nameReGroups);
% N_var    = length(names);
reGroups   = cell(N_regroups,1);

for i=1:N_regroups,
    N_groups = length(nameReGroups{i});
    start = 1;
    for j=1:N_groups,
        idx = 0;
        for k=1:length(nameGroups)
            if strcmp(nameGroups{k},nameReGroups{i}{j})
                idx = k;
            end
        end
        aux_vec = groups{idx};
        reGroups{i}(start:start+length(aux_vec)-1) = aux_vec;   % Copy the indices to the original feature list
        start = start+length(aux_vec);
    end
end

