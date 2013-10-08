%
% SP Sept 2010
%
% Plots length versus position (in matrix) for selected whisker Ids.  Each
%  frame is plotted as a dot.
%
% USAGE: 
%
%  plotLengthVPosition (whiskerIds)
%
% PARAMS:
%
%  whiskerIds: whiskers plotted (blank means 1:numWhiskers)
%
function plotLengthVPosition(obj, whiskerIds)
  % sanity
	if (nargin < 2)
	  whiskerIds = 1:obj.numWhiskers;
	end

  % color setup
	for w=1:length(whiskerIds)
	  colIdx(w) = find(obj.whiskerIds == whiskerIds(w));
	end

  % figure
  figure;
	hold on;

	% trajectories
	for F=1:length(obj.frames)
	  f = obj.frames(F);
	  fpmi = find(obj.positionMatrix(:,1) == f);
		
		for w=1:length(whiskerIds);
		  widx = find(obj.positionMatrix(fpmi,2) == whiskerIds(w));
			if (length(widx) == 1)
				fwpmi = fpmi(widx);

        % plotted variables
				wLen = obj.lengthVector(fwpmi);
				wPos = obj.positionMatrix(fwpmi,3);

				if (~isnan(wPos))
					col = obj.whiskerColors(colIdx(w),:);
					plot(wLen, wPos, '.', 'Color', col);
				end
			end
		end
  end
 
	xlabel('whisker length (pixels)');
	ylabel('whisker position (pixels)');
	hold off;
