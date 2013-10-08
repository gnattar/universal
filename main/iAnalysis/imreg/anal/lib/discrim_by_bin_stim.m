%
% SP Jun 2011
%
% This function will divide up the stimulus space into bins and then do ROC 
%  analysis on each bin pair, giving back AUC and ranksum p-val.  It returns  
%  matrices with every bin pair considered.
%
% USAGE:
%
%   [sig_auc_mean n_val_comparisons bin_auc_mat bin_pval_mat bin_bounds] = 
%     discrim_by_bin_stim(stim, resp, n_bins, bin_bounds)
%
%   sig_auc_mean: sum AUC for AUCs where pval < min_pval (.05), divided by # 
%                 of bin pairs where both bins that attain min_bin_count (10)
%   n_val_comparisons: how many bins pair comparisons were done (i.e., met 
%                      min_bin_count)
%   bin_auc_mat: pairwise comparison of each bin ; values repeated.
%   bin_pval_mat: pval of ranksum statistic of pairwise comparison
%   bin_bounds: 2xn matrix, with bounds of each bin
%
%   stim: stimulus vector -- dimension along which bins are made
%   resp: response vector -- dimension along which AUC is computed
%   n_bins: how many equally sized bins to make (dflt = min(7,ceil(length(stim)/20)))
%   bin_bounds: if specified, overrides n_bins and specifies EXACT bin bounds.
%               +/- Inf is allowed, as are overlapping bins.
%
function [sig_auc_mean n_val_comparisons bin_auc_mat bin_pval_mat bin_bounds] = discrim_by_bin_stim(stim, resp, n_bins, bin_bounds)

  min_bin_count = 10; % this many entries per bin @ MINIMUM to count
	min_pval = 0.05;

  % --- sanity checks
	if (nargin < 3) 
	  n_bins = min(7,ceil(length(stim)/20));
	end
	if (nargin < 4)
	  bin_bounds = [];
	end

	sig_auc_mean = nan;
	bin_auc_mat = nan*zeros(n_bins,n_bins);
	bin_pval_mat = nan*zeros(n_bins,n_bins);
	if (length(stim) == 0 | length(resp) == 0) ; return ; end

	% --- bin setup
	if (length(bin_bounds) == 0)
		R = range(stim);
		d_bin = R/n_bins;
		m = min(stim);
		bin_bounds = zeros(2,n_bins);
		for b=1:n_bins
		  bin_bounds(:,b) = [m+(b-1)*d_bin   m+b*d_bin];
		end
		bin_bounds(2,n_bins) = bin_bounds(2,n_bins) + .001*d_bin; % so that we include last guy
	end

	% --- the meat
	for b1=1:size(bin_bounds,2)
	  val_1 = find(stim >= bin_bounds(1,b1) & stim < bin_bounds(2,b1));
		if (length(val_1) >= min_bin_count)
			for b2=b1+1:size(bin_bounds,2)
				val_2 = find(stim >= bin_bounds(1,b2) & stim < bin_bounds(2,b2));
				
				if (length(val_2) >= min_bin_count)
					auc  = roc_area_from_distro(resp(val_1), resp(val_2));
					pval = ranksum(resp(val_1), resp(val_2));
					bin_auc_mat(b1,b2) = auc;
					bin_auc_mat(b2,b1) = auc;

					bin_pval_mat(b1,b2) = pval;
					bin_pval_mat(b2,b1) = pval;
				end
			end
		end
	end

	% eliminate duplicates with upper-triangular matrix
  unique_p_mat = triu(bin_pval_mat,1);
  unique_auc_mat = triu(bin_auc_mat,1);
  omat = triu(ones(size(unique_p_mat)),1);
	unique_p_mat(find(omat == 0)) = nan;
	unique_auc_mat(find(omat == 0)) = nan;

	% p value treshold
	val = find(unique_p_mat < min_pval);
  inval = find(unique_p_mat >= min_pval);
  unique_auc_mat(inval) = 0.5;

	% compute returned values
	n_val_comparisons = length(find(~isnan(unique_auc_mat)));
  if (n_val_comparisons > 0)
	  sig_auc_mean = nanmean(reshape(unique_auc_mat,[],1)); % nanmean will exclude upper triang 
	end


