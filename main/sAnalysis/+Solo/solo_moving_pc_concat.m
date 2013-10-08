function [cumulative_trialnum, trialnum, y] = solo_moving_pc_concat(xcell,span)
%
% Returns percent correct moving average for session in x.
%
% xcell is a cell array of Solo files.
% span: must be odd to center on current trial.
%
% Requires: Curve Fitting Toolbox.
%
% DHO, 9/07.

if mod(span,2)==0
    error('Span must be odd')
end

% Don't increment cumulative_trialnum by trials discarded (via 'etrim' value) at end
% of session, since these may be run-ons after the mouse has finished and the
% assumption is that mouse is no longer doing the task. However, do increment
% by all trials at start of experiment, even if excluded from plotting by
% 'btrim' value. Assumption is that although mouse is performing poorly, he is
% in fact doing task.

[trialnum,y] = cellfun(@Solo.solo_moving_pc,xcell,repmat({span},size(xcell)),'UniformOutput',false);
cumulative_trialnum = trialnum;
for k=2:length(cumulative_trialnum)
    cumulative_trialnum{k} = cumulative_trialnum{k} + cumulative_trialnum{k-1}(end) + floor(span/2);
end


