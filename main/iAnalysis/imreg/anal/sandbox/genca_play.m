scimFilePath = '/data/an38596/2010_02_08/scanimage/fluo_batch_out/';
roiArrayPath = '/data/an38596/roi/2010_02_08_cell_20100220_093_based.mat';
scimFileWC ='Image_Registration_4*tif';
scimFileWC ='Image_Registration_4*_01*tif';


caTSA = session.calciumTimeSeriesArray.generateCalciumTimeSeriesArray( ...
	  roiArrayPath, scimFilePath, scimFileWC, 0, [], []);

