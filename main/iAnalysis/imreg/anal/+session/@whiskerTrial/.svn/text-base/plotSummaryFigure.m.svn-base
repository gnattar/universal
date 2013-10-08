%
%
% This method plots a summary figure for a single trial.
%
% USAGE:
%
%  handles = wt.plotSummaryFigure(figHandle, hide)
%
% ARGUMENTS:
%
%  figHandle: figure to display in ; pass [] for blank
%  hide: if 1, will disable visibility
%
% RETURNS:
%
%  handles: handles ; (1): figure (2): position plot (3): length plot 
%                     (4,5): out,in reach figures, resp
%
% (C) S Peron Oct 2010
%
function handles = plotSummaryFigure(obj, figHandle, hide)

  %% --- setup
  % hide?
  vis = 'on';
  fvis = 'on';
	if (nargin < 3)
	  hide = 0; 
	end

  % passed a figure handle?
  if (nargin > 1 && length(figHandle) > 0)
	  figure(figHandle);
	else
	  if (hide)
      fvis = 'off';
    end
		figHandle = figure('Position',[0 0 600 700], 'Visible',fvis);
	end

	% generate subplots
	sPosPlot = subplot('Position', [0.1 0.7 0.8 0.25],'Visible',vis);
	sLenPlot = subplot('Position', [0.1 0.4 0.8 0.25],'Visible',vis);
	sFfPlot = subplot('Position', [0.05 0.05 0.4 0.3],'Visible',vis);
	sFlPlot = subplot('Position', [0.55 0.05 0.4 0.3],'Visible',vis);

	handles = [figHandle sPosPlot sLenPlot sFfPlot sFlPlot];

  %% -- plot

	% plot trajectory etc.
	obj.plotThetas(1:obj.numWhiskers, sPosPlot);
	axis(sPosPlot,[0 max(obj.frames) -60 60]);
	hold(sPosPlot,'on');

	% circle nans
	for w=1:obj.numWhiskers
	  nanval = find(isnan(obj.thetas(:,w)));
		if (length(nanval) > 0)
		  plot(sPosPlot,obj.frames(nanval), obj.thetas(nanval,w), 'ko','Visible',vis);
		end
	end

	% bar in reach
	bir = find(obj.barInReach);
	plot(sPosPlot,[obj.frames(bir(1)) obj.frames(bir(end))], [-40 -40], 'k-', 'LineWidth', 5,'Visible',vis);
	biri = bir(round(0.1*length(bir)));
	text (obj.frames(biri), -35, 'Bar In Reach', 'Color', 'k','Visible',vis, 'Parent',sPosPlot);

	% length
	whiskerIds = obj.whiskerIds(find(obj.whiskerIds > 0));
	lenMat = zeros(obj.numWhiskers, obj.numFrames);
	for F=1:length(obj.frames)
	  f = obj.frames(F);
	  fpmi = find(obj.positionMatrix(:,1) == f);
		
		for w=1:length(whiskerIds)
		  widx = find(obj.positionMatrix(fpmi,2) == whiskerIds(w));
			if (length(widx) == 1)
				fwpmi = fpmi(widx);
				lenMat(w,F) = obj.lengthVector(fwpmi);
			end
		end
  end
  hold(sLenPlot,'on');
	for w=1:length(whiskerIds)
    plot(sLenPlot,obj.frames, lenMat(w,:), 'Color', obj.whiskerColors(w+1,:), 'LineWidth',2,'Visible',vis);
	end
	ylabel(sLenPlot,'Length (pixels)');

	% length @ which kappa is measured
	klMatrix = zeros(obj.numFrames,obj.numWhiskers); % length values used in parameteric solution
  switch obj.kappaPositionType
    case 1 % just use length @ the position-measuring polynomial intersect, our makeshift mask
		  klMatrix = obj.lengthAtPolyXYIntersect;

	  case 2 % at follicle - so do nothing and leave ZERO!

	  case 3 % at some specified length
      klMatrix(:) = obj.kappaPosition;

		case 4 % some distance from polynomial intersect
		  klMatrix = obj.lengthAtPolyXYIntersect + obj.kappaPosition;

		case 5 % some *fraction* of distance from base
			for f=1:obj.numFrames
	      for w=1:obj.numWhiskers
					L = lengthMatrix(f,w);
					if (L > 0) % sanity check
					  klMatrix(f,w) = obj.kappaPosition*L;
					end
				end
			end

		case 6 % some fraction of length from polynomial intersect XY 
			for f=1:obj.numFrames
	      for w=1:length(whiskerIds)
					L = lengthMatrix(f,w);
		      baseL = obj.lengthAtPolyXYIntersect(f,w);
					if (baseL >= 0 & L > 0) % sanity check
					  klMatrix(f,w) = baseL + obj.kappaPosition*(L-baseL);
					end
				end
			end
	end

	hold(sLenPlot,'on');
	for w=1:length(whiskerIds)
    plot(sLenPlot,obj.frames(bir), klMatrix(bir,w), 'Color', 0.5*obj.whiskerColors(w+1,:),'Visible',vis);
		if (w == 1) ; text(obj.frames(bir(1))-350, klMatrix(bir(1),w)+20, 'kappa len','Visible',vis,'Parent',sLenPlot); end
	end
	a = axis(sLenPlot);
	axis(sLenPlot,[0 max(obj.frames) a(3) a(4)]);


	% plot sample frames
	obj.plotFrame(1,sFfPlot);
	obj.plotFrame(biri,sFlPlot);



