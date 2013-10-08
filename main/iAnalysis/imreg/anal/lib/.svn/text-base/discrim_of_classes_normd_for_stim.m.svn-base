%
% SP Jun 2011
%
% This will compute discriminability of 2 (or more in future?) classes of 
%  variables (e.g., protraction/rectraction, single/multi-whisker touches)
%  while controlling for some variable (e.g., force).  That is, it ensures that
%  the comparison for the classes in resposne space (e.g., df/f) is done using
%  matched distributions in strimulus space (e.g., force).  The user
%  selects which distribution matching method to use with cvar_overlap_method.
%
%  The final returned statistic is the AUC for the ROC curve between the
%  comparable subsets of both classes.  The Mann-Whitney p-value for the 
%  comparison is also returned.
%
% USAGE:
%
%   [resp_auc resp_auc_ci resp_auc_distro resp_rs_pval A_idx B_idx cvar_ks_pval cvar_rs_pval cvar_auc] = 
%     discrim_of_classes_normd_for_stim(resp_A, cvar_A, resp_B, cvar_B, 
%       cvar_overlap_method, cvar_overlap_params, n_boot)
%
%   resp_auc: area uner the ROC curve for compared subsets of the classes; 
%             always in [0.5 1]
%   resp_auc_ci: confidence intervals for AUC from bootstrap (5/95%iles)
%   resp_auc_distro: underlying distribution of AUCs from bootstrap
%   resp_rs_pval: ranksum (Mann-Whitney) p-value for this comparison
%   A_idx, B_idx: indices of resp_A, resp_B that were used
%   cvar_ks_pval, cvar_rs_pval: p-values for testing if the cvar distributions
%                             were different.
%   cvar_auc: area under ROC curve for cvar along A_idx, B_idx; [0.5 1] bound.
%
%   resp_A, resp_B: values of the response, for which ROC is computed.
%   cvar_A, cvar_B: correspond in size to relevant resp_ vector, indicating the
%                 value at that trial for the cvariable which is controlled for
%                 via thresholds.
%
%   cvar_overlap_method: which method to use (string) to compile overlapping
%                        distributions in terms of cvar; cvar_overlap_params is
%                        a structure, whose members depend on method.
%
%     'dmat_grow': Compile a distance matrix along var axis, and add points
%                  until cvar_overlap_params.rs_thresh or cvar_overlap_params.ks_thresh
%                  is crossed (i.e., p-value < thresh)
%     'dmat_shrink': Compile a distance matrix along var axis, and, starting 
%                    with ALL points, remove points whose mean distance to
%                    all points of the other set is largest until the p-value 
%                    criteria specified by cvar_ovrlap_params.rs_thresh, ks_thresh
%                    are met (i.e., pval goes ABOVE the thresh).
%
%   n_boot: how many times to do the bootstrap on the resp_A resp_B (subset) 
%           comparison?  DEfault 50.
%                          
function [resp_auc resp_auc_ci resp_auc_distro resp_rs_pval A_idx B_idx cvar_ks_pval cvar_rs_pval cvar_auc] = ...
     discrim_of_classes_normd_for_stim(resp_A, cvar_A, resp_B, cvar_B, cvar_overlap_method, ...
		                                   cvar_overlap_params, n_boot)

  % --- sanity checks // input processing
	switch cvar_overlap_method
	  case {'dmat_grow' , 'dmat_shrink'}
		  cvar_ks_thresh = cvar_overlap_params.ks_thresh;
			cvar_rs_thresh = cvar_overlap_params.rs_thresh;

		otherwise
		  disp('discrim_of_classes_normd_for_stim::invalid overlap method specified.');
	end

	if (nargin < 7) ; n_boot = 50 ;end

	% seed
	resp_auc = nan;
  resp_auc_ci = [nan nan];
	resp_auc_distro = nan;
	resp_rs_pval = [];
	A_idx = [];
	B_idx = [];
  cvar_ks_pval = [];
	cvar_rs_pval = [];
	cvar_auc = [];

  % --- run main body
	switch cvar_overlap_method
	  case 'dmat_grow'
		  [A_idx B_idx] = get_overlap_idx_via_dist_mat_grow(cvar_A, cvar_B, cvar_ks_thresh, cvar_rs_thresh);
	  case 'dmat_shrink'
		  [A_idx B_idx] = get_overlap_idx_via_dist_mat_shrink(cvar_A, cvar_B, cvar_ks_thresh, cvar_rs_thresh);
   end

  if (0) % a nice debug plot showing used points
    figure;
    plot (cvar_A,resp_A,'rx');
    hold on;
    plot (cvar_B,resp_B,'bx');
    plot (cvar_A(A_idx),resp_A(A_idx),'ko');
    plot (cvar_B(B_idx),resp_B(B_idx),'ko');
  end

	% --- get statistics on these
  if (length(A_idx) > 0 & length(B_idx) > 0)
    [irr cvar_ks_pval] = kstest2(cvar_A(A_idx), cvar_B(B_idx));
    cvar_rs_pval = ranksum(cvar_A(A_idx), cvar_B(B_idx));
    cvar_auc = roc_area_from_distro(cvar_A(A_idx), cvar_B(B_idx));
    if (cvar_auc < 0.5) ; cvar_auc = 1-cvar_auc ; end
    [resp_auc resp_auc_ci resp_auc_distro] = roc_area_from_distro_boot(resp_A(A_idx), resp_B(B_idx), n_boot);
    if (resp_auc < 0.5) ; resp_auc = 1-resp_auc ; end
    resp_rs_pval = ranksum(resp_A(A_idx), resp_B(B_idx));
  end


%
% shrinking via greatest outlier
%
function  [A_idx B_idx] = get_overlap_idx_via_dist_mat_shrink(cvar_A, cvar_B, cvar_ks_thresh, cvar_rs_thresh)

  % fail condition
  if (length(cvar_A) < 5 | length(cvar_B) < 5)
    A_idx = []; B_idx = [];
    return;
  end
  
	% compile the distance matrix
	dist_mat = nan*zeros(length(cvar_A), length(cvar_B));
	A_mat = repmat(cvar_A, length(cvar_B),1)';
	B_mat = repmat(cvar_B, length(cvar_A),1);
	dist_mat = abs(A_mat - B_mat);

  
  % remove points, naning as you go . . .
	A_idx = 1:length(cvar_A);
	B_idx = 1:length(cvar_B);
  if (length(A_idx) == 0 | length(B_idx) == 0) ; return ; end
	[irr pks] = kstest2(cvar_A(A_idx), cvar_B(B_idx));
	prs = ranksum(cvar_A(A_idx), cvar_B(B_idx));
  while (pks < cvar_ks_thresh | prs < cvar_rs_thresh)
    % next one -- one with greatest avg distance from OTHER set
    min_dist_A = nanmin(dist_mat');
    min_dist_B = nanmin(dist_mat);

    [max_val idx] = nanmax([min_dist_A min_dist_B]);
    [irr midx_A] = find(min_dist_A == max_val);
    [irr midx_B] = find(min_dist_B == max_val);
    
    if (length(midx_A) > 0 & length(midx_B) == 0)
      mean_dist_A = max_val;
      midx_A = midx_A(1);
      mean_dist_B = 0;
    elseif (length(midx_A) == 0 & length(midx_B) > 0)
      mean_dist_B = max_val;
      midx_B = midx_B(1);
      mean_dist_A = 0;
    else
      % tie break:take out from the set where the MEAN distance is largest
      mean_dist_A = nanmean(dist_mat(midx_A,:));
      mean_dist_B = nanmean(dist_mat(:,midx_B));
    end
    
    if (mean_dist_A >= mean_dist_B) % pull from A
		  A_idx = setdiff(A_idx,midx_A);
			dist_mat(midx_A,:) = nan;    
    else
		  B_idx = setdiff(B_idx,midx_B);
			dist_mat(:,midx_B) = nan;    
    end

		
	  % termination condition
		if (length(find(isnan(dist_mat))) == 0 | length(A_idx) == 0 | length(B_idx) == 0)
			break;
		end

		% recompute pvals
		[irr pks] = kstest2(cvar_A(A_idx), cvar_B(B_idx));
		prs = ranksum(cvar_A(A_idx), cvar_B(B_idx));
  end


%
% growing via distance matrix
%
function  [A_idx B_idx] = get_overlap_idx_via_dist_mat_grow(cvar_A, cvar_B, cvar_ks_thresh, cvar_rs_thresh)
  
  % fail condition
  if (length(cvar_A) < 5 | length(cvar_B) < 5)
    A_idx = []; B_idx = [];
    return;
  end

	% compile the distance matrix
	dist_mat = nan*zeros(length(cvar_A), length(cvar_B));
	A_mat = repmat(cvar_A, length(cvar_B),1)';
	B_mat = repmat(cvar_B, length(cvar_A),1);
	dist_mat = abs(A_mat - B_mat);


  % build up the overlapping point sets, nan-ing as you go ...
	min_val = nanmin(nanmin(dist_mat));
	if (length(min_val) > 0)
		[r,c] = find(dist_mat == min_val(1));
		A_idx = r;
		B_idx = c;
		dist_mat(r,c) = nan;
	else
	  return;
	end

  pks = 1; % initially we don't use KS 
	prs = ranksum(cvar_A(A_idx), cvar_B(B_idx));
  while (pks > cvar_ks_thresh & prs > cvar_rs_thresh)
    % next one ...
		min_val = nanmin(nanmin(dist_mat));
		if (length(min_val) > 0)
			[r,c] = find(dist_mat == min_val(1));
			last_A_idx = A_idx;
			last_B_idx = B_idx;
			if (length(r) > 0)
				A_idx = union(A_idx,r);
				B_idx = union(B_idx,c);
				dist_mat(r,c) = nan;
				[irr pks] = kstest2(cvar_A(A_idx), cvar_B(B_idx));
				prs = ranksum(cvar_A(A_idx), cvar_B(B_idx));
				
				% n < 5, pks is irrelevant
				if (length(A_idx) < 5) ; pks = 1; end
			else % terminate!
				pks = cvar_ks_thresh - 1;
			end
		else % terminate!
			pks = cvar_ks_thresh - 1;
		end

	  % termination condition
		if (length(find(isnan(dist_mat))) == prod(size(dist_mat)))
			pks = cvar_ks_thresh - 1;
		end
  end
  A_idx = last_A_idx;
  B_idx = last_B_idx;
