%
% SP Nov 2010
%
% Plots net whisker trajectory - coloring all squares where whisker was present -
%  for all whiskers requested, using *whisker polynomials* for speed.
%
% USAGE:
% 
%   plotNetWhiskerTrajectory(whiskerIds, frames)
%
%   whiskerIds: the whiskers you want to plot [default: 1:numWhiskers]
%   frames: the frames at which you want to plot [default: obj.frames]
%
function plotNetWhiskerTrajectory(obj, whiskerIds, frames)
  % --- sanity checks
	if (nargin < 2)
	  whiskerIds = 1:obj.numWhiskers;
	end
	if (nargin < 3)
	  frames = obj.frames;
	end
	if (max(whiskerIds) > obj.numWhiskers)
	  disp('plotNetWhiskerTrajectory::only works on 1:obj.numWhiskers IDs');
		return;
	end
	if (size(obj.whiskerPolysX,1) == 0)
	  disp('plotNetWhiskerTrajectory::you need to first run computeWhiskerPolys');
	end

	% --- build up image
	obj.loadMovieFrames(1);
	imWidth = obj.whiskerMovieFrames{1}.width;
	imHeight = obj.whiskerMovieFrames{1}.height;
	f = figure;
	axis([0 imWidth 0 imHeight]);
  hold on;

	% --- look frames
	for f=1:length(frames)
		pmi = find(obj.positionMatrix(:,1) == f);
		for wi=1:length(whiskerIds)
	 	  w = whiskerIds(wi);

      % pull length
			wpmi = pmi(find(obj.positionMatrix(pmi,2) == w));
			L = obj.lengthVector(wpmi);
			if (L > 0)
				lenVec = linspace(0,L,100); 

				% pull the relevant data from obj.whiskerPolysX and obj.whiskerPolysY
				i1 = (w-1)*(obj.whiskerPolyDegree+1)+1;
				i2 = i1+obj.whiskerPolyDegree;
				xPoly = obj.whiskerPolysX(f,i1:i2);
				yPoly = obj.whiskerPolysY(f,i1:i2);

				% compute x,y
				X = polyval(xPoly,lenVec);
				Y = polyval(yPoly,lenVec);

				% plot
				widx = find(obj.whiskerIds == w);
				col = obj.whiskerColors(widx,:);
				plot(X,Y,'color', col);
			end
		end
	end

	% --- wrapup
	set(gca,'XTick',[]);
	set(gca,'YTick',[]);
	set(gca,'YDir','reverse'); % match image
