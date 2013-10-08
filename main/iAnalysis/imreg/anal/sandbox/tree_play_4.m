%% ROUND 1

featureList = [ ...
10000 ... % Whisker setpoint
10010 ... % Mean whisker amplitude
10011 ... % Max whisker amplitude
10020 ... % Mean whisker velocity
10021 ... % Max whisker velocity
20001 ... % c2 max (abs(kappa))
20021 ... % c2 max neg kappa
20031 ... % c2 max pos kappa
];
runModes = [0 0 0 0 1];

if(0)
	% for generating tree test
	cd('/data/an166555/session');
	fl = dir('*sess.mat'); load(fl(1).name);

	nev = 0*s.caTSA.ids; 
	for i=1:length(s.caTSA.ids) 
		nev(i) = length(s.caTSA.caPeakEventSeriesArray.esa{i}); 
	end

	totalTimeSec = length(s.caTSA.time)*mode(diff(s.caTSA.time))/1000;
	freq = nev/totalTimeSec;

	activeIdx = find(freq > .05);

	clear treeBaggerParams;
	treeBaggerParams.roiIdList = s.caTSA.ids(activeIdx);
	treeBaggerParams.runModes = runModes;
	treeBaggerParams.featureIdList = featureList;

	s.setupTreeBaggerPar ('/data/tree_out/tree_touchwhisk_an166555',treeBaggerParams);


	% for generating tree test
	cd('/data/an166558/session');
	fl = dir('*sess.mat'); load(fl(1).name);

	nev = 0*s.caTSA.ids; 
	for i=1:length(s.caTSA.ids) 
		nev(i) = length(s.caTSA.caPeakEventSeriesArray.esa{i}); 
	end

	totalTimeSec = length(s.caTSA.time)*mode(diff(s.caTSA.time))/1000;
	freq = nev/totalTimeSec;

	activeIdx = find(freq > .05);

	clear treeBaggerParams;
	treeBaggerParams.roiIdList = s.caTSA.ids(activeIdx);
	treeBaggerParams.runModes = runModes;
	treeBaggerParams.featureIdList = featureList;

	s.setupTreeBaggerPar ('/data/tree_out/tree_touchwhisk_an166558',treeBaggerParams);
end


% for generating tree test
cd('/media/an160508b/session_merged');
for v=11
	load (sprintf('an160508_vol_%02d_sess',v));

	nev = 0*s.caTSA.ids; 
	for i=1:length(s.caTSA.ids) 
		nev(i) = length(s.caTSA.caPeakEventSeriesArray.esa{i}); 
	end

	totalTimeSec = length(s.caTSA.time)*mode(diff(s.caTSA.time))/1000;
	freq = nev/totalTimeSec;

  activeIdx = find(freq > .05);
	disp(['actives: ' num2str(length(activeIdx))]);

	clear treeBaggerParams;
	treeBaggerParams.roiIdList = s.caTSA.ids(activeIdx);
	treeBaggerParams.runModes = runModes;
	treeBaggerParams.featureIdList = featureList;

	s.setupTreeBaggerPar (['/data/tree_out/tree_touchwhisk_an160508_' sprintf('%02d',v)],treeBaggerParams);
end


