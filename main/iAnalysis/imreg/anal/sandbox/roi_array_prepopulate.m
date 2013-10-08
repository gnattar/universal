
if ( 1) 
	an = 'an171923';
	src_date = '2012_06_12';
	V = 1:8
	P = 2:4;
	id1 = 1;

	src_date = '2012_06_13';
	V = 9:16
	P = 2:4;
	id1 = 24001;
end

an = 'an171215';
src_date = '2012_06_12';
V = 17:19
P = 1:4;
id1 = 50001;

%V = 8
%P = 4
%id1 = 23000;

basePath = [pwd filesep src_date filesep 'scanimage/fov_%02d%03d' filesep 'fluo_batch_out' filesep]
roiPath = [pwd filesep 'rois' filesep src_date '_based_fov_%02d%03d.mat'];
for v = V
  for p = P
    rPath = sprintf(roiPath, v, p);
    bPath = sprintf(basePath, v, p);
	  
	  rA = roi.roiArray();
    rA.masterImage = [bPath 'session_mean.tif'];
		rA.roiIdRange = [0 999]+id1;
		rA.addAccessoryImage([bPath 'session_sdmax.tif'], 'sdmax');
		rA.addAccessoryImage([bPath 'session_pertrial_sd.tif']);

    rA.saveToFile(rPath);

		id1 = id1+1000;
	end
end
