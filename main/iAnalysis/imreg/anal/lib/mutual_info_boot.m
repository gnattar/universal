%
% SP Jun 2011
%
% Bootstrap of mutual_info.m; repeated calls thereto to generate a distro and
%  also confidence intervals.  Uses 80% of data.
%
% USAGE:
%
%   [mi_mode mi_ci mi] = mutual_info_boot(vec_x, vec_y, method, n_bins, n_boot_steps)
%
%   mi_mode: mode of mi, obtained from ksdensity peak
%   mi_ci: 5th and 95th %iles of distro
%   mi: distribution of MI values
%
%   vec_x, vec_y: the two vectors for which this is computed
%   method: 'bin' -- will use equal bins and calculate
%           'entropy' -- calls entropy_calc, with ksd1 method
%           'ksd' -- uses kernel density to estimate p(.) and computes explcitly
%   n_bins: how many bins to partition each distro into ; 1 number means use
%           same for both. Default is 10.  If 2 numbers, first is for vec_x,
%           second for vec_y.  'ksd' will use ksdensity estimate for all.
%   n_boot_steps: how many bootstrap steps to do? default 100.
%
function [mi_mode mi_ci mi] = mutual_info_boot(vec_x, vec_y, method, n_bins, n_boot_steps)
  mi_mode = nan;
  mi_ci = [nan nan];

	if (nargin < 4) ; n_bins = 10 ; end
	if (nargin < 5) ; n_boot_steps = 100 ; end

	% prepare
	mi = zeros(1,n_boot_steps);

	% go
	N = ceil(length(vec_x)*0.8);
	idx_vec = 1:length(vec_x);
	for n=1:n_boot_steps 
	  idx = randsample(idx_vec, N);

		% compute 
		mi(n) = mutual_info(vec_x(idx), vec_y(idx), method, n_bins);
	end

	% cleanup
  if (length(find(~isnan(mi))) > 0 && nansum(abs(diff(mi))) > 0)
    [pdf mis] = ksdensity(mi);
    [irr peak_idx] = max(pdf);
    mi_mode = mis(peak_idx);
    mi_ci = [quantile(mi,.05) quantile(mi,.95)];
  end

  % degenerate condition where too few points
	if (mi_mode < mi_ci(1) | mi_mode > mi_ci(2)) ; mi_mode = nan ; end

