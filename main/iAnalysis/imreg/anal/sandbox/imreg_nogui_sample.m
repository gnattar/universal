on_cluster = 1;

if (on_cluster)
  rawdata_path = '/groups/svoboda/wdbp/imreg/perons/an148378/2011_09_15/scanimage';
  par_path = '/groups/svoboda/wdbp/perons/tree/anal/par/parout_imreg_%###';
else
  rawdata_path = '/data/testing/an148378/2011_09_15/scanimage';
  par_path = '/home/speron/sci/anal/par/parout2_%###';
end
base_image_fname = 'an148378_2011_09_15_main_135.tif';
num_fovs = 4;
offset = 1;

%
% 1) breakup images to FOVs
%

% check proper ordering in breakup volume imaging -- change offset to correct

if (~on_cluster)
  breakup_volume_images(rawdata_path, '*main*tif', num_fovs,1,base_image_fname, offset,[],1,57);
end
disp('If you have checked offset, hit enter and continue ; otherwise, check on local machine and set offset');
pause

% now run it for real ...
breakup_volume_images(rawdata_path, '*main*tif', num_fovs,1,base_image_fname, offset,[],0,57);

%
% 2) setup image-registration
%
source_path = [rawdata_path filesep '%wc{fov_*}'];
source_wildcard = '*main*tif';
output_path = ''; % fluo_batch_out is default

% step 1: register using norm x corr on 5 stillest frames as target
processor_names{1} = 'imreg';
pr_params.spmv = 1;
pr_params.tpmv = 2;
pr_params.t_img_mode = 1;
pr_params.t_img_stillest_nframe = 5;
pr_params.meth =  9;
processor_params{1} = pr_params;


% step 2: register using piecewise on 5 stillest frames as target
processor_names{2} = 'imreg';
pr_params.spmv = 1;
pr_params.tpmv = 2;
pr_params.t_img_mode = 1;
pr_params.t_img_stillest_nframe = 5;
pr_params.meth =  1;
processor_params{2} = pr_params;

% step 3: postprocess for piecewise imreg
processor_names{3} = 'imreg_postprocess';
pr_params.init_mf_size = 20;
pr_params.adapt_correct_params = [0.9 1 20];
pr_params.final_mf_size = 20;;
processor_params{3} = pr_params;

% step 4: register normxcorr to stillest movie in directory
processor_names{4} = 'imreg';
pr_params.spmv = 2;
pr_params.tpmv = 2;
pr_params.t_img_mode = 3;
pr_params.t_img_stillest_nframe = 0;
pr_params.meth =  9;
processor_params{4} = pr_params;

% step 5: summarize & cleanup
processor_names{5} = 'imreg_session_stats';
pr_params.zstack_path = [];
pr_params.source_wildcard = 'Image_Registration_4_*tif';
pr_params.delete_other_tifs = 1;
processor_params{5} = pr_params;

fluo_pargen_nogui(source_path, source_wildcard, output_path, par_path, ...
                  processor_names, processor_params, 1);


