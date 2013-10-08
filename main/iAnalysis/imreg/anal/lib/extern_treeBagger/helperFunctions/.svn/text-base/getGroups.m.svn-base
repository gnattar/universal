function groups = getGroups (names,nameGroups)
%%
%--------------------------------------------------------------------------
%
% Goal : To get an array (groups) corresponding to nameGroups and the indices of the variables grouped that correspond to 'names' 
% ----

%
%--------------------------------------------------------------------------
%
% Input
% -----
%
% names:               array of variable names
% nameGroups:          array of grouped names. These array will be compared to 'names' to find the strings that match. 
%
% Output
% ------
% groups:              an array from 1..N_nameGroups. groups{i} has the indices of names that are grouped by nameGroups{i}. 
%                      For instance if names = {'lick','whisk','lick_shift','whisk_shift1', 'whisk_shift2'} and
%                      nameGroups = {'lick', 'whisk'}. groups{1} = [1 3]. groups{2} = [2 4 5]/
%%

N_groups = length(nameGroups);
N_var    = length(names);
groups   = cell(N_groups,1);
for i=1:N_groups
    % Find all the names that have nameGroups{i} as part of its name (i.e.
    % if names = 'lick_shift' and nameGroups{i} = 'lick', it will be selected. 
    aux  = regexp(names,nameGroups{i});
    % There can be some nameGroups that will be found because they have part of the name in common 
    aux2 = regexp(nameGroups,nameGroups{i});
    cont2 = 0;
    extraGroup = [];
    % Indices of found names in aux
    listFound        = getFoundNames (aux);
    % Check name is not subset of another
    listOverlapNames = getFoundNames (aux2);
    listOverlapNames(find(listOverlapNames==i)) = []; % Take out the one with the actual name.
    if isempty(listOverlapNames)
        groups{i} = listFound;
    else
        tempList = listFound;
        for k=1:length(listOverlapNames)
            aux3 = regexp(names,nameGroups{listOverlapNames(k)});
            listOverlap = getFoundNames(aux3);
            tempList = setdiff(tempList,listOverlap);
        end
        groups{i} = tempList;
    end

    
end