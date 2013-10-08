function [rt_hit, rt_fa] = solo_get_trial_reaction_times(x)
%
%
% x is a loaded-from-disk Solo file.
% 
%
%
% DHO, 9/07.

trialEvents = x.saved_history.RewardsSection_LastTrialEvents;

% Trim trials from start and end if needed:
trialEvents = trialEvents((1+x.trim(1)):(end-x.trim(2))); 


rt_hit = []; rt_fa = [];
for j=1:length(trialEvents)
    s = trialEvents{j};
    side = x.saved.SidesSection_previous_sides(j);
    rts =  x.saved.make_and_upload_state_matrix_RealTimeStates;
    if ~isempty(s(find(s(:,1)==41))) & ~isempty(s(find(s(:,1)==43)))
        t = min(s(find(s(:,1)==43),3)) - min(s(find(s(:,1)==41),3));
        rt_hit = [rt_hit t];
    elseif rts.airpuff==48 & ~isempty(s(find(s(:,1)==41))) & ~isempty(s(find(s(:,1)==48))) % prior to 8/7/07, False alarm state was 48; subsequently, 49.
        t = min(s(find(s(:,1)==48),3)) - min(s(find(s(:,1)==41),3));
        rt_fa = [rt_fa t];
    elseif rts.airpuff==49 & ~isempty(s(find(s(:,1)==41))) & ~isempty(s(find(s(:,1)==49))) % prior to 8/7/07, False alarm state was 48; subsequently, 49.
        t = min(s(find(s(:,1)==49),3)) - min(s(find(s(:,1)==41),3));
        rt_fa = [rt_fa t];
    end
end

