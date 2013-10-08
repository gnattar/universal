function evdet_play_2(s, vec, noise, expRate)
  dt  = mode(diff(s.caTSA.time));
	dt = dt/1000;

  taus = 2*dt:2*dt:50*dt;
	%evdet_play(s.caTSA.dffTimeSeriesArray.valueMatrix(ei,:), noise(ei));
	val = find(~isnan(vec));

	vec(find(isnan(vec))) = 0;

	q_vec(1) = quantile(vec(val),.05);
	q_vec(2) = quantile(vec(val),.95);

	sdThresh = 1.4826*3*noise;
	madThresh = 1.4826*3*noise;
 
	minRate = 0.025;
	minDff = 0.025;
%	expRate = length(find((vec-median(vec)) > noise))/length(vec)
expRate


	n_mat = zeros(length(taus),length(vec));
	c_mat = zeros(length(taus),length(vec));
	n_evs = 0*taus;
	resid = 0*taus;

	ev_prob_thresh = .25;
	
	for t=1:length(taus)
		guessTau = taus(t);
%		[n_best P_best V_best C_best X] = extern_oopsi_deconv (vec', round(1/0.143), ...
    
    V.dt = dt;
		V.tau = guessTau;
		P.gam = (1-V.dt/V.tau);
		T = length(vec);

		P.lam = expRate;
		
		[n_best P_best V_best C_best]=extern_fast_oopsi(vec,V,P);

		% quantile adjustment of convolved result . . . (wish I knew what this was!!)
		q_C = [quantile(C_best(val),.05) quantile(C_best(val),.95)];
		C_best = C_best*(diff(q_vec)/diff(q_C));
		C_best = C_best - (q_C(1)+q_vec(1));

		n_mat(t,:) = n_best;
		c_mat(t,:) = C_best;
 
		n_evs(t) = length(find(n_best > ev_prob_thresh));
		residVec = abs(vec(val) - C_best(val)');

		resid(t) = nanmean(residVec);
		% only consider when resid > 1 SD
%			residVal = find(residVec > 1.4826*noise(ei));
%			resid(t) = nanmean(abs(vec(residVal) - C_best(residVal)'));
	end
 
	[minres bti] = min(resid);
	if (minres == 0)
		[irr tidx] = min(n_evs(bti));
		bti = bti(tidx);
	else % product is better!
		% product?  use power for weight?
		score = n_evs.*(resid);
		[irr bti] = min(score);

		% how about minimize # of events for residuals < 1 SD
%			valResid = find(resid < 1.4826*noise(ei));
%     [irr ti] = min(n_evs(valResid));
%			bti = valResid(ti);
	end

	eidx = find(n_mat(bti,:) > ev_prob_thresh);
	plot(vec); hold on;
	plot(c_mat(bti,:), 'r-');
	plot(eidx,vec(eidx),'g.');
	title(['Tau: ' num2str(taus(bti)) ' Noise: ' num2str(noise)]);
	pause;
