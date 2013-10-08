%
% This method will take an planar image and a volume (in the form of a stack)
%  and return, for each point in the image, the best-matching x,y, and z
%  coordinates in the stack.
%
% USAGE:
%
%  [X Y Z] = map_plane_to_stack_warpfield (plane, stack, params)
%
% PARAMS:
%
%  X,Y,Z: coordinates, in terms of stack, for each point in plane.  These are
%         all matrices of size size(plane).
%
%  plane: An image
%  stack: An image stack, 3rd dimension being 'z'
%  params: Additional parameters ; any field that is passed will be used.  
%          This is a structure.
%     n_subim: how many subimages per dimension? 2 numbers, [hor ver] dflt [5 5]
%     subim_size: how big? frac or pixel. [hor ver] dflt [.1 .1]
%     prenorm_gauss_size: how big of a gaussian to prenormalize by? frac or pix
%                         dflt .02
%     downsample: how much to downsample each dimension by? integral value 
%                 [2 2 1] dflt [hor vert z]
%     edge_avoid: what fraction away from edge to avoid?  [hor vert]  dflt [.1 .1]
%     z_ver_only: default is 1 -- in piezo imaging, z for all points along a 
%                 horizontal stripe is same, so only need z for vertical.  Turn 
%                 off (0) if you want regular interpolation of z.
%     ub: upper bounds for [x y z] displacement (magnitude) ; default is [50 50 50]
%     z_guess: guess value for Z ; useful only if you have ub
%     min_corr: subimages for which correlation is below this are rejected; dflt 0.2
%
function  [X Y Z] = map_plane_to_stack_warpfield (plane, stack, params)

  X = nan*plane; 
	Y = X ; 
	Z = X ; 

  %% --- declarations & default settings
  n_subim = [5 5]; % in hor/vert
	subim_size = [.1 .1]; % integer means in pixels ; < 1 means fraction of size ; hor,ver
	prenorm_gauss_size = 0.05; % prenormalize by this size gaussian -- frac of STACK
	max_displacement = [50 50]; % in XY only ; no Z
	downsample = [2 2 1]; % factor by which we downsample template & image
	edge_avoid = [0.1 0.1]; % fraction from edge to avoid x,y or pixels
	z_ver_only = 1;
	ub = [50 50 50]; % X Y Z displacement upper bound
	guess_z = [];
  min_corr = 0.2;

  if (nargin >= 3 && isstruct(params))
		fnames = fieldnames(params);
		for f=1:length(fnames)
		  eval([fnames{f} '= params.' fnames{f} ';']);
		end
	end

  %% --- process inputs
	S_st = size(stack);
	S_pl = size(plane);

	if (subim_size(1) < 1) ; subim_size(1) = floor(subim_size(1)*S_pl(2)); end
	if (subim_size(2) < 1) ; subim_size(2) = floor(subim_size(2)*S_pl(1)); end
	if (edge_avoid(1) < 1) ; edge_avoid(1) = ceil(edge_avoid(1)*S_pl(2)); end
	if (edge_avoid(2) < 1) ; edge_avoid(2) = ceil(edge_avoid(2)*S_pl(1)); end

	pn_gauss_size = round([prenorm_gauss_size*S_st(1) prenorm_gauss_size*S_st(2)]);

	%% --- preprocessing

	% prenormalize images with gaussian
	if (sum(pn_gauss_size) > 0)
	  plane = normalize_via_gaussconvdiv(plane, pn_gauss_size);
	  stack = normalize_via_gaussconvdiv(stack, pn_gauss_size);
	end

	%% --- loop through subimages, call gradient-descent method for each (we assume 
	%     that there is a genuine minimum)
	h_span = S_pl(2) - ceil(edge_avoid(1)*2);
	v_span = S_pl(1) - ceil(edge_avoid(2)*2);

	dh = floor(h_span/n_subim(1));
	hor_cen = round(((dh/2)+edge_avoid(1)):dh:(S_pl(2)-(dh/2)-edge_avoid(1)));
	dv = floor(v_span/n_subim(2));
	ver_cen = round(((dv/2)+edge_avoid(2)):dv:(S_pl(1)-(dv/2)-edge_avoid(2)));

  % build set of coordinates tested
	x_0 = zeros(1,length(hor_cen)*length(ver_cen));
	y_0 = zeros(1,length(hor_cen)*length(ver_cen));
	x_f = x_0;
	y_f = y_0;
	z_f = y_0;
	peakcorr = y_0;
	i = 1;
	for hi=1:length(hor_cen) ; for vi=1:length(ver_cen)
		x_0(i) = hor_cen(hi);
		y_0(i) = ver_cen(vi);
		i = i+1;
	end ; end

  % core computation - fit images
  for i=1:length(x_0)
	  % build subimage
	  h_coords = round([x_0(i)-(subim_size(1)/2) x_0(i)+(subim_size(1)/2)]);
	  v_coords = round([y_0(i)-(subim_size(2)/2) y_0(i)+(subim_size(2)/2)]);
	  subim = plane(v_coords(1):v_coords(2),h_coords(1):h_coords(2));

    % fit it
		[x_f(i) y_f(i) z_f(i) peakcorr(i)] = get_position_in_stack(subim, stack, x_0(i), y_0(i), ub, guess_z, downsample);

    % output some crap
		disp([' xo -> xf: ' num2str(x_0(i)) ' -> ' num2str(x_f(i)) ...
			      ' yo -> yf: ' num2str(y_0(i)) ' -> ' num2str(y_f(i)) ...
			      ' z: ' num2str(z_f(i))]);

    % image . . . 
		if (0)
		  bwim = zeros(size(plane,1), size(plane,2),3);
			bwim(:,:,1) = stack(:,:,z_f(i));
	    bh_coords = round([x_f(i)-(subim_size(1)/2) x_f(i)+(subim_size(1)/2)]);
	    bv_coords = round([y_f(i)-(subim_size(2)/2) y_f(i)+(subim_size(2)/2)]);
			bwim(bv_coords(1):bv_coords(2), bh_coords(1):bh_coords(2), 2) = subim;
			M = quantile(reshape(bwim,[],1),.98);
			imshow(bwim*(1/M));
			text(10,10,[' xo -> xf: ' num2str(x_0(i)) ' -> ' num2str(x_f(i)) ...
			      ' yo -> yf: ' num2str(y_0(i)) ' -> ' num2str(y_f(i)) ...
			      ' z: ' num2str(z_f(i)) ' peakcorr: ' num2str(peakcorr)], 'Color', [0 1 1],'FontWeight', 'bold', 'FontSize', 13);
			pause (.05);
		end

		% increment counter
		i = i+1;
	end

	% discard correlation rejects
	val_corr_idx = find(peakcorr >= min_corr);
	inval_corr_idx = find(peakcorr < min_corr);
	x_0i = x_0(val_corr_idx);
	y_0i = y_0(val_corr_idx);
	x_fi = x_f(val_corr_idx);
	y_fi = y_f(val_corr_idx);
	z_fi = z_f(val_corr_idx);

  %% --- use x/y displacement to determine outliers 
	o_coords = [x_0i' y_0i'];
	n_coords = [x_fi' y_fi'];
	d_coords = o_coords-n_coords;
	outlier_idx = get_displacement_outliers(o_coords, d_coords);
	val_idx = setdiff(1:length(x_0i), outlier_idx);
	outlier_idx = [inval_corr_idx val_corr_idx(outlier_idx)];

	%% --- interpolate full warpfield matrix using the non-outlier x/y/z displacements
% DEBUG: figure ; plot([reshape(x_0M,[],1)'; reshape(x_fM,[],1)'], [reshape(y_0M,[],1)' ; reshape(y_fM,[],1)'])

  % create small matrices containing only points at which calculation was done explicitly
	x_fM = reshape(x_f, length(ver_cen), length(hor_cen));
	x_fM (outlier_idx) = nan;
	y_fM = reshape(y_f, length(ver_cen), length(hor_cen));
	y_fM (outlier_idx) = nan;
	z_fM = reshape(z_f, length(ver_cen), length(hor_cen));
	z_fM (outlier_idx) = nan;

  % convert these matrices into FULL matrix form, in preparation for 
	%  extern_inpaint_nans.
	X(ver_cen,hor_cen) = x_fM;
	Y(ver_cen,hor_cen) = y_fM;

  % interpolate these
	X = extern_inpaint_nans(X);
	Y = extern_inpaint_nans(Y);

	% Z is special since it should be the same along the horizontal axis
	if (z_ver_only)
		z_mu = nanmean(z_fM,2);
		z_full_interp = interp1(ver_cen, z_mu, 1:S_pl(1),'linear', 'extrap');
		Z = repmat(z_full_interp',1,S_pl(2));	
	else % of course we could do it the base way ...
	  Z(ver_cen,hor_cen) = z_fM;
	  Z = extern_inpaint_nans(Z);
	end

%%
% wrapper for repeated calls across Z to get_subimage_displacement; returns 
%  x,y,z for this guy.  c_x and c_y are the positions of subim's center within the
%  image it comes from, so that max displacements can be enforced.
%
%  ub and guess_z are the [x y z] displacement upper bounds and the guess for z.
%  z upper bound is only in play if you have a guess for z.
%
%  downsample: downsampling [x y z] (3 el vector);
%
function [x y z peakcorr] = get_position_in_stack(subim, stack, c_x, c_y, ub, guess_z, downsample)

	% sanity checks
	downsample = [downsample ones(3-length(downsample),1)'];
  nz = size(stack,3);
	corrval = nan*zeros(1,nz);
	dx = nan*zeros(1,nz);
	dz = nan*zeros(1,nz);

	% setup zvals
	if (length(guess_z) > 0 && length(ub) >= 3)
	  zvals = max(guess_z-ub(3),1):min(guess_z+ub(3),nz);
	else
	  zvals = 1:nz;
	end

	% downsample 
	if (length(downsample) >= 3 && downsample(3) > 1) ; zvals = zvals(1:downsample(3):end); end
	if (length(downsample) >= 2 && (downsample (2) > 1 | downsample (1) > 1)) 
	  subim = subim(1:downsample(2):end, 1:downsample(1):end);
	end

  % core loop
  for zi=1:length(zvals)
	  % downsample stack?
	  if (length(downsample) >= 2 && (downsample (2) > 1 | downsample (1) > 1)) 
			stackim = stack(1:downsample(2):end, 1:downsample(1):end, zvals(zi));
	  end

		% run it
    [dx(zi) dy(zi) corrval(zi)] = get_subimage_displacement(stackim, subim, round(c_x/downsample(1)), ...
		  round(c_y/downsample(2)), round(ub(1)/downsample(1)), round(ub(2)/downsample(2)));
		disp(['doing ' num2str(zvals(zi)) ' x ' num2str(dx(zi)) ' y ' num2str(dy(zi)) ' corr: ' num2str(corrval(zi))]);
	end

	% compute best
	[peakcorr idx] = max(corrval);
	z = zvals(idx);
	x = c_x + downsample(1)*dx(idx);
	y = c_y + downsample(2)*dy(idx);

	if (0) %DEBUG
    figure ; 
		subplot(2,2,1) ; 
		imshow(subim, [0 quantile(reshape(subim,[],1), .99)]); 
		subplot(2,2,2);
		Ss = size(subim);
		sx = (x-round(Ss(2)/2)):(x+round(Ss(2)/2));
		sy = (y-round(Ss(1)/2)):(y+round(Ss(1)/2));
		subim_stack = stack(sy,sx,z);
		imshow(subim_stack, [0 quantile(reshape(subim_stack,[],1), .99)]); 
    subplot(2,1,2); plot(corrval) ; 
	end


%%
% for a given source sub-image (subim), compute the best normxcorr2-based 
%  translation to get it to line up to somewhere in target (im_t).  Pass the
%  center of the subim because dx and dy are relative im_t, so you must then
%  offset by the x, y coordinates of where you took subim from in source 
%  image.  Thus, c_x and c_y are the coordinates of the center of subim in im_s.
%  ub_x and ub_y are max displacements in x/y.
%
function [dx dy corrval] = get_subimage_displacement(im_t, subim, c_x, c_y, ub_x, ub_y)
	dx = 0;
	dy = 0;
	corrval = 0;

  try 
		% correlation computation
		cim = normxcorr2(subim, im_t); 
		ssi = ceil((size(subim)-[1 1])/2);
		cim = cim(ssi(1):size(cim,1)-ssi(1)-1, ssi(2):size(cim,2)-ssi(2)-1) ; % remove borders
	%subplot(2,2,4); imshow(cim, [min(min(cim)) max(max(cim))]); axis square

		% compute dx, dy, keeping in mind displacement constraintrs
		ix = max(1,c_x-ub_x):min(size(cim,2),c_x+ub_x);
		iy = max(1,c_y-ub_y):min(size(cim,1),c_y+ub_y);
		cim = cim(iy,ix);
    S = size(cim);
		cim_v = reshape(cim,[],1);
		[corrval idx] = max(cim_v);
		x_peak = ceil(idx/S(1)) ;
		y_peak = idx-S(1)*(x_peak-1);
		x_peak = x_peak + ix(1) - 1; 
		y_peak = y_peak + iy(1) - 1;

		% 1 is the correction factor due to rounding issues 
		dx = x_peak-c_x-1;
		dy = y_peak-c_y-1;
	catch me
		disp('================================================================================');
	  disp('map_plane_to_stack_warpfield::error encountered in normxcorr2 step.');
		disp(' ');
		disp('Detailed error message: ');
		disp(getReport(me, 'extended'));
		disp (' ');
		disp('================================================================================');
	end
