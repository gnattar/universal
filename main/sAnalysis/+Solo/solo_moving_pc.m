function [trialnum,y] = solo_moving_pc(x,span)
%
% Returns percent correct moving average for session in x, with edges trimmed
% such that no value of y is computed with less than span samples. trialnum
% is the original trial number from Solo. 
%
% x is a loaded-from-disk Solo file.
% span: must be odd to center on current trial.
%
% Requires: Curve Fitting Toolbox.
%
% DHO, 9/07.

correct = x.saved.poles_discobj_hit_history;
trialnum = (1:length(correct))';

% Trim trials from start and end if needed:
correct = correct((1+x.trim(1)):(end-x.trim(2))); 
trialnum = trialnum((1+x.trim(1)):(end-x.trim(2))); 

y = smooth(correct,span,'moving');    

len = length(correct);
ind = ceil(span/2):(len-floor(span/2));   % trim off edges with less than span samples

trialnum = trialnum(ind);
y = y(ind);