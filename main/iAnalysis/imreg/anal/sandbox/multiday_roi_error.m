cd /data/an38596/roi

load ('2010_02_20_cell_20100220_093_based.mat');
rA = obj;

% loop thru everyone
fl = dir('*_093_based.mat');
names = {};

global corrMat;
global cmfi;
corrMat = nan*ones(length(rA.rois),length(fl));

for f=1:length(fl)
  load(fl(f).name);
	rB = obj;
  names{f} = rB.idStr;

  cmfi = f;

  rB.rois = {} ; 
	rB.roiIds = [];

	roi.roiArray.findMatchingRoisInNewImage(rA,rB);
end

baseId = rA.idStr;
save('multiday_roi_corr.mat', 'corrMat', 'names', 'baseId');
