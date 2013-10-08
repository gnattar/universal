function r = solo_get_session_duration(x)
%
% Returns time (in min) between end of last trial (after trimming!)
% and beginning of first trial (again, after trimming).
%
% x is a loaded-from-disk Solo file.
% 
%
% Note that if Solo program crashed, any time during restarting, 
% after crashing and before pressing run 
% button again, is lost and not included in the result of this function. 
%
% DHO, 9/07.

trialEvents = x.saved_history.RewardsSection_LastTrialEvents;

% Trim trials from start and end if needed:
trialEvents = trialEvents((1+x.trim(1)):(end-x.trim(2))); 

% Need to check for cases in which program crashed and clock
% starts over on relaunch:
 y = cellfun(@(x) mean(x(:,3)), trialEvents);
 new_first_trial = find(diff(y)<0) + 1;
 
 if isempty(new_first_trial)
    starttime = trialEvents{1}(1,3);
    stoptime = trialEvents{end}(end,3);
    r = (stoptime - starttime) / 60;  
 else
    starttime1 = trialEvents{1}(1,3);
    stoptime1 = trialEvents{new_first_trial-1}(end,3);
    starttime2 = trialEvents{new_first_trial}(1,3);
    stoptime2 = trialEvents{end}(end,3);
    r = ((stoptime1 - starttime1) + (stoptime2 - starttime2))  / 60;  
 end

     




    