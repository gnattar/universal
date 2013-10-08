% Tsai-Wen's data format:
%  para.t_frame: time vector for calcium data
%  para.fmean, para.fneuropil: cell and neuropil fluorescence traces
%  para.t_ephys: cell attached data time vector
%  para.epys: voltage for cell attached data

% create calcium timeSeries 
caTS = session.timeSeries(para.t_frame*1000, session.timeSeries.millisecond, para.fmean-0.7*para.fneuropil);

% downsample this to be closer to what my imaging conditions are (~8 Hz)
newTime = caTS.time(1:8:end);
caTS = caTS.reSample(100,[],newTime);

% now create calciumTimeSeriesArray so you can run dff and events
caTSA = session.calciumTimeSeriesArray({caTS}, 1+0*caTS.value, [], 1);

% 1) 'classic' dff and event detection
% assign the default dffOpts and run updateDff
caTSA.dffOpts = [];
caTSA.dffOpts.filterType = 2; % median
caTSA.dffOpts.filterSize = 10; % seconds
caTSA.dffOpts.fzeroMethod = 2; % full-trace ksd, since we prenormalize trace
caTSA.dffOpts.fzeroSlidingWindowSize = 0; % irrelevant since we use full trace ksd
caTSA.dffOpts.fzeroMin = 1; % raw data with raw fluo value BELOW this are set to this
caTSA.dffOpts.subtractMethod = 3; % anti-ROI [1 also works well for sparse brain regions]
tic;
caTSA.updateDff();
disp(['dff 1: ' num2str(toc)]);

% defaults for event detection
caTSA.evdetOpts = [];
caTSA.evdetOpts.evdetMethod = 1; % SD thresh via MAD
caTSA.evdetOpts.threshMult = 4; % event must be this much greater 
caTSA.evdetOpts.threshStartMult =2;
caTSA.evdetOpts.threshEndMult =2;
caTSA.evdetOpts.minEvDur = 500; % ms
caTSA.evdetOpts.minInterEvInterval = 500; 
caTSA.evdetOpts.madPool = 2; % use inactive cells
caTSA.evdetOpts.filterType = 2; % prefilter with median
caTSA.evdetOpts.filterSize = 10; % in s
caTSA.evdetOpts.riseDecayMethod = 2;  % goodness-of-fit based
tic;
caTSA.updateEvents();
disp(['evdet 1: ' num2str(toc)]);

% 2) redo dff computation w/ events included
caTSA.dffOpts = [];
caTSA.dffOpts.filterType = 4; % slower but MUCH better quantile based
caTSA.dffOpts.filterSize = 10; % seconds
caTSA.dffOpts.fzeroMethod = 3; % EXCLUDE high-event regions from fzero estimation
caTSA.dffOpts.fzeroSlidingWindowSize = 0; % irrelevant since we use full trace ksd
caTSA.dffOpts.fzeroMin = 1; % raw data with raw fluo value BELOW this are set to this
caTSA.dffOpts.subtractMethod = 3; % anti-ROI [1 also works well for sparse brain regions]
tic;
caTSA.updateDff();
disp(['dff 2: ' num2str(toc)]);

% 3) Vogelstein event detection
caTSA.evdetOpts = [];
caTSA.evdetOpts.evdetMethod = 4;
caTSA.evdetOpts.riseDecayMethod = 2; 
caTSA.evdetOpts.eventBasedDffMethod = 2;
caTSA.evdetOpts.threshMult = 4; % event must be this much greater 
caTSA.evdetOpts.threshStartMult =2;
caTSA.evdetOpts.threshEndMult =2;
caTSA.evdetOpts.minEvDur = 500; % ms
caTSA.evdetOpts.minInterEvInterval = 500; 
caTSA.evdetOpts.madPool = 2; % use inactive cells
caTSA.evdetOpts.filterType = 0;
tic;
caTSA.updateEvents();
disp(['evdet 2: ' num2str(toc)]);

% 4) detect active ROIs
caTSA.detectActiveRois();


%%%
% ephus data
ephTS = session.timeSeries(para.t_ephys*1000, session.timeSeries.millisecond, para.ephys);
