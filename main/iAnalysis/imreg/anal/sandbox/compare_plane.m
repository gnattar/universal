function compare_plane( plane, stack, z0, dz_max)
	figure('Position',[0 0 800 400]);
	ax1 = subplot('Position',[0 0 0.5 1]);
	ax2 = subplot('Position',[0.5 0 0.5 1]);

  dd = 2;

	xy2z = 600/512;
	dz = linspace(0,dz_max,512);
	tplane = 0*plane;
	for y=1:size(plane,2)
		z = z0 + round(dz(y));
		tplane(y,:) = stack(y,:,z);
	end
			
	imshow(tplane, [0 1000], 'Parent', ax1, 'Border', 'tight');
	imshow(plane, [0 1000], 'Parent', ax2, 'Border', 'tight');

	set(gcf,'Name',['z0: ' num2str(z0) ' dz-max: ' num2str(dz_max)]);
  c = normxcorr2(tplane(100:dd:end-100,1:dd:end),plane(1:dd:end,1:dd:end));
  C = normxcorr2(tplane(1:dd:end,1:dd:end),plane(1:dd:end,1:dd:end));

	max(max(c))
	max(max(C))

