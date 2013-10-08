%
% SP Sept 2010
%
% This will plot the tracjectories of the follicle -- end of whisker closest
%  to face.
%
% USAGE: 
%
%  plotPositionTrajectory (whiskerIds, axHandle, plotBadFrames)
%
% PARAMS:
%
%  whiskerIds: whiskers plotted
%  plotBadFrames: if 1, will indicate bad frames
%  axHandle: axis handle ; if none is provided, makes new figure
%
function plotPositionTrajectory(obj, whiskerIds, axHandle, plotBadFrames)

  % sanity
	if (nargin < 2)
	  whiskerIds = 1:obj.numWhiskers;
	end
	if (nargin < 3) 
	  figure;
		axHandle = gca;
	end
  if (nargin < 4)
	  plotBadFrames = 0;
	end
	if (length(axHandle) == 0) ; figure; axHandle = gca; end

  % actual plot
  axes(axHandle);
	hold on;
	legStr={};

	% bad frames
	if (plotBadFrames)
	 % legStr{w} = 'Bad Frames';

    yValm = min(min(obj.positionMatrix(:,3))) - 10;
    yValM = max(max(obj.positionMatrix(:,3))) + 10;
		  
    for f=1:length(obj.badFrames)
		  patch ([obj.badFrames(f)-0.5 obj.badFrames(f)+0.5 obj.badFrames(f)+0.5 obj.badFrames(f)-0.5], ...
			[yValm yValm yValM yValM], [0.5 0.5 0.5], 'EdgeColor', [0.5 0.5 0.5]);
		end
	end

  % frame constraint
  minidx = min(find(obj.positionMatrix(:,1) == min(obj.frames)));
  maxidx = max(find(obj.positionMatrix(:,1) == max(obj.frames)));
	fidx = minidx:maxidx;
	whiskerIds = intersect(whiskerIds,obj.positionMatrix(fidx,2));

 
  % loop over whiskers
	for w=1:length(whiskerIds)
		indices = fidx(find(obj.positionMatrix(fidx,2) == whiskerIds(w)));
		if (length(indices) == 0 | whiskerIds(w) == 0) ; continue ; end % no instances? id 0? f it

    widx = find(obj.whiskerIds == whiskerIds(w));
		if (widx > size(obj.whiskerColors,1))
		  disp('plotPositionTrajectory::whisker ID exceeds color count; make larger whiskerTrial.whiskerColors (displaying black)');
			col = [0 0 0];
		elseif (length(widx) == 1)
			col = obj.whiskerColors(widx,:);
		else
%		  disp(['plotPositionTrajectory::whisker ID ' num2str(whiskerIds(w)) ' not found ; not plotting.']);
		  continue;
		end
		plot( obj.positionMatrix(indices,1), obj.positionMatrix(indices,3), 'Color', col, 'LineWidth', 2);
		plot( obj.positionMatrix(indices,1), obj.positionMatrix(indices,3), '.', 'Color', col);

		if (obj.whiskerIds <= obj.numWhiskers) % pop id # for valids
			text (obj.positionMatrix(round(length(indices/10)),1), 10+obj.positionMatrix(indices(ceil(length(indices)/10)),3), num2str(whiskerIds(w)), 'Color', col);
		end
  end
%legStr
 
  % finish
	A = axis;
	fs = obj.frames(1);
	ff = obj.frames(length(obj.frames));
  yValm = min(min(obj.positionMatrix(:,3))) - 10;
  yValM = max(max(obj.positionMatrix(:,3))) + 10;
	axis([fs ff yValm yValM]);
	xlabel('frame #');
	ylabel('whisker position (pixels)');
	title(strrep(obj.basePathName,'_','-'));
	hold off;

