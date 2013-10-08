% for generating tree test
if (exist('s','var') == 0)
	cd /media/an160508b/session_merged;
	load an160508_vol_04_sess;
end

% test 1: limited rois (top 200 active), key features
nev = 0*s.caTSA.ids; 
for i=1:length(s.caTSA.ids) 
  nev(i) = length(s.caTSA.caPeakEventSeriesArray.esa{i}); 
end
[irr idx] = sort(nev, 'descend');

clear treeBaggerParams;
treeBaggerParams.roiIdList = s.caTSA.ids(idx(1:200));
treeBaggerParams.featureIdList = [ ...
10000 ... % Whisker setpoint
10010 ... % Mean whisker amplitude
10011 ... % Max whisker amplitude
10020 ... % Mean whisker velocity
10021 ... % Max whisker velocity
10200 ... % Whisker setpoint no touch
10210 ... % Mean whisker amplitude no touch
10211 ... % Max whisker amplitude no touch
10220 ... % Mean whisker velocity no touch
10221 ... % Max whisker velocity no touch
20001 ... % c2 max (abs(kappa))
20011 ... % c2 abs max kappa
20021 ... % c2 max neg kappa
20031 ... % c2 max pos kappa
20041 ... % c2 max sumabskappa at touch
20051 ... % c2 mean thetamean at touch
20061 ... % c2 Pro max sumabskappa at touch
20071 ... % c2 Pro mean thetamean at touch
20062 ... % c2 Ret max sumabskappa at touch
20072 ... % c2 Ret mean thetamean at touch
30001 ... % Beam Breaks Left Rate
30002 ... % Beam Breaks Right Rate
30000 ... % Beam Breaks All Rate
40000 ... % Pole Move All
40001 ... % Pole Move In
40002 ... % Pole Move Out
50001 ... % Left Rewards
50002 ... % Right Rewards
50000 ... % All Rewards
60000 ... % Stimulus Position
];

s.setupTreeBaggerPar ('/data/an160508/partest',treeBaggerParams);
