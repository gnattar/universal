%
% SP Aug 2011
%
% This function will breakup a series of volume images into individual planes
%  in subdirectories.  Subdirectories are named fov_vvppp, where vv is volume 
%  id (vol_id) and ppp is plane id (fov_id usually; e.g., 01001). These are
%  subdirectories of fpath.  Ensures that each file starts with fov 1, so some
%  files are broken up, asjusting triggerFrameStartTime and triggerTime 
%  accordingly.  Assumes standard SI4 header.
%
% USAGE:
%
%   breakup_volume_images(fpath, flist, n_planes, mode, reference_image, 
%     reference_image_offset, reference_image_frames, preview_or_xml,
%     frames_correlated, cluster_fpath, fov_ids, vol_id, imreg_wc, do_warp)
%
% PARAMS:
%
%   fpath: directory where data is, output will be
%   flist: either a wildcard (string) or list of files (cell-array -- RELATIVE 
%          path).  You can also pass comma-separated list with NO WHITESPACE!
%   n_planes: how many planes?  fov output will be to 001:n_planes, unless 
%             you give fov_ids
%   mode: 1 - use reference image ; 2 - use header to infer plane # 
%         (triggerFrameNumber)
%   reference_image: which image stack to use as reference (will use mean) --
%                    either FULL path, or image stack.  Or pass a SINGLE digit, 
%                    in which case it will use flist{reference_image} or file 
%                    # reference_image that matches flist wildcard.
%   reference_image_offset: use an offset? (e.g., to use frame 2 as 1st fov, pass 1) 
%                           default is 0.
%   reference_image_frames: which frames to use to generate averages? default all.
%                           VECTOR of frame #s.
%   preview_or_xml: if 1, will preview reference image; if blank or 0, it will 
%                   go ahead and do the breakup.  If 2, it will generate a 
%                   cluster-compatible xml in the directory with the images.
%   frames_correlated: if mode 1, this tells which frames to correlate.  If 0
%                      (default), it will ONLY check 1st frame, then assume the
%                      rest are in sequence m...n,1 2 ... n,1 2 ... n.  If a value
%                      above 0, it will check every frames_correlated'th frame 
%                      so a value of 1 means all frames checked.  Use a prime!
%   cluster_fpath: if preview_or_xml == 2, this is what path on CLUSTER will be
%   fov_ids: if you want to specify names of output dirs, pass this vector of #s
%            and it will output to these instead.  Pass a single number and 
%            fov_ids:fov_ids+n_planes-1 will be used. Must be < 1000.
%   vol_id: volume ID ; if not passed, 1 ; must be < 100.
%   imreg_wc: if you are generating image registration, wildcard for it; dfeault
%             *main*tif
%   do_warp: if generating XML, this sets the do_warp flag, telling imreg to 
%            run warp step.  Eventually should be able to pass a imreg pipeline
%            specification via XML. Default 0 (no).
%  
% EXAMPLE: for generating XML for a single volume (no vol_id) with 4 planes
%
%  offs = 3; 
%  breakup_volume_images(pwd, '*main*tif', 4, 1, 'an148378_2011_09_13_main_157.tif', ...
%    offs, 1:200, 2, 0, strrep(pwd, '/media/an148378', '/groups/svoboda/wdbp/imreg/perons'));
%
function breakup_volume_images(fpath, flist, n_planes, mode, reference_image,  ...
         reference_image_offset, reference_image_frames, preview_or_xml, ...
         frames_correlated, cluster_fpath, fov_ids, vol_id, imreg_wc, do_warp)

	SI_date_format_str = 'dd-mm-yyyy HH:MM:SS.FFF';
  d2ms = 24*60*60*1000; % date number from MATLAB to ms conversion factor

  % --- Input parse
	if (nargin < 4 || (mode == 1 && nargin < 5))
	  help('breakup_volume_images');
		error('breakup_volume_images::insufficient input arguments.');
    return;
	end

	if ((mode == 1 && nargin < 6) | (mode ~=1 && length (reference_image_offset) == 0)) ; reference_image_offset = 0; end
	if (mode == 1 && nargin < 7) ; reference_image_frames = []; end
	if (nargin < 8 || length(preview_or_xml) == 0) ; preview_or_xml = 0; end
	if (nargin < 9 || length(frames_correlated) == 0) ; frames_correlated = 0; end
	if (nargin < 11 || length(fov_ids) == 0) ; fov_ids = 1:n_planes ; end
	if (nargin < 12 || length(vol_id) == 0) ; vol_id = 1; end
	if (nargin < 13 || length(imreg_wc) == 0) ; imreg_wc = '*main*tif'; end
	if (nargin < 14 || length(do_warp) == 0) ; do_warp = 0; end
	
	if (length(fov_ids) == 1 && n_planes > 1) ; fov_ids = fov_ids:(fov_ids+n_planes-1); end

  % --- build file list
	pflist = flist ; % store passed flist for xml generation
	if (ischar(flist))
	  commalist = strfind(flist,',');
	  if (length(commalist) == 0)
			tflist = dir([fpath filesep flist]);
			if (length(tflist) == 0)
				disp('breakup_volume_images::no files matching specified pattern.');
				return;
			end
			for f=1:length(tflist) 
				nflist{f} = tflist(f).name;
			end
			flist = nflist;
		else % build flist from coma list
		  commalist = [0 commalist length(flist)+1];
		  for c=1:length(commalist)-1
			  nflist{c} = flist(commalist(c)+1:commalist(c+1)-1);
			end
			flist = nflist;
		end
	end

  % --- generate reference images if called for ...
	fov_refims = {};
	if (mode == 1)
         if (ischar(reference_image))
              if (~exist(reference_image, 'file')) % try with fpath added
                    rim = load_image_pre([fpath filesep reference_image]);
              else
                    rim = load_image_pre(reference_image);
              end
         elseif (max(size(reference_image)) == 1) % it is refering to flist member
              rim = load_image_pre(flist{reference_image}); 
         else
              rim = reference_image;
         end
    
        if (length(reference_image_frames)>0)
            rim = rim(:,:,reference_image_frames);
            if (rem(min(reference_image_frames), n_planes)-1 ~= reference_image_offset)
              disp('breakup_volume_images::your reference_image_frames must start at a multiple of reference_image_offset.');
            end
        end

        for n=1:n_planes
              fov_refims{n} = mean(rim(:,:,reference_image_offset+n:n_planes:end),3);
            end

            % preview?
            if (preview_or_xml > 0)
              nf = ceil(sqrt(n_planes));
          df = 1/nf;

          figure('Position', [100 100 800 800]);
                X = 0;
                Y = 1-df;
                Xi = 0;
                for n=1:n_planes
                  ar = subplot('Position', [X Y df df]);
                    X = X+df; Xi = Xi + 1;
                    if (Xi >= nf) ; X = 0 ; Xi = 0 ; Y = Y-df; end
                    M = 1.5*quantile(reshape(fov_refims{n},[],1),.995);
    				M = roi.roiArray.maxImagePixelValue;
                    imshow(fov_refims{n}, [0 M], 'Parent', ar, 'Border', 'tight');
                    text(50,50,num2str(n), 'Color', [1 0 0], 'FontSize', 24);
                end
                disp('breakup_volume_images::preview mode skips output.');

                if (preview_or_xml == 2) % output to XML
                 generate_xml (fpath, cluster_fpath, n_planes, pflist, imreg_wc, ...
                       reference_image,reference_image_frames,reference_image_offset, vol_id, do_warp);
                end

                return;
            end

		clear rim;
		clear reference_image;
    else

    end
    
 
  % --- prepare output directories
	for n=1:n_planes
	  fov_dir{n} = sprintf('%s%sfov_%02d%03d', fpath, filesep, vol_id, fov_ids(n));
	  if (~exist(fov_dir{n},'dir')) ; mkdir (fov_dir{n}) ; end
	end

	% --- loop for determining FOV sequence
  disp('breakup_volume_images::gathering data from files ... this will take time.');
  for f=1:length(flist)
	  [fov_sequence{f} start_time(f) n_frames(f) frame_dt(f) im_size{f}] = ...
		  get_file_info(flist{f}, mode, n_planes, fpath, fov_refims, frames_correlated);
  end
  
  % remove guys rejected by get_file_info
  good_files = find(frame_dt ~= -1);
  flist = flist(good_files);
  fov_sequence = fov_sequence(good_files);
  start_time = start_time(good_files);
  n_frames = n_frames(good_files);
  frame_dt = frame_dt(good_files);
  im_size = im_size(good_files);

  
  % sanity check::aberrant frame dt??
	if (sum(diff(frame_dt)) > 0) 
	  disp('breakup_volume_images::different frame dt among files; aborting.');
    return;
	end
	frame_dt = frame_dt(1);

	% sanity check::different image size?
  fim_size = [];
	for f=1:length(flist)
	  if (length(im_size{f}) > 0)
		  if (length(fim_size) == 0)
			  fim_size = im_size{f};
			elseif (sum(fim_size == im_size{f}) < 2)
  	    disp('breakup_volume_images::different frame size among files; aborting.');
	  		return;
			end
		end
	end

	% --- process the derived sequence to determine output file mapping

	% 1) sort by order of timestamp
  [irr indexing] = sort(start_time);
	flist = flist(indexing);
	fov_sequence = fov_sequence(indexing);
  im_size = im_size(indexing);
	start_time = start_time(indexing);
	n_frames = n_frames(indexing);
	triggerFrameStartTime_offset = zeros(1,length(indexing)); % in seconds -- how much we will add to triggerFrmeStartTime in hdr
  
	% 2) breakup into contiguous blocks -- sequences of files separated by less than 1 frame dt
	block_membership = ones(1,length(flist));
	bi = 1;
  for f=1:length(flist)-1
	  block_membership(f) = bi;
	  next_start = (n_frames(f)+0.9)*frame_dt + start_time(f);
		if (start_time(f+1) > next_start) ; bi = bi + 1; end
	end
	block_membership(end) = bi;


	% 3) breakup into files that start/end with FOV 1/n_planes
	% build up a original_file_membership, (expanded) block_membership,
	%  and fov_sequence vector for session 
	total_n_frames = sum(n_frames);
	original_file_membership = nan*zeros(1,total_n_frames);
	final_file_membership = nan*zeros(1,total_n_frames);
	frame_block_membership = nan*zeros(1,total_n_frames);
	frame_fov_sequence = nan*zeros(1,total_n_frames);
	frame_within_file_frame_idx = nan*zeros(1,total_n_frames);
	val_frames = ones(1,total_n_frames);

	% frame-based vectors 
	fi = 1;
	for f=1:length(flist)
	  original_file_membership(fi:fi+n_frames(f)-1) = f;
	  frame_block_membership(fi:fi+n_frames(f)-1) = block_membership(f);
	  frame_fov_sequence(fi:fi+n_frames(f)-1) = fov_sequence{f};
		frame_within_file_frame_idx(fi:fi+n_frames(f)-1) = 1:n_frames(f);
		fi = fi+n_frames(f);
	end

  % for each block, loop thru its files ...
	u_blocks = unique(block_membership);
	for b=1:length(u_blocks)
    bi = find(frame_block_membership == u_blocks(b));

    u_block_files = unique(original_file_membership(bi));

    for f=1:length(u_block_files) 
      f_idx = u_block_files(f);
			fi = find(original_file_membership == f_idx);

			% ensure file starts will frame 1 
			first_i = min(fi);
			start_f = first_i;
      if (frame_fov_sequence(first_i) ~= 1) % block DOES NOT start with one? *discard* those frames
			  first_1 = fi(min(find(frame_fov_sequence(fi) == 1)));
				if (length(first_1) == 0) % in this case discard *all* from this file
          val_frames(fi) = 0;
					start_f = -1;
				else
				  df = first_1-first_i; % how many frames from start is first frame in fov1?
					start_f = first_1;
          
					% increment trggerFrameStartTime_offset --> frame_dt is in ms so convert to seconds
	        triggerFrameStartTime_offset(f_idx) = frame_dt*df/1000; % in seconds

					% if this is FIRST file, discard previous frames ...
					if (f == 1)
					  val_frames(first_i:first_1-1) = 0;
					end
        end
			end

			% ensure file ends with frame n_planes --> steal from next file in block if possible, OR
			%  discard the frames
			last_i = max(fi);
			end_f = last_i;
			if (frame_fov_sequence(last_i) ~= n_planes)
			  discard = 0;

			  % possible to steal from next file in block?
				candi_frames = bi(find(frame_fov_sequence(bi) == n_planes));
				if (length(candi_frames) > 0)
				  if (length(find(candi_frames > last_i)) > 0)
					  end_f = candi_frames(min(find(candi_frames > last_i)));
					else
					  discard = 1;
					end
				else
				  discard = 2;
				end

				if (discard == 1) % move BACK to find previous one
				  end_f = candi_frames(max(find(candi_frames < last_i)));
					val_frames(end_f+1:last_i) = 0;
				elseif (discard == 2) % discard ALL --> NO termination planes
				  disp('breakup_volume_images::found a file with NO final-FOV frames.');
				  val_frames(bi) = 0;
				end
			end
			
			% assign final_file_membership
      if (start_f > 0 )
			  final_file_membership(start_f:end_f) = f_idx;
      end
		end
	end

	% 4) actual output based on flist, original&final file_membership
  disp('breakup_volume_images::building output files ...');
	uf = unique(final_file_membership(find(~isnan(final_file_membership))));
	for f=1:length(uf)

	  % prebuild tif with ALL FOVs
		fi = find(final_file_membership == uf(f));
    if (length(fi) == 0) ; disp(['No data for ' flist{uf(f)}]); continue ; end
		fim = zeros(fim_size(1), fim_size(2), length(fi));

		% load necessary files 
		u_ofi = unique(original_file_membership(fi));
		for u=1:length(u_ofi)
		  [im irr] = load_image_pre ([fpath filesep flist{u_ofi(u)}]);
			ui = find(original_file_membership(fi) == u_ofi(u));
			fim(:,:,ui) = im(:,:,frame_within_file_frame_idx(fi(ui)));
    end
    
    % update header
		[irr improps] = load_image_pre ([fpath filesep flist{uf(f)}]);
		ihdr = improps.header;
		tr_s = strfind(ihdr, 'ScanImage.SI4App.triggerFrameStartTime') +length('ScanImage.SI4App.triggerFrameStartTime = ');
    if (length(tr_s) == 0)
   		tr_s = strfind(ihdr, 'scanimage.SI4.triggerFrameStartTime') +length('scanimage.SI4.triggerFrameStartTime = ');
    end

		newline_idx = find(ihdr == 10);
		tr_e = newline_idx(min(find(newline_idx > tr_s)))-1;
		ihdr = [ihdr(1:tr_s-1) num2str(str2num(ihdr(tr_s:tr_e))+triggerFrameStartTime_offset(uf(f))) ihdr(tr_e+1:end)];
		improps.header = ihdr;
		
		% output *individual FOVs*
	  disp(['breakup_volume_image::outputting ' flist{uf(f)}]);
		for n=1:length(fov_dir)
			used_idx = find(frame_fov_sequence(fi) == n);
			if (length(used_idx) > 0)
				nim = fim(:,:,used_idx);
% IN HEADER, UPDATE START TIME, TRIGGER OFFSET
				save_image(nim, [fov_dir{n} filesep flist{uf(f)}], improps.header);
			end
		end
	end

%
% Gets the timestamp and FOV sequence for a single file
%
function [fov_sequence start_time n_frames frame_dt im_size] = ...
  get_file_info(fname, mode, n_planes, fpath, fov_refims, frames_correlated)
  
  fov_sequence = [];
	start_time = -1;
	frame_rate = -1;
	frame_dt = -1;
  n_frames = 0;
	im_size = [];
	 
  % --- load ; prelims
	try
		disp(['breakup_volume_image::gathering frame info for ' fname]);

		% skip if > 500 mb
		fh = fopen([fpath filesep fname]);
		fseek(fh,0,'eof');
		fsize = ftell(fh);
		fclose(fh);
		if (fsize > 500000000)
			disp(['breakup_volume_image::found excessively large file ; skipping ' fname]);
			return;
		end
	 
		% load ; get start_time
		[im improps] = load_image_pre([fpath filesep fname]);
		n_frames = size(im,3);
		fov_sequence = zeros(1,n_frames); % vector for FOV ID for each frame ...
		start_time = improps.startTimeMS;
		frame_dt = 1000/improps.frameRate/improps.numPlanes;
		im_size = [improps.height improps.width];

		% --- do the breakup --> assign each frame an fov
		if (mode == 1)
			if (frames_correlated == 0 )
				fc_vec = 1 ;
			else
				fc_vec = 1:frames_correlated:n_frames;
			end

			% check all the frames you are supposed to check
			for i=fc_vec
				disp(['breakup_volume_image::processing frame ' num2str(i) ' for ' fname]);
				score = zeros(1,n_planes);
				for n=1:n_planes
					% for speedup, use downsampled image
% 					im1 = im(1:4:end,1:4:end, i);%%GRchange
% 					im2 = fov_refims{n}(1:4:end,1:4:end);
                    im1 = im(1:1:end,1:1:end, i);
					im2 = fov_refims{n}(1:1:end,1:1:end);
	%	  		cim = normxcorr2(im(:,:,i),fov_refims{n});
					cim = normxcorr2(im1,im2);
					score(n) = max(max(cim));
				end
				[irr idx] = max(score);
				fov_sequence(i) = idx;
			end

			% build up rest of fov_sequence OR check it if needed -- assumption is
			%  that frames are SEQUENTIAL
			if (frames_correlated ~= 1 & n_frames > 0)
				expected_sequence = repmat(1:n_planes, 1, ceil(n_frames/n_planes)+n_planes);
				expected_sequence = expected_sequence(fov_sequence(1):fov_sequence(1)+n_frames-1);
				if (frames_correlated == 0)
					fov_sequence = expected_sequence;
				else
					% longer than 1 and frames_correalted > 0?  check if right for ones that were done ...
					checked = setdiff(find(fov_sequence > 0),1);
					if (length(checked) > 0)
						if (sum(fov_sequence(checked) == expected_sequence(checked)) ~= length(checked))  
							disp(['breakup_volume_image::expected sequence deviated from detected sequence ; skipping ' fname]);
							fov_sequence = []; start_time = -1; frame_rate = -1; frame_dt = -1; n_frames = 0; im_size = [];
							return;
						else
							fov_sequence = expected_sequence;
						end
					else
						fov_sequence = expected_sequence;
					end
				end
			end
		elseif (mode == 2) % simply use the firstFrameNumberRelTrigger field
			expected_sequence = repmat(1:n_planes, 1, ceil(n_frames/n_planes)+2*n_planes);
			first_frame_offset = rem(improps.firstFrameNumberRelTrigger, n_planes);
			if (improps.firstFrameNumberRelTrigger == 1) ; first_frame_offset =0 ; end % this is a special bug case -- neg trig time?
			fov_sequence = expected_sequence(first_frame_offset+(1:n_frames));
		else
			disp(['Mode ' num2str(mode) ' not currently supported.']);
		end

		% --- check for aberrant orderings
		dfi = diff(fov_sequence);
		inval = find(~ismember(dfi, [1 -1*(n_planes-1)]));
		if (length(inval) > 0) 
			disp(['breakup_volume_image::found aberrant ordering ; skipping ' fname]);
			fov_sequence = [];
			return;
		end
	catch % just set defaults and return 
		disp(['breakup_volume_image::file was corrupt, skipping ' fname]);
		fov_sequence = [];
		start_time = -1;
		frame_rate = -1;
		frame_dt = -1;
		n_frames = 0;
		im_size = [];
	end
	

%
% Generates XML file for imreg on cluster
%
function generate_xml (data_path, cluster_rawdata_path, num_fovs, prebreakup_image_wc, ...
              postbreakup_image_wc, base_image_fname,base_image_frames, offset, vol_id, do_warp)
    
    cluster_rawdata_path =  strrep(cluster_rawdata_path, 'GR_Data01/2PData_proc/BehaviorImaging/', sprintf('mageelab/GR_dm11/imreg/'));
% 	par_path = strrep(cluster_rawdata_path, 'scanimage', sprintf('parout_imreg_%02d%%###', vol_id));
    par_path = cluster_rawdata_path; %%GRchange
	base_frames = [num2str(base_image_frames(1)) ' ' num2str(base_image_frames(length(base_image_frames)))];

    outstr = '<?xml version="1.0" encoding="UTF-8" ?>';
	outstr = sprintf('%s\n%s', outstr, '<imreg_par_data>');
	outstr = sprintf('%s\n\t<rawdata_path>%s</rawdata_path>', outstr, cluster_rawdata_path);
	outstr = sprintf('%s\n\t<par_path>%s</par_path>',outstr, par_path);
	outstr = sprintf('%s\n\t<base_image_fname>%s</base_image_fname>', outstr, base_image_fname);
    outstr = sprintf('%s\n\t<base_image_frames>%s</base_image_frames>', outstr, base_frames);
	outstr = sprintf('%s\n\t<num_fovs>%d</num_fovs>', outstr, num_fovs);
	outstr = sprintf('%s\n\t<volume_id>%d</volume_id>', outstr, vol_id);
	outstr = sprintf('%s\n\t<offset>%d</offset>', outstr, offset);
	outstr = sprintf('%s\n\t<do_warp>%d</do_warp>', outstr, do_warp);
	outstr = sprintf('%s\n\t<prebreakup_image_wildcard>%s</prebreakup_image_wildcard>', outstr, prebreakup_image_wc);
	outstr = sprintf('%s\n\t<postbreakup_image_wildcard>%s</postbreakup_image_wildcard>', outstr, postbreakup_image_wc);
	outstr = sprintf('%s\n%s\n', outstr, '</imreg_par_data> ');

	disp(outstr);

  % write the file
	fid = fopen([data_path filesep sprintf('imreg-%02d.xml', vol_id)], 'w');
	fprintf(fid, '%s', outstr);
  fclose(fid);
