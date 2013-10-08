roiId = 42;
whiskers = {'c1'};
whiskerId = 'c1';
%roiId = 202;
%whiskers = {'c2'};
%whiskerId = 'c2';

dKappaRange = [-0.005 0.005];
dKappaSumRange = [-0.05 0.5];

% -------------------------------------------
% contact-triggered average, all whiskers
clear eparams;
eparams.displayedId = roiId;
eparams.plotMode = [1 1 0];
eparams.excludeOthers = 0;
eparams.whiskerTags = whiskers;
sA.plotEventTriggeredAverageCrossDays(eparams);

% -------------------------------------------
% EXCLUSIVE contact-triggered average, all whiskers
clear eparams;
eparams.displayedId = roiId;
eparams.plotMode = [1 1 0];
eparams.excludeOthers = 1;
eparams.whiskerTags = whiskers;
sA.plotEventTriggeredAverageCrossDays(eparams);


% -------------------------------------------
% peri-contact curvature change 
clear eparams;
eparams.whiskerTags = whiskers;
eparams.timeRange = [-0.1 0.5];
eparams.excludeOthers = 0;
eparams.displayedId = whiskerId;
eparams.valueRange = dKappaRange;
eparams.displayedTSA = 'whiskerCurvatureChangeTSA';
eparams.plotMode = [0 1 0 0];
sA.plotEventTriggeredAverageCrossDays(eparams)

% -------------------------------------------
% peri-contact curvature change, bigger time window 
clear eparams;
eparams.whiskerTags = whiskers;
eparams.timeRange = [-0.5 2];
eparams.excludeOthers = 0;
eparams.displayedId = whiskerId;
eparams.valueRange = dKappaRange;
eparams.displayedTSA = 'whiskerCurvatureChangeTSA';
eparams.plotMode = [0 1 0 0];
sA.plotEventTriggeredAverageCrossDays(eparams)


% -------------------------------------------
clear kparams;
kparams.roiId = roiId;
kparams.whiskerTags = whiskers;
kparams.contactType = [0 1 1];
kparams.trialContactNumber = [];
kparams.dKappaRange = dKappaRange;
sA.plotKappaRFCrossDays(kparams)
set(gcf, 'Name', 'all contact maxabs', 'NumberTitle','off');

% -------------------------------------------
clear kparams;
kparams.roiId = roiId;
kparams.whiskerTags = whiskers;
kparams.contactType = [0 1 1];
kparams.trialContactNumber = [];
kparams.kappaMode = 'sumabs';
kparams.dKappaRange = dKappaSumRange;
sA.plotKappaRFCrossDays(kparams)
set(gcf, 'Name', 'all contact sumabs', 'NumberTitle','off');

% -------------------------------------------
clear kparams;
kparams.roiId = roiId;
kparams.whiskerTags = whiskers;
kparams.contactType = [0 1 1];
kparams.dKappaRange = dKappaRange;
kparams.trialContactNumber = 'max';
sA.plotKappaRFCrossDays(kparams)
set(gcf, 'Name', 'max contact maxabs', 'NumberTitle','off');

% -------------------------------------------
clear kparams;
kparams.roiId = roiId;
kparams.whiskerTags = whiskers;
kparams.contactType = [0 1 1];
kparams.trialContactNumber = 'max';
kparams.kappaMode = 'sumabs';
kparams.dKappaRange = dKappaSumRange;
sA.plotKappaRFCrossDays(kparams)
set(gcf, 'Name', 'max contact sumabs', 'NumberTitle','off');


% -------------------------------------------
clear kparams;
kparams.roiId = roiId;
kparams.whiskerTags = whiskers;
kparams.contactType = [0 1 1];
kparams.dKappaRange = dKappaRange;
kparams.trialContactNumber = 1;
sA.plotKappaRFCrossDays(kparams)
set(gcf, 'Name', 'contact #1 maxabs', 'NumberTitle','off');

% -------------------------------------------
clear kparams;
kparams.roiId = roiId;
kparams.whiskerTags = whiskers;
kparams.contactType = [0 1 1];
kparams.trialContactNumber = 1;
kparams.kappaMode = 'sumabs';
kparams.dKappaRange = dKappaSumRange;
sA.plotKappaRFCrossDays(kparams)
set(gcf, 'Name', 'contact #1 sumabs', 'NumberTitle','off');


