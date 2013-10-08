%
% Goes through a directory and all files matching img_path are assumed to be tif 
%  stacks.  They are checked for motion based on the sum of inter-trial difference
%  (therefore, luminance conditions for files are assumed to be the same).  The
%  trial with the minimum rating in this regard is set to the variable tgt_path,
%  and this variable is saved in the mat file mat_path.  imopt is passed to load_image.
%
% blank imopt and mat_path are allowed.
%
function [fd flist tgt_path] = determine_trial_with_least_motion(img_path, mat_path, imopt)
  tgt_path = '';
  Nf = 0; % TOTAL number of frames considered across all files ; files have variable #frames

  % set returned variables to default / get file list
  fd = -1;
	flist = dir(img_path);

  % sanity cheq
	if (length(flist) == 0) ; disp(['determine_trial_with_least_motion::no files found matching ' img_path]); return ; end

  % loop thru files and compute diff
	fs_idx = find(img_path == filesep);
	root_path = img_path(1:fs_idx(length(fs_idx)));
	all_lum = [];
	f_idx = [];
  for f=1:length(flist)
	  fullname = [root_path flist(f).name];
		im = load_image(fullname, -1, imopt);

    % nan stripes
		im(find(im == 0)) = nan;

		fd_tmp = abs(diff(im,[],3));
    if (length(fd_tmp) == 0)  % single framers
		  fd(f) = 0;
		else % multi-framers
		  fd(f) = nansum(nansum(nansum(fd_tmp)))/size(im,3);
		end

		% luminance change
    if (fd(f) == 0) ; nf = 1; else ; nf = size(im,3); end
		for fr=1:nf
		  lum(f).val(fr) = nanmean(reshape(im(:,:,fr),[],1));
			all_lum(length(all_lum)+1) = lum(f).val(fr);
      f_idx(length(f_idx)+1) = f;
		end
	end

	% now loop again and drop abberant luminance frames containing sets -- this is a very
	%  conservative approach [too conservative for GCaMP5 -- relaxed]
	med_lum = nanmedian(all_lum);
	sd_lum = nanstd(all_lum);
	for f=1:length(flist)
	  lumvec = lum(f).val;
		n_bad = length(find(lumvec > (med_lum+1.5*sd_lum))) +  length(find(lumvec < (med_lum-1.5*sd_lum)));
		if (n_bad > 0)
		  disp(['***********determine_trial_with_least_motion::Omitting ' flist(f).name ' due to luminance issues.']);
			fd(f) = 0;
		end

		% also omit if more than 5% of frames are 'stripes'
		if (length(find(isnan(im)))/prod(size(im)) > .05)
		  disp(['***********determine_trial_with_least_motion::Omitting ' flist(f).name ' due to too many stripes (NaN).']);
			fd(f) = 0;
		end
	end


	% the min? forget single-framers
	fd(find(fd == 0)) = max(fd);
  [irr idx] = min(fd);
  tgt_path = [root_path flist(idx).name];

  % and save
	if (length(mat_path) > 0)
		save (mat_path, 'tgt_path');
	end
