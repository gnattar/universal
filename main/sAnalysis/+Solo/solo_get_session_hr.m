function r = solo_get_session_hr(x)
%
% Returns hit rate overall for session in x.
%
% x is a loaded-from-disk Solo file.
% 
% DHO, 9/07.
% Adapted by NX, 5/2010

correct = x.saved.pole_detect_nxobj_hit_history; % x.saved.poles_discobj_hit_history;
trialtype  = (x.saved.SidesSection_previous_sides(1:(end-1)) == 114)'; % 114 charcode for 'r', 108 for 'l'. 1 = S1 (go), 0 = S0 (nogo).

trials = [trialtype correct];

% % Trim trials from start and end if needed:
% trials = trials((1+x.trim(1)):(end-x.trim(2)),:); 

% Trim vector (x.trim) is interpreted thus:
% If trim vector has 2 elements, they are the number of trials to trim
% from the start and end of the experiment.
% If trim vector has >2, the first two elements are still the number to trim
% from the start and end, but the 3rd and subsequent elements are taken as
% trials to trim.
if length(x.trim)>2
    trialnums = 1:length(trials);
    trials = trials(setdiff(trialnums,x.trim(3:end)),:);
    trials = trials((1+x.trim(1)):(end-x.trim(2)),:);  % now trim ends as normal.
else
    trials = trials((1+x.trim(1)):(end-x.trim(2)),:); 
end



ntrials_s1 = length(find(trials(:,1)==1));

r = length(find(trials(:,1)==1 & trials(:,2)==1)) / ntrials_s1;    
