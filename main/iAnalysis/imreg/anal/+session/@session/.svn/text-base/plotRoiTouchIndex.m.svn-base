%
% SP Feb 2011
%
% Plots touch scores.  If computeRTIParams is passed, will call computeTouchIndex.
%  Leave it blank ( [] ) to not call computeRTIParams if you want to pass later 
%  vars.
%
%  USAGE:
%
%  s.plotRoiTouchIndex (params, computeRTIParams)
%
%  params: a structure with the following fields:
%    axRef: axes on which to plot [1/whisker].  Note that in the case of 
%           multi-FOV, axRef should be a cell array with one entry per FOV, and
%           each entry containing 1/whisker.
%    colorRange: min and max of color scale ; default is [], meaning min max
%                You can specify 2 values, or pair per whisker.  Specify nothing
%                and it will use min/max ACROSS whiskers.  Specify -1 and it 
%                will use min/max for INDIVIDUAL whiskers.
%    plotMax: if 1, will plot the max across all whiskers too ; default YES
%    showColorbar: if 1, will plot colorbar for each panel; defualt 0.
%    mode: 1 (default) - show continuous whisker score 2: show prefered whisker
%    groupBy: 1 (default) each figure shows a FOV, with each panel being a whisker
%             2: each figure shows a whisker, with each panel being FOV (irrel in mode 2)
%
%  computeRTIParams: parameters for computeRoiTouchIdx -- see that method for
%    deitals.  Leave blank to skip recomputation.
%
function plotRoiTouchIndex (obj, params, computeRTIParams)
  % --- arguments

  % computeRTIParams -- at the very least must define whisker tags(!)
	skipCRTI = 0;
	if (nargin < 3 || ~isstruct(computeRTIParams))
	  whiskerTags = obj.whiskerTag;
		skipCRTI = 1;
	elseif (~isfield(computeRTIParams,'whiskerTags'))
	  computeRTIParams.whiskerTags = obj.whiskerTag;
	else
	  whiskerTags = computeRTIParams.whiskerTags;
	end

	% params? defaults, then process
  colorRange = [];
  plotMax = 1;
	axRef = [];
	showColorbar = 0;
	mode = 1;
	groupBy = 1;
	if (nargin >= 2 && isstruct(params))
	  if(isfield(params, 'axRef')); axRef = params.axRef; end
	  if(isfield(params, 'plotMax')); plotMax = params.plotMax; end
	  if(isfield(params, 'showColorbar')); showColorbar = params.showColorbar; end
	  if(isfield(params, 'colorRange')); colorRange = params.colorRange; end
	  if(isfield(params, 'mode')); mode = params.mode; end
	  if(isfield(params, 'groupBy')); groupBy = params.groupBy; end
	end

  % --- compute roi touch indices
	if (~skipCRTI)
		obj.computeRoiTouchIndex( computeRTIMethod, computeRTIParams);
	end
	touchIndex = obj.cellFeatures.get('touchIndex');

	% axRef?
	if (size(touchIndex,1) == 2*length(obj.whiskerTag))
	  nWhiskerTags = {};
	  for w=1:length(whiskerTags)
	    nWhiskerTags{2*w-1} = ['Protraction contacts for ' whiskerTags{w}];
	    nWhiskerTags{2*w} = ['Retraction contacts for ' whiskerTags{w}];
		end
		whiskerTags = nWhiskerTags;
	end
	if (length(axRef) == 0)
	  if (mode == 1)
		  if (groupBy == 1) % each figure is an FOV
				for f=1:obj.caTSA.numFOVs
					figure('Position', [0 0 800 800]);
					Nw = ceil(sqrt(length(whiskerTags) + plotMax));
					x = 0 ;
					y = Nw-1;
					for w=1:length(whiskerTags);
						axRef{f}(w) = subplot('Position', [x/Nw y/Nw 1/Nw 1/Nw]);
						x = x+1; 
						if (x == Nw) ; x = 0 ; y = y - 1 ; end
					end
					if (plotMax)
						axRef{f}(w+1) = subplot('Position', [x/Nw y/Nw 1/Nw 1/Nw]);
					end
				end
			elseif (groupBy == 2)
			 for w=1:(length(whiskerTags) + plotMax)
					figure('Position', [0 0 800 800]);
					Nf = ceil(sqrt(obj.caTSA.numFOVs));
					x = 0 ;
					y = Nf-1;
				  for f=1:obj.caTSA.numFOVs
						axRef{w}(f) = subplot('Position', [x/Nf y/Nf 1/Nf 1/Nf]);
						if (w > length(whiskerTags)) % plotMax case
							axRef{w+1}(f) = subplot('Position', [x/Nf y/Nf 1/Nf 1/Nf]);
						end
						x = x+1; 
						if (x == Nf) ; x = 0 ; y = y - 1 ; end
					end
				end
			end
		elseif (mode == 2) % just 1 panel / FOV
			figure('Position', [0 0 800 800]);
			Np = ceil(sqrt(obj.caTSA.numFOVs));
			x = 0 ;
			y = Np-1;
			for f=1:obj.caTSA.numFOVs
				axRef{f} = subplot('Position', [x/Np y/Np 1/Np 1/Np]);
				x = x+1; 
				if (x == Np) ; x = 0 ; y = y - 1 ; end
			end
		end
	else
	  if (~iscell(axRef)) ; axRef = {axRef} ; end % wrap it ..
	end

  % color range?
	if (length(colorRange) == 0)
	  colorRange(1) = nanmin(nanmin(touchIndex));
		colorRange(2) = nanmax(nanmax(touchIndex));
	elseif (length(colorRange) == 1 && colorRange == -1)
	  colorRange = zeros(length(whiskerTags)+1,2);
	  for w=1:length(whiskerTags)
		  colorRange(w,:) = [nanmin(touchIndex(w,:)) nanmax(touchIndex(w,:))];
		end
		maxTouch = nanmax(touchIndex);
		colorRange(w+1,:) = [nanmin(maxTouch) nanmax(maxTouch)];
	end

	if (size(colorRange,1) == 1)
	  colorRange = repmat(colorRange, length(whiskerTags)+1, 1);
	end

	% --- plot
	varMaxColor = hsv(length(whiskerTags));
	for f=1:obj.caTSA.numFOVs
	  if (mode == 1)
			for w=1:length(whiskerTags)
			  if (groupBy == 1) ; aRef = axRef{f}(w) ; elseif (groupBy == 2) ; aRef = axRef{w}(f) ;end
				cmap = [linspace(0,varMaxColor(w,1),256)' linspace(0,varMaxColor(w,2),256)' linspace(0,varMaxColor(w,3),256)'];
				
				if (~isnan(aRef))
					obj.plotColorRois('custom', [], [], cmap, touchIndex(w,:), colorRange(w,:), aRef, showColorbar,f);
					axes(aRef);
					A = axis;
					text(A(2)/20, A(4)/20, ['Touch score for ' whiskerTags{w}], 'Color', [1 1 1]);
				end
			end
			if (plotMax)
			  if (groupBy == 1) ; aRef = axRef{f}(w+1) ; elseif (groupBy == 2) ; aRef = axRef{w+1}(f) ;end
				cmap = [linspace(0,1,256)' linspace(0,1,256)' linspace(0,0,256)'];
				if (~isnan(aRef))
					obj.plotColorRois('custom', [], [], cmap, nanmax(touchIndex), colorRange(length(whiskerTags)+1,:), aRef, showColorbar,f);
					axes(aRef);
					A = axis;
					text(A(2)/20, A(4)/20, ['Max touch score across whiskers'], 'Color', [1 1 1]);
				end
			end
		elseif (mode == 2) % preferred whisker
			[MTVal MTIdx] = max(touchIndex);
      valMTI = find(MTVal > 0);
      prefW = 0*MTIdx;
      prefW(valMTI) = MTIdx(valMTI);
      cmap = [0 0 0; hsv(length(whiskerTags))];
        obj.plotColorRois('custom',[],[],cmap,prefW,[0 length(whiskerTags)], axRef{f}, 0, f);
		end
	end

