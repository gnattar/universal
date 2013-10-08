%
% This will play difference images as a movie
%
% im_s, im_t, im_c: source, target, and corrected source images
% dx, dy: dx and dy vectors ; can be empty
% debug: 2 - show
%
function imreg_wrapup_plot_err_movie( im_s, im_t, im_c, dx, dy, debug)
  % measurements
	sim = size(im_s);
	nframes = sim(3);

  % invoke figure, defaults
	im1_rgb = zeros(sim(1),sim(2), 3);
	im2_rgb = zeros(sim(1),sim(2), 3);
	im_s = im_s/max(max(max(im_s)));
	im_t = im_t/max(max(max(im_t)));
	dim_c = im_c/max(max(max(im_c)));

	im1_rgb(:,:,1) = im_t;

	figure;
	if (size(dx,1) >= 1)
		sp1 = subplot(2,2,1);
		sp2 = subplot(2,2,2);
	else
		sp1 = subplot('Position', [0.05 0.05 .45 .45]);
		sp2 = subplot('Position', [0.5 0.05 .45 .45]);
  end

	for f=1:nframes
		% plot corrected image
		subplot(sp1);
		im2_rgb(:,:,2) = dim_c(:,:,f);
		imshow(im1_rgb + im2_rgb, 'Border','tight');
		axis square;

    % compute correlation coefficient, discarding invalid pixels (<= 0)
		imsl = reshape(im_t,1,[]);
		imcl = reshape(im_c(:,:,f),1,[]);
		val = find(imcl > 0 & imsl > 0);
		imsl = imsl(val)/median(imsl(val));
		imcl = imcl(val)/median(imcl(val));
		R = corrcoef(imsl,imcl);
		Err = R(1,2);
		title(['corrected f: ' num2str(f) ' corr: ' num2str(Err)]);

		% plot original image
		subplot(sp2);
		im2_rgb(:,:,2) = im_s(:,:,f);
		imshow(im1_rgb + im2_rgb, 'Border', 'tight');
		axis square;
		imsl = reshape(im_t,1,[]);
		imcl = reshape(im_s(:,:,f),1,[]);
		val = find(imcl ~= -1);
		imsl = imsl(val)/median(imsl(val));
		imcl = imcl(val)/median(imcl(val));
		R = corrcoef(imsl,imcl);
		Err = R(1,2);
		title(['original f: ' num2str(f) ' corr: ' num2str(Err)]);

		% plot dx and dy vectors if needbe
		if (size(dx,1) >= f)
			subplot(2,2,3) ;
			plot(dx(f,:), 'b');
			title('dx');
			subplot(2,2,4) ;
			plot(dy(f,:));
			title('dy');
		end
		pause;
	end
