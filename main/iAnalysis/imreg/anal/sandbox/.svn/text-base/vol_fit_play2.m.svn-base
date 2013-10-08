
%% iterate over different angles, z's
rfs = {'an160508_2012_02_10_based_2012_02_10_fov_01002','an160508_2012_02_10_based_2012_02_10_fov_01003','an160508_2012_02_10_based_2012_02_10_fov_01004', ...
       'an160508_2012_02_10_based_2012_02_10_fov_02002','an160508_2012_02_10_based_2012_02_10_fov_02003','an160508_2012_02_10_based_2012_02_10_fov_02004', ...
       'an160508_2012_02_10_based_2012_02_10_fov_03002','an160508_2012_02_10_based_2012_02_10_fov_03003','an160508_2012_02_10_based_2012_02_10_fov_03004', ...
       'an160508_2012_02_10_based_2012_02_10_fov_04002','an160508_2012_02_10_based_2012_02_10_fov_04003','an160508_2012_02_10_based_2012_02_10_fov_04004', ...
       'an160508_2012_02_10_based_2012_02_10_fov_05002','an160508_2012_02_10_based_2012_02_10_fov_05003','an160508_2012_02_10_based_2012_02_10_fov_05004', ...
       'an160508_2012_02_10_based_2012_02_10_fov_06002','an160508_2012_02_10_based_2012_02_10_fov_06003','an160508_2012_02_10_based_2012_02_10_fov_06004', ...
       'an160508_2012_02_10_based_2012_02_10_fov_07002','an160508_2012_02_10_based_2012_02_10_fov_07003','an160508_2012_02_10_based_2012_02_10_fov_07004', ...
       'an160508_2012_02_10_based_2012_02_10_fov_08002','an160508_2012_02_10_based_2012_02_10_fov_08003','an160508_2012_02_10_based_2012_02_10_fov_08004', ...
       'an160508_2012_02_10_based_2012_02_10_fov_09002','an160508_2012_02_10_based_2012_02_10_fov_09003','an160508_2012_02_10_based_2012_02_10_fov_09004', ...
       'an160508_2012_02_10_based_2012_02_10_fov_10002','an160508_2012_02_10_based_2012_02_10_fov_10003','an160508_2012_02_10_based_2012_02_10_fov_10004', ...
       'an160508_2012_02_10_based_2012_02_10_fov_11002','an160508_2012_02_10_based_2012_02_10_fov_11003','an160508_2012_02_10_based_2012_02_10_fov_11004'};
r_cen = 80:15:80+(15*(length(rfs)-1));

cd /Volumes/an160508b;
if (~exist('ntvim'))
	load processed_stack.mat;
end

X = {};
Y = {};
Z = {};
idx = {};
for r=1:length(rfs)
	pre_rbc_thresh = .99;
	pre_rbc_connected_size = [25 500];

for zi=1:length(z)
  for ti=1:length(theta)
	   im = get_plane_im_from_vol_im(vim, [256 256 z(zi)], [theta(ti) 0]);% imshow(im,[0 2000], 'Parent', ax); 
		 corrs(zi,ti) = max(max(normxcorr2(im(cr,cc), fim(cr,cc)))) ;
		 %title(num2str(nxc(zi))) ; pause; end

  params = [];
  params.subim_ublb_offs = [0 0 15 0 0];

	% what subset of ntvim to pass?
	z1 = max(1,r_cen(r)-100)
  dz_up = r_cen(r)-z1;
	z2 = min(size(ntvim,3),r_cen(r)+100)
  dz_down = z2 - r_cen(r);

	% lb/ub -- 40 or less if not possible
  params.init_lb = [0 0 dz_up-min(40,dz_up-1) 0 0];
  params.init_ub = [0 0 dz_up+min(40,dz_down-1) 6 0];

  [X{r} Y{r} Z{r} idx{r}] = fit_plane_im_to_vol_im_warpfield(ntvim(:,:,z1:z2), im, params);
	Z{r} = Z{r} + z1 - 1;

	save('vol_fit_play2_b.mat', 'X','Y','Z','idx');
end

  if (1) 
		figure ; 
		ax = subplot('Position', [0.1 0.1 .8 .8]); 
		imshow(corrs', [min(min(corrs)) max(max(corrs))], 'parent', ax, 'border','tight') ; 
		set(gca,'XTick', 1:length(z));
		xlab = {};
		for i=1:length(z) ; xlab{i} = num2str(z(i));  end
		set (gca, 'XTickLabel' ,xlab);
		xlabel('z');
		set(gca,'YTick', 1:length(theta));
		ylab = {};
		for i=1:length(theta) ; ylab{i} = num2str(theta(i));  end
		set (gca, 'YTickLabel' ,ylab);
		ylabel('theta');
		colormap jet
	end
