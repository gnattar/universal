%
% playin with trees
%

% should correspond (eg c1 c2 c3)
treeFeaturesIdx = [10 16 22];
whiskerContactIdx = [1 2 3];
roi = 42;

% 1) load the tree-predicted fluorescent trace
[pz az tv] = s.getPredictedFromTree('../tree_par', [], s.treeFeatureList{treeFeaturesIdx(1)}, roi, s);
tsp = session.timeSeries(tv, 1, pz, 555, 'predicted', 0, '');

% 2) rescale to match distro of actual calcium trace

% 3) resample it to be same time vector
tsp.reSample(100, 1, s.caTSA.dffTimeSeriesArray.time);

% 4) get epoch around where ONLY a given whisker touches, values exist 
iet =  s.whiskerBarContactESA.esa{whiskerContactIdx(1)}.getStartTimes;
xet =  s.whiskerBarContactESA.esa{whiskerContactIdx(2)}.getStartTimes;
xet = [xet s.whiskerBarContactESA.esa{whiskerContactIdx(3)}.getStartTimes];
%[idxMat timeMat timeVec] = 
%       getIndexWindowsAroundEventsS(time, timeUnit, timeWindow, timeWindowUnit, 
%     		  includeEventTimes, ieTimeUnit, excludeTimeWindow, excludeEventTimes, 
%          eeTimeUnit, allowOverlap) 
tsCa = s.caTSA.dffTimeSeriesArray.tsa{roi};

[idxMat timeMat timeVec] = session.timeSeries.getIndexWindowsAroundEventsS(tsCa.time, ...
  tsCa.timeUnit, [0 2], 2, iet, tsCa.timeUnit, [-2 2], xet);
 

% 5) compute corr over this
