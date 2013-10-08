%
% For now this is a script bc I hope this is not a frequent occurrence --
%  will go thru a dir with master_imreg_image, then take imreg_wildcard 
%  matching guys and generate Image_Registration_WARP_... output tifs.
%  Note that it actually matches imreg_wildcard*, so do NOT include *!
%
%  Works on directory dirname.
%
% EXAMPLE:
%
%   warp_cleanup(pwd, 'Image_Registration_4_');
%
function warp_cleanup (dirname, imreg_wildcard)

  %% --- file list get
	flist = dir([dirname filesep imreg_wildcard '*tif']);
	master_im = load_image([dirname filesep 'master_imreg_image.tif']);
	for f=1:1:length(flist)
	  fname = [dirname filesep flist(f).name];
	  new_name = strrep(fname, imreg_wildcard, 'Image_Registration_WARP_');
		try
  	  process_single_file(master_im, [dirname filesep flist(f).name], new_name);
		catch
		  disp(['FAILED on ' flist(f).name]);
		end
	end

function process_single_file (master_im, fname, new_name)
  [im imh]= load_image(fname);
	disp(['warp_cleanup::processing ' fname]);

	%% --- get base warp for average image
	opt.n_divs = 20;
	opt.lum_gauss_sd_size = .02;
tic
	[im_c warp_parms_r E] = imreg_warp_via_subregion(mean(im,3), master_im, opt);
toc
	% debug
	if (0)
		zim = zeros(512,512,3);
		zim(:,:,1) = master_im;
		zim(:,:,2) = im_c;
		figure;imshow(zim/2000);
	end

%	zim = zeros(512,512,3);
%	zim(:,:,1) = master_im;
%	zim(:,:,2) = mean(im,3);
%	figure;imshow(zim/2000);


	%% now correct all frames and generate corrected movie
	nim = im*0;
tic
	for f=1:size(im,3)
	  nim(:,:,f) = get_warp_image(im(:,:,f), warp_parms_r.X,warp_parms_r.Y); 
	end
toc
  save_image(nim, new_name, imh.header);
