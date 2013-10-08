%
% For evaluating an image segmentation relative hand drawn ROIs.
%
function evaluate_segmented (segmented_file, vol_fit_root_path)

 load(segmented_file); 
 load(vol_fit_root_path);

	% TEMPORARY -- should be in there in the future!
	roi_file_path = {};
	for v=1:11
	  for p=2:4
		  roi_file_path{length(roi_file_path)+1} = sprintf('rois%can160508_2012_02_10_based_2012_02_10_fov_%02d%03d.mat', filesep, v, p);
		end
	end

 
  % binarize segmented -- ALL will now just be 1(!)
  S = size(segmented);
	bi_segmented = segmented*0;
	bi_segmented(find(segmented > 0)) = 1;

  % plot ROIs versus segmented
	fig = figure;
	ax = axes;
	aviobj = avifile(strrep(segmented_file, 'mat', 'avi'));
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
	  for x=1:size(X{r},2)
		  for y=1:size(X{r},1)
			  x_ = round(X{r}(y,x));
			  y_ = round(Y{r}(y,x));
			  z_ = round(Z{r}(y,x));

        if (x_ <= S(2) && x_ > 0 && y_ <= S(1) && y_ > 0 && z_ > 0 && z_ <= S(3))
					sim(y,x) = bi_segmented(y_, x_, z_);
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

		P_ggr = length(intersect(hand_idx,auto_idx))/length(auto_idx);
		P_rgg = length(intersect(hand_idx,auto_idx))/length(hand_idx);

   
		fim(hand_idx) = 253/256;
		fim(auto_idx) = 254/256;
		fim(intersect(auto_idx,hand_idx)) = 255/256;

		imshow(fim, [0 1], 'Parent', ax);
		colormap(cm);
		text(20,20,(sprintf('Green: hand Red: auto ; P(g|r): %0.2f P(r|g) %0.2f Z (0=surface): %d', P_ggr, P_rgg, round(mean(mean(Z{r}))))), 'Color', [1 1 1], 'BackgroundColor', [0 0 0], 'FontSize', 12);

    F = getframe(fig);
		aviobj = addframe(aviobj,F);
		pause (.05);
	end
	aviobj = close(aviobj);

	% statistic 1
  
	save('mapping.mat', 'im', 'X', 'Y', 'Z', 'lim');
