%
% SP FEb 2011
%
% Function for PSF measurement from a stack of bead data.
%
%  USAGE:
%
%  psf = psf_measure(im, pix2um, bead_coords)
%
%    psf: nx3 matrix with PSF's in FWHM of all beads
%
%    im: the image stack 
%    pix2um: 3 element vector with pixel-to-micron conversion for each
%            dimension of im (in units of microns/pixel)
%    bead_coords: 3xn matrix with (approx) positions of bead centers
%
function psf = psf_measure(im, pix2um, bead_coords)
  debug = 0;
   
	if (size(bead_coords,2) == 3) ; bead_coords = bead_coords' ; end
  psf = nan*bead_coords;

  % how big of a box around we will look @ - multiply by 2 to get um range ;
	%  this will vary based on your bead density but should be same for entire sample
	sub_size = ceil([2.5 2.5 10]./pix2um) ;

  % --- loop over beads
	for b=1:size(bead_coords,2)
	  % find the center 
		simbx = [max(1, -1*sub_size(1)+bead_coords(1,b)) min(size(im,1), sub_size(1)+bead_coords(1,b))];
		simby = [max(1, -1*sub_size(2)+bead_coords(2,b)) min(size(im,2), sub_size(2)+bead_coords(2,b))];
		simbz = [max(1, -1*sub_size(3)+bead_coords(3,b)) min(size(im,3), sub_size(3)+bead_coords(3,b))];

		subim1 = im(simbx(1):simbx(2), simby(1):simby(2), simbz(1):simbz(2));

		% find max Z
		[irr best_z] = max(squeeze(sum(sum(subim1,1))));
		z = best_z - sub_size(3)+bead_coords(3,b);
    
		if (debug)
		  close all;
			imshow(subim1(:,:,best_z), [0 max(max(max(subim1)))]);
			pause;
		end

		% max X/Y
		[val irr] = max(squeeze(subim1(:,:,best_z)),[],2);
    [irr best_x] = max(val);
		x = best_x - sub_size(1)+bead_coords(1,b);
		[val irr] = max(squeeze(subim1(:,:,best_z)),[],1);
    [irr best_y] = max(val);
		y = best_y - sub_size(2)+bead_coords(2,b);

		fbc = [x y z];
		disp(['Original center: ' num2str(bead_coords(:,b)') ' new: ' num2str(fbc)]);

		% get new stack with adjusted bead center
		simbx = [max(1, -1*sub_size(1)+x) min(size(im,1), sub_size(1)+x)];
		simby = [max(1, -1*sub_size(2)+y) min(size(im,2), sub_size(2)+y)];
		simbz = [max(1, -1*sub_size(3)+z) min(size(im,3), sub_size(3)+z)];
		subim = im(simbx(1):simbx(2), simby(1):simby(2), simbz(1):simbz(2));
    
		if (debug)
			imshow(subim(:,:,sub_size(3)), [0 max(max(max(subim)))]);
			pause;
		end

		% and now compute gaussians
		c1 = sub_size(1)+1;
		c2 = sub_size(2)+1;
		c3 = sub_size(3)+1;

		% Z 
    for z=1:size(subim,3)
		  % 5x5 pixel area used for averaging
		  prof_z(z) = squeeze(sum(sum(subim(c1-2:c1+2,c2-2:c2+2,z))));
		end
    tpsf(3) = get_fwhm(prof_z);

		% X, Y
    subim = squeeze(subim(:,:,c3-1));
		for x=1:size(subim,1)
		  prof_x(x) = subim(x,c2-1);
		end
    tpsf(1) = get_fwhm(prof_x);
		for y=1:size(subim,2)
		  prof_y(y) = subim(c1-1,y);
		end
    tpsf(2) = get_fwhm(prof_y);

		% rescale psf to microns
    psf(:,b) = tpsf.*pix2um;

		if (debug)
		  disp(num2str(psf));
			pause;
		end
	end

%
% computes full-width half-max in pixels ...
%
function fwhm = get_fwhm(prof)

  % --- compute half-max
	vbase = quantile(prof,0.1);% 10th %ile SHOULD be essentially baseline
	prof = prof-vbase; % zero it

  [vmax imax] = max(prof);
	hm = (vmax)/2;

	% --- fit to a gaussian 
	%options = optimset('Display','off','TolFun',tol,'LargeScale','off');
	options = optimset('Display','off','LargeScale','off');
	x = 1:length(prof);
	ip = [imax,1,vmax];
	fp = fminunc(@fitGaussian1D,ip,options,prof,x);

	% --- calculate fwhm LAZY WAY! (hi-res from fit then find calls
	hiResX = 1:0.1:length(prof);
	hiResProf = fp(3)*exp(-0.5*(hiResX-fp(1)).^2./(fp(2)^2));

	i1 = min(find(hiResProf > hm));
	i2 = max(find(hiResProf > hm));
	fwhm = hiResX(i2)-hiResX(i1);

  % activate to see gauss fit
  if (0)
	  plot(prof);
		hold on;
		plot(hiResX, hiResProf, 'r-');
		plot([hiResX(i1) hiResX(i2)], [hiResProf(i1) hiResProf(i2)], 'm-');
  end
	

%
% Gaussian fitter
%
function [z] = fitGaussian1D(p,v,x);
	zx = p(3)*exp(-0.5*(x-p(1)).^2./(p(2)^2)) - v;
	z = sum(zx.^2);
