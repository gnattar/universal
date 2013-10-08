clear params;
clear actParams;

actParams.cofThresh = 0.15;
actParams.nabThresh = 0.005;
actParams.forceRedo = 1;
s.caTSA.getRoiActivityStatistics(actParams);

params.hyperactiveIdx = s.caTSA.roiActivityStatsHash.get('hyperactiveIdx');
params.activeIdx = s.caTSA.roiActivityStatsHash.get('activeIdx');

params.timeUnit = s.caTSA.timeUnit;

params.tausInDt = 3:30;
params.tRiseInDt = 1:5;

params.initThreshSF = [1.5 2 2.5];
params.debug = 0;

params.minFitRawCorr = 0.25;
params.fitResidualSDThresh = 2;
  

%params.activeIdx = intersect(params.activeIdx,1:5);
%params.hyperactiveIdx = intersect(params.hyperactiveIdx,1:5);

tvec = s.caTSA.time;
vmat = s.caTSA.dffTimeSeriesArray.valueMatrix;

caES = session.timeSeries.getCalciumEventSeriesFromExponentialTemplateS(tvec,vmat,params);

% trial assignment ...
caESA = session.calciumEventSeriesArray(caES);
caESA.trialTimes = s.behavESA.trialTimes;

% assign IDs
for e=1:length(s.caTSA.ids)
  caESA.esa{e}.id = s.caTSA.ids(e);
	caESA.esa{e}.idStr = ['Ca events for ROI ' num2str(s.caTSA.ids(e))];
end
caESA.ids = s.caTSA.ids;

s.caTSA.caPeakEventSeriesArray = caESA;
