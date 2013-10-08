function r = solo_get_session_pc(x)
%
% Returns percent correct overall for session in x.
%
% x is a loaded-from-disk Solo file.
% 
% DHO, 9/07.

correct = x.saved.poles_discobj_hit_history;

% Trim vector (x.trim) is interpreted thus:
% If trim vector has 2 elements, they are the number of trials to trim
% from the start and end of the experiment.
% If trim vector has >2, the first two elements are still the number to trim
% from the start and end, but the 3rd and subsequent elements are taken as
% trials to trim.
if length(x.trim)>2
    trialnums = 1:length(correct);
    correct = correct(setdiff(trialnums,x.trim(3:end)));
    correct = correct((1+x.trim(1)):(end-x.trim(2)));  % now trim ends as normal.
else
    correct = correct((1+x.trim(1)):(end-x.trim(2))); 
end
r = mean(correct);    
