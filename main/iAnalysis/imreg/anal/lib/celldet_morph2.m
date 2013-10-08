%
% S Peron Apr 2010
%
% A morphology based roi re-aligner.  Uses a template image to match it against the larger image
%  via normxcorr2. 
%
% Note that aspect ratios are treated by scaling the image into a square, upsampling to the
%  largest dimension.  This will therefore fail if the larger dimension is not a multiple of
%  the smaller dimension, in therms of size.
%
% params(x).value has the following:
%   1: im_t - the target image for which ROIs are already assigned
%   2: im_s - the soruce image to which ROIs will be assigned
%   3: roi_t - the roi structure in im_t
%   4: debug - 1 to show messages ; 0 dflt 
%   5: gauss_size: how big is your luminance pre-convolving gaussian? in fraction of img size
%   6: min_template_size: what is the minimal template size, in terms of FRACTION of img size
%   7: translation_bound: how much can the roi move - AGAIN in terms of fraction of img size; 1 = off
%   8: n_closest: how many neighbors to use if you have to fall back to closest paradigm?
%
% returns new array of roi objects, roi_s.
%
function roi_s = roimove_morph1(params)
  % --- 0) prelims

  if (length(params) < 3)
	  disp('celldet_morph2::must at LEAST pass the images and rois!');
		members = [];
		return;
	end

  % defaults
	debug = 0;
	lum_gauss_sd_size = 0.005; % 4
	min_template_size = .05;
	translation_bound = 0.1;
	n_closest = 5;

  % pull from passed
	oim_t = params(1).value;
	oim_s = params(2).value;
	rois = params(3).value;
	rois_s = rois; % this is what ends up getting returned

	if (length(params) >= 4) 
	  if (length(params(4).value) > 0) % why dont you have conditional ifs matlab?  you are stupid!
		  debug = params(4).value;
		end
	end
	if (length(params) >= 5)
	  if (length(params(5).value) > 0) % why dont you have conditional ifs matlab?  you are stupid!
			lum_gauss_sd_size = params(5).value; 
		end
	end
	if (length(params) >= 6)
	  if (length(params(6).value) > 0) % why dont you have conditional ifs matlab?  you are stupid!
			min_template_size = params(6).value; 
		end
	end
	if (length(params) >= 7)
	  if (length(params(7).value) > 0) 
			translation_bound = params(7).value; 
		end
	end
	if (length(params) >= 8)
	  if (length(params(8).value) > 0) 
			n_closest = params(8).value; 
		end
	end

  % other assignments / sanity chex
  members(1).indices = [];
  S_o = size(oim_s);
	if (sum(size(oim_s) == size(oim_t)) ~= length(size(oim_s))) ; disp ('celldet_morph2::dimensions of images must agree.') ; return ;  end


  % --- 1) pre-processing
	
  % --- normalize aspect ratios for image -- 'upsample' along smaller dimension
	ar = 1;
	if (S_o(1) > S_o(2))
	  ar = S_o(1)/S_o(2);
		if (round(ar) ~= ar) ; disp('celldet_morph2::can only handle images with integral aspect ratio for large/small.'); return ; end 
	  for d=1:S_o(2)
		  i1=((d-1)*ar)+1;
			for i=i1:i1+ar-1;
				bigims(:,i) = oim_s(:,d);
				bigimt(:,i) = oim_t(:,d);
			end
		end
	elseif(S_o(2) > S_o(1))
	  ar = S_o(2)/S_o(1);
		if (round(ar) ~= ar) ; disp('celldet_morph2::can only handle images with integral aspect ratio for large/small.'); return ;end 
	  for d=1:S_o(1)
		  i1=((d-1)*ar)+1;
			for i=i1:i1+ar-1;
				bigims(i,:) = oim_s(d,:);
				bigimt(i,:) = oim_t(d,:);
			end
		end
	end
	im_s = bigims;
	im_t = bigimt;
	S = size(im_s); 

	% --- normalize aspect ratios for ROI borders, members -- again, upsample along smaller dim
  for r=1:length(rois)
	  roi = rois(r);

		% corners
		if (S_o(1) > S_o(2))
		  roi.corners(1,:) = ar*roi.corners(1,:);
	  elseif (S_o(1) < S_o(2))
		  roi.corners(2,:) = ar*roi.corners(2,:);
		end % otherwise ar is 1 so no biggie

		% indices -- quite YUK
		indices = roi.indices;
		Y = indices-S_o(1)*floor(indices/S_o(1));
	  X = ceil(indices/S_o(1));
%		Y = Y - moveby;
%      indices = Y + S(1)*(X-1);
			% reject border
%			keep_idx = find(Y > 0 & Y < S(1) & X > 0 & X < S(2)); % universal
    nX = [];
		nY = [];
		if (S_o(1) > S_o(2)) % more Y (1) values than X (2) -- grow in X
		  ux = unique(X);
			nX = [];
			nY = [];
			for d=1:length(ux)
			  fidx = find(X == ux(d));
				Ni = length(fidx);
				xo=((ux(d)-1)*ar)+1;
        xf = xo+ar-1;
				ax = [];
				for x=xo:xf
				  aX = [aX x*ones(Ni,1)'];
				end
				aY = repmat(Y(fidx),ar,1);
				nX = [nX aX];
				nY = [nY aY'];
			end
	  elseif (S_o(1) < S_o(2)) % more X points -- add Y
		  uy = unique(Y);
			nX = [];
			nY = [];
			for d=1:length(uy)
			  fidx = find(Y == uy(d));
				Ni = length(fidx);
				yo=((uy(d)-1)*ar)+1;
        yf = yo+ar-1;
				aY = [];
				for y=yo:yf
				  aY = [aY y*ones(Ni,1)'];
				end
				aX = repmat(X(fidx),ar,1);
				nY = [nY aY];
				nX = [nX aX'];
			end
    end
    new_indices = nY + S(1)*(nX-1);
		roi.indices = new_indices;

    % bling
		rois(r) = roi;
	end

	% --- precompute roi COM based on borders, distance matrix
	roi_com = zeros(2,length(rois));
  for r=1:length(rois)
	  roi = rois(r);
	  roi_com(1,r) = mean(roi.corners(1,:));
	  roi_com(2,r) = mean(roi.corners(2,:));
  end
	roi_dist = zeros(length(rois),length(rois));
	for r1=1:length(rois)
	  roi_dist(r1,r1) = 0;
	  for r2=r1+1:length(rois)
		  D = sqrt(((roi_com(1,r1)-roi_com(1,r2))^2)+((roi_com(2,r1)-roi_com(2,r2))^2));
			roi_dist(r1,r2) = D;
			roi_dist(r2,r1) = D;
		end
	end
	nroi_com = roi_com; % where new coms are stored

	% --- normalize light intensity via gaussian
	nim_s = normalize_via_gaussconvdiv(im_s,lum_gauss_sd_size);
	nim_t = normalize_via_gaussconvdiv(im_t,lum_gauss_sd_size);

  % --- set to [0 1] range
  nim_s = nim_s - min(min(nim_s));
  nim_s = nim_s/max(max(nim_s));
  nim_t = nim_t - min(min(nim_t));
  nim_t = nim_t/max(max(nim_t));

	% --- 2) Actual matching
	wb = waitbar(0,'celldet-morph2::Main processing loop ...');
	min_rs = ceil((min_template_size*S)/2);
	max_dp = ceil(translation_bound*S(1)); % same in x and y since we work with skwarZ
	dx_r = [] ; dy_r = [] ; % where the displacements are stored
  for r=1:length(rois)
		waitbar(r/length(rois),wb, ['celldet-morph2::Main processing loop: ' num2str(r) ' of ' num2str(length(rois)) ' ROIs']);
	  roi = rois(r);

    % call the template matcher
    [dx dy corrval] = find_match_to_roi_template(nim_t, nim_s, roi, min_rs, max_dp);

		if (debug) ; disp(['dx: ' num2str(dx) ' dy: ' num2str(dy) ' corr: ' num2str(corrval)]); end

    % store dx, dy -- you can use this later to test for failures
		dx_r(r) = dx;
		dy_r(r) = dy;

    % new roi com -- for redo test
  	nroi_com(:,r) = roi_com(:,r) + [dx dy]';
	end

  % --- process redos

  %OLD determine which ones are not up to snuff based on median MAKE THRESH GUI BASED
	%OLD ALT: look at change in distance to (5?) closest guys in original -- should not chng much 
	%OLD: redo = zeros(size(dx_r));
	%OLD: redo(find(dx_r > median(dx_r)+3*std(dx_r) | dx_r < median(dx_r)-3*std(dx_r))) = 1;
	%OLD: redo(find(dy_r > median(dy_r)+3*std(dy_r) | dy_r < median(dy_r)-3*std(dy_r))) = 1;
	% determine bad by looking at distribution of displacement vectors for neighbors
%  [redo dv_distro] = determine_redos_dispvec(roi_dist, n_closest, dx_r, dy_r);
  [redo d_distro] = determine_redos_dist(roi_dist, n_closest, dx_r, dy_r, nroi_com);
	if (length(find(redo == 1)) >= length(dx_r)/4) % If a lot of redos, user should inspect visually
	  disp('celldet_morph2::at least 25% of ROIs had to be redone ; entering debug mode.  Redone ROIs will be circled in yellow in displacement plot.  Check manually!') ; 
		debug = 1; 
	end
	oredo = redo; % for plotting in debug mode, keep original redo so you can flag redone guys

  % loop thru
	for r=1:length(redo)
		waitbar(r/length(redo),wb, ['celldet-morph2::Processing redos ...']);
	  if (redo(r))
			roi = rois(r);
   
			% --- try to redo with larger templates -- can you get in criteria?
			for n=1:4
			  if(debug) ; disp(['**** Attempting correction ' num2str(n)]); end
				min_rs = (n+1)*ceil((min_template_size*S)/2);

				% call the template matcher
				[dx dy corrval] = find_match_to_roi_template(nim_t, nim_s, roi, min_rs, max_dp);
				if (debug) 
				  disp(['corrected dx: ' num2str(dx) ' (was ' num2str(dx_r(r)) ') dy: ' num2str(dy) ' (was ' num2str(dy_r(r)) ') corr: ' num2str(corrval)]); 
				end

				% store dx, dy -- you can use this later to test for failures
				dx_r(r) = dx;
				dy_r(r) = dy;

				% new roi com -- for redo test
				nroi_com(:,r) = roi_com(:,r) + [dx dy]';

				% okay?
        % OLD: redo(r) = is_redo_dispvec(dx, dy, r, dv_distro, roi_dist, n_closest, dx_r, dy_r);
        redo(r) = is_redo_nbr_dist(r, d_distro, roi_dist, n_closest, nroi_com);
%				if(dx > median(dx_r)+3*std(dx_r) | dx < median(dx_r)-3*std(dx_r) | dy > median(dy_r)+3*std(dy_r) | dy < median(dy_r)-3*std(dy_r))
%				  if(debug) ; disp('Correction failed'); end
%				else
%				  if(debug) ; disp('Correction succeeded'); end
%				  redo(r) = 0;
%				end

				if (~ redo(r)) ; break ; end
			end

			% --- fail -- then go and just use your (5?) nearest neighbors from ORIGINAL set
			if (redo(r))
			  % compute 5 closest UNFAILED neighbors
				dists = roi_dist(r,:);
				[cd closest_idx] = sort(dists);

        n = 2; % first is going to be the same roi since distance is 0!
				nc = 0;
				closest_good = [];
        while (nc < n_closest & n < length(closest_idx))
				  if (~redo(closest_idx(n))) % if its good, use it
					  closest_good = [closest_good closest_idx(n)];
						nc = nc+1;
					end
					n = n+1;
				end

				% average their dx/dy and use it
				dx_r(r) = round(mean(dx_r(closest_good)));
				dy_r(r) = round(mean(dy_r(closest_good)));

				if (debug) 
				  disp(['Based on average of neighbors, corrected dx: ' num2str(dx_r(r)) ' dy: ' num2str(dy_r(r))]);
				end
			end
		end
	end
	delete(wb);
	

	% --- 3) post-processing

  % --- apply dx_r, dy_r -- build rois_s
	for r=1:length(rois)
    roi = rois(r);

	  % Borders via corners 
		roi.corners(1,:) = roi.corners(1,:)+dx_r(r);
		roi.corners(2,:) = roi.corners(2,:)+dy_r(r);

		% Indices
		indices = roi.indices;
		Y = indices-S(1)*floor(indices/S(1)) + dy_r(r);
	  X = ceil(indices/S(1)) + dx_r(r);
    new_indices = Y + S(1)*(X-1);
		roi.indices = new_indices;
    rois_s(r) = roi;
	end

  % --- plot outcome
  if (debug) ; debug_plot_compare(im_s, im_t, rois, rois_s, oredo) ; end

	% --- convert aspect ratio of ROI borders, member indices by downsampling - and 
	%     assign return while at it ... (members.indices, members.corners, members.n_corners, members.groups)
	for r=1:length(rois_s)
    roi = rois_s(r);

	  % Borders via corners - should just divide by ar
		if (S_o(1) > S_o(2))
		  roi.corners(1,:) = round(roi.corners(1,:)/ar);
	  elseif (S_o(1) < S_o(2))
		  roi.corners(2,:) = round(roi.corners(2,:)/ar);
		end % otherwise ar is 1 so no biggie

		% Indices: convert to x/y in corrected image, then simply skip the x/ys that
		%  you remove when you return to original size
		indices = roi.indices;
		Y = indices-S(1)*floor(indices/S(1));
	  X = ceil(indices/S(1));
		if (S_o(1) > S_o(2)) % remove some Xs since we added some before
			rems = rem(X, ar);
			val = find(rems == 0);
      nX = X(val)/ar;
			nY = Y(val);
	  elseif (S_o(1) < S_o(2)) % remove some Ys since we added some
			rems = rem(Y, ar);
			val = find(rems == 0);
      nX = X(val);
			nY = Y(val)/ar;
		end % otherwise ar is 1 so no biggie
%		Y = Y - moveby;
%      indices = Y + S(1)*(X-1);
			% reject border
%			keep_idx = find(Y > 0 & Y < S(1) & X > 0 & X < S(2)); % universal
    %new_indices = nY + S(1)*(nX-1);

    % verify indices in x/y bounds
		val_idx = find(nX > 0 & nX < S(2) & nY > 0 & nY  < S(1));
		nX = nX(val_idx);
		nY = nY(val_idx);

		% verify ROI corners are in x/y bounds - squish otherwise
		inval = find(roi.corners(1,:) < 1);
		roi.corners(1,inval) = 1;
		inval = find(roi.corners(1,:) > S(2));
		roi.corners(1,inval) = S(2);
		inval = find(roi.corners(2,:) < 1);
		roi.corners(1,inval) = 1;
		inval = find(roi.corners(2,:) > S(1));
		roi.corners(1,inval) = S(1);

		% create new indices
    new_indices = nY + S_o(1)*(nX-1);

    % make sure indices are in bounds
		val_inds = find(new_indices > 1 & new_indices <= S_o(1)*S_o(2));

    % assign roi
		roi.indices = new_indices(val_inds);
    rois_s(r) = roi;

		% members
		members(r).groups = rois_s(r).groups;
		if (oredo(r))  
		rois_s(r).groups
		  if (length(find(rois_s(r).groups == 9001)) == 0)
			  members(r).groups = [rois_s(r).groups 9001];
			end
		end

		members(r).indices = new_indices(val_inds)';
		members(r).corners = roi.corners;
		members(r).n_corners = size(roi.corners,2);
	end

  if (debug) ; debug_plot_compare(oim_s, oim_s, rois_s, rois_s, oredo) ; end

%
% The core function -- returns dx, dy given an roi, source and target images, and
%  max displacement (max_dp) and minimal size of template (min_rs).  Note that
%  min_rs is 2x1 while max_dp is 1x1 - this is odd and not important! both min_rs 
%  should be same.  
%
function [dx dy corrval] = find_match_to_roi_template(nim_t, nim_s, roi, min_rs, max_dp)
  S = size(nim_t);

	% based on corners, define template bounding rectangle 
	corners = roi.corners;
	min_x = round(min(corners(1,:)));
	max_x = round(max(corners(1,:)));
	min_y = round(min(corners(2,:)));
	max_y = round(max(corners(2,:)));

	% is rectangle large enuff? if not, make bigger ; get center and radius
	r_x = ceil((max_x-min_x)/2); 
	c_x = min_x + r_x;
	r_y = ceil((max_y-min_y)/2);
	c_y = min_y + r_y;
	if (r_y < min_rs(1)) ; r_y = min_rs(1); end
	if (r_x < min_rs(2)) ; r_x = min_rs(2); end

	% make the bounds and ensure their respect of image boundaries -- since it is ASSUMED that the template
	%  is CENTERED on ROI center, you must keep symmetrical radii about center
	x1 = c_x-r_x;
	x2 = c_x+r_x;
	if (x1 < 1) ; x2 = x2+x1-1 ; x1 = 1 ; end
	if (x2 > S(2)) ; x1 = x1+ (x2-S(2)); x2 = S(2) ; end
	y1 = c_y-r_y;
	y2 = c_y+r_y;
	if (y1 < 1) ;y2 = y2+y1-1; y1 = 1 ; end
	if (y2 > S(1)) ; y1=y1+(y2-S(1)); y2 = S(1) ; end

	% now make the template
	template = nim_t(y1:y2, x1:x2);

	% debug show
	if (1 == 0 ) ; figure ; debug_plot_roi_detail(nim_t, roi, template, x1, x2, y1, y2, c_x, c_y); end

	% for each template, determine the x/y displacement and rotation *about its center* using normxcorr2
	%  here, you get cross correlation of template with the 'source' image -- where you want to find the
	%  template, which is in a sense the 'target' -- and you then look for the hopefully-unique peak in 
	%  the x-corr landscape

	cim = normxcorr2(template, nim_s); 
	st = ceil((size(template)-[1 1])/2);
	cim = cim(st(1):size(cim,1)-st(1)-1, st(2):size(cim,2)-st(2)-1) ; % remove borders

	if ( 1 == 0 ) ; figure ; imshow(cim) ; colormap jet ; pause ; end

	% compute dx, dy, accomodating maximal displacement
	lb1 = max(1,c_y-max_dp);
	ub1 = min(S(1),c_y+max_dp);
	lb2 = max(1,c_x-max_dp);
	ub2 = min(S(2),c_x+max_dp);
	d1 = ub1-lb1+1;
	d2 = ub2-lb2+1;
	%OLD
	%cim_v = reshape(cim,[],1);
	%[val idx] = max(cim_v);
	%x_peak = ceil(idx/S(1));
	%y_peak = idx-S(1)*(x_peak-1);

	cim_v = reshape(cim(lb1:ub1,lb2:ub2),[],1);
	[corrval idx] = max(cim_v);
	x_peak = ceil(idx/d1);
	y_peak = idx-d1*(x_peak-1);
	x_peak = x_peak + lb2;
	y_peak = y_peak + lb1;

	% 2 is the correction factor due to rounding issues above
	dx = x_peak-c_x-2;
	dy = y_peak-c_y-2;

%
% This function decides if there is a need to redo based on distribution of 
%  distances to neighbors before and after displacement
%
% Indexing of these should be same:
%  roi_dist: ROI distance matrix (triang. symm.) ; BEFORE displacement
%  dx_r, dy_r: displacement in x and y
%  nroi_com: the center-of-mass for SHIFTED rois
%
% Returns a boolean array indicating which distances are outliers, as well
%  as the distribution of distances that can be used in subsequent tests of
%  compliance.
%
function [redo d_distro] = determine_redos_dist(roi_dist, n_closest, dx_r, dy_r, nroi_com)
  % by default everone is redo
  redo = ones(1,size(roi_dist,1));
  d_distro = zeros(1,size(roi_dist,1));

  % determine *new* distance matrix
	nroi_dist = zeros(length(dx_r),length(dx_r));
	for r1=1:length(dx_r)
	  nroi_dist(r1,r1) = 0;
	  for r2=r1+1:length(dx_r)
		  D = sqrt(((nroi_com(1,r1)-nroi_com(1,r2))^2)+((nroi_com(2,r1)-nroi_com(2,r2))^2));
			nroi_dist(r1,r2) = D;
			nroi_dist(r2,r1) = D;
		end
	end

  % main loop over rois
	for r=1:size(roi_dist,1)
		% compute n_closest neighbors
		dists = roi_dist(r,:);
		[cd closest_idx] = sort(dists);
		ndists = nroi_dist(r,:);

		% compute distances to neighbors that were closest
		cldist = dists(closest_idx(2:n_closest));
		ncldist = ndists(closest_idx(2:n_closest));

		% store, for this roi, distance difference
		d_distro(r) = mean(abs(cldist-ncldist));
  end

  % determine non-outliers
	thresh = 7*median(d_distro); % cutoff will be 5xmedian -- usually median is close to 0
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

%
% Performs aberration test for *single* dx/dy based on distance to nearnest neighbors
%
% r is your index ; d_distro is distance distribution from original determine_redos_dist call
% roi_dist is the ORIGINAL roi distance matrix (prior to displacement)
% n_closest is how many neighbors to use and nroi_com is new COM matrix
%
function redo = is_redo_nbr_dist(r, d_distro, roi_dist, n_closest, nroi_com)
  thresh = 7*median(d_distro); % tolerance level
	redo = 1;
	N = size(nroi_com,2); % how many ROIs are ther

	% get the closets neighbors for THIS particular roi
	dists = roi_dist(r,:);
	[cd closest_idx] = sort(dists);

  % determine *new* distance VECTOR for this guy
	nroi_dist = zeros(N,1);
	for r1=1:N
		D = sqrt(((nroi_com(1,r)-nroi_com(1,r1))^2)+((nroi_com(2,r)-nroi_com(2,r1))^2));
		nroi_dist(r) = D;
	end

	% compute n_closest neighbors for this particular roi
	dists = roi_dist(r,:);
	[cd closest_idx] = sort(dists);
	ndists = nroi_dist';

	% compute distances to neighbors that were closest
	cldist = dists(closest_idx(2:n_closest));
	ncldist = ndists(closest_idx(2:n_closest));

	% store, for this roi, distance difference
	D = mean(abs(cldist-ncldist));

  % and test -- if below threshold OK!
	if (D < thresh) ; redo = 0 ; end

%
% This function decides if there is a need to redo based on distribution of 
%  displacement vectors of neighbors.
%
% Indexing of these should be same:
%  roi_dist: ROI distance matrix (triang. symm.)
%  dx_r, dy_r: displacement in x and y
%
% Returns a boolean array indicating which distances are outliers, as well
%  as the distribution of distances that can be used in subsequent tests of
%  compliance.
%
function [redo dv_distro] = determine_redos_dispvec(roi_dist, n_closest, dx_r, dy_r)
  % by default everone is redo
  redo = ones(1,size(roi_dist,1));
  dv_distro = zeros(1,size(roi_dist,1));


  % main loop over rois
	for r=1:size(roi_dist,1)
		% compute n_closest neighbors
		dists = roi_dist(r,:);
		[cd closest_idx] = sort(dists);

		% compute distance between displacement vectors for this guy vs. n_closest neighbors
		D = [];
		for n=2:n_closest+1
			D(n) = sqrt(((dx_r(r)-dx_r(n))^2)+((dy_r(r)-dy_r(n))^2));
		end

		% store, for this roi, its distribution of vector differences
		dv_distro(r) = mean(D);
  end

  % determine non-outliers
	thresh = 3*median(dv_distro); % cutoff will be 3*median  -- you want a dispersion-insensitive metric in case ALL are ok!
	val = find(dv_distro < thresh);
  redo(val) = 0;

  % debugging -- look at distro of dstances and make sure your metric is insensitive to dispersion
	if ( 1 == 0 )
	  figure;
		hist(dv_distro,20);
		nDr = dv_distro(val);
		nthresh= 3*median(nDr);
		disp(['Old thresh: ' num2str(thresh) '.  Thresh without outliers (should be very close) : ' num2str(nthresh) '.']);
  end

%
% Performs aberration test for *single* dx/dy based on a distribution of dx/dy 
%  vectors.
%
% dx, dy are your displacements ; dv_distro is your distribution of displacements
% r is your index, dx_r and dy_r are displacements for all other things and n_closest is your neighbors
%
function redo = is_redo_dispvec(dx, dy, r, dv_distro, roi_dist, n_closest, dx_r, dy_r)
  thresh = 2*median(dv_distro); % LOWER tolerance here
	redo = 1;

	% compute n_closest neighbors
	dists = roi_dist(r,:);
	[cd closest_idx] = sort(dists);

	% compute distance between displacement vectors for this guy vs. n_closest neighbors
	D = [];
	for n=2:n_closest+1
		D(n) = sqrt(((dx-dx_r(n))^2)+((dy-dy_r(n))^2));
	end

  % and test -- if below threshold OK!
	if (mean(D) < thresh) ; redo = 0 ; end

%
% for plotting comparison -- DEBUG
% 
function debug_plot_compare(im_s, im_t, rois, rois_s, redo)
	figure;

	% original
	subplot(1,2,1);
	M = max(max(im_t));
	for r=1:length(rois)
		roi = rois(r);
%		im_t(roi.indices) = M;
	end
	imshow(mean(im_t,3), [0 3500]);
	axis square;
	hold on;
	for r=1:length(rois)
		roi = rois(r);
		mycol = roi.color;
		for p=1:length(roi.corners)-1
			plot ([roi.corners(1,p) roi.corners(1,p+1)], ...
						[roi.corners(2,p) roi.corners(2,p+1)], ...
						'-', 'Color', mycol);
		end
	end

	% fit
	subplot(1,2,2);
	imshow(mean(im_s,3), [0 3500]);
	axis square;
	hold on;
	for r=1:length(rois_s)
		roi = rois_s(r);
		mycol = roi.color;
		if (redo(r)) ; mycol = [1 1 0] ;end
		for p=1:length(roi.corners)-1
			plot ([roi.corners(1,p) roi.corners(1,p+1)], ...
						[roi.corners(2,p) roi.corners(2,p+1)], ...
						'-', 'Color', mycol );
		end
		oroi = rois(r);
		plot([mean(roi.corners(1,:)) mean(oroi.corners(1,:))], ...
				 [mean(roi.corners(2,:)) mean(oroi.corners(2,:))], 'w-');
	end

% 
% for debug plotting of a closeup view of roi
%
function debug_plot_roi_detail(nim_t, roi, template, x1, x2, y1, y2, c_x, c_y);
	subplot(1,2,1);
	imshow(mean(nim_t,3), [0 max(max(nim_t))]);
	hold on;
	mycol = roi.color;
	for p=1:length(roi.corners)-1
		plot ([roi.corners(1,p) roi.corners(1,p+1)], ...
					[roi.corners(2,p) roi.corners(2,p+1)], ...
					'-', 'Color', mycol );
	end

	plot([x1 x2], [y1 y1], '-', 'Color', mycol);
	plot([x1 x2], [y2 y2], '-', 'Color', mycol);
	plot([x1 x1], [y1 y2], '-', 'Color', mycol);
	plot([x2 x2], [y1 y2], '-', 'Color', mycol);
	plot(c_x, c_y, 'rx');

	subplot(1,2,2);
	imshow(template, [0 max(max(nim_t))], 'InitialMagnification' ,'fit') ; 
	axis square;
	pause;
