function evdet_play_3(vec, noise, evidx)
	a_taus = 2:20;
	a_taus = 2:30;

	a_taus = 3:20;
	a_trise = 0:5;
	done = 0*vec;

  o_evidx = evidx;

  taus = zeros(length(a_taus)*length(a_trise),1);

  % build kernels ..
	kernMat = nan*zeros(length(a_taus)*length(a_trise), 5*max(a_taus) + max(a_trise));
	kern_peak_idx = max(a_trise)+1; 
%	kernMat = nan*zeros(length(taus), 5*max(taus));
  ki = 1;
	for t=1:length(a_taus)
	  for r=1:length(a_trise)
			nDec = 5*(a_taus(t));
%			kernMat(t,1:nDec) =  exp(-1*(0:nDec-1)/taus(t));
		  kernMat(ki,kern_peak_idx-a_trise(r):kern_peak_idx+nDec-1) =  [linspace(0,1,a_trise(r)+1) exp(-1*(2:nDec)/a_taus(t))];
	%  	kernMat(t,1:nDec) = kernMat(t,1:nDec)/sum(kernMat(t,1:nDec)) ; % normalize yo kernl fool

      taus(ki) = a_taus(t);
      trise(ki) = a_trise(r);
	    ki = ki+1;
    end
	end

  % start with largeset ...
%	[irr evtidx] = sort(vec(evidx), 'descend');
%	evidx = evidx(evtidx)
ovec = vec;
  good_ev = [];
  good_taus = [];
  good_ki = [];
  good_amp = [];
  good_trise = [];

	while (length(evidx) > 0)
  	peak_idx= evidx(1);
    maxL = length(vec) - peak_idx;
    [best_idx resid] = fit_single(vec, peak_idx, kernMat, kern_peak_idx);
   
		n_removed_post_and_peak = min(maxL,5*taus(best_idx));
    n_removed_pre_peak = min(peak_idx, trise(best_idx));

    % subtract from vec
		i1 = peak_idx-n_removed_pre_peak;
    L = n_removed_pre_peak + n_removed_post_and_peak;
    i2 = i1 + L -1;
%  	cvec = conv(vec(i1:i2),kernMat(k,1:L),'same');
    cvec = zeros(1,L);
    cvec(n_removed_pre_peak+1:end) = vec(peak_idx)*kernMat(best_idx,kern_peak_idx+(0:n_removed_post_and_peak-1));
    cvec(1:n_removed_pre_peak) = vec(peak_idx)*kernMat(best_idx, kern_peak_idx-(n_removed_pre_peak:-1:1));


    % got you at least noise gain
%    if (nanmean(cvec) > noise && ~isnan(resid(best_idx)))
    if (nanmean(cvec) > noise && ~isnan(resid(best_idx)))
%    if (nanmean(cvec) > noise && resid(best_idx) < 5*noise)

		disp(['NOISE : ' num2str(noise) ' resid: ' num2str(resid(best_idx)) ...
          ' tau: ' num2str(taus(best_idx)) ' trise: ' num2str(trise(best_idx))  ...
					' mean gain: ' num2str(nanmean(cvec))]);
      good_ev = [good_ev evidx(1)];
      good_taus = [good_taus taus(best_idx)];
      good_ki = [good_ki best_idx];
			good_amp = [good_amp vec(peak_idx)];
			good_trise = [good_trise trise(best_idx)];

			vec(i1:i2) = vec(i1:i2)-cvec;
      % add to done
      done(i1:i2) = 1;
%      keep = find(ismember(evidx,find(done == 0)));
      keep = setdiff(1:length(evidx),1);
      evidx = evidx(keep);
		else
%      disp('not enuff to keep');
      if (length(evidx) > 1)
        evidx = evidx(2:end);
      else
        evidx = [];
      end 
    end
		
		if (0)
			cla
			plot(ovec,'k-');
			hold on;
			plot(vec);
			plot(find(done),vec(find(done)),'r-');
			plot(evidx,vec(evidx),'ro', 'MarkerFaceColor','r','MarkerSize',5)
			if (length(evidx) > 1)
				plot(evidx(1),vec(evidx(1)),'go', 'MarkerFaceColor','g','MarkerSize',10);
			end
			pause
		end
	end

  cla;
  
	fvec = 0*ovec;
	for e=1:length(good_ev)
	  ki = good_ki(e);
		kern = kernMat(ki,:);
		kern = kern(find(~isnan(kern)));

    maxL = length(ovec) - good_ev(e);

	  n_removed_post_and_peak = min(maxL,5*good_taus(e));
    n_removed_pre_peak = min(good_ev(e), good_trise(e));

    % subtract from vec
		i1 = good_ev(e)-n_removed_pre_peak;
    L = n_removed_pre_peak + n_removed_post_and_peak;
    i2 = i1 + L -1;
%  	cvec = conv(vec(i1:i2),kernMat(k,1:L),'same');
    gvec = zeros(1,L);
    gvec(n_removed_pre_peak+1:end) = good_amp(e)*kernMat(good_ki(e),kern_peak_idx+(0:n_removed_post_and_peak-1));
    gvec(1:n_removed_pre_peak) = good_amp(e)*kernMat(good_ki(e), kern_peak_idx-(n_removed_pre_peak:-1:1));

		fvec(i1:i2) = fvec(i1:i2)+gvec;
	end
	fvec = fvec(1:length(ovec));
  rvec = ovec-fvec;

  plot(ovec,'k-');
	hold on ; 
  plot(fvec,'r-');

  cvi = find(~isnan(ovec) & ~isnan(fvec));
	if (length(cvi) > 0)
		disp(['CORR: ' num2str(corr(ovec(cvi)',fvec(cvi)'))]);
	end

  plot(o_evidx,ovec(o_evidx),'ro', 'MarkerFaceColor','r','MarkerSize',3);
  plot(good_ev,ovec(good_ev),'go', 'MarkerFaceColor','g','MarkerSize',7);

%  plot(ovec-2,'k-', 'LineWidth',1);
  plot(rvec-2,'b-', 'LineWidth', 1);


% figure;
%  plot(taus,resid,'rx');
%  [taus ; resid']

function [best_idx resid] = fit_single(vec, i1, kernMat, kern_peak_idx)
	ks = size(kernMat,1);
	resid = nan*zeros(ks,1);
	resi_rat = nan*zeros(ks,1);

  maxL = length(vec) - i1;
	% convolve and immediately compute residual for points beyond peak ...
	for k=1:ks
    n_pre = kern_peak_idx-min(find(~isnan(kernMat(k,:))));
    k_offs = kern_peak_idx-n_pre-1;

		L = length(find(~isnan(kernMat(k,:))));
    if (L > maxL) ; continue ; end % skip if @ end
    if (i1 <= n_pre) ; continue ; end % skip 2 start
    i2 = i1 + L -1;
%  	cvec = conv(vec(i1:i2),kernMat(k,1:L),'same');
  	cvec = vec(i1)*kernMat(k,k_offs+(1:L));

		ri2 = L-n_pre;
    vec_i_for_error_calc = [i1-(n_pre:-1:1) i1+1:i1+ri2-1];
    cvec_i_for_error_calc = [1:n_pre n_pre+(2:ri2)];
   

if (0)
    cla
		plot(vec(vec_i_for_error_calc(1):vec_i_for_error_calc(end)),'k-');
		hold on;
		plot(cvec(cvec_i_for_error_calc(1):cvec_i_for_error_calc(end)),'r-');
		title(['n-pre: ' num2str(n_pre)]);
% pause
end

  resivec = vec(vec_i_for_error_calc) - cvec(cvec_i_for_error_calc);

  % if your error for first 1/5th >> last 1/5th ...
  tauL = round(0.2*(L-n_pre-1));
	resi_rat(k) = nanmean(resivec(1:tauL))/nanmean(resivec(4*tauL:end));

  % make negative residual more costly.  This is to ensure that when you 
	%  fit with a dff *above* the actual trace over a long stretch, you get
	%  rejected.
	nidx = find(resivec < 0);
	resivec(nidx) = -10*resivec(nidx); % punish below more

  % cumulative mean error AFTER peak -- take the minimum of this value after
	%  2 taus (0.4 * length since length is 5 taus).  What this does is that in 
	%  cases where you have a new event 2 taus or later, it does not penalize
	%  you ; otherwise, you would often have the template try to fit that event
	%  and get unusual long taus.
  cum_erri = (n_pre+1):length(vec_i_for_error_calc);
  cum_err_div = 1:length(cum_erri);
  cum_err = abs(cumsum(resivec(cum_erri)))./cum_err_div;
  
  pre_err = nanmean(abs(vec(vec_i_for_error_calc(1:n_pre)) - cvec(cvec_i_for_error_calc(1:n_pre))));

  resid(k) = min(cum_err(round((L-n_pre-1)*.4):end)) + pre_err;

  
% penalize negative residual (i.e,. you overshoot)
%  	resivec = vec(vec_i_for_error_calc) - cvec(cvec_i_for_error_calc);
%		nidx = find(resivec < 0);
%		resivec(nidx) = -10*resivec(nidx); % punish below more
%  	resid(k) = nanmean(resivec);

    % very basic residual
 % 	resid(k) = nanmean(abs(vec(vec_i_for_error_calc) - cvec(cvec_i_for_error_calc)));

	end

	[irr best_idx] = nanmin(resid);
%	disp(['rr: ' num2str(resi_rat(best_idx))]);
	if (resi_rat(best_idx) < -3) ; resid(best_idx) = nan; end
%	if (resi_rat(best_idx) < -10) ; resid(best_idx) = nan; end


