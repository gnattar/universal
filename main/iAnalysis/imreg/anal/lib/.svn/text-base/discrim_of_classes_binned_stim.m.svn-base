%
% SP Jun 2011
%
% This will compute discriminability of 2 (or more in future?) classes of 
%  variables (e.g., protraction/rectraction, single/multi-whisker touches)
%  while controlling for some variable (e.g., force).  It achieves the normalization
%  by binning, and testing whether the control variable distributions are
%  not different in the individual bins.
%
% USAGE:
%
%   [bin_resp_aucs bin_resp_rs_pvals bin_var_ks_pvals bin_var_rs_pvals bin_bounds] = 
%     discrim_of_classes_binned_stim(resp_A, var_A, resp_B, var_B, n_var_bins, var_bin_bounds)
%
%   bin_resp_aucs: for each bin, computes area-under-curve (AUC).  Will return
%             [0.5 1], performed on the resp_X vectors.
%   bin_resp_rs_pvals: pvals for each bin using ranskum -- for members of a bin
%                      from resp_A and resp_B, are the distros different?
%   bin_var_ks_pvals: pvals for each bin using KS test on the var_A vs var_B
%                     telling you probability that you would observe these
%                     distros if they were THE SAME (null hypothesis). Thus,
%                     you will have to decide at what p-value you no longer
%                     accept null hypothesis (e.g., p < 0.8).  Lower p-value 
%                     means more likely that distros DIFFER.
%   bin_var_rs_pvals: same, but with ranksum test, which tests median more than
%                     shape.
%   bin_bounds: var_bin_bounds if specified ; if not, will be calculated 
%
%   resp_A, resp_B: values of the response, for which ROC is computed.
%   var_A, var_B: correspond in size to relevant resp_ vector, indicating the
%                 value at that trial for the variable which is controlled with
%                 binning
%   n_var_bins: how many bins to make from the var axis? default is 9
%   var_bin_bounds: overrides n_var_bins, with explicit definition of bin 
%                   boundaries. 2xn matrix, with each pair specifying boundaries.
%                   Bins can overlap, and +/-inf is allowable.
%
function [bin_resp_aucs bin_resp_rs_pvals bin_var_ks_pvals bin_var_rs_pvals bin_bounds] = ...
  discrim_of_classes_binned_stim(resp_A, var_A, resp_B, var_B, n_var_bins, var_bin_bounds)

  % --- sanity checks
	if (nargin < 5) 
	  n_var_bins = 9;
		var_bin_bounds = [];
	end
	if (nargin < 6)
	  var_bin_bounds = [];
	end

	% --- bin setup
	if (length(var_bin_bounds) == 0)
	  udist = union(var_A, var_B);
		R = range(udist);
		d_bin = R/n_var_bins;
		m = min(udist);
		var_bin_bounds = zeros(2,n_var_bins);
    if (length(udist) > 0)
      for v=1:n_var_bins
        var_bin_bounds(:,v) = [m+(v-1)*d_bin   m+v*d_bin];
      end
      var_bin_bounds(2,n_var_bins) = var_bin_bounds(2,n_var_bins) + .00001; % so that we include last guy
    end
	end

	% --- the meat
	bin_resp_aucs = nan*zeros(1,size(var_bin_bounds,2));
	bin_resp_rs_pvals = nan*zeros(1,size(var_bin_bounds,2));
	bin_var_ks_pvals = nan*zeros(1,size(var_bin_bounds,2));
	bin_var_rs_pvals = nan*zeros(1,size(var_bin_bounds,2));
	bin_bounds = var_bin_bounds;
	for b=1:size(var_bin_bounds,2)
	  val_A = find(var_A >= var_bin_bounds(1,b) & var_A < var_bin_bounds(2,b));
	  val_B = find(var_B >= var_bin_bounds(1,b) & var_B < var_bin_bounds(2,b));

		if (length(val_A) > 0 & length(val_B) > 0)
			% ROC
			bin_resp_aucs(b) = roc_area_from_distro(resp_A(val_A), resp_B(val_B));
			
      % ranksum on response
			bin_resp_rs_pvals(b) = ranksum(resp_A(val_A), resp_B(val_B));

			% KS test on var
			[irr bin_var_ks_pvals(b)] = kstest2(var_A(val_A), var_B(val_B));

			% ranksum on var
			[bin_var_rs_pvals(b) irr] = ranksum(var_A(val_A), var_B(val_B));

		end
	end

	ltp5 = find(bin_resp_aucs < 0.5); 
	if (length(ltp5) > 0) ; bin_resp_aucs(ltp5) = 1 - bin_resp_aucs(ltp5); end


