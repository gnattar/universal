%
% SP Jun 2011
%
% Computes the entropy for a given signal, which can either be a vector or a
%  matrix where each column is a particular dimension of data and each row is 
%  a data-pair.
%
% USAGE:
%
%  H = entropy_calc(data, method)
%
% PARAMS:
%
%  H: entropy
%
%  data: vector or matrix where each column is a dimension of data
%  method: 'regest': estimate by bootstrappign and regressing a la Osborne 
%                    et al. 2004
%          'ksd1': kernel density based using matlab
%
function H = entropy_calc(data, method)

  switch method
	  case 'regest'
		  H = entropy_calc_regest(data);

		case 'ksd1'
		  H = entropy_calc_ksd1(data);

		otherwise
		  disp('entropy_calc::invalid method');
	end

%
% estimate using simple KSDensity estimators
%
function H = entropy_calc_ksd1(data)
  H = nan;
  n_bins = 64; % ALWAYS

  % --- 1-D case
	if (min(size(data)) == 1)
	  xi = linspace(min(data),max(data),n_bins);
		f_x = ksdensity(data,xi);

		f_x = f_x/sum(f_x); % normalize
		val = find(f_x > 0);
		if (length(val) > 0)
			H = -1*sum(f_x(val).*log2(f_x(val)));
		end
  % --- 2-D case
	elseif (size(data,2) == 2)
    try
      [bw f_xy X Y] = extern_ksdensity2([data(:,1) data(:,2)],n_bins);


      f_xy = f_xy/sum(sum(f_xy));

      % compute
      H = 0;
      for x=1:n_bins
        val = find(f_xy(x,:) > 0);
        if (length(val) > 0)
          H = H + 1*sum(f_xy(x,val).*log2(f_xy(x,val)));
        end
      end
      H = -1*H;
    catch
      H = nan;
    end
  else
	  disp(['entropy_calc_ksd1::cannot handle data of ' num2str(size(data,2)) ' dimensions.']);
	end

 
%
% estimate with regression
%
function H = entropy_calc_regest(data)
  H = nan;
	data_fracs = [0.95 0.9 0.85 0.8 0.7 0.6 0.5 0.4 0.3]; 
	n_calcs = 100;
  n_bins = 64;

	% --- 1-D case
	if (min(size(data)) == 1)

		% compute SD and mean at each fraction
		mu_H = zeros(1,length(data_fracs));
		sd_H = mu_H;
  	for d=1:length(data_fracs);
	    [mu_H(d) sd_H(d)] = compute_entropy_distro(data, n_bins, data_fracs(d), n_calcs);
  	end

   % regression fit ...
   pfit = polyfit(1./data_fracs, mu_H,1);
	 H = pfit(2);
	else
	  disp(['entropy_calc_regest::cannot handle data of ' num2str(size(data,2)) ' dimensions.']);
	end

%
% resample randomly
%
function [mu sd] = compute_entropy_distro(data, n_bins, data_frac, n_calcs)
  H = nan*ones(1,n_calcs);
	N = length(data);
	N_frac = ceil(N*data_frac);

	for c=1:n_calcs
	  idx = randperm(N);
	  H(c) = entropy_for_even_binning_1d(data(idx(1:N_frac)), n_bins);
	end

	mu = mean(H);
	sd = std(H);

%
% calculates entropy for evenly distributed bins in 1d
%
function H = entropy_for_even_binning_1d(data_vec, n_bins)
  d_bin = range(data_vec)/n_bins;
  bin_bounds = min(data_vec):d_bin:max(data_vec);
	bin_bounds(1) = bin_bounds(1)-.001*d_bin ; 
	bin_bounds(end) = bin_bounds(end)+.001*d_bin;
  
	H = entropy_for_binning_1d(data_vec, bin_bounds);

%
% calculates entropy for a specified binning, 1d
%
function H = entropy_for_binning_1d(data_vec, bin_bounds)
  f_b = histc(data_vec,bin_bounds);
  f_b = f_b/sum(f_b);
	H = -1*nansum(f_b.*log2(f_b));


