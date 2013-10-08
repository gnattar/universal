% 
% SP Apr 2011
%
% plots a ROI's health (tau, fillage) across days.
%
%  USAGE:
%
%   sA.plotRoiHealthCrossDays(params)
%
%  PARAMS:
%
%    params: a structure with following fields (or, you can just pass the roiID
%            that is, if isstruct(params) is true, then it will look for fields,
%            and if false, it will assume you are ONLY passing roiId).
%      roiId: # of roi to ploit ; set to Inf to do cross-ROI stuff
%      sessions: indices of sessions to plot ; by default all
%      showPlot: (1) tau across days
%                (2) roi across days (via plotRoiCrossDays)
%                (3) roi filling stats cross days
%                (4) roi filling stats vs. tau 
%                
%
function plotRoiHealthCrossDays (obj, params)

  % --- argument process
	if (nargin < 2) ; help('session.sessionArray.plotRoiHealthCrossDays'); disp('plotRoiHealthCrossDays::must @ least give RoiID.') ; return ; end

  % defualts
	showBorder = 0;
	showFill = 0;
	nSF = 0.25;
	showPlot = [1 1 1 1];
	normMode = 1;
	sessions = 1:length(obj.sessions);
	imageUsed = 1;

	% paramns structure
	if (~isstruct(params)) ; roiId = params ; end
	if (isstruct(params)) roiId = params.roiId; end % must pass roiId in params
	if (isstruct(params) && isfield(params, 'sessions')); sessions = params.sessions ; end
	if (isstruct(params) && isfield(params, 'showPlot')); showPlot = params.showPlot ; end

	% for ease of use
  Ns = length(sessions); % how many total
	ri = [];

  % all rois?
  if (length(roiId) == 1)
	  roiIdStr = num2str(roiId);
		ri = find(obj.roiIds == roiId);
	elseif (isinf(roiId))
	  roiId = obj.roiIds;
		roiIdStr = ' all ROIs ';
	else
		roiIdStr = strrep(' ', ',', num2str(roiId));
	end

  % ===== TIME CONSTANT RELATED

  % --- gather the data
	decaytau_p10 = nan*ones(length(sessions),length(roiId));
	decaytau_p25 = nan*ones(length(sessions),length(roiId));
	decaytau_p75 = nan*ones(length(sessions),length(roiId));
	decaytau_p50 = nan*ones(length(sessions),length(roiId));
	for s=1:Ns
		si = sessions(s);

    for r=1:length(roiId)
			eri = find(obj.sessions{si}.caTSA.ids == roiId(r));
			if (length(eri) > 0)
				decayTimes = obj.sessions{si}.caTSA.caPeakEventSeriesArray.esa{eri}.decayTimeConstants;
				pos = find (decayTimes > 0);

				% compile IQR stats
				decaytau_p25(s,r) = quantile(decayTimes(pos), .25);
				decaytau_p50(s,r) = quantile(decayTimes(pos), .5);
				decaytau_p75(s,r) = quantile(decayTimes(pos), .75);
				decaytau_p10(s,r) = quantile(decayTimes(pos), .10);
			end
		end
	end

	% --- time constants across days
	if (showPlot(1))

	  % figure setup
	  figure;
		sp1=subplot(2,1,1);
		hold on;
		sp2=subplot(2,1,2);
		hold on;

    % --- raw tau plot
		if (length(roiId) == 1) % only do if we are single-cell
			% session loop
			for s=1:Ns
				si = sessions(s);
		
				eri = find(obj.sessions{si}.caTSA.ids == roiId);
				if (length(eri) > 0)
					decayTimes = obj.sessions{si}.caTSA.caPeakEventSeriesArray.esa{eri}.decayTimeConstants;
					pos = find (decayTimes > 0);
					neg = find (decayTimes < 0);

					% plot raw
					subplot(sp1);
					plot(s*ones(1,length(pos)),decayTimes(pos), 'ko');
					plot(1.2+s*ones(1,length(neg)),-1*decayTimes(neg), 'ro');
				end
			end
			subplot(sp1);
			set(gca, 'TickDir', 'out');
			axis([0 Ns+1 0 5000]);
			ylabel('Tau (ms)')
			set(gca,'XTick',[]);
			text(1, 4000, 'GOF-accepted', 'Color',[0 0 0]);
			text(1, 3000, 'GOF-rejected', 'Color',[1 0 0]);
			title(['Time constant shift for ' obj.mouseId ' ROI ' roiIdStr]);
		end

		% IQR plot
		subplot(sp2);
		if (length(roiId) == 1) % single roi
			plot_with_errorbar2(sessions, decaytau_p50, decaytau_p75-decaytau_p50, decaytau_p50-decaytau_p25, [0 0 0]);
			plot_with_errorbar(sessions+.2,decaytau_p10,0*decaytau_p10,[0 0 1]);
		else % multiple? in this case we want cross-ROI IQR for both p10 and p50 (10th and 50th quantiles)
		  for s=1:length(sessions)
				median_p25(s) = quantile(decaytau_p50(s,:),.25);
				median_p50(s) = quantile(decaytau_p50(s,:),.5);
				median_p75(s) = quantile(decaytau_p50(s,:),.75);

				q10_p25(s) = quantile(decaytau_p10(s,:),.25);
				q10_p50(s) = quantile(decaytau_p10(s,:),.5);
				q10_p75(s) = quantile(decaytau_p10(s,:),.75);
			end

			plot_with_errorbar2(sessions-.2, median_p50, median_p75-median_p50, median_p50-median_p25, [0 0 0]);
			plot_with_errorbar2(sessions+.2, q10_p50, q10_p75-q10_p50, q10_p50-q10_p25, [0 0 1]);
		end
		set(gca, 'TickDir', 'out');
		axis([0 Ns+1 0 5000]);
		ylabel('Tau (ms)');
		set(gca,'XTick',[]);
		text(0.5,2000,'10th quantile', 'Color',[0 0 1]);
		% session labels, mark filled days ...
		for s=1:Ns
			text(s,3000, obj.dateStr{sessions(s)}(1:6) , 'Rotation', 90);
		  si = sessions(s);
			if (length(roiId) == 1 && obj.roiIsFilled(si,ri))
			  plot([-0.4 0.4] + sessions(s), [5 5], 'r-', 'LineWidth', 3);
			end
		end
	end

  % ===== FILLING RELATED

  % --- first just the roi itself, indicating fillage with color
	if (showPlot(2) & length(roiId) == 1)
	  prcdp.roiId = roiId;
		prcdp.sessions = sessions;
	  obj.plotRoiCrossDays(prcdp);
	end

	% --- now collect stats for this(all?) rois
	ecRatio = nan*ones(length(sessions),length(roiId));
	cmRatio = nan*ones(length(sessions),length(roiId));
	pixValIQR = nan*ones(length(sessions),length(roiId));
	borderVal = nan*ones(length(sessions),length(roiId));
	centerVal = nan*ones(length(sessions),length(roiId));

  for s=1:Ns
	  if (length(roiId) > 1)
		  disp(['Processing session ' obj.sessions{sessions(s)}.dateStr]);
		end
	  rA = obj.sessions{sessions(s)}.caTSA.roiArray;
		for r=1:length(roiId)
			[isFilled ecRatio(s,r) cmRatio(s,r) pixValIQR(s,r) borderVal(s,r) centerVal(s,r)] = rA.getRoiFillingStatistics(roiId(r));
		end
	end

	% --- plot
	if (showPlot(3))

	  % figure setup
	  figure; sp1=subplot(5,1,1); hold on;
		sp2=subplot(5,1,2); hold on;
		sp3=subplot(5,1,3); hold on;
		sp4=subplot(5,1,4); hold on;
		sp5=subplot(5,1,5); hold on;

	  % EC ratio
		subplot(sp1);
		if (length(roiId) == 1)
			plot_with_errorbar(sessions,ecRatio,0*ecRatio,[1 0 0]);
		else
		  quant = quantile(ecRatio, [0.25 0.5 0.75], 2);
			plot_with_errorbar2(sessions, quant(:,2), quant(:,3)-quant(:,2), quant(:,2)-quant(:,1), [1 0 0]);
		end
		set(gca, 'TickDir', 'out');
		axis([0 Ns+1 0 2]);
		plot([0 Ns+1], [1 1], 'k:');
		ylabel('edge:center ratio');
		set(gca,'XTick',[]);

    % center:median ratio change
		subplot(sp2);
		if (length(roiId) == 1)
			plot_with_errorbar(sessions,cmRatio/cmRatio(1),0*cmRatio,[0 0 1]);
		else
		  dcmr = cmRatio.*repmat(1./cmRatio(1,:)',1,size(cmRatio,1))';
		  quant = quantile(dcmr, [0.25 0.5 0.75], 2);
			plot_with_errorbar2(sessions, quant(:,2), quant(:,3)-quant(:,2), quant(:,2)-quant(:,1), [0 0 1]);
		end
		set(gca, 'TickDir', 'out');
		axis([0 Ns+1 0 3]);
		plot([0 Ns+1], [1 1], 'b:');
		ylabel({'center:image median', 'ratio change'});
		set(gca,'XTick',[]);

		% pixel IQR change
		subplot(sp3);
		if (length(roiId) == 1)
			plot_with_errorbar(sessions,pixValIQR/pixValIQR(1),0*pixValIQR,[0 0 1]);
		else
		  dpiq = pixValIQR.*repmat(1./pixValIQR(1,:)',1,size(pixValIQR,1))';
		  quant = quantile(dpiq, [0.25 0.5 0.75], 2);
			plot_with_errorbar2(sessions, quant(:,2), quant(:,3)-quant(:,2), quant(:,2)-quant(:,1), [0 0 1]);
		end
		set(gca, 'TickDir', 'out');
		axis([0 Ns+1 0 5]);
		plot([0 Ns+1], [1 1], 'b:');
		ylabel({'pixel IQR', 'ratio change'});
		set(gca,'XTick',[]);

		% border intensity change
		subplot(sp4);
		if (length(roiId) == 1)
			plot_with_errorbar(sessions,borderVal/borderVal(1),0*borderVal,[0 0 1]);
		else
		  dbor = borderVal.*repmat(1./borderVal(1,:)',1,size(borderVal,1))';
		  quant = quantile(dbor , [0.25 0.5 0.75], 2);
			plot_with_errorbar2(sessions, quant(:,2), quant(:,3)-quant(:,2), quant(:,2)-quant(:,1), [0 0 1]);
		end
		set(gca, 'TickDir', 'out');
		axis([0 Ns+1 0 3]);
		plot([0 Ns+1], [1 1], 'b:');
		ylabel({'edge value', 'ratio change'});
		set(gca,'XTick',[]);

		% center intensity change
		subplot(sp5);
		if (length(roiId) == 1)
			plot_with_errorbar(sessions,centerVal/centerVal(1),0*centerVal,[0 0 1]);
		else
		  dcen = centerVal.*repmat(1./centerVal(1,:)',1,size(centerVal,1))';
		  quant = quantile(dcen, [0.25 0.5 0.75], 2);
			plot_with_errorbar2(sessions, quant(:,2), quant(:,3)-quant(:,2), quant(:,2)-quant(:,1), [0 0 1]);
		end
		set(gca, 'TickDir', 'out');
		axis([0 Ns+1 0 3]);
		plot([0 Ns+1], [1 1], 'b:');
		ylabel({'center value', 'ratio change'});
		set(gca,'XTick',[]);

		% session labels, mark filled days ...
		subplot(sp1);
		title(['Cell morphology shift for ' obj.mouseId ' ROI ' roiIdStr]);
		for s=1:Ns
			text(s,0.05, obj.dateStr{sessions(s)}(1:6) , 'Rotation', 90);
		  si = sessions(s);
			if (length(roiId) == 1 && obj.roiIsFilled(si,ri))
			  plot([-0.4 0.4] + sessions(s), .01*[1 1], 'r-', 'LineWidth', 3);
			end
		end
	end

  % ===== FILLING VS TAU
	if (showPlot(4))

	  % figure setup
		figure('Name', ['ROI ' roiIdStr], 'NumberTitle','off');
	  sp1=subplot(4,4,1); hold on;
		sp2=subplot(4,4,2); hold on;
		sp3=subplot(4,4,3); hold on;
		sp4=subplot(4,4,4); hold on;
		sp5=subplot(4,4,5); hold on;
		sp6=subplot(4,4,6); hold on;
		sp7=subplot(4,4,7); hold on;
		sp8=subplot(4,4,8); hold on;
		sp9=subplot(4,4,9); hold on;
		sp10=subplot(4,4,10); hold on;
		sp11=subplot(4,4,11); hold on;
		sp12=subplot(4,4,12); hold on;
		sp13=subplot(4,4,13); hold on;
		sp14=subplot(4,4,14); hold on;
		sp15=subplot(4,4,15); hold on;
		sp16=subplot(4,4,16); hold on;

		% fills
		if (length(roiId) == 1)
			fillIdx = find(obj.roiIsFilled(:,ri));
		else
		  ri = find(ismember(obj.roiIds, roiId));
			fillIdx = find(obj.roiIsFilled(:,ri));
			fillIdx = reshape(fillIdx,[],1);
		end

    % here, we want one value per roi per day if there are multiple rois
 
	  % plot
    plotWithCor(decaytau_p10, ecRatio, 'Tau (10th quantile; ms)', 'edge:center ratio', [0 0 0], [0 2000], [0.5 2], fillIdx, sp1);
    plotWithCor(decaytau_p50, ecRatio, 'Tau (median; ms)', 'edge:center ratio', [0 0 1], [0 5000], [0.5 2], fillIdx, sp2);

    plotWithCor(decaytau_p10, cmRatio, 'Tau (10th quantile; ms)', 'center:median ratio', [0 0 0], [0 2000], [0 5], fillIdx, sp3);
    plotWithCor(decaytau_p50, cmRatio, 'Tau (median; ms)', 'center:median ratio', [0 0 1], [0 5000], [0 5], fillIdx, sp4);

    plotWithCor(decaytau_p10, pixValIQR, 'Tau (10th quantile; ms)', 'pixel IQR', [0 0 0], [0 2000], [0 3], fillIdx, sp5);
    plotWithCor(decaytau_p50, pixValIQR, 'Tau (median; ms)', 'pixel IQR', [0 0 1], [0 5000], [0 3], fillIdx, sp6);

    plotWithCor(decaytau_p10, borderVal, 'Tau (10th quantile; ms)', 'edge value', [0 0 0], [0 2000], [0 5], fillIdx, sp7);
    plotWithCor(decaytau_p50, borderVal, 'Tau (median; ms)', 'edge value', [0 0 1], [0 5000], [0 5], fillIdx, sp8);

    plotWithCor(decaytau_p10, centerVal, 'Tau (10th quantile; ms)', 'center value', [0 0 0], [0 2000], [0 5], fillIdx, sp9);
    plotWithCor(decaytau_p50, centerVal, 'Tau (median; ms)', 'center value', [0 0 1], [0 5000], [0 5], fillIdx, sp10);

    plotWithCor(decaytau_p10, decaytau_p50, 'Tau (10th quantile; ms)', 'Tau (median; ms)', [0 1 0], [0 2000], [0 5000], fillIdx, sp11);

    plotWithCor(ecRatio, cmRatio, 'edge:center ratio', 'center:median ratio', [1 0 0], [0.5 2], [0 5], fillIdx, sp12);
    plotWithCor(ecRatio, pixValIQR, 'edge:center ratio', 'pixel IQR', [1 0 0], [0.5 2], [0 3], fillIdx, sp13);
    plotWithCor(ecRatio, borderVal, 'edge:center ratio', 'border value', [1 0 0], [0.5 2], [0 5], fillIdx, sp14);
    plotWithCor(ecRatio, centerVal, 'edge:center ratio', 'center value', [1 0 0], [0.5 2], [0 5], fillIdx, sp15);
    plotWithCor(centerVal, borderVal, 'center value', 'border value', [1 0 0], [0 5], [0 5], fillIdx, sp16);

		text(0.1,4.5,'filled','Color',[1 0 0]);
		text(0.1,3.5,'unfilled','Color',[0 0 0]);
	end


%
% plots subplot of corr
%
function plotWithCor(xval, yval, xlab, ylab, col, xlim, ylim, fillIdx, ax);
  % ensure dimensions
  if (min(size(xval)) > 1) ; xval = reshape(xval,[],1); end
  if (min(size(yval)) > 1) ; yval = reshape(yval,[],1); end
	if (size(xval,1) < size(xval,2)) ; xval = xval' ; end
	if (size(yval,1) < size(yval,2)) ; yval = yval' ; end

  col = [0 0 0];
	fillCol = [1 0 0];
  notFillIdx = setdiff(1:length(xval), fillIdx);

	subplot(ax);
	plot(xval(notFillIdx), yval(notFillIdx), 'o', 'Color', col, 'MarkerFaceColor', col);
	plot(xval(fillIdx), yval(fillIdx), 'o', 'Color', fillCol, 'MarkerFaceColor', fillCol);
	xlabel(xlab);
	ylabel(ylab);
	axis([xlim(1) xlim(2) ylim(1) ylim(2)]);
	val = find(~isnan(xval) & ~isnan(yval));
	corrval = corr(xval(val), yval(val), 'type','Spearman');
%	text(xlim(1)+0.1*diff(xlim), ylim(1)+0.1*diff(ylim), ['Corr: ' num2str(corrval)]);
	title(['Corr: ' num2str(corrval)]);
  
