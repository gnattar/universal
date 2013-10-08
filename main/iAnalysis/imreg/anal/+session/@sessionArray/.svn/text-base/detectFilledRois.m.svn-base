% 
% SP Apr pvalThresh1
%
% Determines whether a ROI is filled or not by looking at several featuers
%  over days.  Will assign pertinent part of roiIsFilled.  Looks at five 
%  parameters, applying a hard threshold for center:edge ratio (0.8) and
%  a probabalistic change detector for the other 4 (center:median ratio,
%  border value change, center value change, pixel IQR value change).
%
%  USAGE:
%
%   sA.detectFilledRois(params)
%
%  PARAMS:
%
%    params: a structure with following fields:
%      roiIds: IDs of ROIs to test ; blank means ALL
%      sessions: indices of sessions to do ; by default all
%      showVals: for debugging ; if 1, will plot details
%
function detectFilledRois (obj, params)

  % --- init variables

  % defaults
  ecRatioThresh =1;
	pvalThresh = 0.01; % must at least have this pval 
	ecScore = 0.4; % add this much if ratio crossed
	scoreThresh = 0.5;  % if reach this, will be called filled

	roiIds = obj.roiIds;
	showVals = 0;
	sessions = 1:length(obj.sessions);

	% passed params structure
	if (nargin < 2) ; params = []; end
	if (~isstruct(params) && length(params) > 0) ; roiIds = params ; end
	if (isstruct(params) && isfield(params, 'roiIds')); roiIds = params.roiIds ; end
	if (isstruct(params) && isfield(params, 'showVals')); showVals = params.showVals ; end
	if (isstruct(params) && isfield(params, 'sessions')); sessions = params.sessions ; end

  % --- gather data
	ecRatio = nan*ones(length(sessions),length(roiIds));
	cmRatio = nan*ones(length(sessions),length(roiIds));
	pixValIQR = nan*ones(length(sessions),length(roiIds));
	borderVal = nan*ones(length(sessions),length(roiIds));
	centerVal = nan*ones(length(sessions),length(roiIds));
  for s=1:length(sessions)
	  si = sessions(s);
	  if(length(roiIds) > 10) ; disp(['Processing session ' obj.dateStr{si}]);end
    rA = obj.sessions{si}.caTSA.roiArray;

		% assign image used [checksum for speed]
		% "checksum" (do we actually need to assign, which will kickoff time consuming stuff?)
		imSize = prod(size(rA.workingImage));
    rp = randperm(imSize);
		csIdx = rp(1:min(100,imSize));
		if (sum(rA.workingImage(csIdx) ~= obj.sessions{si}.caTSA.activityFreeImage(csIdx)) > 0)
			rA.workingImage = obj.sessions{si}.caTSA.activityFreeImage;
		end

	  % get stats from roiArray.getRoiFillingStatistics
    [isFilled ecRatio(s,:) cmRatio(s,:) pixValIQR(s,:) borderVal(s,:) centerVal(s,:)] ... 
		  = rA.getRoiFillingStatistics(roiIds);
	end
	
	% prep roiIsFilled?
	if (length(obj.roiIsFilled) == 0)
	  obj.roiIsFilled = nan*obj.roiPresent;
	end

	% --- determine filled rois -- first day of fillage
	for r=1:length(roiIds)
	  % for ecRatio, apply 2-in-a-row across thresh rule
		ecb = 0*sessions;
		ecb(find(ecRatio(:,r)<ecRatioThresh)) = 1;
		diffEcb = diff(ecb);
		eci = min(intersect(find(ecb > 0), find(diffEcb(1:end-1) == 0 & diff(ecb,2) ==0)));
		diffEcb2 = diff(ecb,2);
		diffEcb3 = diff(ecb,3);
		eci5 = min(intersect(find(ecb > 0), find(diffEcb(1:end-3) == 0 & diffEcb2(1:end-2) ==0 & diffEcb3(1:end-1) ==0 & diff(ecb,4) ==0)));

		% for  cmRatio, pixVaLIQR, border, centerVal, normalize to first day and then apply min pvalue detector
		ncm = cmRatio(:,r)/cmRatio(1,r);
    cmi = get_delta_idx_from_diff(ncm, .25, pvalThresh);

		nv = pixValIQR(:,r)/pixValIQR(1,r);
    pvi = get_delta_idx_from_diff(nv, .25, pvalThresh);

    nb = borderVal(:,r)/borderVal(1,r);
    nbi = get_delta_idx_from_diff(nb, .25, pvalThresh);

    nc = centerVal(:,r)/centerVal(1,r);
    nci = get_delta_idx_from_diff(nc, .25, pvalThresh);

    % minimal p-value
		if (sliding_pval(ncm) > pvalThresh) ; cmi = []; end
		if (sliding_pval(nv) > pvalThresh) ; pvi = []; end
		if (sliding_pval(nb) > pvalThresh) ; nbi = []; end
		if (sliding_pval(nc) > pvalThresh) ; nci = []; end

		% --- now compute score
    fillScore = 0*sessions;

		% - threshold-based score changes:
		if(length(eci) > 0) ; fillScore(eci:end) = fillScore(eci:end)+ecScore; end
		if(length(eci5) > 0) ; fillScore(eci5:end) = fillScore(eci5:end)+ecScore; end

    % - pval-based score changes:
		
		% determine delta around lowest pval
		if (cmi > 1) ; dCmRatio = abs(median(ncm(cmi:end))-median(ncm(1:cmi-1))); else ; dCmRatio = 0 ;end
		if (pvi > 1) ; dPixValIQR = abs(median(nv(pvi:end))-median(nv(1:pvi-1))); else ; dPixValIQR = 0 ;end
		if (nci > 1) ; dCenterVal = abs(median(nc(nci:end))-median(nc(1:nci-1))); else ; dCenterVal = 0 ;end
		if (nbi > 1) ; dBorderVal = abs(median(nb(nbi:end))-median(nb(1:nbi-1))); else ; dBorderVal = 0 ;end

		% change score based on delta where acceptable pval was reached, starting at that point in time
		pvSF = 0.25;
		if(length(cmi) > 0) ;	fillScore(cmi:end) = fillScore(cmi:end)+pvSF*dCmRatio; end
		if(length(pvi) > 0) ;	fillScore(pvi:end) = fillScore(pvi:end)+pvSF*dPixValIQR;end
		if(length(nci) > 0) ;	fillScore(nci:end) = fillScore(nci:end)+pvSF*dCenterVal;end
		if(length(nbi) > 0) ;	fillScore(nbi:end) = fillScore(nbi:end)+pvSF*dBorderVal;end

		% message
		if (showVals)
			if (length(cmi) > 0)
			 disp(['dCmRatio: '  num2str(dCmRatio)]);
			end
			if (length(pvi) > 0)
			 disp(['dPixIQR: '  num2str( dPixValIQR)]);
			end
			if (length(nci) > 0)
			 disp(['dCenter: '  num2str( dCenterVal)]);
			end
			if(length(nbi) > 0) 
			 disp(['dBorder: '  num2str(dBorderVal)]);
			end
			disp(['SCORE : ' num2str(fillScore)]);
		end

    % --- assign roiIsFilled
		rif = 0*sessions;
		rif(find(fillScore >= scoreThresh)) = 1;
		ridx = find(obj.roiIds == roiIds(r));
		obj.roiIsFilled(sessions,ridx) = rif;

    % debug plot ...
		if (showVals)
		  figure;

		  subplot(8,1,1);
			plot(ecRatio(:,r), 'ro');
			hold on;
			title(['ROI : ' num2str(roiIds(r))]);
			plot([0 length(sessions)+1], ecRatioThresh*[1 1],'k:');
			ylabel('EC');
			axis([0 length(sessions)+1 0.5 1.5]);
		  subplot(8,1,2);
			plot(cmRatio(:,r), 'mo');
			hold on;
			ylabel('CM');
			axis([0 length(sessions)+1 0 5]);
		  subplot(8,1,3);
			plot(pixValIQR(:,r), 'bo');
			hold on;
			ylabel('IQR')
			axis([0 length(sessions)+1 0 3]);

      subplot(8,1,4); hold on;
			plot(ecb,'ro');
			axis([0 length(sessions+1) -0.5 1.5]);

			subplot(8,1,5); hold on;
		  plot(borderVal(:,r)/borderVal(1,r), 'kx');
			axis([0 length(sessions)+1  0 3]);
			ylabel('borderR');
			subplot(8,1,6); hold on;
		  plot(borderVal(:,r)/borderVal(1,r), 'rx');
			axis([0 length(sessions)+1  0 3]);
			ylabel('centerR');

			subplot(8,1,7); hold on;
		  plot(2:length(sessions), sliding_pval(nb), 'kx');
		  plot(2:length(sessions), sliding_pval(nc), 'ro');
			axis([0 length(sessions)+1  0 1])

			subplot(8,1,8);
			plot(fillScore, 'r-x');
			hold on;
			axis([0 length(sessions)+1 0 2]);
			ylabel('score');
			plot([0 length(sessions)+1], scoreThresh*[1 1],'k:');
			for s=1:length(sessions)
				text(s,0.2, obj.dateStr{sessions(s)}(1:6) , 'Rotation', 90);
			end
		end
	end

%
% computes p-val minimum-based division point for a series
%
function idx = get_delta_idx_from_pval(val)
	pv = sliding_pval(val);
	idx = 1+min(find(pv == min(pv)));

%
% computes division point for vector based on deflection ; ensures that the
%  deflection point satisfies sliding_pval min_pval
%
function idx = get_delta_idx_from_diff(val, min_delta, min_pval)
  idx = [];

  dval = diff(val);
	pval = sliding_pval(val);
	candi = find(dval > min_delta);
  if (length(candi) > 0)
		pval_candi = pval(candi);
		candi = candi(find(pval_candi <= min_pval));
		if (length(candi) > 0)
			idx = candi(1)+1;
		end
	end

%
% Computes point with largest delta meeting p-val criteria -- difference
%  at val(idx)-val(idx-1) is largest of p-value criteria meeting diferences.
%
function idx = get_largest_delta_satisfying_pval(val, min_pval)
	pv = sliding_pval(val);
	candi  = 1+find(pv < min_pval);
	candi = setdiff(candi,length(val)); % omit end
 
  if (length(candi) == 0 )
	  idx = [];
	else
		for c=1:length(candi)
			dval(c) = abs(median(val(candi(c):end))-median(val(1:candi(c)-1)));
		end

		[irr biggest_delta] = max(dval);
		idx = candi(biggest_delta)
  end
