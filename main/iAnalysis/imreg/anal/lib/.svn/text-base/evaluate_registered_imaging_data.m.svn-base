%
% S Peron Apr 2010
%
% This will go thru and compile, for a given set of files that have been thru 
%  imreg, dx, dy, mean and median luminance for each frame.  Based on these, it
%  will return a vector, accept, that is 0 for aberant trials and 1 for trials
%  that satisfy luminance and motion criteria.  Also returns stats on all files,
%  frames, and the file that was used as the main target for all image registration.
%
% Note that in addition to the .tif file, a .imreg_out file *must* exist in the
%  directory.
%
% im_file_path is the top path that is used, im_file_wc is the wildcard within
%  the directory; file list obtained via dir call.
%
% Returns:
%  accept: 1 or 0 ; indexing corresponds to im_file_data
%  im_file_data: structure with following fields:
%    .fullpath: filename of image file this summarizes
%    .dx: dx for each frame imreg applied
%    .dy: dy for each frame imreg applied
%    .mu_lum: mean luminance for each frame 
%    .med_lum: median luminance for each frame 
%  master_target_idx: within im_file_data, which file was used as the master 
%    target for the final image registration step (off of imreg_err_file.mat);
%    -1 if not found.
%    
%
% USAGE:
%
% [accept im_file_data master_target_idx] = evaluate_registered_imaging_data(im_file_path, im_file_wc)
%
function [accept im_file_data master_target_idx] = evaluate_registered_imaging_data(im_file_path, im_file_wc)

  % --- definitions
	sw_size = 21; % slding window size (must be odd)
	min_size_for_sw = sw_size*5; % must have at least this many trials for sliding

  % --- sanity
	if (exist(im_file_path,'dir') == 0)
	  disp(['evaluate_registered_imaging_data::' im_file_path ' not a valid directory.']);
	end
	if (nargin == 1) ; im_file_wc = '*.tif' ; end

	% --- get directory list and SORT
	fl = dir ([im_file_path filesep im_file_wc]);
	for f=1:length(fl)
	  fn{f} = fl(f).name;
	end
	[irr si] = sort(fn);
	fl = fl(si);

	% --- figure out trial used for final registration step (imreg_err_file.mat)
	master_target_idx = -1;
	ief_path = [im_file_path filesep 'imreg_err_file.mat'];
	if (exist(ief_path, 'file') == 0)
	  disp(['evaluate_registered_imaging_data::' ief_path ' not found; not assigning master file.']);
	else
	  tp = load(ief_path);
		str = tp.tgt_path;
		uidx = find(str == '_');
		pidx = find(str == '.');
		master_idx_str = str(uidx(length(uidx)):pidx(length(pidx)));
	end
	for f=1:length(fl)
		str = fl(f).name;
		uidx = find(str == '_');
		pidx = find(str == '.');
		master_idx_candidate_str = str(uidx(length(uidx)):pidx(length(pidx)));
		if (strcmp(master_idx_str, master_idx_candidate_str))
		  master_target_idx = f;
			disp(['evaluate_registered_imaging_data::master target is ' str]);
			break;
		end
	end

  % --- loop over the files ...
	dx = zeros(1,length(fl)); % sstores mean dx for each file
	dy = zeros(1,length(fl)); % store smean dy
	ml = zeros(1,length(fl)); % mean of single frame median luminances
	mdl = zeros(1,length(fl)); % maximal change in median luminance between frames
	for f=1:length(fl)
		disp(['evaluate_registered_imaging_data:: processing ' fl(f).name]);
		dx(f) = NaN;

    % file names
	  fname_tif = [im_file_path filesep fl(f).name];
		fname_imregout = strrep(fname_tif, '.tif', '.imreg_out');

    % default parameters
    im_file_data(f).fullpath = fname_tif;
		im_file_data(f).dx = [];
		im_file_data(f).dy = [];
		im_file_data(f).mu_lum = [];
		im_file_data(f).med_lum = [];
   
		% check for imreg file ... abort otherwise!!
		if(exist(fname_imregout,'file') == 0)
			disp(['evaluate_registered_imaging_data::' fname_imregout ' not found; will assume it is a bad .tif.']);
		else % the meat

		  % get params from imregout
		  load(fname_imregout, '-mat');
			im_file_data(f).dx = dx_r;
			im_file_data(f).dy = dy_r;

      % params from image
			[im improps] = load_image(fname_tif);
			med_lum = []; mu_lum = [];
			for n=1:size(im,3)
			  im_vec = reshape(im(:,:,n),[],1);
        mu_lum(n) = mean(im_vec);
        med_lum(n) = median(im_vec);
			end
			im_file_data(f).mu_lum = mu_lum;
			im_file_data(f).med_lum = med_lum;

			% assign evaluated params
			dx(f) = mean(dx_r);
			dy(f) = mean(dy_r);
			ml(f) = mean(im_vec);
			% this stores maximal single frame fluo change to find bad trials
			if (size(im,3) > 1)
			  d_lum = abs(diff(med_lum));
			  mdl(f) = max(d_lum);
			else 
			  mdl(f) = 0;
			end
			disp([' mean dx: ' num2str(dx(f)) ' dy: ' num2str(dy(f)) ' lum: ' num2str(ml(f)) ' lum chg: ' num2str(mdl(f))]);
		end
  end

  % some preparation for checks
	val = find(~isnan(dx));
	dx = abs(dx);
	dy = abs(dy);
	accept = zeros(1,length(fl)); % default is REJECT!!

	% --- cutoffs -- NO sliding window
	if (length(fl) < min_size_for_sw)
		dx_thresh = mean(dx) + 2.5*std(dx);
		dy_thresh = mean(dy) + 2.5*std(dy);
		ml_thresh_u = median(ml)+2*std(ml);
		ml_thresh_l = median(ml)-2*std(ml);
		mdl_thresh = 10*median(mdl);

		% --- loop over again and decide who stays and who goes
		for f=1:length(im_file_data)
			accept(f) = accept_or_reject(fl(f).name, val(f), dx(f), dx_thresh, dy(f), dy_thresh, ...
						mdl(f), mdl_thresh, ml(f), ml_thresh_u, ml_thresh_l);
		end
	% --- sliding window
	else 
	  sw_edge = (sw_size-1)/2;
    for s=sw_edge+1:length(fl)-sw_edge
		  % thresholds
      sw_i = s-sw_edge:s+sw_edge;
			dx_thresh = mean(dx(sw_i)) + 2.5*std(dx(sw_i));
			dy_thresh = mean(dy(sw_i)) + 2.5*std(dy(sw_i));
			ml_thresh_u = median(ml(sw_i))+2*std(ml(sw_i));
			ml_thresh_l = median(ml(sw_i))-2*std(ml(sw_i));
			mdl_thresh = 10*median(mdl(sw_i));

			% apply
      accept(s) = accept_or_reject(fl(s).name, val(s), dx(s), dx_thresh, dy(s), dy_thresh, ...
			  mdl(s), mdl_thresh, ml(s), ml_thresh_u, ml_thresh_l);

			% edge? for 1:sw_edge, use first window; for end, use last window
			if (s == sw_edge+1)
				for f=1:sw_edge
					accept(f) = accept_or_reject(fl(f).name, val(f), dx(f), dx_thresh, dy(f), dy_thresh, ...
						mdl(f), mdl_thresh, ml(f), ml_thresh_u, ml_thresh_l);
				end
			elseif (s == length(fl)-sw_edge) % end
				for f=s+1:length(fl);
					accept(f) = accept_or_reject(fl(f).name, val(f), dx(f), dx_thresh, dy(f), dy_thresh, ...
						mdl(f), mdl_thresh, ml(f), ml_thresh_u, ml_thresh_l);
				end
			end
		end
	end

%
% Returns true if yo ushould accept , false if reject.  Gives nice message on
%  what criteria were satisfied.
%
function accept = accept_or_reject(name, val, dx, dx_thresh, dy, dy_thresh, mdl, mdl_thresh, ml, ml_thresh_u, ml_thresh_l)
  disp(['Evaluating ' name]);
  accept = 1;
	if (~ val)
	  disp('  previously invalidated.');
	  accept=0;
	end
	if (dx > dx_thresh)
	  disp(['  dx threshold ' num2str(dx_thresh) ' exceeded: ' num2str(dx)]);
		accept = 0;
	end
	if (dy > dy_thresh)
	  disp(['  dy threshold ' num2str(dy_thresh) ' exceeded: ' num2str(dy)]);
		accept = 0;
	end
	if (mdl > mdl_thresh)
	  disp(['  lum chg threshold ' num2str(mdl_thresh) ' exceeded: ' num2str(mdl)]);
		accept = 0;
	end
	if (ml < ml_thresh_l)
	  disp(['  lum threshold ' num2str(ml_thresh_l) ' underceded: ' num2str(ml)]);
		accept = 0;
	end
	if (ml > ml_thresh_u)
	  disp(['  lum threshold ' num2str(ml_thresh_u) ' exceeded: ' num2str(ml)]);
		accept = 0;
	end

