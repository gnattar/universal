%% imanalysis

% breakup_volume_images(pwd,'*main*tif',4,1, 'anm174708_2012_07_10_7_main_184.tif', 0, [1:32], 2, 0,pwd,1,1,'*main*tif',1);
% breakup_volume_images(pwd,'*main*tif',4,1, 'anm174708_2012_07_10_7_main_119.tif', 0,[1:40], 2, 0,strrep(pwd,'/Volumes/', '/groups/magee/'),1,1,'*main*tif',1);
% breakup_volume_images(pwd,'*main*tif',5,1, 'anm174708_2012_08_30_13_main_406.tif', 0,[11:200], 2, 0,strrep(pwd,'/Volumes/GR_Data_02/Data/', '/groups/magee/mageelab/GR_dm11/imreg/'),1,1,'*main*tif',1);
breakup_volume_images(pwd,'*main*tif',1,1, 'anm181053_2012_11_14_08_main_332.tif', 0,[11:225], 2, 0,strrep(pwd,'/Volumes/', '/groups/magee/'),1,1,'*main*tif',1);
imreg_par_fromxml([pwd '/imreg-01.xml'], 0);
par_execute(pwd, 0);

% breakup_volume_images(fpath, flist, n_planes, mode, reference_image,  ...
%          reference_image_offset, reference_image_frames, preview_or_xml, ...
%          frames_correlated, cluster_fpath, fov_ids, vol_id, imreg_wc, do_warp)
