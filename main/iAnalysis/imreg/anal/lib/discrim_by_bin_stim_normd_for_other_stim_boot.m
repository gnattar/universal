%
% SP Jun 2011
%
% Bootstrap wrapper for discrim_by_bin_stim_normd_for_other_stim. This will 
%  get a distribution of  AUCs. Bootstrap is done with 80% of data.  Also
%  returns the max auc bin.
%
%  Base call is to roc_area_from_distro_boot, which enforces AUC > 0.5.
%
% USAGE:
%
%  [auc_mode auc_ci auc maxauc_mode maxauc_ci maxauc] = 
%     discrim_by_bin_stim_normd_for_other_stim_boot(stim1, stim2, resp, n_bins, n_boot)
%
% PARAMS:
%
%  auc_mode: mode (ksdensity) of the AUCs computed
%  auc_ci: 5 and 95%iles of the AUC distro
%  auc: the AUC distro
%  maxXXX: same as above, but for maximal AUC computed by discrim_by_bin_stim_boot
%
%  stim1: variable for which RF is measured
%  stim2: variable which is controlled for
%  resp: response vector
%  n_bins: # of bins to use ; default 4
%  n_boot: how many bootstrap steps? default 50
%
function [auc_mode auc_ci auc maxauc_mode maxauc_ci maxauc] = ...
  discrim_by_bin_stim_normd_for_other_stim_boot(stim1, stim2, resp, n_bins, n_boot)

  % inputs
	if (nargin < 4) ; n_bins = 4 ; end
	if (nargin < 5) ; n_boot = 50 ; end

	% prepare
	auc = nan*zeros(1,n_boot);
	maxauc = nan*zeros(1,n_boot);
  
  % strip out nan!
  val = find(~isnan(stim1));
  val = intersect(val, find(~isnan(stim2)));
  val = intersect(val, find(~isnan(resp)));
  stim1 = stim1(val);
  stim2 = stim2(val);
  resp = resp(val);

	% go
  if (length(val) > 0)
    N = ceil(length(stim1)*0.8);
    idx_vec = 1:length(stim1);
    for n=1:n_boot 
      idx = randsample(idx_vec, N);
      [auc(n) pooper poop maxauc(n) ] =  ...
           discrim_by_bin_stim_normd_for_other_stim(stim1(idx), stim2(idx), resp(idx), n_bins, 'even');
    end
  end

	% compute modes
  if (length(find(~isnan(auc))) > 0.25*n_boot)
		[pdf auc_xis] = ksdensity(auc);
		[irr idx] = max(pdf);
		auc_mode = auc_xis(idx);
		auc_ci = [quantile(auc,.05) quantile(auc,.95)];
	else
	  auc_mode = nan;
		auc_ci = [nan nan];
	end

  if (length(find(~isnan(maxauc))) > 0.25*n_boot)
		[pdf maxauc_xis] = ksdensity(maxauc);
		[irr idx] = max(pdf);
		maxauc_mode = maxauc_xis(idx);
		maxauc_ci = [quantile(maxauc,.05) quantile(maxauc,.95)];
	else
	  maxauc_mode = nan;
		maxauc_ci = [nan nan];
	end

