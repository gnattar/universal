%
% S PEron 2010 Mar
%
% This function will return a vector with z-displacement for a given movie set provided
%  a reference stack (not necessarily xy-aligned).  The operating assumption is that
%  you will be doing lots of data (a session) with a single stack, and it is also
%  assumed that your data is xy aligned to itself (i.e., image registration has been
%  performed).  Employs matlab normxcorr2.
%
% Usage:
%  
%  flist_dz = compute_dz(flist, best_stack_path, z_stack_path)
%
% Params:
%  flist - cell array of filenames to process - exact path
%  best_stack_path - exact path of the 'best stack' in flist ; 
%  z_stack_path - path to the z-stack; exact
%
% Returns:
%  flist_dz: array where flist_dz(f).dz is the vector of frame-by-frame dz for flist(f)
%
% It operates by 
%  1) fitting the z-stack to the average of the stillest stack, thereby
%     determining z=0 AND appropriate x-y displacement (basically, every plane
%     in the z-stack is rigid-registered to the target stack from step 1 and a
%     correlation is obtained.  The plane with the best correlation is considered z=0
%     and its x/y displacement is applied to the entire z-stack).
%  2) Looping through all the requested data stacks and, for each frame of each one,
%     finding the z-stack plane to which it is most correlated, thereby determining
%     z for each frame.
%
function flist_dz = compute_dz(flist, best_stack_path, z_stack_path)
  % --- prelims
	flist_path = fileparts(best_stack_path);
	optimized_z_stack_path = [flist_path filesep 'compute_dz_optimized_z.mat'];

  % --- which stack should be target for z stack?
	% load the best stack
	best_im = load_image(best_stack_path, -1, []);
	best_im = mean(best_im,3);

	% --- determine z=0, optimal x/y displacement for z stack
  % otpimized z-stack exists? load it
	if (exist(optimized_z_stack_path,'file') == 2)
	  load(optimized_z_stack_path);
	% register z-stack
	else
		z_im = load_image(z_stack_path, -1, []);
		imreg_opt.wb_on = 1; % gui mode is assumed
		imreg_opt.debug = 0;
		disp(['compute_dz::generating ' optimized_z_stack_path '... This may take a while.']);
    [im_c warp_parms_r E] = imreg_warp_via_subregion(z_im, best_im, imreg_opt);

    % apply *best* warp to all images
    [val best_idx] = max(E);
		z_0 = best_idx;
		for f=1:size(z_im,3)
		  z_im(:,:,f) =  extern_warpImage(z_im(:,:,f), warp_parms_r(best_idx).originalMarks, warp_parms_r(best_idx).desiredMarks);
		end

		% save optimized z-stack
		save(optimized_z_stack_path, 'z_im', 'z_0');
		disp(['compute_dz::generated ' optimized_z_stack_path]);
	end

	% --- THE HEART OF THE MATTER -- run through files and compute dz
	% get indices in dim1 and dim2 you will actually use for your normxcorr2 *template*
	S = size(z_im);
	d1=round(3*S(1)/8):round(5*S(1)/8);
	d1=round(S(1)/4):round(3*S(1)/4);
	d2=round(3*S(2)/8):round(5*S(2)/8);
	d2=round(S(2)/4):round(3*S(2)/4);

  % z image normalize luminance
	for f=1:size(z_im,3)
	  z_im(:,:,f) = normalize_via_gaussconvdiv(z_im(:,:,f), 0.02);
	end

  % loop w. work
  for f=1:length(flist)
	  tic;
    disp(['Processing ' flist{f}]);

	  % load image
		[im im_props] = load_image(flist{f}, -1, []);


		% loop over frames, fitting each frame to each z frame
		dz_vec = [];
		for i=1:size(im,3)
			disp(['Processing frame ' num2str(i) ' of ' num2str(size(im,3))]);
		  sim_t = im(d1,d2,i);

			% normalize luminance
			nim = normalize_via_gaussconvdiv(sim_t, 0.02);
			st = ceil((size(nim)-[1 1])/2); % size of template - i.e., target image
			for z=1:size(z_im,3)
				% compute normxcorr and trim borders
				nxc_im = normxcorr2(nim,z_im(:,:,z));
				nxc_im = nxc_im(st(1):size(nxc_im,1)-st(1)-1, st(2):size(nxc_im,2)-st(2)-1) ; % remove borders

        % vectorize, find max
				nxc_im_v = reshape(nxc_im, [], 1);
				[corrval idx] = max(nxc_im_v);

        % store it
				corr_v(z) = corrval;
			end
			% take max corr -- this is your best match
			[corr_max idx_max] = max(corr_v);
			dz_vec(i) = idx_max-z_0;
		end
		flist_dz(f).dz = dz_vec;
	  toc;
%		subplot(2,1,1) ; plot(dz(:,f)); axis([0 100 -16 16]); 
%		subplot(2,1,2); imshow(mean(im,3), [0 4000]) ; axis square ;pause
	end




