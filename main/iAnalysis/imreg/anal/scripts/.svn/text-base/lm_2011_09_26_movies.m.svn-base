save_path = '/data/an148378/lm_2011_09_26/';
load_path = '/data/an148378/2011_09_12/scanimage/fov_002/fluo_batch_out/';

doMovie = [0 0 0 0 1];

if (doMovie(1))
  if (~exist('im','var'))
    im = load_image([load_path 'Image_Registration_5_an148378_2011_-09_12_main_25*tif']);
		im = im(:,:,1:210);
	end
	aviobj = avifile([save_path 'an148378_0912_250s.avi'],'fps',7);

  f = figure;
	ax = axes;
	for i=1:size(im,3);
		imshow(im(:,:,i), [0 4000], 'Parent',ax, 'border','tight');
    F = getframe(f);
		aviobj = addframe(aviobj,F);
  end
	aviobj = close(aviobj);
end
if (doMovie(2))
	aviobj = avifile([save_path 'an148378_0912_250s_10frmavg.avi'],'fps',7);

  f = figure;
	ax = axes;
	for i=10:size(im,3);
		imshow(mean(im(:,:,i-9:i),3), [0 2000], 'Parent',ax, 'border','tight');
    F = getframe(f);
		aviobj = addframe(aviobj,F);
  end
	aviobj = close(aviobj);
end
if (doMovie(3))
  im1 = load_image([strrep(load_path,'fov_002','fov_001') 'Image_Registration_5_an148378_2011_-09_12_main_25*tif']);
  im1 = im1(:,:,1:210);
	im2 = im;
  im2 = load_image([load_path 'Image_Registration_5_an148378_2011_-09_12_main_25*tif']); 
  im3 = load_image([strrep(load_path,'fov_002','fov_003') 'Image_Registration_5_an148378_2011_-09_12_main_25*tif']);
  im3 = im3(:,:,1:210);
  im4 = load_image([strrep(load_path,'fov_002','fov_004') 'Image_Registration_5_an148378_2011_-09_12_main_25*tif']);
  im4 = im4(:,:,1:210);
	aviobj = avifile([save_path 'an148378_0912_250s_4panels_10frmavg.avi'],'fps',7);

  f=figure ('Position', [0 0 800 800]);
	sp1 = subplot('Position', [0 0.5 0.5 0.5]);
	sp2 = subplot('Position', [0.5 0.5 0.5 0.5]);
	sp3 = subplot('Position', [0 0 0.5 0.5]);
	sp4 = subplot('Position', [0.5 0 0.5 0.5]);
	for i=10:min([size(im1,3),size(im2,3),size(im3,3),size(im4,3)])
		imshow(mean(im1(:,:,i-9:i),3), [0 4000], 'Parent',sp1, 'border','tight');
		imshow(mean(im2(:,:,i-9:i),3), [0 4000], 'Parent',sp2, 'border','tight');
		imshow(mean(im3(:,:,i-9:i),3), [0 4000], 'Parent',sp3, 'border','tight');
		imshow(mean(im4(:,:,i-9:i),3), [0 4000], 'Parent',sp4, 'border','tight');
    F = getframe(f);
		aviobj = addframe(aviobj,F);
  end
	aviobj = close(aviobj);
end
if (doMovie(4))
	aviobj = avifile([save_path 'an148378_0912_250s_4panels.avi'],'fps',7);

  f=figure ('Position', [0 0 800 800]);
	sp1 = subplot('Position', [0 0.5 0.5 0.5]);
	sp2 = subplot('Position', [0.5 0.5 0.5 0.5]);
	sp3 = subplot('Position', [0 0 0.5 0.5]);
	sp4 = subplot('Position', [0.5 0 0.5 0.5]);
	for i=1:min([size(im1,3),size(im2,3),size(im3,3),size(im4,3)])
		imshow(im1(:,:,i), [0 4000], 'Parent',sp1, 'border','tight');
		imshow(im2(:,:,i), [0 4000], 'Parent',sp2, 'border','tight');
		imshow(im3(:,:,i), [0 4000], 'Parent',sp3, 'border','tight');
		imshow(im4(:,:,i), [0 4000], 'Parent',sp4, 'border','tight');
    F = getframe(f);
		aviobj = addframe(aviobj,F);
  end
	aviobj = close(aviobj);
end

if (doMovie(5))
  load_path = '/data/an38596/2010_02_11/scanimage/fluo_batch_out/';
%  im = load_image([load_path 'Image_Registration_4_an38596_*main_25*tif']);
  im = im(:,:,1:round(210*4/7));
	aviobj = avifile([save_path 'an38596_2010_02_11_4hz.avi'],'fps',4);
  f = figure('Position',[0 0 400 400]);
	ax = axes('Position',[0 0 1 1]);
	for i=1:size(im,3);
		imshow(im(:,:,i), [0 4000], 'Parent',ax, 'border','tight');
		set(ax, 'DataAspectRatio', [2 1 1]);
    F = getframe(f);
		aviobj = addframe(aviobj,F);
  end
	aviobj = close(aviobj);

end
