%
% Script for generating whiskerTrialArrays for following animals:
%
%  160508
%

%rootPath = '/Volumes/';
rootPath = '/media/';

%dates = {'2012_02_09', '2012_02_10', '2012_02_11' , '2012_02_12', '2012_02_13'};
dates = {'2012_02_09', '2012_02_10', '2012_02_11' , '2012_02_12', '2012_02_13', '2012_02_14','2012_02_15'};
barCenterOffsets = [-2 0; -2 0 ; -2 0 ; -2 0 ; -2 0 ; -2 0 ; -2 0];


%for d=1:length(dates)
for d=1
  ds = dates{d};
	params.whiskerFilePath = [rootPath '160508w/' ds '-1'];
	params.whiskerFileWC = '*WDBP*mat';
	params.barInReachFraction = 0.4;

	% bar center is automatically detected, but sometimes needs to be shifted
	%  because bar not perfectly normal to imaging plane
	params.barCenterOffset = [-2 1];
	% bar radius sometimes is off by a pixel, so set manually
	params.barRadius = 7;

	params.ephusPath = [rootPath 'an160508b/' ds '/ephus/'];
	params.ephusWC = '*xsg';

	params.baseFileName = [rootPath '160508w/whiskerTrialArray_' ds];

	wta = session.whiskerTrialArray.generateUsingParams(params);
end
