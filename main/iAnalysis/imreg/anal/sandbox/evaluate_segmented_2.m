%
% For evaluating an image segmentation relative hand drawn ROIs.
%
function evaluate_segmented_2 (segmented_file, vol_fit_root_path, bounding_boxes_path, volume_im_path)

 load(segmented_file); 
 load(vol_fit_root_path);
 load(bounding_boxes_path);
 vim = load_image(volume_im_path);

	% TEMPORARY -- should be in there in the future!
	roi_file_path = {};
	for v=1:11
	  for p=2:4
		  roi_file_path{length(roi_file_path)+1} = sprintf('rois%can160508_2012_02_10_based_2012_02_10_fov_%02d%03d.mat', filesep, v, p);
		end
	end

 
  % binarize segmented -- ALL will now just be 1(!)
	if (exist('labeling', 'var'))
  	segmented = labeling;
	end
  S = size(segmented);
	bi_segmented = segmented*0;
	bi_segmented(find(segmented > 0)) = 1;

  % plot ROIs versus segmented
	fig = figure;
	ax = axes;
	aviobj = avifile(strrep(segmented_file, 'mat', 'avi'));
	P_ggr(length(roi_file_path)) = nan;
	P_rgg(length(roi_file_path)) = nan;
	mean_Z(length(roi_file_path)) = nan;
	for r=1:length(roi_file_path)
	  load(roi_file_path{r});
    rA = obj;
		
	  tim = 0*rA.masterImage;
		im{r} = rA.masterImage;
		for ri=1:length(rA.rois)
		  tim(rA.rois{ri}.indices) = 1;
		end
		lim{r} = bwlabel(tim);

	  sim = 0*tim;
	  bbim = 0*tim;
	  for x=1:size(X{r},2)
		  for y=1:size(X{r},1)
			  x_ = round(X{r}(y,x));
			  y_ = round(Y{r}(y,x));
			  z_ = round(Z{r}(y,x));

        if (x_ <= S(2) && x_ > 0 && y_ <= S(1) && y_ > 0 && z_ > 0 && z_ <= S(3))
					sim(y,x) = bi_segmented(y_, x_, z_);
					bbim(y,x) = bb(y_, x_, z_);
				end
			end
		end

    % final image
		fim = double(rA.masterImage/quantile(reshape(rA.masterImage,[],1),.995));
		fim(find(fim > 1)) = 1;
		fim = fim*(252/256);
		cm = gray(253);
		cm(253,:) = [0 1 0];
		cm(254,:) = [1 0 0];
		cm(255,:) = [1 1 0];
		hand_idx = find(tim);
		auto_idx = find(sim);
		train_idx = find(bbim);

		P_ggr(r) = length(intersect(hand_idx,auto_idx))/length(auto_idx);
		P_rgg(r) = length(intersect(hand_idx,auto_idx))/length(hand_idx);
		mean_Z(r) = mean(reshape(Z{r},[],1));

    fim(train_idx) = fim(train_idx)/2;
		fim(hand_idx) = 253/256;
		fim(auto_idx) = 254/256;
		fim(intersect(auto_idx,hand_idx)) = 255/256;

		imshow(fim, [0 1], 'Parent', ax);
		colormap(cm);
		text(20,20,(sprintf('Green: hand Red: auto ; P(g|r): %0.2f P(r|g) %0.2f Z (0=surface): %d', P_ggr(r), P_rgg(r), round(mean(mean(Z{r}))))), 'Color', [1 1 1], 'BackgroundColor', [0 0 0], 'FontSize', 12);

    F = getframe(fig);
		aviobj = addframe(aviobj,F);
		pause (.05);
	end
	aviobj = close(aviobj);

	% statistic 1
  
	save('mapping.mat', 'im', 'X', 'Y', 'Z', 'lim');

	% more
	figure ; 
	plot(mean_Z, P_ggr, 'k-') ; hold on ; plot(mean_Z, P_rgg, 'm-');
	legend({'P(hand-labeld | algorithm-labeld)', 'P(algorithm-labeld | hand-labeled)'});
	xlabel('Depth (um)');
	ylabel('Probability');

	% boring -- distro of test volumes vs depth
	frac_test = 0*mean_Z;
  for i=1:size(bb,3)
    frac_test(i) = length(find(bb(:,:,i)))/(size(bb,2)*size(bb,1));
	end
	figure ; 
	plot(1:611, frac_test, 'k-') ;
	xlabel('Depth (um)');
	ylabel('Fraction of image included in training data');

	% distro of test volumes vs luminance
  figure;
	bbidx = find(bb);
	vvim = reshape(vim,[],1);
	subplot(3,1,1);
	N_reg = hist(vvim,0:10:6000);
  bar(0:10:6000, N_reg);
	a=axis; axis([0 1000 a(3) a(4)]);
	title('Luminance histogram all image regions');
	subplot(3,1,2);
	N_bb = hist(vvim(bbidx),0:10:6000);
  bar(0:10:6000, N_bb);
	a=axis; axis([0 1000 a(3) a(4)]);
	title('Luminance histogram training image regions');

  % normalize
	N_reg = N_reg/max(N_reg);
	N_bb = N_bb/max(N_bb);

	% plot diff
	subplot(3,1,3);
	plot(N_reg-N_bb);
	a=axis; axis([0 1000 a(3) a(4)]);
	title('Difference between peak-normalized histograms (all minus training)');


