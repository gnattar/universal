cd /data/an38596/roi

load ('2010_02_20_cell_20100220_093_based.mat');
rA = obj;

% zstack 
zim = load_image ('~/data/an38596/zcorr_stack.tif');

% loop thru everyone
global corrMat;
global cmfi;
corrMat = nan*ones(length(rA.rois),size(zim,3));

for z=1:size(zim,3);
	rB = roi.roiArray();
	rB.workingImage = zim(:,:,z);
  cmfi = z;

	roi.roiArray.findMatchingRoisInNewImage(rA,rB);
end

baseId = rA.idStr;
save('z_roi_corr.mat', 'corrMat',  'baseId');
