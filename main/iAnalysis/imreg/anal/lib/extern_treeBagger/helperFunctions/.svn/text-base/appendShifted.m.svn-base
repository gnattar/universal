function [new_x newNames newType ] = appendShifted (x,names,type,varToBeShifted,shifts,typeShift)
%%
%--------------------------------------------------------------------------
%
% Goal : to shift variable 'varToBeShifted' the amount in vector shifts. It creates new variables, names and types   
% ----
%      : Variables shifted positively (negatively) have name _P_Shift
%      (N_shift). If typeShift = 1, the name will be _SingleEvent_
%
%--------------------------------------------------------------------------
% x:              is the original N_var x N_trials x N_time indepedent variables
% names:          are the corresponding names in order
% type:           0 for continous
%                 1 for categorical
% varToBeShifted: is the name of the variable that will be shifted
% shifts:         are all the shifts (positive, negative) in a vector format ([-5 -3 1 3]). A positive shift
%                 moves x to the right. 
% typeShift:      0 for regular shift
%                 1 for only first occurence shift. The varToBeShifted has
%                 to be an Event type of variable. That is is 0 if it is
%                 not present and some other value otherwise. In the case
%                 of pole position it will take the first occurrence of the
%                 pole-up. 
%               

%%
idxVar                 = find(ismember (names,varToBeShifted));
N_shifts               = length(shifts);
N_var_orig             = size(x,1);
N_time                 = size(x,3);
N_trials               = size(x,2);
new_x                  = zeros(N_var_orig+N_shifts,N_trials,N_time);
new_x (1:N_var_orig,:,:) = x;
newNames              = cell(N_var_orig + N_shifts,1);
newNames(1:N_var_orig) = names;
newType                = zeros(1,N_var_orig + N_shifts);
newType(1:N_var_orig)  = type;
for i=1:N_shifts
    aux                    = squeeze(x(idxVar,:,:));
    if typeShift == 0
        if shifts(i) > 0
            new_x(N_var_orig+i,:,:)     = [NaN(N_trials,shifts(i)) aux(:,1:N_time-shifts(i))];
            newNames{N_var_orig+i}      = sprintf('%s%s%d',char(names(idxVar)),'_P_Shift_',shifts(i));
        elseif shifts(i) < 0
            new_x(N_var_orig+i,:,:)     = [aux(:,-shifts(i)+1:N_time) NaN(N_trials,-shifts(i))];
            newNames{N_var_orig+i}      = sprintf('%s%s%d',char(names(idxVar)),'_N_Shift_',-shifts(i)); 
        else
            new_x(N_var_orig+i,:,:)     = aux;
            newNames{N_var_orig+i}      = sprintf('%s%s',char(names(idxVar)),'_NO_Shift_');
        end
    else
        % Will check the first event per trial (shifts can be 0 in only
        % this case, because it will create a single time-event)
        timeEvent = zeros(N_trials,N_time);
        for k=1:N_trials,
            aux = find (squeeze(x(idxVar,k,:)),1,'first');
            timeEvent(k,aux) = 1; 
        end
        if shifts(i) > 0
            new_x(N_var_orig+i,:,:)     = [NaN(N_trials,shifts(i)) timeEvent(:,1:N_time-shifts(i))];
            newNames{N_var_orig+i}      = sprintf('%s%s%d',char(names(idxVar)),'_SingleEvent_P_Shift_',shifts(i));
        elseif shifts(i) < 0
            new_x(N_var_orig+i,:,:)     = [timeEvent(:,-shifts(i)+1:N_time) NaN(N_trials,-shifts(i))];
            newNames{N_var_orig+i}      = sprintf('%s%s%d',char(names(idxVar)),'_SingleEvent_N_Shift_',-shifts(i));
        else
            new_x(N_var_orig+i,:,:)     = timeEvent(:,1:N_time) ;
            newNames{N_var_orig+i}      = sprintf('%s%s',char(names(idxVar)),'_SingleEvent_NO_Shift_');                    
        end
    end
    newType(N_var_orig+i)  = type(idxVar);    
    
end
