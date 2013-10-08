%
% SP May 2011
%
% Computes area under ROC curve given two distributions.  DVa is considered
%  to be signal response given signal.  AUC < .5 is allowed.
%
% USAGE:
%
%  [roc_area] = roc_area_from_distro(DVa, DVb)
%  
%  roc_area: area under ROC curve
%  
%  DVa, DVb: values in two distrbutions
%
function [roc_area] = roc_area_from_distro(DVa, DVb)
  % compute area under ROC ... -- divide range into 100 bins
	critVec = sort(unique([DVb DVa]));
	critVec = min(critVec):(range(critVec)/100):max(critVec);

  % sanity check
	if (isempty(critVec) || range(critVec) == 0)
	  roc_area = 0.5; % chance
		return;
	end

	% generate ROC Curve from sliding criterion
	Nb = length(DVb);
	Na = length(DVa);
	P_bGcrit = 0*critVec;
	P_aGcrit = 0*critVec;
	for c=1:length(critVec)
	  P_bGcrit(c) = length(find(DVb > critVec(c)))/Nb;
	  P_aGcrit(c) = length(find(DVa > critVec(c)))/Na;
	end

  % plot if you want
  if (0)
	  subplot(2,1,1);
		hist(DVb,25);
		axis([min(critVec) max(critVec) 0 max(length(DVb),length(DVa))]);
		subplot(2,1,2);
		hist(DVa,25);
		axis([min(critVec) max(critVec) 0 max(length(DVb),length(DVa))]);
		pause;
		close;
	end

	% zero values for P_bGcrit -- keep HIGHEST P_aGcrit only
	zVals = find(P_bGcrit == 0);
	if (length(zVals) > 0)
	  [irr mi] = max(P_aGcrit(zVals));
	  zIdx = zVals(mi);
		P_bGcrit(zIdx) = 1e-5; % infinitesmally larger than 0 so we can interp it!
	  keepIdx = zIdx;
    keepIdx = [keepIdx find(P_bGcrit ~= 0)];
		P_bGcrit = P_bGcrit(keepIdx);
		P_aGcrit = P_aGcrit(keepIdx);
	end

  % 0,0 and 1,1 always
	P_bGcrit(c+1:c+2) = [0 1];
	P_aGcrit(c+1:c+2) = [0 1];

	% not enough for ROC?
	[irr ui] = unique(P_bGcrit);
	if (length(ui) < 3 )%| min(P_bGcrit) > 0.1 | max(P_bGcrit) < 0.9)
	  roc_area = nan; 
		disp('Insufficient PDF coverage for ROC with array');
		xvals = [] ; yvals= [];
   else
		% discrimination = area under ROC - interpolate missing poitns lienarlty
		xvals = 0.01:0.01:.99; 
		yvals = interp1(P_bGcrit(ui),P_aGcrit(ui),xvals,'linear');
		roc_area = nanmean(yvals);
	end

	% plot ROC
	if (0) 
	  hold off;
	  plot(P_bGcrit, P_aGcrit,'rx');
		hold on;
	  plot(xvals, yvals,'bx');
		title(['Under ROC: ' num2str(roc_area)]);
		hold off;
		pause;
	end

