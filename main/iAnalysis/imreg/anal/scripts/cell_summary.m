function cell_summary(obj, roiId, imDffRange, plotDffRange, plotTouch)
  if (nargin < 3 || length(imDffRange) == 0) ; imDffRange = [0 1] ; end
  if (nargin < 4 || length(plotDffRange) == 0) ; plotDffRange = [-0.25 2] ; end
  if (nargin < 5 ) ; plotTouch = 0; end

  lm_data = '/data/an148378/lm_2011_09_26/';
  printon = 1;
	outFile = [lm_data 'cell_' num2str(roiId) '_summ.png'];
	roiIdx = find(obj.caTSA.ids == roiId);

	fh = figure ('Position',[0 0 800 800]);
	sp1 = axes('Position',[0.025 0.05 0.5 .9]);
	obj.plotTimeSeriesAsImage(obj.caTSA.dffTimeSeriesArray, ...
														roiIdx, ...
														{obj.whiskerBarInReachES, obj.behavESA.esa{5}}, ...
														[],[],[],[0 10], imDffRange, sp1);
  set(sp1,'YTick',[]);

	sp2 = axes('Position', [0.575 0.05 0.4 0.2]);
	sp3 = axes('Position', [0.575 0.3 0.4 0.2]);
	obj.plotTimeSeriesAsLine(obj.caTSA.dffTimeSeriesArray, ...
														roiIdx, ...
														{obj.whiskerBarInReachES, obj.behavESA.esa{5}}, ...
														[],[],[0 10 plotDffRange(1) plotDffRange(2)],  [sp3 sp2]);
	ylabel('dF/F');

	sp4 = axes('Position', [0.6 0.6 0.35 0.35]);
	valVec = 0*obj.caTSA.ids;
	valVec(roiIdx) = 1;
	obj.plotColorRois('', [],[],[],valVec,[0 1],sp4,0,obj.caTSA.roiFOVidx(roiIdx));

  set(gcf, 'PaperPositionMode', 'auto');
	if (printon) ; print(fh, '-dpng', '-noui', '-r300', outFile); end
	
  if (plotTouch)
	  fh = figure;
		ax = axes;
		hold on;
		colors = [1 0 0 ; 0 1 0 ; 0 0 1];
		lab = {'c1','c2','c3'};
		for e=1:length(obj.whiskerBarContactESA)
  		obj.plotEventTriggeredAverage(obj.caTSA.dffTimeSeriesArray,...
	  	  roiIdx, obj.whiskerBarContactESA.esa{e}, 1, [-2 5 plotDffRange(1) plotDffRange(2)], ...
				[nan ax], colors(e,:), [-2 5], ...
				obj.whiskerBarContactESA.getExcludedCellArray(e), [-2 2]);
			text(-1,((range(plotDffRange)/4)*e),lab{e},'Color',colors(e,:));
		end
	  outFile = [lm_data 'cell_' num2str(roiId) '_touch_whisker.png'];
    set(gcf, 'PaperPositionMode', 'auto');
	  if (printon) ; print(fh, '-dpng', '-noui', '-r300', outFile); end

	  fh=figure;
		ax = axes;
		hold on;
		colors = [1 0 0 ; 1 .5 .5 ; 0 1 0 ; .5 1 .5 ;  0 0 1 ; .5 .5 1];
		lab = {'Pc1','Rc1','Pc2','Rc2','Pc3','Rc3'};
		for e=1:length(obj.whiskerBarContactClassifiedESA)
  		obj.plotEventTriggeredAverage(obj.caTSA.dffTimeSeriesArray,...
	  	  roiIdx, obj.whiskerBarContactClassifiedESA.esa{e}, 1, [-2 5 plotDffRange(1) plotDffRange(2)], ...
				[nan ax], colors(e,:), [-2 5]);%, ...
			%	obj.whiskerBarContactClassifiedESA.getExcludedCellArray(e), [-2 2]);
			text(-1,((range(plotDffRange)/8)*e),lab{e},'Color',colors(e,:));
		end
	  outFile = [lm_data 'cell_' num2str(roiId) '_touch_dir.png'];
    set(gcf, 'PaperPositionMode', 'auto');
	  if (printon) ; print(fh, '-dpng', '-noui', '-r300', outFile); end
	end

	end


