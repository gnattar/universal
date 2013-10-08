%
% SP Jun 2011
%
% Plots a summary of the animal's whisking.
%
% USAGE:
% 
%  s.plotWhiskingSummary(params)
%
% PARAMS: pass via params structure:
%   params.plotsShown: which plots to show?
%                      (1): counts of all touch types
%                      (2): kappa & theta for touches
%                      (3): kappa & theta for unique touches
%                      (4): PDFs for all kappa/theta versions
%   params.wsData: if a previous call to getWhiskingSummaryData was made,
%                  you can pass results directly . . .
%
function plotWhiskingSummary(obj, params)
  % --- presets
	whiskerTags = {'c1','c2','c3'};
	whiskerCols = [1 0 0 ; 0 1 0 ; 0 0 1];
	whiskerIdx = [nan nan nan];

	kappaRange = [-.001 .001 ; -.001 .001 ; -.001 .001];
	kappaRange = [-.001 .001 ; -.001 .001 ; -.01 .01];
	thetaRange = [-30 30; -30 30; -30 30];
	thetaRange = [-50 50; -50 50; -50 50];
	plotsShown = [1 0 0 0 0];

	% --- user input
	wsData = [];
	if (nargin > 1 && isstruct(params))
	  if(isfield(params,'plotsShown')) ; plotsShown = params.plotsShown; end
	  if(isfield(params,'wsData')) ; wsData = params.wsData; end
	end

	if (length(wsData) == 0); wsData = obj.getWhiskingSummaryData() ; end

	% === 1) compile event series, RFs
  for w=1:length(whiskerTags)
    % in this animal ...
		widx = find(strcmp(obj.whiskerTag,whiskerTags{w}));
		if (length(widx) == 0) ; continue ; end
		whiskerIdx(w) = widx;
	end

	% combo touches
	% seq touches

	% === 2) summarize event counts
	if (plotsShown(1))
	  plotEventCountSummary(whiskerTags, wsData.touchCount, wsData.firstTouchCount);
  end

	% === 3) summarize kappa & theta distros

	% non-uniques
	if (plotsShown(2))
		figure('Position', [0 0 1600 800]);
		if (~isnan(whiskerIdx(1)) ) 
			plotKTSummaryRow(obj, 1, whiskerIdx, kappaRange, thetaRange, .65, wsData.firstTouches, [1 4 3]);
		end
		if (~isnan(whiskerIdx(2)) ) 
			plotKTSummaryRow(obj, 2, whiskerIdx, kappaRange, thetaRange, .35, wsData.firstTouches, [1 4 3]);
		end
		if (~isnan(whiskerIdx(3)) ) 
			plotKTSummaryRow(obj, 3, whiskerIdx, kappaRange, thetaRange, .05, wsData.firstTouches, [1 4 3]);
			title('Non-unique touches');
		end
  end

	% uniques
	if (plotsShown(3))
		figure('Position', [0 0 1600 800]);
		if (~isnan(whiskerIdx(1)) ) 
			plotKTSummaryRow(obj, 1, whiskerIdx, kappaRange, thetaRange, .65, wsData.firstTouches, [2 6 5]);
		end
		if (~isnan(whiskerIdx(2)) ) 
			plotKTSummaryRow(obj, 2, whiskerIdx, kappaRange, thetaRange, .35, wsData.firstTouches, [2 6 5]);
		end
		if (~isnan(whiskerIdx(3)) ) 
			plotKTSummaryRow(obj, 3, whiskerIdx, kappaRange, thetaRange, .05, wsData.firstTouches, [2 6 5]);
			title('Unique touches');
		end
	end

	% === 4) PDFs for theta & kappa relative touch in various ways
	if (plotsShown(4))
%	es = touchES; % uTouchES ; proTouchES ; retTouchES ; upro; u ret
	  % touchES, uTouchES
	  figure('Position', [0 0 1600 800]);
		y = 0.8; ri = 1;
		for w=1:3
		  if (~isnan(whiskerIdx(w)))
    	  plotPDFRow(obj, ri, wsData.touches{w}{1}, y, whiskerTags, w, thetaRange, kappaRange, [whiskerTags{w}]);
	      plotPDFRow(obj, ri+1, wsData.touches{w}{2}, y-.15, whiskerTags, w, thetaRange, kappaRange, ['unique ' whiskerTags{w}]);
				ri = ri+2;
				y = y-0.3;
			end
		end

		% proTouchES, uProTouchES
	  figure('Position', [0 0 1600 800]);
		y = 0.8; ri = 1;
		for w=1:3
		  if (~isnan(whiskerIdx(w)))
    	  plotPDFRow(obj, ri, wsData.touches{w}{3}, y, whiskerTags, w, thetaRange, kappaRange, ['pro ' whiskerTags{w}]);
	      plotPDFRow(obj, ri+1, wsData.touches{w}{4}, y-.15, whiskerTags, w, thetaRange, kappaRange, ['unique pro ' whiskerTags{w}]);
				ri = ri+2;
				y = y-0.3;
			end
		end

		% retTouchES, uRetTouchES
	  figure('Position', [0 0 1600 800]);
		y = 0.8; ri = 1;
		for w=1:3
		  if (~isnan(whiskerIdx(w)))
    	  plotPDFRow(obj, ri, wsData.touches{w}{5}, y, whiskerTags, w, thetaRange, kappaRange, ['ret ' whiskerTags{w}]);
	      plotPDFRow(obj, ri+1, wsData.touches{w}{6}, y-.15, whiskerTags, w, thetaRange, kappaRange, ['unique ret ' whiskerTags{w}]);
				ri = ri+2;
				y = y-0.3;
			end
		end
  end

%
% plots a row of PDFs --> all interesting variables
%
function plotPDFRow(obj, row, ES, fy, whiskerTags, w, thetaRange, kappaRange, rowLabel)
	fw = 0.07;
	fp = 0.01;
	sx = 0.03;
	fh = .12;

	% kappa: maxabs [], 1st ; sumabs [], 1, max ; summaxabs abssummaxabs [] [7]
	ax = subplot('Position', [sx fy fw fh]);
	plotSinglePDF(obj, ax, ES, whiskerTags{w},  'whiskerCurvatureChangeTSA', ['Curvature change for ' whiskerTags{w}], ...
		'maxabs', 1, linspace(kappaRange(w,1),kappaRange(w,2), 50), 0.25, [-0.1 0.5]);
	set(ax, 'YTick', [0 0.25]);
	if (row == 1) ; title('Max kappa 1st'); end
	ylabel(rowLabel);
	if (row == 6) ; xlabel('1/pixel'); end
	ax = subplot('Position', [sx + (fp+fw) fy fw fh]);
	plotSinglePDF(obj, ax, ES, whiskerTags{w},  'whiskerCurvatureChangeTSA', ['Curvature change for ' whiskerTags{w}], ...
		'maxabs', [], linspace(kappaRange(w,1),kappaRange(w,2),50), 0.25, [-0.1 0.5]);
	if (row == 1) ; title('Max kappa all'); end
	if (row == 6) ; xlabel('1/pixel'); end

	ax = subplot('Position', [sx + 2*(fp+fw) fy fw fh]);
	plotSinglePDF(obj, ax, ES, whiskerTags{w},  'whiskerCurvatureChangeTSA', ['Curvature change for ' whiskerTags{w}], ...
		'sumabs', 1, linspace(0,100*kappaRange(w,2),50), 0.25, [-0.1 0.5]);
	if (row == 1) ; title('Sum kappa 1st'); end
	if (row == 6) ; xlabel('1/pixel'); end
	ax = subplot('Position', [sx + 3*(fp+fw) fy fw fh]);
	plotSinglePDF(obj, ax, ES, whiskerTags{w},  'whiskerCurvatureChangeTSA', ['Curvature change for ' whiskerTags{w}], ...
		'sumabs','max', linspace(0,100*kappaRange(w,2),50), 0.25, [-0.1 0.5]);
	if (row == 1) ; title('Sum kappa max'); end
	if (row == 6) ; xlabel('1/pixel'); end
	ax = subplot('Position', [sx + 4*(fp+fw) fy fw fh]);
	plotSinglePDF(obj, ax, ES, whiskerTags{w},  'whiskerCurvatureChangeTSA', ['Curvature change for ' whiskerTags{w}], ...
		'sumabs', [], linspace(0,100*kappaRange(w,2),50), 0.25, [-0.1 0.5]);
	if (row == 1) ; title('Sum kappa all'); end
	if (row == 6) ; xlabel('1/pixel'); end

	ax = subplot('Position', [sx + 5*(fp+fw) fy fw fh]);
	plotSinglePDF(obj, ax, ES, whiskerTags{w},  'whiskerCurvatureChangeTSA', ['Curvature change for ' whiskerTags{w}], ...
		'summaxabs', [], linspace(10*kappaRange(w,1), 10*kappaRange(w,2),50), 0.25, [-0.1 0.5]);
	if (row == 1) ; title('Sum max/touch K'); end
	if (row == 6) ; xlabel('1/pixel'); end
	ax = subplot('Position', [sx + 6*(fp+fw) fy fw fh]);
	plotSinglePDF(obj, ax, ES, whiskerTags{w},  'whiskerCurvatureChangeTSA', ['Curvature change for ' whiskerTags{w}], ...
		'abssummaxabs', [], linspace(0,10*kappaRange(w,2),50), 0.25, [-0.1 0.5]);
	if (row == 1) ; title('Abs sum max/touch K'); end
	if (row == 6) ; xlabel('1/pixel'); end

	% theta: mean [], 1 ; 1st 1 [3]
	ax = subplot('Position', [sx + 7*(fp+fw) fy fw fh]);
	plotSinglePDF(obj, ax, ES, whiskerTags{w},  'whiskerAngleTSA', ['Angle for ' whiskerTags{w}], ...
		'mean', 1, linspace(thetaRange(w,1), thetaRange(w,2),50), 0.25, [-0.1 0.5]);
	if (row == 1) ; title('Mean theta 1st'); end
	if (row == 6) ; xlabel('degrees'); end
	ax = subplot('Position', [sx + 8*(fp+fw) fy fw fh]);
	plotSinglePDF(obj, ax, ES, whiskerTags{w},  'whiskerAngleTSA', ['Angle for ' whiskerTags{w}], ...
		'mean', [], linspace(thetaRange(w,1), thetaRange(w,2),50), 0.25, [-0.1 0.5]);
	if (row == 1) ; title('Mean theta all'); end
	if (row == 6) ; xlabel('degrees'); end
	ax = subplot('Position', [sx + 9*(fp+fw) fy fw fh]);
	plotSinglePDF(obj, ax, ES, whiskerTags{w},  'whiskerAngleTSA', ['Angle for ' whiskerTags{w}], ...
		'first', 1, linspace(thetaRange(w,1), thetaRange(w,2),50), 0.25, [-0.1 0.5]);
	if (row == 1) ; title('1st theta 1st'); end
	if (row == 6) ; xlabel('degrees'); end

	% duration [2]
	ax = subplot('Position', [sx + 10*(fp+fw) fy fw fh]);
	plotSinglePDF(obj, ax, ES, whiskerTags{w},  'whiskerCurvatureChangeTSA', ['Curvature change for ' whiskerTags{w}], ...
		'duration', 1, linspace(0,1000,50), 0.25, [-0.1 2]);
	if (row == 1) ; title('1st touch duration'); end
	if (row == 6) ; xlabel('ms'); end

	ax = subplot('Position', [sx + 11*(fp+fw) fy fw fh]);
	plotSinglePDF(obj, ax, ES, whiskerTags{w},  'whiskerCurvatureChangeTSA', ['Curvature change for ' whiskerTags{w}], ...
		'duration', [], linspace(0,1000,50), 0.25, [-0.1 2]);
	if (row == 1) ; title('all touch duration'); end
	if (row == 6) ; xlabel('ms'); end

%
% plots a single PDF
%
function plotSinglePDF(obj, ax, es, wStr,  stimTSA, stimTSId, stimMode, trialEventNumber, pdfBins, maxProb, stimTimeWindow)
	params.roiId = 1;
	params.wcESA = es;
	params.wcESId = [];
	params.stimTSA = stimTSA;
	params.stimTSId = stimTSId;
	params.stimMode = stimMode;
	params.stimTimeWindow = stimTimeWindow;
	params.trialEventNumber = trialEventNumber;

	[st re] = obj.getPeriWhiskerContactRF(params);

	axes(ax);
	[n xout] = hist(st,pdfBins(1:end-1));
	N = length(st);
	bar(pdfBins(1:end-1)+0.5*mode(diff(pdfBins)), n/N);
	axis([pdfBins(1) pdfBins(end) 0 maxProb]);

  set(gca,'TickDir', 'out');
%	set(gca,'XTick', []);
	set(gca,'YTick', []);


%
% plots single kappa-theta summary row
%
function plotKTSummaryRow(obj, w, whiskerIdx, kappaRange, thetaRange, y, touches, tidx);
	sp = subplot('Position', [0.025 y 0.15 0.25]);
	set(gca,'TickDir','out');
	ylabel(obj.whiskerTag{whiskerIdx(w)});
  obj.plotTimeSeriesAsLine(obj.whiskerCurvatureChangeTSA, whiskerIdx(w), {obj.whiskerBarInReachES, obj.behavESA.esa{5}}, [], [], [0 7 kappaRange(w,1) kappaRange(w,2)], [nan sp], 0);
	if (whiskerIdx(w) == 1) ; title(['Kappa by trial type ' obj.mouseId ' ' obj.dateStr(1:6)]); end
	if (whiskerIdx(w) == 1) 
	  R = abs(diff(kappaRange(w,:)));
    m = kappaRange(w,1);
		text(4, m+0.1*R, 'CR', 'Color', [1 0 0]);
		text(4, m+0.2*R, 'FA', 'Color', [0 1 0]);
		text(4, m+0.3*R, 'Miss', 'Color', [0 0 0]);
		text(4, m+0.4*R, 'Hit', 'Color', [0 0 1]);
	end
	if (whiskerIdx(w) ~= 3) ; set(gca,'XTick',[]);  xlabel(''); end

	sp = subplot('Position', [0.025+.16 y 0.15 0.25]);
	set(gca,'TickDir','out');
	set(gca,'YTick', []);
	if (length(touches{w}{tidx(1)}) > 0) ; obj.plotEventTriggeredAverage(obj.whiskerCurvatureChangeTSA, whiskerIdx(w), touches{w}{tidx(1)}, 1, [-2 5 kappaRange(w,1) kappaRange(w,2)], [nan sp], [0 0 0]); end
	hold on;
	if (length(touches{w}{tidx(2)}) > 0) ; obj.plotEventTriggeredAverage(obj.whiskerCurvatureChangeTSA, whiskerIdx(w), touches{w}{tidx(2)}, 1, [-2 5 kappaRange(w,1) kappaRange(w,2)], [nan sp], [1 0 0 ]);end
	if (length(touches{w}{tidx(3)}) > 0) ; obj.plotEventTriggeredAverage(obj.whiskerCurvatureChangeTSA, whiskerIdx(w), touches{w}{tidx(3)}, 1, [-2 5 kappaRange(w,1) kappaRange(w,2)], [nan sp], [ 0 0 1]);end
	if (whiskerIdx(w) == 1) ; title('Kappa aligned to 1st touch'); end
	if (whiskerIdx(w) ~= 3) ; set(gca,'XTick',[]); xlabel('');  end
	if (whiskerIdx(w) == 1) 
	  R = abs(diff(kappaRange(w,:)));
    m = kappaRange(w,1);
		text(4, m+0.1*R, 'Pro', 'Color', [0 0 1]);
		text(4, m+0.2*R, 'Ret', 'Color', [1 0 0]);
		text(4, m+0.3*R, 'All', 'Color', [0 0 0]);
	end

	sp = subplot('Position', [0.025+.16+.16 y 0.15 0.25]);
	set(gca,'TickDir','out');
	set(gca,'YTick', []);
	if (length(touches{w}{tidx(1)}) > 0) ; obj.plotEventTriggeredAverage(obj.whiskerCurvatureChangeTSA, whiskerIdx(w), touches{w}{tidx(1)}, 1, [-0.05 .1 kappaRange(w,1) kappaRange(w,2)], [nan sp], [0 0 0]);end
	hold on;
	if (length(touches{w}{tidx(2)}) > 0) ; obj.plotEventTriggeredAverage(obj.whiskerCurvatureChangeTSA, whiskerIdx(w), touches{w}{tidx(2)}, 1, [-.05 .1 kappaRange(w,1) kappaRange(w,2)], [nan sp], [1 0 0 ]);end
	if (length(touches{w}{tidx(3)}) > 0) ; obj.plotEventTriggeredAverage(obj.whiskerCurvatureChangeTSA, whiskerIdx(w), touches{w}{tidx(3)}, 1, [-.05 .1 kappaRange(w,1) kappaRange(w,2)], [nan sp], [ 0 0 1]);end
	if (whiskerIdx(w) ~= 3) ; set(gca,'XTick',[]); xlabel('');  end

	sp = subplot('Position', [0.525 y 0.15 0.25]);
	set(gca,'TickDir','out');
  obj.plotTimeSeriesAsLine(obj.whiskerAngleTSA, whiskerIdx(w), {obj.whiskerBarInReachES, obj.behavESA.esa{5}}, [], [], [0 7 thetaRange(w,1) thetaRange(w,2)], [nan sp], 0);
	if (whiskerIdx(w) == 1) ; title('Theta by trial type'); end
	if (whiskerIdx(w) ~= 3) ; set(gca,'XTick',[]); xlabel(''); end

	sp = subplot('Position', [0.525+.16 y 0.15 0.25]);
	set(gca,'TickDir','out');
	set(gca,'YTick', []);
	if (length(touches{w}{tidx(1)}) > 0) ; obj.plotEventTriggeredAverage(obj.whiskerAngleTSA, whiskerIdx(w), touches{w}{tidx(1)}, 1, [-2 5 thetaRange(w,1) thetaRange(w,2)], [nan sp], [0 0 0]);end
	hold on ;
	if (length(touches{w}{tidx(2)}) > 0) ; obj.plotEventTriggeredAverage(obj.whiskerAngleTSA, whiskerIdx(w), touches{w}{tidx(2)}, 1, [-2 5 thetaRange(w,1) thetaRange(w,2)], [nan sp], [1 0 0]);end
	if (length(touches{w}{tidx(3)}) > 0) ; obj.plotEventTriggeredAverage(obj.whiskerAngleTSA, whiskerIdx(w), touches{w}{tidx(3)}, 1, [-2 5 thetaRange(w,1) thetaRange(w,2)], [nan sp], [ 0 0 1]);end
	if (whiskerIdx(w) == 1) ; title('Theta aligned to 1st touch'); end
	if (whiskerIdx(w) ~= 3) ; set(gca,'XTick',[]); xlabel('');  end
	
	sp = subplot('Position', [0.525+.16+.16 y 0.15 0.25]);
	set(gca,'TickDir','out');
	set(gca,'YTick', []);
	if (length(touches{w}{tidx(1)}) > 0) ; obj.plotEventTriggeredAverage(obj.whiskerAngleTSA, whiskerIdx(w), touches{w}{tidx(1)}, 1, [-.05 .1 thetaRange(w,1) thetaRange(w,2)], [nan sp], [0 0 0]);end
	hold on ;
	if (length(touches{w}{tidx(2)}) > 0) ; obj.plotEventTriggeredAverage(obj.whiskerAngleTSA, whiskerIdx(w), touches{w}{tidx(2)}, 1, [-.05 .1 thetaRange(w,1) thetaRange(w,2)], [nan sp], [1 0 0]);end
	if (length(touches{w}{tidx(3)}) > 0) ; obj.plotEventTriggeredAverage(obj.whiskerAngleTSA, whiskerIdx(w), touches{w}{tidx(3)}, 1, [-.05 .1 thetaRange(w,1) thetaRange(w,2)], [nan sp], [ 0 0 1]);end
	if (whiskerIdx(w) ~= 3) ; set(gca,'XTick',[]); xlabel('');  end



%
% plots event count summary with bars
%
function plotEventCountSummary(whiskerTags, touchCount, firstTouchCount)
	figure;
	% touch plot --> # touch / whisker ; # unique touch
	subplot(2,2,1); 
	xvec = [1 2 3 5 6 7];
	yvec = [touchCount(1:3,1), touchCount(1:3,2)];
	colMat = [1 0 0 ; 0 1 0 ; 0 0 1 ; 1 0 0 ; 0 1 0 ; 0 0 1];
	for i=1:length(xvec) ; plot_bar_error(xvec(i), yvec(i), 0, 0.8, colMat(i,:) );end
	set(gca,'TickDir','out','XTick',[]);
	A = axis;
	axis([0 8 0 A(4)]);
	text(1, A(4)*.9, 'All');
	text(5, A(4)*.9, 'Unique');
	text(5, A(4)*0.3, whiskerTags{1}, 'Color', [1 0 0]);
	text(5, A(4)*0.45, whiskerTags{2}, 'Color', [0 1 0]);
	text(5, A(4)*0.6, whiskerTags{3}, 'Color', [0 0 1]);
	ylabel('Touch count');
	
	% directional touch plot --> # touch / whisker ; # unique touch
	subplot(2,2,2); 
	xvec = [1 2 3 4 5 6 8 9 10 11 12 13];
	yvec = [touchCount(1,3:4) touchCount(2,3:4) touchCount(3,3:4) touchCount(1,5:6) touchCount(2,5:6) touchCount(3,5:6)];
	colMat = [1 0 0 ; 1 0.75 0.75 ;  0 1 0 ; 0.75 1 0.75 ; 0 0 1;  0.75 0.75 1 ];
	colMat = [colMat ; colMat];
	for i=1:length(xvec) ; plot_bar_error(xvec(i), yvec(i), 0, 0.8, colMat(i,:) );end
	set(gca,'TickDir','out','XTick',[]);
	A = axis;
	axis([0 14 0 A(4)]);
	text(2, A(4)*.9, 'All');
	text(9, A(4)*.9, 'Unique');
	text(9, A(4)*0.2, ['Pro ' whiskerTags{1}], 'Color', [1 0 0]);
	text(9, A(4)*0.3, ['Ret ' whiskerTags{1}], 'Color', [1 0.75 0.75]);
	text(9, A(4)*0.4, ['Pro ' whiskerTags{2}], 'Color', [0 1 0]);
	text(9, A(4)*0.5, ['Ret ' whiskerTags{2}], 'Color', [0.75 1 0.75]);
	text(9, A(4)*0.6, ['Pro ' whiskerTags{3}], 'Color', [0 0 1]);
	text(9, A(4)*0.7, ['Ret ' whiskerTags{3}], 'Color', [0.75 0.75 1]);
	ylabel('Touch count');

	% first touch plot --> # touch / whisker ; # unique touch
	subplot(2,2,3); 
	xvec = [1 2 3 5 6 7];
	yvec = [firstTouchCount(1:3,1), firstTouchCount(1:3,2)];
	colMat = [1 0 0 ; 0 1 0 ; 0 0 1 ; 1 0 0 ; 0 1 0 ; 0 0 1];
	for i=1:length(xvec) ; plot_bar_error(xvec(i), yvec(i), 0, 0.8, colMat(i,:) );end
	set(gca,'TickDir','out','XTick',[]);
	A = axis;
	axis([0 8 0 A(4)]);
	text(1, A(4)*.9, 'All');
	text(5, A(4)*.9, 'Unique');
	text(5, A(4)*0.3, whiskerTags{1}, 'Color', [1 0 0]);
	text(5, A(4)*0.45, whiskerTags{2}, 'Color', [0 1 0]);
	text(5, A(4)*0.6, whiskerTags{3}, 'Color', [0 0 1]);
	ylabel('Touch trial count');
	
	% first directional touch plot --> # touch / whisker ; # unique touch
	subplot(2,2,4); 
	xvec = [1 2 3 4 5 6 8 9 10 11 12 13];
	yvec = [firstTouchCount(1,3:4) firstTouchCount(2,3:4) firstTouchCount(3,3:4) firstTouchCount(1,5:6) firstTouchCount(2,5:6) firstTouchCount(3,5:6)];
	colMat = [1 0 0 ; 1 0.75 0.75 ;  0 1 0 ; 0.75 1 0.75 ; 0 0 1;  0.75 0.75 1 ];
	colMat = [colMat ; colMat];
	for i=1:length(xvec) ; plot_bar_error(xvec(i), yvec(i), 0, 0.8, colMat(i,:) );end
	set(gca,'TickDir','out','XTick',[]);
	A = axis;
	axis([0 14 0 A(4)]);
	text(2, A(4)*.9, 'All');
	text(9, A(4)*.9, 'Unique');
	text(9, A(4)*0.2, ['Pro ' whiskerTags{1}], 'Color', [1 0 0]);
	text(9, A(4)*0.3, ['Ret ' whiskerTags{1}], 'Color', [1 0.75 0.75]);
	text(9, A(4)*0.4, ['Pro ' whiskerTags{2}], 'Color', [0 1 0]);
	text(9, A(4)*0.5, ['Ret ' whiskerTags{2}], 'Color', [0.75 1 0.75]);
	text(9, A(4)*0.6, ['Pro ' whiskerTags{3}], 'Color', [0 0 1]);
	text(9, A(4)*0.7, ['Ret ' whiskerTags{3}], 'Color', [0.75 0.75 1]);
	ylabel('Touch trial count');
	

