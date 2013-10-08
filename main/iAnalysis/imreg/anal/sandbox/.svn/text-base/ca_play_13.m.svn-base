% Alternate event detection scheme

%% 1) large delta detector 
if (1)

	% get activity
	if (exist('actParams') == 0)
		actParams.cofThresh = 0.15;
		actParams.nabThresh = 0.005;
		actParams.forceRedo = 1;

		s.caTSA.getRoiActivityStatistics(actParams);
	end


	% get noise
	if (exist('noise') == 0)
		clear nParams;

		nParams.debug = 0;
		nParams.method = 'hfMADn';
		nParams.prefiltSizeInSeconds = 1;
		noise = session.timeSeries.computeNoiseS(s.caTSA.time,s.caTSA.dffTimeSeriesArray.valueMatrix, nParams);
	end

	cof = s.caTSA.roiActivityStatsHash.get('cutoffToMaxRatio');
	nab = s.caTSA.roiActivityStatsHash.get('numAboveCutoff');
	skew = s.caTSA.roiActivityStatsHash.get('skew');
	hyperactiveIdx = s.caTSA.roiActivityStatsHash.get('hyperactiveIdx');
	activeIdx = s.caTSA.roiActivityStatsHash.get('activeIdx');

if (0)
  for i=1:s.caTSA.length()
	  s.caTSA.getTimeSeriesByIdx(i).plot;
		typeStr = '';
		if (ismember(i, activeIdx)) ; typeStr = ' ACTIVE ' ; end
		if (ismember(i, hyperactiveIdx)) ; typeStr = ' HYPERACTIVE ' ; end
		title(['nab: ' num2str(nab(i)) ' skew: ' num2str(skew(i)) ' cof: ' num2str(cof(i)) ' ' typeStr] );
		pause;
	end
end

	rise_ts = 1:5;
%	for ei = [3 159 23  8 9 1 7 19 81 82 30]
% 14 FIX
%	for ei = 1:200
%	for ei = 15:200
%	for ei = [4 9]
	%for ei = 1:200
	for ei = 1:5
%	for ei = 102
%	for ei = 14
		vec = s.caTSA.dffTimeSeriesArray.valueMatrix(ei,:); 

		thresh_sf = [4 5 7]; % ORIGINAL
		thresh_sf = [1.5 2 2.5];
		thresh_sf = [2 3 4]; % 354
		thresh_sf = [1.5 2 2.5]; % 641
		thresh_sf = [1.5 2 2.5]; % 641

    % prefilter
    ks = 20;
		kern = ones(1,ks);
		kern = kern/sum(kern) ; % normalize the kernel
	  svec = conv(vec,kern,'same');
		cvec = vec-svec;

    if (ismember(ei,hyperactiveIdx))
			noise_thresh = (thresh_sf(1)*1.4826*noise(ei));
		elseif (ismember(ei,activeIdx))
			noise_thresh = (thresh_sf(2)*1.4826*noise(ei));
		else
			noise_thresh = (thresh_sf(3)*1.4826*noise(ei));
    end
    
    d_mat = zeros(length(rise_ts),length(cvec));

		pidx = [];
		lstr = {};

		for r=rise_ts
			cvec_1 = cvec(1:end-r);
			cvec_2 = cvec(r+1:end);

			d_cvec = cvec_2-cvec_1;
      d_mat(r,r+1:end) = d_cvec;

	    pidx = union(pidx,find(d_mat(r,:) > noise_thresh));
			lstr{r} = num2str(r);
		end

		% contiguity ...
		pvec = 0*vec;
		pvec(pidx) = 1;
		pvec = bwlabel(pvec);
		up = unique(pvec);
		for p=1:length(up)
		  pp = find(pvec == up(p));
			if (length(pp) > 1)
				[irr pmax_idx] = max(vec(pp));
				pmax_idx = pp(pmax_idx);
				remove_idx = setdiff(pp,pmax_idx);
        pidx = setdiff(pidx,remove_idx);
			end
		end

    evdet_play_3(vec, 1.4826*noise(ei), pidx );
		title(num2str(s.caTSA.ids(ei)));
		pause
%    expRate = 50*length(pidx)/length(vec);
%		expRate = max(expRate,.25);
%    evdet_play_2(s, vec, noise(ei), expRate);

		% plot it . . .
		if(0)
			subplot(3,1,1);
			cla;
			plot(vec, 'k-');
			hold on;
			plot(pidx,vec(pidx),'r.');

			title([num2str(ei) ' noise thresh: ' num2str(noise_thresh)]);

			subplot(3,1,2);
			cla;
			plot(cvec,'r-');

			subplot(3,1,3);
			cla;
			plot(d_mat');
			legend(lstr);
			hold on ; 
			a = axis;
			plot([a(1) a(2)], [1 1]*noise_thresh, 'k-');
			title(['nab: ' num2str(nab(ei)) ' skew: ' num2str(skew(ei))]);
			pause;
		end
	end
end


%% 2) work bakward in time approach?
