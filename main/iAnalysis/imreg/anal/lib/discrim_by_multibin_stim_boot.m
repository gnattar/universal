%
% SP Jun 2011
%
% Bootstrap wrapper for discrim_by_bin_stim_boot. This will get AUCs for 
%  a series of binnings, and do this repeatedly to get a distribution of 
%  AUCs. Bootstrap is done with 80% of each data vector (stim, resp).  ROC
%  is computed along resp dimension.  Binning is along stim dimension.  So
%  basically, you bin the stimulus dimension, and compare pairs of bins to 
%  see if the responses to the bins can be discriminated.
%
%  Base call is to roc_area_from_distro_boot, which enforces AUC > 0.5.
%
% USAGE:
%
%  [auc_mode auc_ci auc maxauc_mode maxauc_ci maxauc] = 
%     discrim_by_multibin_stim_boot(stim, resp, n_bins, n_boot_steps)
%
% PARAMS:
%
%  auc_mode: mode (ksdensity) of the AUCs computed
%  auc_ci: 5 and 95%iles of the AUC distro
%  auc: the AUC distro
%  maxXXX: same as above, but for maximal AUC computed by discrim_by_bin_stim_boot
%
%  stim, resp: stimulus and response vectors
%  n_bins: vector of bin numbers to use (e.g., to do 2, 3 and 4 bins, [2 3 4]) ; default 2:7
%  n_boot_steps: how many bootstrap steps? default 50
%
function [auc_mode auc_ci auc maxauc_mode maxauc_ci maxauc] = discrim_by_multibin_stim_boot(stim, resp, n_bins, n_boot_steps)

  % inputs
	if (nargin < 3) ; n_bins = 2:8 ; end
	if (nargin < 4) ; n_boot_steps = 50 ; end

	% prepare
	auc = zeros(1,n_boot_steps);
	maxauc = zeros(1,n_boot_steps);

	% go
	N = ceil(length(stim)*0.8);
	idx_vec = 1:length(stim);
	for n=1:n_boot_steps 
	  idx = randsample(idx_vec, N);
	  aucs = zeros(1,length(n_bins));
		nval = zeros(1,length(n_bins));
	  max_aucs = zeros(1,length(n_bins));
	  for b=1:length(n_bins)
      [aucs(b) nval(b) poop max_aucs(b)] = discrim_by_bin_stim_boot(stim(idx), resp(idx), n_bins(b), 'even');
		end

		% compute single statistic from this
		nval(union(find(isnan(nval)), find(isnan(aucs)))) = 0;
		aucs(find(isnan(aucs))) = 0;
		aucs = aucs.*nval;
		maxauc(n) = nanmean(max_aucs);
 		auc(n) = sum(aucs)/sum(nval);
	end

	% compute modes
  if (length(find(~isnan(auc))) > 0.25*n_boot_steps)
		[pdf auc_xis] = ksdensity(auc);
		[irr idx] = max(pdf);
		auc_mode = auc_xis(idx);
		auc_ci = [quantile(auc,.05) quantile(auc,.95)];
	else
	  auc_mode = nan;
		auc_ci = [nan nan];
	end

  if (length(find(~isnan(maxauc))) > 0.25*n_boot_steps)
		[pdf maxauc_xis] = ksdensity(maxauc);
		[irr idx] = max(pdf);
		maxauc_mode = maxauc_xis(idx);
		maxauc_ci = [quantile(maxauc,.05) quantile(maxauc,.95)];
	else
	  maxauc_mode = nan;
		maxauc_ci = [nan nan];
	end

