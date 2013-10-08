%
% S Peron Dec. 2009
%
% A morphology based cell detector.  Uses a detector bank - usually annuli and/or disks - to
%  determine centers of cells, then runs dilations from these centers to pickoff luminance
%  thresholded components and add them to the cell.
%
% Note that aspect ratios are treated by scaling the image into a square, upsampling to the
%  largest dimension.  This will therefore fail if the larger dimension is not a multiple of
%  the smaller dimension, in therms of size.
%
% params(x).value has the following:
%   1: im - your image -- SINGLE frame
%   2: size_thresh - 2 element vector determining size of connected cell set [25 300] dflt
%   3: debug - 1 to show messages ; 0 dflt 
%   4: gauss_size: how big is your luminance pre-convolving gaussian? in fraction of img size
%   5: lum_thresh_sd_mult: what is the threshold, after convolution, to construct a binary 
%      image:'maybe cell'/'not cell' [this is the MULTIPLIER in mu+X*sd - X]
%   6: annular radii (2xn matrix) [if blank, uses DEFAULT detector bank]
%   7: annular thicknesses (vector)
%   8: annular halos (vector)
%   9: annular angles (vector)
%   10: disk radii (2xn matrix -- can be noncircular)
%   11: disk halos (vector)
%   12: disk angles (vector)
%   13: cen_lum_thresh: threshold of post convolved image uses this scalar * mean
%   14: cen_thresh: how big must center be, post detection, to do dilation?
%   15: dilation_extent: this times the maximal radius is how many steps of
%                        dilation will be performed
%   16: mapadd_overlap: what fraction of child roi must belong to parent to merge?
%
% returns structure 'groups', each of which has a vector, 'members', specifying
%  index-based (in im) membership.
%
function members = celldet_morph1(params)
  % --- 0) prelims

  if (length(params) < 1)
	  disp('celldet_morph1::must at LEAST pass the image!');
		members = [];
		return;
	end

  % defaults
	debug = 0;
	size_thresh = [25 600];
	lum_gauss_sd_size = 0.005; % 4
	lum_thresh_sd_mult = 0.1; % intensity threshold = mean + sd_mult*sd; 5
	ann_rads = [4 4 ; 5 5 ; 5 3 ; 6 6 ; 6 3; 7 7 ; 7 4 ; 8 8 ; 8 5]; % 6
	ann_ths = [2 3 4];
	ann_hals = [3];
	ann_angs = [0 45 90 135];
	disk_rads = [10 10 ; 7 7];
	disk_hals = [2];
	disk_angs = [0 45 90 135]; % rotation - 4 angles for now; symmetry means you cover all of it this way
  cen_lum_thresh = 0.7; % to count as cell, convolved image value must be >= this * max of convolved image
  cen_thresh = 2; % center must have at least this many points % 13
	dilation_extent = 1.5; % this x maximal radius is how many dilation steps are performed
  mapadd_overlap = 0.75;

  % pull from passed
	im = params(1).value;
	if (length(params) >= 2) 
	  if (length(params(2).value) == 2) % why dont you have conditional ifs matlab?  you are stupid!
		  size_thresh = params(2).value;
		end
	end
	if (length(params) >= 3)
	  if (length(params(3).value) > 0) % why dont you have conditional ifs matlab?  you are stupid!
			debug = params(3).value; 
		end
	end
	if (length(params) >= 4)
	  if (length(params(4).value) > 0) % why dont you have conditional ifs matlab?  you are stupid!
			lum_gauss_sd_size = params(4).value; 
		end
	end
  if (length(params) >= 5)
	  if (length(params(5).value) > 0) 
			lum_thresh_sd_mult = params(5).value; 
		end
	end

  % annulus stuff
  if (length(params) >= 6)
	  if (length(params(6).value) > 0) 
			ann_rads = params(6).value; 
		end
	end
  if (length(params) >= 7)
	  if (length(params(7).value) > 0) 
			ann_ths = params(7).value; 
		end
	end
  if (length(params) >= 8)
	  if (length(params(8).value) > 0) 
			ann_hals = params(8).value; 
		end
	end
  if (length(params) >= 9)
	  if (length(params(9).value) > 0) 
			ann_angs = params(9).value; 
		end
	end


  % disk stuff
  if (length(params) >= 10)
	  if (length(params(10).value) > 0) 
			disk_rads = params(10).value; 
		end
	end
  if (length(params) >= 11)
	  if (length(params(11).value) > 0) 
			disk_hals = params(11).value; 
		end
	end
  if (length(params) >= 12)
	  if (length(params(12).value) > 0) 
			disk_angs = params(12).value; 
		end
	end

  % postprocessing arams
  if (length(params) >= 13)
	  if (length(params(13).value) > 0) 
			cen_lum_thresh = params(13).value; 
		end
	end
  if (length(params) >= 14)
	  if (length(params(14).value) > 0) 
			cen_thresh = params(14).value; 
		end
	end
  if (length(params) >= 15)
	  if (length(params(15).value) > 0) 
			dilation_extent = params(15).value; 
		end
	end
  if (length(params) >= 16)
	  if (length(params(16).value) > 0) 
			mapadd_overlap = params(16).value; 
		end
	end

  % other assignments
  members(1).indices = [];
  S_o = size(im);

	% --- ANNULAR parameters
	a_angs = ann_angs;
	a_rads = ann_rads;
	a_ths = ann_ths;
  a_hals = ann_hals;

	% --- DISK parameters
	d_angs = [0 45 90 135]; % rotation - 4 angles for now; symmetry means you cover all of it this way
	d_rads = disk_rads;
	d_hals = disk_hals;

	% compute max_rad -- used to size your convolution matrices
	m_arad = max(max(a_rads)) + max(max(a_ths)) + max(max(a_hals));
	m_drad = max(max(d_rads)) + max(max(d_hals));
	max_rad = max(m_drad, m_arad);

  % --- 1) pre-processing
	
  % --- normalize aspect ratios for image -- 'upsample' along smaller dimension
	ar = 1;
	if (S_o(1) > S_o(2))
	  ar = S_o(1)/S_o(2);
		if (round(ar) ~= ar) ; disp('celldet_morph1::can only handle images with integral aspect ratio for large/small.'); return ; end 
		fim = zeros(S_o(1),S_o(1));
	  for d=1:S_o(2)
		  i1=((d-1)*ar)+1;
			for i=i1:i1+ar-1;
				bigim(:,i) = im(:,d);
			end
		end
	elseif(S_o(2) > S_o(1))
	  ar = S_o(2)/S_o(1);
		fim = zeros(S_o(2),S_o(2));
		if (round(ar) ~= ar) ; disp('celldet_morph1::can only handle images with integral aspect ratio for large/small.'); return ;end 
	  for d=1:S_o(1)
		  i1=((d-1)*ar)+1;
			for i=i1:i1+ar-1;
				bigim(i,:) = im(d,:);
			end
		end
	end
	im = bigim;
	S = size(im); 

	% --- normalize light intensity via gaussian
%lum_gauss_sd_size = 0.005; % 4
	fm = normalize_via_gaussconvdiv(im,lum_gauss_sd_size);

%debug = 1;
%	size_thresh = [10 600];
%lum_thresh_sd_mult = .5; % intensity threshold = mean + sd_mult*sd; 5
%fm = -1*gradient(gradient(fm));
	%fm = normalize_via_gaussconvdiv(xm,.05);
  
  % --- set to [0 1] range
  fm = fm - min(min(fm));
  fm = fm/max(max(fm));
  fm = fm - mean(mean(fm)); % subtract mean 


	% --- now pre-label using vector and apply size threshold

	% build label matrix via threshold of gauss-conv'd
  fmv = reshape(fm,[],1);
%  if(debug) ;	figure; imshow(fm, [0 3500], 'InitialMagnification', 'fit'); axis square ; end ; pause
  if(debug) ;	figure; imshow(fm, [0 max(max(fm))/5], 'InitialMagnification', 'fit'); axis square; title('init img'); pause ; end ;
  fmb = im2bw(fm,mean(fmv)+lum_thresh_sd_mult*std(fmv));
	labmat = bwlabel(fmb);

 	% reject too small and too large
  ul = unique(labmat);
	altim = fm;
	for u=1:length(ul)
	  uidx = find(labmat == ul(u));
	  sul = length(uidx);
		if (sul < ar*size_thresh(1) | sul > ar*size_thresh(2))  
			altim(uidx) = 0;
		end
	end
%  if(debug) ;	figure; imshow(altim, [0 max(max(fm))/5], 'InitialMagnification', 'fit'); axis square; title('alt img'); end

	altimv = reshape(altim, [], 1);
  altimb = im2bw(altim, mean(altimv) +lum_thresh_sd_mult*std(altimv)); % reapply threshold without uglies
  if(debug) ;	figure; imshow(altimb, 'InitialMagnification', 'fit'); axis square; title('alt img'); pause ; end


	% show pre-process final step
	if (debug)
		labmat = bwlabel(fmb);
		RGB_label = label2rgb(labmat, @hsv, 'c', 'shuffle');
%		figure ; imshow(RGB_label,'InitialMagnification','fit'); axis square; 

		R = RGB_label(:,:,1); 
		G = RGB_label(:,:,2); 
		B = RGB_label(:,:,3); 
		R(find(labmat == 0)) = 0;
		G(find(labmat == 0)) = 0;
		B(find(labmat == 0)) = 0;
		RGB_label = R + G + B;
%		figure ;	imshow(RGB_label,'InitialMagnification','fit'); axis square; 
	end

  % --- 2) build your detector bank
	% SPECIFY: angle ; radius of inner hole ; thickness of annulus [if disk, this is radius] ; thickness of surround halo
	% you must do aspect ratio yourself

  % prepare matrix size for convolution matrices
	min_s = ceil(max_rad*2.5); % minimal matrix dimension 
	min_s = round(min_s/2); % divide by two - we want odd number so . . . 
	mat_size =[ min_s min_s];
	mat_size = (2*mat_size)+1; % ensure it is odd so we can center properly

  % annuli
  [a_dets a_dil_rads a_det_rs a_dets_str] = celldet_morph1_generate_templates(a_rads, a_ths, a_hals, a_angs, mat_size);
	% disks
  [d_dets d_dil_rads d_det_rs d_dets_str] = celldet_morph1_generate_templates(d_rads, 0, d_hals, d_angs, mat_size);

  % merge it all
	n_disks = size(d_dets,3);
	n_anns = size(a_dets,3);
	n_dets = n_disks + n_anns;

	dil_rads = [a_dil_rads d_dil_rads];
	det_rs = [a_det_rs d_det_rs];
	dets_str = [a_dets_str d_dets_str];

  dets = zeros(mat_size(2), mat_size(1), n_disks+n_anns);
	dets(:,:,1:n_anns) = a_dets;
	dets(:,:,n_anns+1:n_anns+n_disks) = d_dets;

  % sort by radius (for annuli, this includes inner and outer ; for disks, only outer)
  [val det_ordering] = sort(det_rs);

	% --- 3) run detectorZ to find cell centers
	disp(['celldet_morph1::Using ' num2str(n_dets) ' detectors.']);
	altimbd = double(altimb);
  cellcen = zeros(size(altimbd)); % this is where cell centers will be stored
  finmap = zeros(size(altimbd)); % this is where cell centers will be stored
	mspc = ceil(mat_size/2);
	if (debug) ; ff = figure ; end
	wb = waitbar(0, 'Detectors running ...');
	for n=1:n_dets
	  real_idx = det_ordering(n);
	  waitbar(n/n_dets, wb, ['Running detector ' num2str(n)]);
	  % perform convolution
		cm2 = conv2(altimbd,dets(:,:,real_idx));
%cm2 = -1*normxcorr2(dets(:,:,real_idx), altim);
		cm2 = cm2(mspc(2):S(1)+mspc(2)-1, mspc(1):S(2)+mspc(1)-1);
		if (debug) ; figure ; imshow(cm2,[-1 max(max(cm2))], 'InitialMagnification','fit');colormap jet; colorbar ; axis square; end

    % add centers to cell center matrix
		cellcen = 0*cellcen;
		cellcen(find(cm2 >= cen_lum_thresh*max(max(cm2)))) = 1;
%cellcen(find(cm2 >= 0.9*max(max(cm2)))) = 1;

		% -- run the dilation step

		% minimal size for center
		labmat = bwlabel(cellcen);
		cellcen = 0*cellcen;
		ulab = unique(reshape(labmat,[],1));
		for u=1:length(ulab)
			val = find(labmat == ulab(u));
			if (ulab(u) > 0 & length(val) >= cen_thresh)
				cellcen(val) = 1;
			end
		end

		% actual dilation
		fin_im = compute_via_dilation(cellcen, altimb, dil_rads(real_idx), round(dilation_extent*dil_rads(real_idx)));
		% show outcome
		if (1 == 1 & debug)
			RGB_label = label2rgb(fin_im, @hsv, 'c', 'shuffle');
			figure(ff) ;	subplot(1,2,1); imshow(RGB_label,'InitialMagnification','fit'); axis square;
		end

		% -- add to final map
		finmap = add_to_map(finmap, fin_im, mapadd_overlap);
%		mval = max(max(finmap));
%		needinc = find(fin_im > 0);
%		fin_im(needinc) = fin_im(needinc) + mval;
%		finmap = finmap + fin_im;
	
    if (0 == 1 & debug) % show the detector and its outcome
		  figure(ff);
			subplot(1,2,2);
		  cellceni = altimbd;
			cellceni(find(cm2 >= 0.7*max(max(cm2)))) = 5;
			cellceni(1:mat_size(2), 1:mat_size(1)) = dets(:,:,n)*3;
		  imshow(cellceni, [0 5], 'InitialMagnification','fit');axis square; 
			title(dets_str{n});
			pause;
		end
	end
	delete(wb);
	%if (debug) ; figure ; imshow(altimb, 'InitialMagnification','fit'); colorbar ; axis square; end
%	if (debug) ; figure ; imshow(altimb, 'InitialMagnification','fit');  axis square; end

  % run the dilation step  
  %fin_im = compute_via_dilation(cellcen, altimb, 3);
	%RGB_label = label2rgb(fin_im, @hsv, 'c', 'shuffle');
  %if (debug) ; figure ;	imshow(RGB_label,'InitialMagnification','fit'); axis square; end
	% show outcome
	if (debug)
		RGB_label = label2rgb(finmap, @hsv, 'c', 'shuffle');
		figure ;	 imshow(RGB_label,'InitialMagnification','fit'); axis square;
	end

  % --- 4) run dilation-based cell detection using center composite matrix

  % for comparison, show original
	if (debug ) ; figure ; imshow(im, [0 max(max(im))], 'InitialMagnification', 'fit') ; axis square ; end

	% --- 5) post-processing

  % --- build final labeled set -- finmap

  % --- reapply size threshold 

	% --- convert aspect ratio
	retmap = zeros(S_o(1),S_o(2));
	if (S_o(1) > S_o(2))
	  for d=1:S_o(2)
		  i=((d-1)*ar)+1;
			retmap(:,d) = finmap(:,i);
		end
	elseif(S_o(2) > S_o(1))
	  for d=1:S_o(1)
		  i=((d-1)*ar)+1;
			retmap(d,:) = finmap(i,:);
		end
	end

	% --- and finally, make the returned structure
 	% reject too small and too large
  ul = unique(retmap);
	M = 1;
	for u=1:length(ul)
	  uidx = find(retmap == ul(u));
	  sul = length(uidx);
		if (sul < size_thresh(1) | sul > size_thresh(2))  
		  retmap(uidx) = 0 ; 
		else
		  members(M).indices = uidx;
			M = M + 1;
		end
	end

	% show outcome
	if (debug)
		RGB_label = label2rgb(retmap, @jet, 'c', 'shuffle');
		figure ;	 imshow(RGB_label,'InitialMagnification','fit'); axis square;
	end
%  if(debug) ;	figure; imshow(altimbd, [0 max(max(fm))/5], 'InitialMagnification', 'fit'); axis square; title('alt img'); end

%
% Given two maps -- master, additions -- it will add additions to master.  If
%  there is overlap, it will simply expand the mater's versions.  Only adds,
%  however, if o_frac*size(additions) of addition's pixels are in master;
%  otherwise it will CHUCK it.
%
%  In both additions and master, pixel value corresponds to ROI identity.
%
% returns the updated master.  Additions are thus either added to master, or
%  discarded.
%
function master = add_to_map(master, additions, o_frac)

  % get the labels for each map
	lm = unique(master); % labels for master
	lm = lm(find(lm > 0)); % get rid of background (label=0)
	mm = max(lm);
	if (length(mm) == 0) ; mm = 1; end
	la = unique(additions); % unique labels for additions
	la = la(find(la > 0)); % background nuke

  % loop over addition labels
	for a=1:length(la)
	  la_i = find(additions == la(a)); % indices having this label
	  min_n = o_frac*length(la_i); % our threshold for number of pixels overlapping
		
		% overlap?
		overlap = 0;
	  for m=1:length(lm) % loop over master labels
		  lm_i = find(master == lm(m)); % master indices having this label
      n_overlap = length(intersect(la_i, lm_i)); % number that overlap
  
			% if overlap exceeds threshold add
      if (n_overlap > min_n)
        overlap = 1;
				master(la_i) = lm(m);
			% If there is too little overlap, then just get rid of the new stuff
			elseif (n_overlap > 0)
			  overlap = 1;
			end

      if (overlap) ; break ; end
		end

		% no overlap? add as an INDEPENDENT roi
    if (~ overlap)
			mm = mm + 1;
		  master(la_i) = mm;
    end
	end

%
% Given a series of belonging-to-cell points, a luminance-threshold matrix, and
%  a radius, this function will incrementally dilate upto radius.  After radius,
%  if no luminance-accepted points are in the cell's points, cell is rejected.
%  If cell points for 2 cells collide, the growth stops at those pixels, even
%  prior to the radius step.  
% 
%  In the end, this function returns a label-set matrix where 0 is background and
%  pixels with a given index correspond to a particular cell.
%
% cellcen: matrix with 'cell centers' - 1 = center, 0 = nothing ; this is labeled
% lumim: luminance image
% rad: radius to go upto
% max_ndils: don't go beyond this number of dilations ; set to 0 for no max
% 
% Returns labeled cell set as matrix, fin_im.
%
function fin_im = compute_via_dilation(cellcen, lumim, rad, max_ndils)

  % prelims
	S = size(lumim);

	% first, get a label matrix to separate all the sub-components
	cellcenbw = im2bw(cellcen/max(max(cellcen)),.2);
	cellcenmat = bwlabel(cellcenbw);
  
	% prep for idlation
  cellid = unique(reshape(cellcenmat,[],1));
  lum_idx = find(lumim == 1); % luminance predetermined points
  cell_idx = []; % points that are cells
	tim = zeros(size(cellcenmat));
	cellim = zeros(size(cellcenmat,1), size(cellcenmat,2), length(cellid));
	cellval = zeros(length(cellid),1);
	for i=1:length(cellid)  
	  if (length(find(cellcenmat == cellid(i))) < 1000)  % keep only cells -- kill bkg
		  cellval(i) = 1; 
		  tim = 0*tim;
			tim(find(cellcenmat == cellid(i))) = 1;
		  cellim(:,:,i) = tim;
			cell_idx = [cell_idx find(cellcenmat == cellid(i))'];
		end
	end

  % predilate by each cell center by radius ... RECOMPUTE idx here
	if (rad > 0)
		cell_idx = []; % points that are cells -- redo
	  for i=1:length(cellid)
			if (cellval(i))
				mat_size = [2*rad+1, 2*rad+1];
				pre_dilel = customdisk([mat_size(2) mat_size(1)], [rad rad], [mat_size(2) mat_size(1)]/2 + 1, 0); 
				dil_cellim = imdilate(cellim(:,:,i),pre_dilel); 
				new_idx = find(dil_cellim == 1);
				new_idx = intersect(new_idx,lum_idx);
				cell_idx = [cell_idx new_idx'];
				dil_cellim = 0*dil_cellim;
				dil_cellim(new_idx) = 1;
				cellim(:,:,i) = dil_cellim;
				if (length(new_idx) == 0) ; cellval(i) = 0; end % reject if no points meet criteria
			end
		end
	end

	% main dilation loop
	dilel = ones(3,3);
	celldone = zeros(size(cellval));
	celldone(find(cellval == 0)) = 1;
	ndil = 0;
	while (sum(celldone) < length(celldone)) % until all are done
		for i=1:length(cellid)
			if (~cellval(i)) ; continue ; end
			% not yet done? process
			if (~celldone(i))  
				% first, just dilate
				dil_cellim = imdilate(cellim(:,:,i),dilel); 
				new_idx = find(dil_cellim == 1);
				last_idx = find(cellim(:,:,i) == 1);

				% are any new points being added (i.e., allowed by luminance and NOT infringing on other cell)
				new_idx = setdiff(new_idx,cell_idx);
				new_idx = intersect(new_idx,lum_idx);

				% flag as done ...
				if (length(new_idx) == 0)
					celldone(i) = 1;
				% ... OR grow cell_idx
				else
				  if (length(cell_idx) == 1)
						cell_idx = [cell_idx new_idx'];
					else
						cell_idx = [cell_idx new_idx];
					end
					dil_cellim=0*dil_cellim;
					dil_cellim(union(new_idx,last_idx)) = 1;
					cellim(:,:,i) = dil_cellim;
				end
			end
		end
		ndil = ndil+1;
		if (max_ndils > 0 & ndil > max_ndils) ; break ; end 
	end

  % build the final label matrix
  fin_im = zeros(size(lumim));
  for i=1:length(cellid)
	  idx = find(cellim(:,:,i) == 1);
		fin_im(idx) = i;
	end


