function r = solo_get_session_numtrials(x)
%
% Returns number of trials for session in x.
%
% x is a loaded-from-disk Solo file.
% 
% DHO, 9/07.

correct = x.saved.poles_discobj_hit_history;

% Trim trials from start and end if needed:
correct = correct((1+x.trim(1)):(end-x.trim(2)),:); 

r = length(correct);    
