function [best_z0 best_dz] = plane2stack_play(stack,plane)

	if (0) % OLD
		clear params;
		params.prenorm_gauss_size = 0; % disable -- already done
		params.edge_avoid = [.1 .1];
		params.z_guess = 60;
		params.ub = [30 30 70];

		params.n_subim = [7 7];
		params.subim_size = [.2 .2];
		params.subim_size = [.1 .1];
		params.subim_size = [.2 .2];
		params.downsample = [4 4 2];

		[X Y Z ] = map_plane_to_stack_warpfield (nplane, nstack, params);
	end


%	figure('Position',[0 0 800 400]);
%	ax1 = subplot('Position',[0 0 0.5 1]);
%	ax2 = subplot('Position',[0.5 0 0.5 1]);

  dy = 100;
	i = 1;
  for yi=1:dy:512-dy
		[best_z0(i) best_dz(i) ] = fit_single(yi:yi+dy, plane, stack);
		i = i+1;
	end


function [best_z0 best_dz] = fit_single(y_range, plane, stack)
	z0s = 100:10:251;
	dz_maxs = 0:2:20;
	C = zeros(length(z0s), length(dz_maxs));
	dd = 2;
  sing_plot = 0;

%sing_plot = 1;
%z0s = 100;
%dz = 100;

  if (sing_plot)
		figure('Position',[0 0 800 400]);
		ax1 = subplot('Position',[0 0 0.5 1]);
		ax2 = subplot('Position',[0.5 0 0.5 1]);
	end


	for i1 = 1:length(z0s)
		z0 = z0s(i1);
		for i2 = 1:length(dz_maxs)
			dz_max = dz_maxs(i2);
			xy2z = 600/512;
			dz = linspace(0,dz_max,512);
			%tplane = zeros(300,300);
			tplane = 0*plane;
	%		ntplane = 0*nplane;
			for y=1:512
				z = z0 + round(dz(y));
	%			tplane(y,:) = stack(y,:,z);
				tplane(y,:) = stack(y,:,z);
	%			ntplane(y,:) = nstack(y,:,z);
			end
			
			if (sing_plot)
				imshow(tplane, [0 2000], 'Parent', ax1, 'Border', 'tight');
				imshow(plane, [0 1000], 'Parent', ax2, 'Border', 'tight');
			end

	%		C = normxcorr2(nplane(400:2:end,1:2:end),tplane(1:2:end,1:2:end)); 
			%c = normxcorr2(tplane(1:2:end,1:2:end),plane(100:2:400,100:2:400));
			%c = normxcorr2(tplane(200:2:300,200:2:300),plane(1:2:end,1:2:end));
			%c = normxcorr2(ntplane(300:2:400,300:2:400),nplane(1:2:end,1:2:end));
			%c = normxcorr2(ntplane(100:dd:400,400:dd:500),nplane(1:dd:end,1:dd:end));
			c = normxcorr2(tplane(min(y_range):dd:max(y_range),100:dd:400),plane(1:dd:end,1:dd:end));
			C(i1,i2) = max(max(c));
			disp(['dz: ' num2str(dz_max) ' z0: ' num2str(z0) ' max corr: ' num2str(C(i1,i2))]);
%			disp(['dz: ' num2str(dz_max) ' z0: ' num2str(z0) ' max corr: ' num2str(C(i1,i2))]);
			%pause;
		end
	end
  
	[irr idx_dz] = max(max(C));
	[irr idx_z0] = max(max(C'));
	best_z0 = z0s(idx_z0);
	best_dz = dz_maxs(idx_dz);

  if (1) 
		figure ; 
		ax = subplot('Position', [0.1 0.1 .8 .8]); 
		imshow(C, [min(min(C)) max(max(C))], 'parent', ax, 'border','tight') ; 
		set(gca,'XTick', 1:length(dz_maxs));
		xlab = {};
		for i=1:length(dz_maxs) ; xlab{i} = num2str(dz_maxs(i));  end
		set (gca, 'XTickLabel' ,xlab);
		xlabel('dz max');
		set(gca,'YTick', 1:length(z0s));
		ylab = {};
		for i=1:length(z0s) ; ylab{i} = num2str(z0s(i));  end
		set (gca, 'YTickLabel' ,ylab);
		ylabel('z0');
		colormap jet
		title(['y_range: ' num2str(min(y_range)) ' to ' num2str(max(y_range))]);
	end
