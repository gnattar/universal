%new touch detector

if (~exist('birTS'))
  birTS = s.whiskerBarInReachES.deriveTimeSeries(s.whiskerAngleTSA.time, s.whiskerAngleTSA.timeUnit, [0 1]);
end
clear params;
dtFrame = mode(diff(s.whiskerAngleTSA.time));

startPoleMove = nanmean(s.behavESA.esa{5}.eventTimesRelTrialStart(1:2:end));
endPoleMove = nanmean(s.behavESA.esa{5}.eventTimesRelTrialStart(2:2:end));
params.barTransitionDurationFrames = [30 25]/dtFrame; % 94953 30 and 25 ms respectively
params.barRadius = 21;

% single trial
uti = unique(s.whiskerAngleTSA.trialIndices);
tid = uti(65);
disp(['trial: ' num2str(tid)]);
val = find(s.whiskerAngleTSA.trialIndices == tid);

% go time
kappas = s.whiskerCurvatureChangeTSA.valueMatrix(:,val);
dtobar = s.whiskerDistanceToBarCenterTSA.valueMatrix(:,val);
bir = birTS.value(val);

% 1) detection based on pure distance to pole

% 2) "X" region around the dkappa-dtopole plot

session.whiskerTrial.detectContactsNew(kappas',dtobar',bir',params);


