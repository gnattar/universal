
if (0)
  subim = plane(400:500, 200:300);

  % dx, dy, dz
	dx = 0;
	dy = 0;
	dz = 0;

	% angles about axes
	xa = 30;
	ya = 0;
	za = 10;
 
  % init transform -- want to rotate about center and not corner
  c = [round(size(subim,1)/2) round(size(subim,2)/2) 0] ; % z 0 
	Tc1 = [1 0 0 0 ; 0 1 0 0 ; 0 0 1 0 ; -1*c(1) -1*c(2) -1*c(3) 1];

	% rotation matrix
  Rx = [1 0 0 ; 0 cosd(xa) -1*sind(xa) ; 0 sind(xa) cosd(xa)]; % about xaxis
  Ry = [cosd(ya) 0 sind(ya) ; 0 1 0 ; -1*sind(ya) 0 cosd(ya)];
  Rz = [cosd(za) -1*sind(za) 0 ; sind(za) cosd(za) 0 ; 0 0 1];
	R = Rx*Ry*Rz;
	% pad for affine
	R = [[R ; 0 0 0]' ; 0 0 0 1]';


	% transform to return to center
	Tc2 = [1 0 0 0 ; 0 1 0 0 ; 0 0 1 0 ; c(1) c(2) c(3) 1];

	% transform for dx, dy, dz
	T = [1 0 0 0 ; 0 1 0 0 ; 0 0 1 0 ; dx dy dz 1];

	% final affine matrix
	A = Tc1*R*Tc2*T;

	T = maketform('affine',A);

R = makeresampler('cubic','circular');
subim2 = tformarray(subim,T,R,[1 2],[2 1],[100 100],[],[]);

end


if (1)
	params = [];
	params.prenorm_gauss_size = 0; % disable -- do before
	params.edge_avoid = [.2 .1];
	params.ub = [10 10 15];
	params.n_subim = [7 7];
	params.subim_size = [.2 .2];
	params.downsample = [4 4 2];
	params.min_corr = 0.5;

	cd /media/an160508b/rois/
%	stack = load_image('../an160508_2012_02_08_dz1_stack_0to611_pz250_start_15_001');
%	nstack = stack;
%  for i=1:size(stack,3) ; nstack(:,:,i)=normalize_via_gaussconvdiv(stack(:,:,i),.05) ; disp(num2str(i)); end
  if(~exist('nstack', 'var')) ; load ('gaussconvstack.mat'); end
	fl = dir('*fov*mat');
	stackfit = [];
	colors = jet(length(fl));
	for f=1:length(fl)
	  params.guess_z = 60 + (f-1)*15;
		load (fl(f).name);
		rA = obj;
		nplane = normalize_via_gaussconvdiv(rA.masterImage,.05);
		[X Y Z ] = map_plane_to_stack_warpfield (nplane, nstack, params);
		stackfit(f).X = X;
		stackfit(f).Y = Y;
		stackfit(f).Z = Z;
		stackfit(f).im = rA.masterImage;
		stackfit(f).fn = fl(f).name;
		save('stackfits2.mat', 'stackfit');
	end
  zplot = figure;
	hold on;
	for f=1:length(fl)
		figure(zplot);
		plot(mean(stackfit(f).Z,2), 'color', colors(f,:));
	end
end
