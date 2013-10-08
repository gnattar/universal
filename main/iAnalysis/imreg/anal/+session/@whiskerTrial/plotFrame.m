%
% SP Aug 2010
% 
% Plots the specified frame(s) of whisker data.  If frameIdx is a vector, plots
%  movie with dt = 0.05.
%
% USAGE: plotFrame(obj, frameIdx, axHandle, plotOpts)
%
% frameIdx: frame to plot
% axHandle: axis object to plot in; blank -> make new figure
% plotOpts: dt: default 0.05 ; dt if viewing movies.
%           plotRejects: default is 0 ; if 1, will plot rejected whiskers (id 0) black
%           plotPoly: if 1, plots the polynomial along face
%           plotWhisker: if 1, it will plot (if available) the whisker fitted polynomial;
%                        0 no whisker, and 2 raw whisker track (obj.whiskerData.whisker.x/y)
%           whiskerWidth: by default, width is 5 ; you may want to use obj.dilationSize/2
%           bareBones: if 1, will not plot anything except movie image
%
function plotFrame(obj, frameIdx, axHandle, plotOpts)
  % --- process input
	dt = 0.05;
	plotRejects = 0;
	plotPoly = 1;
	plotWhisker = 1;
	whiskerWidth = 5;
	bareBones = 0;
%	whiskerWidth = round(obj.dilationSize/2);
  
	% figure panel if needbe
	if (nargin < 3) 
	  figure;
		axHandle = gca;
	elseif (length(axHandle) == 0)
	  figure;
		axHandle = gca;
	end

  % plot options?
	if (nargin > 3 & isstruct(plotOpts))
    if (isfield(plotOpts, 'dt'))
      dt = plotOpts.dt;
		end
    if (isfield(plotOpts, 'plotRejects'))
      plotRejects = plotOpts.plotRejects;
		end
    if (isfield(plotOpts, 'plotWhisker'))
      plotWhisker = plotOpts.plotWhisker;
		end
    if (isfield(plotOpts, 'plotPoly'))
      plotPoly = plotOpts.plotPoly;
		end
    if (isfield(plotOpts, 'whiskerWidth'))
      whiskerWidth = plotOpts.whiskerWidth;
		end
		if (isfield(plotOpts, 'bareBones'))
		  bareBones = plotOpts.bareBones;
		end
	end

	% plot polynomial -- compute it 
	polyX = [];
	polyY = [];
	if (plotPoly & length(obj.polynomial) > 0)
		obj.loadMovieFrames(1);
		imWidth = obj.whiskerMovieFrames{1}.width;
		polyX = 0:0.1:imWidth;
		polyY = polyval(obj.polynomial,polyX);
	end

	% frame loop
	numberLabel = 0;
	if (length(frameIdx) == 1) ; numberLabel = 1; end
  for f=1:length(frameIdx)
	  plotSingleFrame(obj, frameIdx(f), plotRejects, [polyX ; polyY], whiskerWidth, numberLabel, bareBones, plotWhisker, axHandle);
		if (length(frameIdx) > f) ; pause(dt) ; end
	end
%
% Single frame of index frameIdx is plotted.  
%   plotRejects: set to 1 to plot rejects in black ; otherwise don't plot
%   numberLabel: label?
%   bareBones: label NOTHING
%
function plotSingleFrame(obj, frameIdx, plotRejects, whiskerArcPath, whiskerWidth, numberLabel, bareBones, plotWhisker, axHandle)
  % background image from mp4
	obj.loadMovieFrames(frameIdx);
	hold (axHandle,'off');
% vis = get(axHandle,'Visible')
  vis = 'on';
	imshow(obj.whiskerMovieFrames{frameIdx}.cdata, 'Parent',axHandle);
	if (bareBones) ; return ; end

  % whiskers
  obj.enableWhiskerData();
	hold (axHandle,'on');

	% get index based on positionMAtrix
 % widx = pmi-startIdx+1;
  pmiStartIdx = min(find(obj.positionMatrix(:,1) == frameIdx));
	wi = obj.positionMatrix(find (obj.positionMatrix(:,1) == frameIdx),2);
	idx = 1:length(wi);

  if (plotWhisker > 0)
		for w=1:length(wi)
			widx = find(obj.whiskerIds == wi(w));
			% assign color: whisker idx < 1: black ; > ncolors: white ; otherwise, color
			reject = 0;
			if (wi(w)  == 0)   % reject whisker (id 0)
				col = [0 0 0 ]; 
				reject = 1;
			elseif (widx > size(obj.whiskerColors,1)) % out of bounds ...
				col = [1 1 1];  
			else  % regular
				col = obj.whiskerColors(widx,:); 
			end

			% actual plotting 
			if (~reject | plotRejects)
			  if (plotWhisker == 1)
				  wX = obj.whiskerData(frameIdx).whisker(idx(w)).x;
					wY = obj.whiskerData(frameIdx).whisker(idx(w)).y;
				elseif (plotWhisker == 2 & ~reject) % only works on non-rejects!
        	wpmi = find (obj.positionMatrix(:,1) == frameIdx & obj.positionMatrix(:,2) == wi(w));
					wL = obj.lengthVector(wpmi);
					if (wL > 0)
						lenVec = linspace(0,wL,100); 

						% pull the relevant data from obj.whiskerPolysX and obj.whiskerPolysY
						i1 = (wi(w)-1)*(obj.whiskerPolyDegree+1)+1;
						i2 = i1+obj.whiskerPolyDegree;
						xPoly = obj.whiskerPolysX(frameIdx,i1:i2);
						yPoly = obj.whiskerPolysY(frameIdx,i1:i2);

						% compute x,y
						wX = polyval(xPoly,lenVec);
						wY = polyval(yPoly,lenVec);
					end
							
				end
  			plot(axHandle,wX, wY, 'Color', col, 'LineWidth', whiskerWidth, 'Visible',vis);

				% now plot the label for contact // label
				if (wi(w) > 0 & numberLabel)
					L = round(length(wX)/2);
					x= (wX(L)); 
					y = (wY(L));
					fc = [1 1 1];
					if (length(obj.whiskerContacts) > 0 & size(obj.whiskerContacts,2) >= wi(w))
						if (obj.whiskerContacts(frameIdx,wi(w)) > 0)
							fc = [1 0 0];
						end
					end
					plot(axHandle,x+3, y, 'ko', 'MarkerSize', 15, 'LineWidth', 2,  ...
            'MarkerFaceColor', fc, 'MarkerEdgeColor', col,'Visible',vis);
					
					if (length(obj.whiskerTag) < wi(w))
						text(x, y, num2str(wi(w)), 'Color', [0 0 0],'Parent',axHandle,'Visible',vis);
					else
						text(x, y, obj.whiskerTag{wi(w)}, 'Color', [0 0 0],'Parent',axHandle,'Visible',vis);
					end
				end

			end
		end
  end

	% polynomial?
  if (length(whiskerArcPath) > 0)
	  plot (axHandle,whiskerArcPath(1,:), whiskerArcPath(2,:), 'b-','Visible',vis);
	end

	% bar?
	if (length(obj.barCenter) > 0)
	  if (size(obj.barCenter,1) >= frameIdx)
		  barCol = [0 0 1];
			barCenter = obj.barCenter(frameIdx,:);
			[barInReach barCenterAtFirstContact] = obj.getFractionCorrectedBarInReach();
			if (barInReach(frameIdx)) ; barCol = [1 0 0 ]; if (~isnan(barCenterAtFirstContact)) ; barCenter = barCenterAtFirstContact;end;end
			plot (axHandle,barCenter(1), barCenter(2), 'rx','Visible',vis);
			rectangle('Position', [barCenter(1)-obj.barRadius(frameIdx) barCenter(2)-obj.barRadius(frameIdx) ...
			  2*obj.barRadius(frameIdx) 2*obj.barRadius(frameIdx)], 'Curvature', [1 1], 'EdgeColor',  barCol, ...
        'LineWidth', 2, 'Parent', axHandle, 'Visible',vis);
	  end
	end

	title(axHandle,['Frame ' num2str(frameIdx)]);


  
