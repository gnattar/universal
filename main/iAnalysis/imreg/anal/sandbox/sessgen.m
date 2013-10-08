
base = '/Volumes/data_mirror/';
%base = '/data/mouse_gcamp_learn/';

% setup dataSourceParams
dsp.behavSoloFilePath = [base '/an38596/2010_02_25/behav/data_@pole_detect_spobj_an38596_100225a.mat'];
dsp.ephusFilePath = [base '/an38596/2010_02_25/ephus/'];
dsp.scimFilePath = [base '/an38596/2010_02_25/scanimage/'];
dsp.roiArrayPath = [base '/an38596/roi/2010_02_25_cell_20100220_093_based.mat']; 

s = session.session.generateSession(dsp);

%cats = session.calciumTimeSeriesArray.generateCalciumTimeSeriesArray(['~/data/mouse_gcamp_learn/an38596/roi/2010_02_20_cell_20100220_093_based.mat'], ...
%  [base 'an38596/2010_02_20/scanimage/fluo_batch_out/'], 'Image_Registration_4_*tif');

return

% ---- OLD

flist = dir('~/data/mouse_gcamp_learn/an93098/2010*');
for f=1:length(flist)  
%for f=15:18
	dates{f} = flist(f).name;
	base_path = ['~/data/mouse_gcamp_learn/an93098/' dates{f} '/']; 
	scim_p.wc = 'Image_Registration_4*tif';
	scim_p.path = [base_path 'scanimage/fluo_batch_out/'];
	scim_p.roi_file_path = ['~/data/mouse_gcamp_learn/an93098/roi/an93098_' dates{f} '.mat'];
	session_file_path = ['~/data/mouse_gcamp_learn/an93098/session/sess_an93098_' dates{f} '.mat'];
%	if (~exist(session_file_path, 'file'))
		session_generator([], scim_p, [], base_path, session_file_path);
%	end
end

