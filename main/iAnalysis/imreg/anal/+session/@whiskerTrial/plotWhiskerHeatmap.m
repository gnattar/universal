%
% SP Nov 2010
%
% Plots each point based on how many times a whisker visited it, with default
%  colormap hsv.
%
% USAGE:
% 
%   plotWhiskerHeatmap(whiskerIds, frames)
%
%   whiskerIds: the whiskers you want to plot [default: 1:numWhiskers]
%   frames: the frames at which you want to plot [default: obj.frames]
%
function plotWhiskerHeatmap(obj, whiskerIds, frames)
  % --- sanity checks
	if (nargin < 2)
	  whiskerIds = 1:obj.numWhiskers;
	end
	if (nargin < 3)
	  frames = obj.frames;
	end
	if (length(whiskerIds) == 0)
	  whiskerIds = 1:obj.numWhiskers;
	end
	if (max(whiskerIds) > obj.numWhiskers)
	  disp('plotWhiskerHeatmap::only works on 1:obj.numWhiskers IDs');
		return;
	end
	if (size(obj.whiskerPolysX,1) == 0)
	  disp('plotWhiskerHeatmap::you need to first run computeWhiskerPolys');
	end

	% --- build up image
	obj.loadMovieFrames(1);
	imWidth = obj.whiskerMovieFrames{1}.width;
	imHeight = obj.whiskerMovieFrames{1}.height;
	im = zeros(imHeight,imWidth);
	f = figure;

	% --- look frames
	for f=1:length(frames)
		pmi = find(obj.positionMatrix(:,1) == f);
		for wi=1:length(whiskerIds)
	 	  w = whiskerIds(wi);

      % pull length
			wpmi = pmi(find(obj.positionMatrix(pmi,2) == w));
			L = obj.lengthVector(wpmi);
			if (L > 0)
				lenVec = linspace(0,L,300); 

				% pull the relevant data from obj.whiskerPolysX and obj.whiskerPolysY
				i1 = (w-1)*(obj.whiskerPolyDegree+1)+1;
				i2 = i1+obj.whiskerPolyDegree;
				xPoly = obj.whiskerPolysX(f,i1:i2);
				yPoly = obj.whiskerPolysY(f,i1:i2);

				% compute x,y
				X = round(polyval(xPoly,lenVec));
				Y = round(polyval(yPoly,lenVec));
				I = unique(round(Y + (imHeight*(X-1))));
				val = find(I > 0 & I < imWidth*imHeight);
				I = I(val);
				% increment
				im(I) = im(I) + 1;
			end
		end
	end

	% --- wrapup
	im = double(im);
	%im = im/(length(frames)); % normalize to # of frames
	im = im/max(max(im));
	imshow(im);
	colormap jet;
