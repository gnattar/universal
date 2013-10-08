function cell_vs_derived(obj, roiId, imDffRange, derId, derImRange)
  % --- arguments
  if (nargin < 3 || length(imDffRange) == 0) ; imDffRange = [0 1] ; end

  % --- presets
  lm_data = '/data/an148378/lm_2011_09_26/';
  printon = 1;
	roiIdx = find(obj.caTSA.ids == roiId);
	derIdx = find(obj.derivedDataTSA.ids == derId);
  if (nargin < 5 || length(derImRange) == 0) ; derImRange = [nanmin(obj.derivedDataTSA.valueMatrix(derIdx,:)) nanmax(obj.derivedDataTSA.valueMatrix(derIdx,:))]; end
	
	outFile = [lm_data 'cell_' num2str(roiId) '_vs_' strrep(obj.derivedDataTSA.idStrs{derIdx},' ','') '.eps'];

	fh = figure ('Position',[0 0 800 800]);
	sp1 = axes('Position',[0.025 0.05 0.45 .9]);
	obj.plotTimeSeriesAsImage(obj.caTSA.dffTimeSeriesArray, ...
														roiIdx, ...
														{obj.whiskerBarInReachES, obj.behavESA.esa{5}}, ...
														[],[],[],[0 10], imDffRange, sp1);

	sp2 = axes('Position',[0.525 0.05 0.45 .9]);
	obj.plotTimeSeriesAsImage(obj.derivedDataTSA, ...
														derIdx, ...
														{obj.whiskerBarInReachES, obj.behavESA.esa{5}}, ...
														[],[],[],[0 10], derImRange, sp2);

  set(gcf, 'PaperPositionMode', 'auto');
	if (printon) ; print(fh, '-depsc2', '-noui', '-r300', outFile); end
	  
	end
