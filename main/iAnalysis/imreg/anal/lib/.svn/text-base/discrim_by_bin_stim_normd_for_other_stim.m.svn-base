%
% SP Jun 2011
%
% This will perform bin-wise AUC analysis a la discrim_by_bin_stim, while 
%  normalizing for another stimulus axis.  Thus, you need 2 stimulus variables
%  and a response varible, all vectors of = length.  It bins the first stim
%  just like discrim_by_bin_stim, then calls discrim_of_classes_normd_for_stim
%  so that you pick a uniform distribution of stim2.  
%
%  Base call is to roc_area_from_distro_boot, which enforces AUC > 0.5.
%
% USAGE:
%
%   [sig_auc_mean sig_ci_mean max_auc max_auc_ci bin_auc_mat bin_ci_mat bin_bounds] = 
%     discrim_by_bin_stim_boot(stim1, stim2, resp, n_bins, bin_bounds)
%
%   sig_auc_mean: mean of AUC values for which the confidence interval range 
%                 (10-90 quantile) was below some value (0.2 usually)
%   sig_ci_mean: mean of amplitude of valid confidence intervals
%
%   bin_auc_mat: pairwise comparison of each bin 
%   bin_ci_mat: range of values for AUC for bootstrap, sampling 80% data for 5th to 95th quantile - 
%               1,:,: contains 5th and 2,:,: contains 95th
%   bin_bounds: 2xn matrix, with bounds of each bin
%   max_auc: maximal AUC value (if any; may be nan) whose 5-95 CI was below .05.
%   max_auc_ci: confidence interval (5-95) for max AUC -- TWO numbers
%
%   stim1: stimulus dimension along which bins are made
%   stim2: stimulus dimension for which normalization is performed
%   resp: response vector -- dimension along which AUC is computed
%   n_bins: how many equally sized bins to make (dflt = min(7,ceil(length(stim1)/20)))
%   bin_bounds: if specified, overrides n_bins and specifies EXACT bin bounds.
%               +/- Inf is allowed, as are overlapping bins.  If you specify
%               'even', bins will have as-close to equal # of elements as possible.
%
function [sig_auc_mean n_val_comparisons sig_ci_mean max_auc max_auc_ci bin_auc_mat bin_ci_mat bin_bounds] =  ...
  discrim_by_bin_stim_normd_for_other_stim(stim1, stim2, resp, n_bins, bin_bounds)

  max_boot_ci_1090 = .25; % if 10-90 confidence interval range is above this, reject the value b/c too varied
	min_n_vals = 5; % must have at least this many values per bin to even do the comparison
	n_boot = 50; % how many repetitions to run of each comparison with bootsrap

  max_auc_min_ci = .1; % max_auc will be max AUC value with 5-95 CI below this
	max_auc = nan;
	max_auc_ci = [nan nan];
  
  % --- strip out nan!
  val = find(~isnan(stim1));
  val = intersect(val, find(~isnan(stim2)));
  val = intersect(val, find(~isnan(resp)));
  stim1 = stim1(val);
  stim2 = stim2(val);
  resp = resp(val);

  % --- sanity checks
	if (nargin < 3) 
	  n_bins = min(7,ceil(length(stim1)/20));
	end
	if (nargin < 4)
	  bin_bounds = [];
	end

	sig_auc_mean = nan;
	sig_ci_mean = nan;
	bin_auc_mat = nan*zeros(n_bins,n_bins);
	bin_ci_mat = nan*zeros(2,n_bins,n_bins);
	bin_ci_mat_1090 = nan*zeros(n_bins,n_bins);
  n_val_comparisons = 0;
	if (length(stim1) == 0 | length(resp) == 0) ; return ; end

  % for calls to discrim_of_classes_normd_for_stim
  dparams.ks_thresh = 0.2;
  dparams.rs_thresh = 0.2;
   

	% === equal # elements in each bin
	if (strcmp(bin_bounds,'even'))
    % presort stim1
		[irr sidx] = sort(stim1);
		stim1 = stim1(sidx);
		stim2 = stim2(sidx);
		resp = resp(sidx);

	  % setup bin bounds, compute actual for posterity
	  bin_bounds_idx = floor(linspace(1,length(stim1)+1,n_bins+1));
		bin_bounds_idx(end) = bin_bounds_idx(end)-1;
		bin_bounds = zeros(2,n_bins);
		bin_bounds(1,:) = stim1(bin_bounds_idx(1:end-1));
		bin_bounds(2,:) = stim1(bin_bounds_idx(2:end));

		% go
	  for b1=1:n_bins
		  val_1 = bin_bounds_idx(b1):bin_bounds_idx(b1+1)-1;
			if (length(val_1) >= min_n_vals)
  		  for b2=b1+1:n_bins
	  	    val_2 = bin_bounds_idx(b2):bin_bounds_idx(b2+1)-1;
					if (length(val_2) >= min_n_vals)
						[auc auc_ci boot_aucs] = discrim_of_classes_normd_for_stim(resp(val_1), stim2(val_1), ...
																		    resp(val_2), stim2(val_2), 'dmat_shrink', ...
		                                    dparams, n_boot);


						% actual AUC 
						bin_auc_mat(b1,b2) = auc;

						% confidence interval ... 90-10 & 95-5
						bin_ci_mat_1090(b1,b2) = quantile(boot_aucs, .90) - quantile(boot_aucs,.10);
						bin_ci_mat(1,b1,b2) = quantile(boot_aucs, .05);
						bin_ci_mat(2,b1,b2) = quantile(boot_aucs, .95);
				  end
		  	end
			end
		end

	% === unequal
	else
		% --- bin setup
		if (length(bin_bounds) == 0)
			R = range(stim1);
			d_bin = R/n_bins;
			m = min(stim1);
			bin_bounds = zeros(2,n_bins);
			for b=1:n_bins
				bin_bounds(:,b) = [m+(b-1)*d_bin   m+b*d_bin];
			end
			bin_bounds(2,n_bins) = bin_bounds(2,n_bins) + .001*d_bin; % so that we include last guy
		end

		% --- the meat
		for b1=1:size(bin_bounds,2)
			val_1 = find(stim1 >= bin_bounds(1,b1) & stim1 < bin_bounds(2,b1));
			if (length(val_1) >= min_n_vals)
				for b2=b1+1:size(bin_bounds,2)
					val_2 = find(stim1 >= bin_bounds(1,b2) & stim1 < bin_bounds(2,b2));
					if (length(val_2) >= min_n_vals)
						[auc auc_ci boot_aucs] = discrim_of_classes_normd_for_stim(resp(val_1), stim2(val_1), ...
																		    resp(val_2), stim2(val_2), 'dmat_shrink', ...
		                                    dparams, n_boot);

						% actual AUC 
						bin_auc_mat(b1,b2) = auc;

						% confidence interval ... 90-10 & 95-5
						bin_ci_mat_1090(b1,b2) = quantile(boot_aucs, .90) - quantile(boot_aucs,.10);
						bin_ci_mat(1,b1,b2) = quantile(boot_aucs, .05);
						bin_ci_mat(2,b1,b2) = quantile(boot_aucs, .95);
	  			end
	 			end
			end
		end
	end

	% CI threshold
	val = find(bin_ci_mat_1090 < max_boot_ci_1090);
  inval = find(bin_ci_mat_1090 >= max_boot_ci_1090);
	val_auc_mat = bin_auc_mat;
	val_ci_mat = bin_ci_mat;
  val_auc_mat(inval) = nan; % too much noise PSHHHHhhhh
	vcim1 = squeeze(val_ci_mat(1,:,:)); 
	vcim2 = squeeze(val_ci_mat(2,:,:));
	vcim1(inval) = nan ; vcim2(inval) = nan;
	val_ci_mat(1,:,:) = vcim1;
	val_ci_mat(2,:,:) = vcim2;
  dvci = vcim2-vcim1;

	% compute returned values
	n_val_comparisons = length(find(~isnan(val_auc_mat)));
  if (n_val_comparisons > 0)
	  sig_auc_mean = nanmean(reshape(val_auc_mat,[],1));
		sig_ci_mean = abs(nanmean(reshape(vcim1,[],1)) - nanmean(reshape(vcim1,[],1)));
	end

	% max_auc
	max_auc_idx = find(dvci < max_auc_min_ci);
	if (~isempty(max_auc_idx)) 
	  [irr maidx] = max(val_auc_mat(max_auc_idx)); 
		max_auc= val_auc_mat(max_auc_idx(maidx(1)));
		max_auc_ci = [vcim1(max_auc_idx(maidx(1))) vcim2(max_auc_idx(maidx(1)))];
	end

