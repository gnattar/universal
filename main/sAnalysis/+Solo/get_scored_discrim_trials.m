function [trialNum, trialType, trialCorrect, trialTriggerTimesEPHUS, trialTriggerTimesCamera, ...
    beamBreakTimes, rewardTimes, airpuffTimes] = get_scored_discrim_trials(x)
%
%
% [scoredTrials, trialTriggerTimesEPHUS, trialTriggerTimesCamera, ...
%     beamBreakTimes, rewardTimes, airpuffTimes] = solo_get_scored_trials_discrim(x)
%
% -------------------------------------------------------------------------
% Returns values only for discrimination trials (ignores beam break indicator,
% etc, trials).
%
% scoredTrials: matrix of form: [trialNum trialType correct]
%
% trialType: 1 = S1 = go trial, 0 = S0 = no-go trial.
% correct: 1 = correct, 0 = incorrect.
%
% trialTriggerTimes, time for each trial that RTL sent trigger to EPHUS
%
% x is a loaded-from-disk Solo file.
%
% DHO, 4/24.



sessionType = x.saved_history.SessionTypeSection_SessionType;
ind = strmatch('Discrim',sessionType,'exact');


trialCorrect = x.saved.poles_discobj_hit_history;
trialNum = (1:length(trialCorrect))';
trialType  = (x.saved.SidesSection_previous_sides(1:(end-1)) == 114)'; % 114 charcode for 'r', 108 for 'l'. 1 = S1 (go), 0 = S0 (nogo).


trialCorrect = trialCorrect(ind);
trialNum = trialNum(ind);
trialType = trialType(ind);

% scoredTrials = [trialNum(ind) trialType(ind) trialCorrect(ind)];

evt = x.saved_history.RewardsSection_LastTrialEvents;
evt = evt(ind); % limit just to Discrim trials



beamBreakTimes = cellfun(@get_beamBreakTimes, evt, 'UniformOutput', false);
trialTriggerTimesEPHUS = cellfun(@get_trialTriggerTimeEPHUS, evt, 'UniformOutput', false);
trialTriggerTimesCamera = cellfun(@get_trialTriggerTimeCamera, evt, 'UniformOutput', false);
rewardTimes = cellfun(@get_rewardTimes, evt, 'UniformOutput', false);
airpuffTimes = cellfun(@get_airpuffTimes, evt, 'UniformOutput', false);
pinDescentOnsetTimes = cellfun(@get_pinDescentOnsetTime, evt, 'UniformOutput', false);
pinAscentOnsetTimes = cellfun(@get_pinAscentOnsetTime, evt, 'UniformOutput', false);




%------------
function r = get_beamBreakTimes(trialEvt) % All beam break entries, independent of state
rowInd = find(trialEvt(:,2)==1);
if ~isempty(rowInd)
    r = trialEvt(rowInd, 3);
else
    r = [];
end


%------------
function r = get_rewardTimes(trialEvt)% State 49 entries, SHOULD EXTEND TO GIVE EXITS TOO
rowInd = find(trialEvt(:,1)==43 & trialEvt(:,2)==0 );
if ~isempty(rowInd)
    r = trialEvt(rowInd, 3);
else
    r = [];
end



%------------
function r = get_airpuffTimes(trialEvt) % State 49 entries, SHOULD EXTEND TO GIVE EXITS TOO
rowInd = find(trialEvt(:,1)==49 & trialEvt(:,2)==0 );
if ~isempty(rowInd)
    r = trialEvt(rowInd, 3);
else
    r = [];
end



%------------
function r = get_pinDescentOnsetTime(trialEvt) % State 41 entry
rowInd = find(trialEvt(:,1)==41,1);
if ~isempty(rowInd)
    r = trialEvt(rowInd, 3);
else
    r = [];
end



%------------
function r = get_pinAscentOnsetTime(trialEvt) % State 48 entry
rowInd = find(trialEvt(:,1)==48,1);
if ~isempty(rowInd)
    r = trialEvt(rowInd, 3);
else
    r = [];
end


%------------
function r = get_trialTriggerTimeEPHUS(trialEvt) % State 40 entry
rowInd = find(trialEvt(:,1)==40,1);
if ~isempty(rowInd)
    r = trialEvt(rowInd, 3);
else
    r = [];
end


%------------
function r = get_trialTriggerTimeCamera(trialEvt) % State 40 entry
rowInd = find(trialEvt(:,1)==40,1);
if ~isempty(rowInd)
    r = trialEvt(rowInd, 3);
else
    r = [];
end



































