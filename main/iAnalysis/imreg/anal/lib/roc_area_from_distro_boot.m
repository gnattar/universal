%
% SP May 2011
%
% Bootstrap wrapper for roc_area_from_distro.  Uses 80% of data for bootstrap.
%  AUC < 0.5 not allowed, and the entire distribution is shifted by 2*(0.5-mode).
%
% USAGE:
%
%  [auc_mode auc_ci auc] = roc_area_from_distro_boot(DVa, DVb, n_boot_steps)
%  
%  auc_mode: mode of measured areas-under-curve (ksdensity peak)
%  auc_ci: 5 and 95%iles
%  auc: distribution itself
%  
%  DVa, DVb: values in two distrbutions for which AUC is comptued
%  n_boot_steps: how many bootstrap steps to do? default 500
%
function [auc_mode auc_ci auc] = roc_area_from_distro_boot(DVa, DVb, n_boot_steps)
  % args
	if (nargin < 3) ; n_boot_steps = 500 ; end
  if (length(DVa) < 5 || length(DVb) < 5) ; auc_mode = nan ; auc_ci = [nan nan] ; auc = []; return ; end

  % degenerate case, but sample over WHOLE distro
	if (n_boot_steps == 1)
	  auc_mode = roc_area_from_distro(DVa, DVb);
		auc_ci = [nan nan];
		auc = auc_mode;
		return;
	end

	% prepare
	auc = zeros(1,n_boot_steps);

	% go
	Na = ceil(length(DVa)*0.8);
	Nb = ceil(length(DVb)*0.8);
	idx_vec_a = 1:length(DVa);
	idx_vec_b = 1:length(DVb);
	for n=1:n_boot_steps 
	  idx_a = randsample(idx_vec_a, Na);
	  idx_b = randsample(idx_vec_b, Nb);

		% compute 
		auc(n) = roc_area_from_distro(DVa(idx_a), DVb(idx_b));
	end

	% cleanup
	[pdf aucs] = ksdensity(auc);
	[irr peak_idx] = max(pdf);
	auc_mode= aucs(peak_idx);
	auc_ci = [quantile(auc,.05) quantile(auc,.95)];

	% enforce > 0.5
	if (auc_mode < 0.5)
	  d_auc = 0.5 - auc_mode;
		auc_mode = auc_mode + 2*d_auc;
		auc_ci = auc_ci + 2*d_auc; 
		auc = auc + 2*d_auc;
  end
  
  if (diff(auc_ci) == 0) ; auc_ci = [auc_mode auc_mode] ; end
