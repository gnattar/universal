fidStart = 12000;
fidOffs = 1000;
fovIds = {'05002', '05003','05004', ...
          '06002', '06003','06004', ...
          '07002', '07003','07004', ...
          '08002', '08003','08004', ...
          '09002', '09003','09004', ...
          '10002', '10003','10004', ...
          '11002', '11003','11004'};

for f=1:length(fovIds)
  fidRange = [fidStart (fidStart+ fidOffs -1)];
	rA = roi.roiArray();
	rA.masterImage = ['/media/an160508b/2012_02_10/scanimage/fov_' fovIds{f} '/fluo_batch_out/session_mean.tif'];
	rA.roiIdRange = fidRange;
	rA.addAccessoryImage(strrep(rA.masterImageRelPath,'session_mean','session_sdmax'));
	rA.addAccessoryImage(strrep(rA.masterImageRelPath,'session_mean','session_pertrial_sd'));
	rA.saveToFile(['an160508_2012_02_10_based_fov_' fovIds{f}]) ; 
	clear rA;
	fidRange = fidRange + fidOffs;
end
