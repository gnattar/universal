%
% SP Jun 2011
%
% Plots whisking summary across days.
%
% USAGE:
%
%   sA.plotWhiskingSummary(params)
%
% PARAMS: structure params, with fields:
%
%   plotsShown: 1 or 0 to show/not show
%              (1): # touches in all conditions x days
%              (2): kappa across days
%              (3): theta across days
%
function plotWhiskingSummary (obj, params)

  % --- process user inputs
	plotsShown = [1 1 1];
  if (nargin > 1 && isstruct(params))
	  if (isfield(params,'plotsShown')) ; plotsShown = params.plotsShown; end
	end

	% --- 1) # touches per condition
	if (plotsShown(1))
  	% 1-6 = touch uTouch proTouch ret uPro uRet
		figure;
		subplot(3,2,1);
    plotSingleTouchCount(obj, 1, 'touchCount');
		title('All touches');
		ylabel('total # touches');
		subplot(3,2,2);
    plotSingleTouchCount(obj, 2, 'touchCount');
		title('Unique touches');
		subplot(3,2,3);
    plotSingleTouchCount(obj, 3, 'touchCount');
		title('Pro touches');
		subplot(3,2,4);
    plotSingleTouchCount(obj, 5, 'touchCount');
		title('U Pro touches');
		subplot(3,2,5);
    plotSingleTouchCount(obj, 4, 'touchCount');
		title('Ret touches');
		subplot(3,2,6);
    plotSingleTouchCount(obj, 6, 'touchCount');
		title('U Ret touches');

		figure;
		subplot(3,2,1);
    plotSingleTouchCount(obj, 1, 'firstTouchCount');
		title('All touches');
		ylabel('total # trials with touch');
		subplot(3,2,2);
    plotSingleTouchCount(obj, 2, 'firstTouchCount');
		title('Unique touches');
		subplot(3,2,3);
    plotSingleTouchCount(obj, 3, 'firstTouchCount');
		title('Pro touches');
		subplot(3,2,4);
    plotSingleTouchCount(obj, 5, 'firstTouchCount');
		title('U Pro touches');
		subplot(3,2,5);
    plotSingleTouchCount(obj, 4, 'firstTouchCount');
		title('Ret touches');
		subplot(3,2,6);
    plotSingleTouchCount(obj, 6, 'firstTouchCount');
		title('U Ret touches');

	end
	
	% --- 2) # kappa cross days
	if (plotsShown(2))
    wColors = [1 0 0 ; 0 1 0 ; 0 0 1];
  	wTags = {'c1','c2','c3'};
	
   	figure('Position', [0 0 1600 800]);
  	% obj.whiskingSummary{s}.rfKappa{w}{1 4 7 10 13 16}
  	% obj.whiskingSummary{s}.rfTheta{w}{1 4 7 10 13 16}
	  %  touchkappa, utouch, protouch, ret, upro, uret

		% theta
		thetaRange = [-50 50];
    plotSingleDensityPlotSet (obj, wColors, wTags, .05, .5 ,1, 'All theta', 'Theta (deg)', 'rfTheta',1,thetaRange);
    plotSingleDensityPlotSet (obj, wColors, wTags, .05, .05 ,4, 'Unique theta', 'Theta (deg)', 'rfTheta',0,thetaRange);
    plotSingleDensityPlotSet (obj, wColors, wTags, .35, .5 ,7, 'All pro theta', 'Theta (deg)', 'rfTheta',0,thetaRange);
    plotSingleDensityPlotSet (obj, wColors, wTags, .35, .05 ,13, 'Unique pro theta', 'Theta (deg)', 'rfTheta',0,thetaRange);
    plotSingleDensityPlotSet (obj, wColors, wTags, .65, .5 ,10, 'All ret theta', 'Theta (deg)', 'rfTheta',0,thetaRange);
    plotSingleDensityPlotSet (obj, wColors, wTags, .65, .05 ,16, 'Unique ret theta', 'Theta (deg)', 'rfTheta',0,thetaRange);

 		figure('Position', [0 0 1600 800]);

		% kappa
		kappaRange = [-.02 .02];
		kappaAxisLab =  'Kappa (summaxabs ; 1/pix)';
%		kappaRange = [-.005 .005]
%		kappaAxisLab =  'Kappa (maxabs ; 1/pix)'
    plotSingleDensityPlotSet (obj, wColors, wTags, .05, .5 ,1, 'All kappa', kappaAxisLab, 'rfKappa',1, kappaRange);
    plotSingleDensityPlotSet (obj, wColors, wTags, .05, .05 ,4, 'Unique kappa', kappaAxisLab, 'rfKappa',0, kappaRange);
    plotSingleDensityPlotSet (obj, wColors, wTags, .35, .5 ,7, 'All pro kappa', kappaAxisLab, 'rfKappa',0, kappaRange);
    plotSingleDensityPlotSet (obj, wColors, wTags, .35, .05 ,13, 'Unique pro kappa', kappaAxisLab, 'rfKappa',0, kappaRange);
    plotSingleDensityPlotSet (obj, wColors, wTags, .65, .5 ,10, 'All ret kappa', kappaAxisLab, 'rfKappa',0, kappaRange);
    plotSingleDensityPlotSet (obj, wColors, wTags, .65, .05 ,16, 'Unique ret kappa', kappaAxisLab, 'rfKappa',0, kappaRange);
  end
%
% plots a 3-some of density plots
%
function plotSingleDensityPlotSet (obj, wColors, wTags, x0, y0, idx, tstr, xlab, vecUsed, showDates, valRange)
	for w=1:3
		ax = subplot('Position', [x0 y0+(3-w)*0.1 0.2 0.1]);  
		sd = 0;
		if (w == 1 & showDates) ; sd = 1; end
		plotSingleDensityPlot(obj, wColors, wTags, w, ax, idx, sd, vecUsed, valRange);
		if (w == 3) % bottom 
			xlabel(xlab);
		else
			set(gca,'XTick',[]);
		end
		if (w == 1) 
			title(tstr);
		end
		ylabel(wTags{w}, 'Color', wColors(w,:));
		set(gca,'YTick',[]);
	end

%
% plots a single density plot ...
%
function plotSingleDensityPlot(obj, wColors, wTags, w, ax, idx, showDates, vecUsed, valRange)
	dataVecs = {};
	dLabels = {};
	for s=1:length(obj.whiskingSummary)
		wi = find(strcmp(wTags{w}, obj.whiskingSummary{s}.whiskerTags));
		datArray = eval(['obj.whiskingSummary{s}.' vecUsed]);
		if (showDates) ; dLabels{s} = obj.dateStr{s}(1:6); end
		if (length(wi) > 0 && length(datArray) >= wi && ~isempty(datArray{wi}))
			dataVecs{s} = datArray{wi}{idx};
		else % empty make it show up
		  dataVecs{s} = [];
		end
	end
	plot_density_in_color(dataVecs, valRange, dLabels, ax, 100, [0 0 0 ; wColors(w,:)]');

%
% plots a single touch count
%
function plotSingleTouchCount(obj, idx, fieldUsed)
  wColors = [1 0 0 ; 0 1 0 ; 0 0 1];
	wTags = {'c1','c2','c3'};
	for w=1:length(wTags)
    xVec{w} = nan(1,length(obj.whiskingSummary));
    yVec{w} = nan(1,length(obj.whiskingSummary));

    % loop over whisking 
    for s=1:length(obj.whiskingSummary)
		  wi = find(strcmp(wTags{w}, obj.whiskingSummary{s}.whiskerTags));
			if (length(wi) > 0)
			  datArr = eval(['obj.whiskingSummary{s}.' fieldUsed]);
			  yVec{w}(s) = datArr(wi,idx);
			  xVec{w}(s) = s;
			end
  	end
	end
  
  xLabels = {};
	if (idx == 1)
  	for s=1:length(obj.dateStr)
  	  xLabels{s} = obj.dateStr{s}(1:6);
	  end
	end

	plot_multilines_with_error(xVec,yVec,{},wColors,wTags, xLabels, 1:length(obj.dateStr));
	A = axis;
	axis ([0 length(obj.dateStr)+1 A(3) A(4)]);
	set(gca,'XTick',[]);
  
