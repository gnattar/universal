
% SP Sep 2011
%
% This is a par_execute-compliant file with no subfunc and only one parameter -
%  the path of the XML file that contains info needed to run imreg.  IT will
%  run breakup_volume_images, then generate parfiles to do image registration.
%
%  Those parallel jobs need to be run outside of this.  
%
% USAGE:
%
%  imreg_par_fromxml(xml_path, skip_breakup)
%
%  xml_path: XML file to use to direct procedure
%  skip_breakup: if 1, it will NOT do breakup and only generate parfiles
%
function imreg_par_fromxml(xml_path, skip_breakup)

  if (nargin < 1) ; help ('imreg_par_fromxml'); error ('Must specify xml_path at least.'); end
  if (nargin <2 || length(skip_breakup) == 0) ; skip_breakup = 0; end

  % --- pull from XML file -- can't use native because stupid Java not in cluster version 
	fid = fopen(xml_path,'r');
	fseek(fid,0,1); file_size = ftell(fid);
	fseek(fid,0,-1) ; file_content = char(fread(fid,file_size))';
	fclose(fid);
 
  % read in file
	tag = {'rawdata_path', 'par_path', 'base_image_fname','base_image_frames', 'num_fovs', 'volume_id', 'offset', 'prebreakup_image_wildcard', 'postbreakup_image_wildcard', 'do_warp'};
	for t=1:length(tag)
	  ts = strfind(file_content,['<' tag{t} '>']) + length(tag{t}) + 2;
	  te = strfind(file_content,['</' tag{t} '>']) - 1;
		if (length(ts) > 0)
			text{t} = file_content(ts:te);
		else
      text{t} = [];
    end
	end

	% pull relevant elements
	rdi = find(strcmp(tag, 'rawdata_path'));
	ppi = find(strcmp(tag, 'par_path'));
	bifni = find(strcmp(tag, 'base_image_fname'));
    bifri= find(strcmp(tag, 'base_image_frames'));%%GRchange
	nfi = find(strcmp(tag, 'num_fovs'));
	vidi = find(strcmp(tag, 'volume_id'));
	oi = find(strcmp(tag, 'offset'));
	preiwci = find(strcmp(tag, 'prebreakup_image_wildcard'));
	postiwci = find(strcmp(tag, 'postbreakup_image_wildcard'));
	dwi = find(strcmp(tag, 'do_warp'));

	rawdata_path = text{rdi};
	par_path = text{ppi};
	base_image_fname = text{bifni};
	num_fovs = str2num(text{nfi});
	volume_id = str2num(text{vidi});
	offset = str2num(text{oi});
    baseframes =text{bifri};
	prebreakup_image_wildcard = text{preiwci};
	postbreakup_image_wildcard = text{postiwci};

    split=find(isspace(baseframes));
    base_image_frames = [(str2num(baseframes(1:split-1))) : str2num(baseframes(split+1:length(baseframes)))];
    
	if (length(dwi) > 0 && length(text{dwi}) > 0)
		do_warp = str2num(text{dwi});
	else
	  do_warp = 0;
    end
    
    
	% --- now breakup FOVs
% 	if (~skip_breakup) ; breakup_volume_images(rawdata_path, prebreakup_image_wildcard, num_fovs,1,base_image_fname, offset,[],0,57,[],[],volume_id); end
	if (~skip_breakup) ; breakup_volume_images(rawdata_path, prebreakup_image_wildcard, num_fovs,1,base_image_fname, offset,base_image_frames,0,0,rawdata_path,1,1,'*main*tif',1); end %%GRchange

	% --- setup image-registration
	source_path = sprintf('%s%s%%wc{fov_%02d*}', rawdata_path, filesep, volume_id);
	source_wildcard = postbreakup_image_wildcard;
	output_path = ''; % fluo_batch_out is default

	% step 1: register using dft  on 5 stillest frames as target
	processor_names{1} = 'imreg';
	pr_params.spmv = 1;
	pr_params.tpmv = 2;
	pr_params.t_img_mode = 1;
	pr_params.t_img_stillest_nframe = 5;
	pr_params.meth =  10;
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

	% step 4: register dft to stillest movie in directory
	processor_names{4} = 'imreg';
	pr_params.spmv = 2;
	pr_params.tpmv = 2;
	pr_params.t_img_mode = 3;
	pr_params.t_img_stillest_nframe = 0;
%	pr_params.meth =  9; % OLD: jan 2012
	pr_params.meth =  10;
	processor_params{4} = pr_params;

	% step 5: WARP
	if (do_warp)
		processor_names{5} = 'imreg';
		pr_params.spmv = 2;
		pr_params.tpmv = 2;
		pr_params.t_img_mode = 3;
		pr_params.t_img_stillest_nframe = 0;
	%	pr_params.meth =  9; % OLD: jan 2012
		pr_params.meth =  11;
		processor_params{5} = pr_params;


		% step 6: summarize & cleanup (OLD 5)
		processor_names{6} = 'imreg_session_stats';
		pr_params.zstack_path = [];
		pr_params.source_wildcard = 'Image_Registration_5_*tif';
		pr_params.delete_other_tifs = 1;
		processor_params{6} = pr_params;
	else
		% step 5: summarize & cleanup 
		processor_names{5} = 'imreg_session_stats';
		pr_params.zstack_path = [];
		pr_params.source_wildcard = 'Image_Registration_4_*tif';
		pr_params.delete_other_tifs = 1;
		processor_params{5} = pr_params;
	end

	fluo_pargen_nogui(source_path, source_wildcard, output_path, par_path, ...
											processor_names, processor_params, 1);


