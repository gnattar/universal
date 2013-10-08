%
% Static method for calculating curvature change relative baseline.
%
% This will compute change in kappa relative baseline, where baseline is the
%  angle that the kappa for a particular theta range when bar is NOT in reach.
%  It is a static method and can therefore be used to do single trial or pan-
%  session calculations.
%
% USAGE:
%
%  deltaKappas = computeDeltaKappas(kappas, thetas, barInReach)
%
%   deltaKappas - returned matrix same size as kappas
%   kappas - numFrames x numWhiskers matrix with kappas
%   thetas - numFrames x numWhiskers thetas with kappas
%   barInReach - boolean vector with bar in reach ; pass the CONSERVATIVE
%                bar in reach estimate (i.e., NOT fraction corrected)
%   postProcess - if set to true (default is false), it will clean up dKappa
%                 further by first median filtering it then subtracting a 
%                 sliding window mode from the trace
%
% (C) Simon Peron 2010 Dec
%
function deltaKappas = computeDeltaKappas(kappas, thetas, barInReach, postProcess)
  % --- prelims
	dth = 1; % step of theta when fitting
	mfSize = 5; % size of median filter to employ on gathered points
	debug = 0;
	dBIR = 100; % bar OUT of reach is defined as bar in reach MINUS this at start, PLUS at end 
	            % this ensures it is CONSERVATIVE

	% --- argument check
	if (nargin < 4) % disable postProcessing by default
	  postProcess = 0; 
	end

  % --- sanity checks
	if (length(kappas) == 0 | length(thetas) == 0 | length(barInReach) == 0)
	  disp('computeKappas: must first run computeKappas, computeThetas, and computeBarInReach');
		return;
	end

  % make sure matrix properly oriented
	if (size(kappas,1) < size(kappas,2)) ; kappas = kappas';end
	if (size(thetas,1) < size(thetas,2)) ; thetas = thetas';end

  % --- get conservative barInReach/outReach estimates
	barInReachCons = find(barInReach); 
	barInReachStarts = find(diff(barInReach) == 1);
	barInReachEnds = find(diff(barInReach) == -1);
	barOutReachCons = 0*barInReach;
	if (length(barInReachStarts) == 0)
	  barOutReachCons = 1+barOutReachCons;
	else
	  if (barInReachStarts(1) > dBIR)
		  barOutReachCons(1:barInReachStarts(1)-dBIR) = 1;
		end
		for b=2:length(barInReachStarts)
		  if (max(find(barInReachEnds < barInReachStarts(b))) > 0)
				lbie = barInReachEnds(max(find(barInReachEnds < barInReachStarts(b))));
				if (length(lbie) > 0)
					if (lbie + dBIR < barInReachStarts(b) - dBIR)
						barOutReachCons(lbie+dBIR:barInReachStarts(b)-dBIR) = 1;
					end
				end
			end
		end
		if (length(barInReachEnds) > 0)
			if (barInReachEnds(end)+dBIR < length(barOutReachCons))
				barOutReachCons(barInReachEnds(end)+dBIR:end) = 1;
			end
		end
	end
	barOutReachCons = find(barOutReachCons); % convert to index vs binary

	% --- master loop over whiskers
	deltaKappas = nan*kappas;
	for w=1:size(kappas,2)
	 
	  % build theta range
    mth = min(thetas(:,w));
    Mth = max(thetas(:,w));
		mth = floor(mth/dth)*dth;
		Mth = ceil(Mth/dth)*dth;

		% prep vectors
		thetaRange = mth+(dth/2):dth:Mth-(dth/2);
		baselineKappas = nan*thetaRange;
    % for each range, if possible get values
		for t=mth:dth:Mth-dth
		  idx = find(thetaRange-(dth/2) == t);
		  vals = barOutReachCons(find(thetas(barOutReachCons, w) > t & thetas(barOutReachCons, w) < t+dth ));

			if (length(vals) > 0)
			  baselineKappas(idx) = nanmedian (kappas(vals,w));
			else
		    vals = find(thetas(:, w) > t & thetas(:, w) < t+dth );
			  baselineKappas(idx) = nanmedian (kappas(vals,w));
			end
		end

    % adjust mfSize
		if (mfSize > length(baselineKappas)) ; mfSize = ceil(length(baselineKappas)/2)+1; end

		% pad ends so you dont get median filter based error
		mfSize2 = ceil(mfSize/2);
		firstVal = min(find(~isnan(baselineKappas)));
		lastVal = max(find(~isnan(baselineKappas)));
    
    % sometimes this is a clue that you did not have enough data (whisker
    % was real short, for example, so no kappa) - in this case, skip
    % whisker
    if (length(firstVal) + length(lastVal) < 2) ; continue ;end
    
    % padded vec for medfilt
  	tmpVec= [baselineKappas(firstVal)*ones(1,mfSize2) baselineKappas baselineKappas(lastVal)*ones(1,mfSize2)];
  	tmpVec= medfilt1(tmpVec,mfSize);

    if ( debug )
			plot(thetas(barOutReachCons,w),kappas(barOutReachCons,w),'b.');
			hold on; plot(thetaRange,baselineKappas,'ro', 'MarkerFaceColor', [1 0 0]);

			plot(thetaRange, tmpVec(mfSize2+1:end-mfSize2),'ko', 'MarkerFaceColor', [0 0 0 ]);
			pause
		end

		% assign
		baselineKappas = tmpVec(mfSize2+1:end-mfSize2);

		% interpolate anything missing
		missing = find(isnan(baselineKappas));
		found = find(~isnan(baselineKappas));
		if (length(found) > 1)
			baselineKappas(missing) = interp1(thetaRange(found),baselineKappas(found), thetaRange(missing),'pchip');
		else % too few  data points ; use median kappa instead which is BAD but at least no crash
		  baselineKappas(missing) = nanmedian(kappas(:,w));
		end
		
    if ( debug )
			plot(thetaRange,baselineKappas,'mo', 'MarkerFaceColor', [1 0 1 ]);
			hold off;
			pause;
		end

    % now compute delta kappa ...
		for t=mth:dth:Mth-dth
		  idx = find(thetaRange-(dth/2) == t);
		  vals = find(thetas(:, w) > t & thetas(:, w) < t+dth );
			if (length(vals) > 0)
			  deltaKappas(vals,w) = kappas(vals,w) - baselineKappas(idx);
			end
		end

		% post processing
		if (postProcess)
	    % median filter 
			deltaKappas(:,w) = medfilt1(deltaKappas(:,w),5);

			% apply KSDensity filter and subtract it
	    ksfdk = session.timeSeries.filterKsdensityStatic([],deltaKappas(:,w),1000,100);
			deltaKappas(:,w) = deltaKappas(:,w) - ksfdk;
		end

	end

