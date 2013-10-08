%
% SP Jun 2011
%
% Computes mutual informatino between two vectors, where mutual info is 
%  defined by:
%
%   I(x,y) = sum yeY sum xeX p(x,y) log2((p(x,y))/(p1(x)p2(y)))
%
% USAGE:
%
%   mi = mutual_info(vec_x, vec_y, method, n_bins)
%
%   mi: the mutual information in bits ; nan if insufficient data etc.
%
%   vec_x, vec_y: the two vectors for which this is computed
%   method: 'bin' -- will use equal bins and calculate
%           'entropy' -- calls entropy_calc, with ksd1 method
%           'ksd' -- uses kernel density to estimate p(.) and computes explcitly
%   n_bins: how many bins to partition each distro into ; 1 number means use
%           same for both. Default is 10.  If 2 numbers, first is for vec_x,
%           second for vec_y.  'ksd' will use ksdensity estimate for all.
%
function mi = mutual_info(vec_x, vec_y, method, n_bins)
  mi = nan;
	min_n_points = 10; 

  % --- sanity / inputs
	if (nargin < 2) 
	  help('mutual_info');
		return;
	end
	if (nargin < 4) ; n_bins = 10 ; end
	if (length(n_bins) == 1) ; n_bins = [n_bins n_bins]; end
	if (length(vec_x) < min_n_points || length(vec_x) ~= length(vec_y) || range(vec_x) == 0 || range(vec_y) == 0) ; return ; end

	% --- build f(x), f(y), f(x,y)
  switch method
	  case 'bin'
			min_pdf_val = .01/prod(n_bins);

			range_x = range(vec_x);
			bin_bounds_x = min(vec_x):(range_x/n_bins(1)):max(vec_x);
			bin_bounds_x(1) = bin_bounds_x(1) - (range_x/n_bins(1)/1000);
			bin_bounds_x(end) = bin_bounds_x(end) + (range_x/n_bins(1)/1000);
			f_x = zeros(1,n_bins(1));
			for b=1:length(bin_bounds_x)-1;
				f_x(b) = length(find(vec_x > bin_bounds_x(b) & vec_x <= bin_bounds_x(b+1)));
			end
			f_x = f_x/sum(f_x);

			range_y = range(vec_y);
			bin_bounds_y = min(vec_y):(range_y/n_bins(2)):max(vec_y);
			bin_bounds_y(1) = bin_bounds_y(1) - (range_y/n_bins(2)/1000);
			bin_bounds_y(end) = bin_bounds_y(end) + (range_y/n_bins(2)/1000);
			f_y = zeros(1,n_bins(2));
			for b=1:length(bin_bounds_y)-1;
				f_y(b) = length(find(vec_y > bin_bounds_y(b) & vec_y <= bin_bounds_y(b+1)));
			end
			f_y = f_y/sum(f_y);

			% a bit trickier for joint . . . grid it!
			f_xy = zeros(n_bins(1), n_bins(2));
			for bx=1:length(bin_bounds_x)-1;
				for by=1:length(bin_bounds_y)-1;
					f_xy(bx,by) = length(find(vec_x > bin_bounds_x(bx) & vec_x <= bin_bounds_x(bx+1) & ...
																		vec_y > bin_bounds_y(by) & vec_y <= bin_bounds_y(by+1) ));
				end
			end
			f_xy = f_xy/sum(sum(f_xy));

		case 'ksd'
			min_pdf_val = .01/(prod(n_bins));
			[bw f_xy X Y] = extern_ksdensity2([vec_x' vec_y'],n_bins(1));
			f_x = ksdensity(vec_x, X(1,:));
			f_y = ksdensity(vec_y, Y(:,1));

			f_xy = f_xy/sum(sum(f_xy));
			f_x = f_x/sum(f_x);
			f_y = f_y/sum(f_y);

			bin_bounds_x = X(1,:);
			dbx = mode(diff(bin_bounds_x));
			bin_bounds_x = [bin_bounds_x(1)-(dbx/2) bin_bounds_x+(dbx/2)];
			bin_bounds_y = Y(:,1)';
			dby = mode(diff(bin_bounds_y));
			bin_bounds_y = [bin_bounds_y(1)-(dby/2) bin_bounds_y+(dby/2)];

		case 'entropy' % I(X;Y) = H(X) + H(Y) - H(X,Y)
		  H_X = entropy_calc(vec_x, 'ksd1');
			H_Y =  entropy_calc(vec_y, 'ksd1');
			if (size(vec_x,1) > size(vec_x,2)) ; vec_x = vec_x'; end
			if (size(vec_y,1) > size(vec_y,2)) ; vec_y = vec_y'; end
			H_XY =  entropy_calc([vec_x ; vec_y]', 'ksd1');
			mi = H_X + H_Y - H_XY;
		end

  % debug
	if (0)
	  subplot(2,2,1);
		dbx = mode(diff(bin_bounds_x));
		plot(bin_bounds_x(1:end-1)+0.5*dbx, f_x);
		subplot(2,2,2);
		dby = mode(diff(bin_bounds_y));
		plot(bin_bounds_y(1:end-1)+0.5*dby, f_y);
		subplot(2,2,3);
		surf(f_xy)
 %   surf(repmat(bin_bounds_x(1:end-1)+0.5*dbx, n_bins(2),1), repmat((bin_bounds_y(1:end-1)+0.5*dby)', 1,n_bins(1)), f_xy);
	end

	% --- compute mutual information ...
	if (strcmp(method, 'ksd') | strcmp(method, 'bin'))
		mi = 0;
		for bx=1:length(bin_bounds_x)-1;
			p_x = f_x(bx);
			for by=1:length(bin_bounds_y)-1;
				p_y = f_y(by);
				p_xy = f_xy(bx,by);
				if (p_x > min_pdf_val & p_y > min_pdf_val & p_xy > min_pdf_val)
					mi = mi + p_xy*log2((p_xy)/(p_x*p_y));
				end
			end
		end
  end
