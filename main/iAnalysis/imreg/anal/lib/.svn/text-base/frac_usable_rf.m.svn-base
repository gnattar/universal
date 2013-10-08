%
% SP Jun 2011
%
% Computes the fraction of the given receptive field that is 'usable'. That is,
%  it is assumed a neuron can only obtain meaningful information about a 
%  stimulus if its response is above noise.  Furthermore, since this is 
%  used to compare to other stimuli, it is assumed that if a lot of the
%  above-noise responses come in a range that is within noise for the 
%  particular stimulus, the cell cannot possibly be obtaining meaningful
%  information in that regime either.  The function therefore returns the
%  fraction of stim-response pairs that are in the non-noisy stimulus and
%  non-noisy response region.
%
%  USAGE: 
%
%    frac = frac_usabel_rf (stim, resp, all_stim_vec, all_resp_vec, dplot)
%
%  PARAMS:
%
%    stim, resp: stimulus response pairs
%    all_stim/resp_vec: ALL datapoints for stimulus/response (e.g., the
%                       df/f trace for a cell for an entire session ,or the
%                       whisker curvature change over the entire session).
%    dplot: if passed & set to 1, will show a plot of what is actually done.
%  
function frac = frac_usable_rf(stim, resp, all_stim_vec, all_resp_vec, dplot)
  if (nargin < 4)
	  help ('frac_usable_rf');
		return;
	end

	if (nargin < 5) ; dplot = 0 ; end

	% sanity
	if (length(stim) == 0 ) ; frac = nan ; return; end

	% compute noise bounds (2*MAD)
	vs = find(~isnan(all_stim_vec));
	stim_MAD = mad(all_stim_vec(vs));
	stim_thresh = median(all_stim_vec(vs)) + 2*[-1.4826 1.4826]*stim_MAD;
	vr = find(~isnan(all_resp_vec));
	resp_MAD = mad(all_resp_vec(vr));
	resp_thresh = median(all_resp_vec(vr)) + 2*[-1.4826 1.4826]*resp_MAD;

	% useless points
	useless_resp_idx = find (resp < resp_thresh(2) & resp > resp_thresh(1));
	useless_stim_idx = find (stim < stim_thresh(2) & stim > stim_thresh(1));
	useless_idx = union(useless_stim_idx, useless_resp_idx);

	% useful points
	useful_idx = setdiff(1:length(stim), useless_idx);

  % metric
  frac = length(useful_idx)/(length(useful_idx)+length(useless_idx));
	if (isnan(frac) | isinf(frac)) ; frac = 0 ; end

	% plot?
	if (dplot)
	  figure;
    legStr = {};
		hold on;
    if (length(useless_idx) > 0) ;plot(stim(useless_idx),resp(useless_idx),'ro', 'MarkerFaceColor', [1 0 0]);legStr{length(legStr)+1} = 'useless';end
    if (length(useful_idx) > 0) ;plot(stim(useful_idx),resp(useful_idx),'bo', 'MarkerFaceColor', [0 0 1]);legStr{length(legStr)+1} = 'useful';end
		legend(legStr);
		A = axis;
		plot ([A(1) A(2)], resp_thresh(1)*[1 1], 'r-');
		plot ([A(1) A(2)], resp_thresh(2)*[1 1], 'r-');
		plot (stim_thresh(1)*[1 1], [A(3) A(4)], 'r-');
		plot (stim_thresh(2)*[1 1], [A(3) A(4)], 'r-');
		disp(['Frac RF: ' num2str(frac)]);
	end




