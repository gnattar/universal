
function [best_z0 best_dz] = plane2stack_fit_single(x_range, y_range, plane, stack)
	z0s = 100:10:251;
	dz_maxs = 0:10:160;
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
				tplane(y,:) = stack(y,:,z);
			end
			
			if (sing_plot)
				imshow(tplane, [0 2000], 'Parent', ax1, 'Border', 'tight');
				imshow(plane, [0 1000], 'Parent', ax2, 'Border', 'tight');
			end

			c = normxcorr2(tplane(x_range(1):dd:x_range(2),y_range(1):dd:y_range(2)), ...
			    plane(1:dd:end,1:dd:end));
			C(i1,i2) = max(max(c));
			disp(['dz: ' num2str(dz_max) ' z0: ' num2str(z0) ' max corr: ' num2str(C(i1,i2))]);
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
