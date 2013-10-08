%
% [im_c warp_parms_r E] = imreg_warp_via_subregion(im_s, im_t, opt)
%
% Given two images, finds optimal warp transform between the two
%  images by breaking the source image into many subimages, determining 
%  x/y offset for each of those subimages, and using extern_warpImage to
%  get a full warp field from the passed points.
%
%  Returns the corrected image im_c; im_s is source image, im_t is 
%  target image (i.e., shifts source so it fits with target). Also returns
%  error for each frame, E, which is correlation based - so 1 => no error.
%  warp_parms_r(f) contains originalMarks and desiredMarks so you can run
%  extern_warpImages thereby.
%
% Note that im_s can be a stack; in this case, so will im_c.
%
% opt - structure containing parameters 
%       opt.wb_on - if set to 0, no wb
%       opt.debug
%       opt.n_divs - how many divisions to make *per side* - if
%          you specify, e.g., 5, it will make the middle 95% of
%          the image into a 5 x 5 grid and use each of the squares as subim.
%          If you provide 2 numbers, first is for hor (x), second ver (y)
%       opt.subim_size - [x y] size of the subimage to use ; default is to 
%          just space the images based on n_divs so they touch
%       opt.lum_gauss_sd_size - how big of a gaussian to prenormalize with,
%          in FRACTION of image size (.05 dflt)
%      
%
function [im_c warp_parms_r E] = imreg_warp_via_subregion(im_s, im_t, opt)
	E = [];
 
	% --- variable defaults 
	wb_on = 0;
	n_divs = 7;
	debug = 0;
	lum_gauss_sd_size = 0.05;
  subim_size	= [nan nan];
	if (isstruct(opt))
		if (isfield(opt,'n_divs'))
		  n_divs = opt.n_divs;
		end
		if (isfield(opt,'debug'))
		  debug = opt.debug;
		end
    if (isfield(opt,'wb_on'))
		  wb_on = opt.wb_on;
		end
		if (isfield(opt, 'subim_size'))
		  subim_size = opt.subim_size;
		end
		if (isfield(opt, 'lum_gauss_sd_size'))
		  lum_gauss_sd_size = opt.lum_gauss_sd_size;
		end
  end
	if (length(n_divs) == 1) ; n_divs = [n_divs n_divs]; end

	% flip n_divs, subim_size to account for flip of x/y in images
  n_divs = n_divs(2:-1:1);
	subim_size = subim_size(2:-1:1);

	% --- sanity
	if ((size(im_s,1) == size(im_t,1)) + (size(im_s,2) == size(im_t,2)) < 2)
	  disp('imreg_warp_via_transform::im_s and im_t are different sizes; aborting.');
	end

  % 0) setup

	% --- prepare images
	im_c = zeros(size(im_s)); % corrected image
	S = size(im_s);
	if (length(S) == 3) ; F = S(3) ; else F = 1; end

  % compute subimage centers
	if (isnan(subim_size(1))) ; subim_size(1) = S(1)/(n_divs(1)); end
	dcen(1) = (S(1)-subim_size(1))/n_divs(1);
  subimCen1 = round(linspace((subim_size(1)/2),S(1)-(subim_size(1)/2), n_divs(1)));
	if (isnan(subim_size(2))) ; subim_size(2) = S(2)/(n_divs(2)); end
	dcen(2) = (S(2)-subim_size(2))/n_divs(2);
  subimCen2 = round(linspace((subim_size(2)/2),S(2)-(subim_size(2)/2), n_divs(2)));

	% floor subim_size here
	subim_size = floor(subim_size);

	% --- normalize light intensity via gaussian
	nim_s = im_s;
	if (wb_on) ; wb = waitbar(0, 'Warp: gaussian normalization ...'); end
	for f=1:F
	  if (wb_on) ; waitbar(f/F,wb); end
		nim_s(:,:,F) = normalize_via_gaussconvdiv(im_s(:,:,F),lum_gauss_sd_size);
	end
	nim_t = normalize_via_gaussconvdiv(im_t,lum_gauss_sd_size);

	% 1) run algo
	offsVec1 = -1*(floor(subim_size(1)/2)-1):(floor(subim_size(1)/2)-1);
	offsVec2 = -1*(floor(subim_size(2)/2)-1):(floor(subim_size(2)/2)-1);
	for f=1:F
	  % --- first, break the image up into subregions and get all dx, dy
		% store coms for subims
		com_1 = []; 
		com_2 = [];
		dx = [];
		dy = [];
		d = 1;
    for d1=1:n_divs(1)
		  for d2=1:n_divs(2)
			  sub_im = nim_s(subimCen1(d1)+offsVec1, subimCen2(d2)+offsVec2, f);
				com_1(d) = subimCen1(d1);
				com_2(d) = subimCen2(d2);
        [dx(d) dy(d)] = get_subimage_displacement(nim_t, sub_im, com_2(d), com_1(d));
				if (debug) ; disp(['com x y : ' num2str(com_2(d)) ' ' num2str(com_1(d)) ' dx,dy: ' num2str(dx(d)) ',' num2str(dy(d))]); end
        d=d+1;
			end
		end

    % show warpfield
		if (debug)
		  df= figure;
      subplot(2,2,1);	imshow(im_s(:,:,f), [0 max(max(im_s(:,:,f)))]) ; axis square;
      subplot(2,2,2);	imshow(im_t, [0 max(max(im_t))]) ; axis square;
		  for d=1:length(com_1)
			  subplot(2,2,1);
			  hold on;
        plot(com_2(d), com_1(d), 'rx');
        plot([com_2(d) com_2(d)+dx(d)], [com_1(d) com_1(d)+dy(d)], 'y-');
				subplot(2,2,2);
			  hold on;
        plot(com_2(d), com_1(d), 'rx');
        plot([com_2(d) com_2(d)+dx(d)], [com_1(d) com_1(d)+dy(d)], 'y-');
			end
		end

		% --- correct for outliers -- if com_1, com_2 distance differs from 
		%      ncom_1, ncom_2 distance by a lot, this suggests the points where 
		%      displaced non-uniformly, which does not make sense in a near-
		%      affine transform.

		% first compute distances in original space ...
	  t_dist = zeros(length(com_1),length(com_1));
		for c1=1:length(com_1)
			t_dist(c1,c1) = 0;
			for c2=1:length(com_1)
				D = sqrt(((com_1(c1)-com_1(c2))^2)+((com_2(c1)-com_2(c2))^2));
				t_dist(c1,c2) = D;
				t_dist(c2,c1) = D;
			end
		end
		ncom_1 = com_1+dy;
		ncom_2 = com_2+dx;

		% determine rejects 
    [reject d_distro] = determine_redos_dist(t_dist, 5, dx, dy, com_1, com_2);
		accept = ~reject;
 
    % too many rejects? try again with a subset ...
		if (length(find(accept == 1)) < 0.25*length(dx)) 
			for d=1:length(com_1)
				displacement(d) = sqrt(dx(d)*dx(d) + dy(d)*dy(d));
			end
			disp_range = [max(0,median(displacement)-std(displacement)) median(displacement)+std(displacement)];
			vals = find(displacement>disp_range(1) & displacement < disp_range(2));
			reject = 0*reject+1;
			[nreject d_distro] = determine_redos_dist(t_dist(vals,vals), 5, dx(vals), dy(vals), com_1(vals), com_2(vals));
			if (debug) ; disp(['Accepts before: ' num2str(length(find(~reject)))]); end
      reject(vals) = nreject;
			if(debug) ; disp(['After: ' num2str(length(find(~reject)))]); end
		end
		accept = ~reject;
 
    % too many rejects? try again with a FORCED subset
		if (length(find(accept == 1)) < 0.25*length(dx)) 
			for d=1:length(com_1)
				displacement(d) = sqrt(dx(d)*dx(d) + dy(d)*dy(d));
			end
			disp_range = [0 50];
			vals = find(displacement>disp_range(1) & displacement < disp_range(2));
			reject = 0*reject+1;
			[nreject d_distro] = determine_redos_dist(t_dist(vals,vals), 5, dx(vals), dy(vals), com_1(vals), com_2(vals));
			if (debug) ; disp(['Accepts before: ' num2str(length(find(~reject)))]); end
      reject(vals) = nreject;
			if(debug) ; disp(['After: ' num2str(length(find(~reject)))]); end
		end
		accept = ~reject;


		% FAILURE - then apply NO correction
		if (length(find(accept == 1)) < 0.25*length(dx)) 
		  disp('imreg_warp_via_subregion::could not fit -- more than 75%of subregions were off.  Setting displacement to 0.');
			originalMarks = {};
			desiredMarks = {};
			for m=1:length(com_1)
				originalMarks{m}(1) = com_2(m);
				originalMarks{m}(2) = com_1(m);
				desiredMarks{m}(1) = com_2(m);
				desiredMarks{m}(2) = com_1(m);
			end
			warp_parms_r(f).originalMarks = originalMarks;
			warp_parms_r(f).desiredMarks = desiredMarks;
			im_c(:,:,f) = im_s(:,:,f);
		% --- apply warp transofmr if OK
		else
		  vals = find(accept);
			if (length(vals) ~= length(accept)) ; disp(['imreg_warp_via_subregion::rejecting ' ...
			  num2str(length(accept)-length(vals)) ' outliers.']); end
%% interpolate outliers, edges by looking at interp2 twice: once for dx, once for dy
			com_1 = com_1(vals);
			com_2 = com_2(vals);
			ncom_1 = ncom_1(vals);
			ncom_2 = ncom_2(vals);
			dx = dx(vals);
			dy = dy(vals);
			originalMarks = {};
			desiredMarks = {};
			for m=1:length(com_2)
				originalMarks{m}(1) = com_2(m);
				originalMarks{m}(2) = com_1(m);
				desiredMarks{m}(1) = ncom_2(m);
				desiredMarks{m}(2) = ncom_1(m);
			end
			warp_parms_r(f).originalMarks = originalMarks;
			warp_parms_r(f).desiredMarks = desiredMarks;
			im_c(:,:,f) = extern_warpImage(im_s(:,:,f), originalMarks, desiredMarks);

			% show corrected warpfield
			if (debug)
				figure(df);
				subplot(2,2,3);	imshow(im_s(:,:,f), [0 max(max(im_s(:,:,f)))]) ; axis square; title('corrected warpfield');
				subplot(2,2,4);	imshow(im_t, [0 max(max(im_t))]) ; axis square; title('corrected warpfield');
				for d=1:length(com_1)
					subplot(2,2,3);
					hold on;
					plot(com_2(d), com_1(d), 'rx');
					plot([com_2(d) com_2(d)+dx(d)], [com_1(d) com_1(d)+dy(d)], 'y-');
					subplot(2,2,4);
					hold on;
					plot(com_2(d), com_1(d), 'rx');
					plot([com_2(d) com_2(d)+dx(d)], [com_1(d) com_1(d)+dy(d)], 'y-');
				end
				if (debug == 2) ; pause; end
			end

    end
	  if (wb_on) ; waitbar(f/F,wb, 'Warp-based registration ...'); end
	end
	if (wb_on) ; delete(wb); end
  
	% 2) send to imreg_wrapup methods
	wrap_opt.err_meth = 3; % correlation based
	E = imreg_wrapup_calculate_error(wrap_opt.err_meth, im_c, im_t, 1:F);
	


%
% for a given source sub-image (subim), compute the best normxcorr2-based 
%  translation to get it to line up to somewhere in target (im_t).  Pass the
%  center of the subim because dx and dy are relative im_t, so you must then
%  offset by the x, y coordinates of where you took subim from in source 
%  image.  Thus, c_x and c_y are the coordinates of the center of subim in im_s.
%
function [dx dy] = get_subimage_displacement(im_t, subim, c_x, c_y)
	dx = 0;
	dy = 0;

  % prelims
  S = size(im_t);

  try 
		% correlation computation
		cim = normxcorr2(subim, im_t); 
		ssi = ceil((size(subim)-[1 1])/2);
		cim = cim(ssi(1):size(cim,1)-ssi(1)-1, ssi(2):size(cim,2)-ssi(2)-1) ; % remove borders
	%subplot(2,2,4); imshow(cim, [min(min(cim)) max(max(cim))]); axis square
		% compute dx, dy
		cim_v = reshape(cim,[],1);
		[corrval idx] = max(cim_v);
		x_peak = ceil(idx/S(1));
		y_peak = idx-S(1)*(x_peak-1);

		% 1 is the correction factor due to rounding issues 
		dx = x_peak-c_x-1;
		dy = y_peak-c_y-1;
	catch me
		disp('================================================================================');
	  disp('imreg_warp_via_subregion::error encountered in normxcorr2 step.');
		disp(' ');
		disp('Detailed error message: ');
		disp(getReport(me, 'extended'));
		disp (' ');
		disp('================================================================================');
	end


%
% This function decides which displacements need to be rejected based on 
%  distances to neighbors before and after displacement
%
%  n_closest: how many to consider?
% 
% Indexing of these should be same:
%  t_dist: com distance matrix (triang. symm.) ; BEFORE displacement
%  dx, dr: displacement in x and y
%  com_1,2: original coms in y, x
%
% Returns a boolean array indicating which distances are outliers, as well
%  as the distribution of distances that can be used in subsequent tests of
%  compliance.
%
function [redo d_distro] = determine_redos_dist(t_dist, n_closest, dx, dy, com_1, com_2)
  % by default everone is redo
  redo = ones(1,size(t_dist,1));
  d_distro = zeros(1,size(t_dist,1));

  % determine *new* distance matrix
	ncom_1 = com_1+dy;
	ncom_2 = com_2+dx;
	s_dist = zeros(length(com_1),length(com_1));
	for c1=1:length(ncom_1)
		s_dist(c1,c1) = 0;
		for c2=1:length(ncom_1)
			D = sqrt(((ncom_1(c1)-ncom_1(c2))^2)+((ncom_2(c1)-ncom_2(c2))^2));
			s_dist(c1,c2) = D;
			s_dist(c2,c1) = D;
		end
	end

  % main loop over com pairs
	for r=1:size(t_dist,1)
		% compute n_closest neighbors
		dists = t_dist(r,:);
		[cd closest_idx] = sort(dists);
		ndists = s_dist(r,:);

		% compute distances to neighbors that were closest
		cldist = dists(closest_idx(2:n_closest));
		ncldist = ndists(closest_idx(2:n_closest));

		% store, for this roi, distance difference
		d_distro(r) = mean(abs(cldist-ncldist));
  end

  % calculate threshold
	thresh = 7*median(d_distro); % cutoff will be 5xmedian -- usually median is close to 0
	if (thresh > 10)  % absolute threshold in case you are totally whack
	  disp(['imreg_warp_via_subregion::distance-difference threshold is ' num2str(thresh) '; this is unusual, so setting it to 10.']); 
		thresh = 10 ; 
	end 

	% reject outliers
	val = find(d_distro < thresh);
  redo(val) = 0;

  % debugging -- look at distro of dstances and make sure your metric is insensitive to dispersion
	if ( 1 == 0 )
	  figure;
		hist(d_distro,20);
		nDr = d_distro(val);
		nthresh= 7*median(nDr);
		disp(['Old thresh: ' num2str(thresh) '.  Thresh without outliers (should be very close) : ' num2str(nthresh) '.']);
  end




