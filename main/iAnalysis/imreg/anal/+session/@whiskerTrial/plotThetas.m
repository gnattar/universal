%
% SP Sept 2010
%
% This will plot the kappas for the whiskers.
%
% USAGE: 
%
%  plotThetas(whiskerIds, axHandle)
%
% PARAMS:
%
%  whiskerIds: whiskers plotted -- only 1:numWhiskers
%  axHandle: axis handle ; if none is provided, makes new figure
%
function plotThetas(obj, whiskerIds, axHandle)

  % sanity
	if (nargin < 2)
	  whiskerIds = 1:obj.numWhiskers;
	else
	  whiskerIds = whiskerIds(find(whiskerIds <= obj.numWhiskers));
	end
	if (nargin < 3) 
	  figure;
		axHandle = gca;
	end
	if (length(axHandle) == 0) ; figure; axHandle = gca; end

  % actual plot
 % axes(axHandle, 'Visible',vis);
  vis = get(axHandle,'Visible');
	hold (axHandle,'on');
	legStr={};

  % frame constraint
	fidx = obj.frames;
	
  % range
	thetasRange = range(reshape(obj.thetas,[],1));

  % loop over whiskers
	for w=1:length(whiskerIds)
    widx = find(obj.whiskerIds == whiskerIds(w));
		wi = whiskerIds(w);
		if (widx > length(obj.whiskerColors))
		  disp('plotPositionTrajectory::whisker ID exceeds color count; make larger whiskerTrial.whiskerColors (displaying black)');
			col = [0 0 0];
		elseif (length(widx) == 1)
			col = obj.whiskerColors(widx,:);
		else
		  continue;
		end

		% plot
		plot(axHandle, fidx, obj.thetas(fidx,wi), 'Color', col, 'LineWidth', 2, 'Visible',vis);
		plot(axHandle, fidx, obj.thetas(fidx,wi), '.', 'Color', col, 'Visible',vis);

    % label
		if (obj.whiskerIds <= obj.numWhiskers) % pop id # for valids
			text (fidx(round(length(fidx)/10)), .1*thetasRange+obj.thetas(fidx(ceil(length(fidx)/10)),wi), ...
         num2str(whiskerIds(w)), 'Color', col,'Visible',vis, 'Parent',axHandle);
		end


  end
%legStr
 
  % finish
	A = axis(axHandle);
	fs = obj.frames(1);
	ff = obj.frames(length(obj.frames));
  yValm = min(min(obj.thetas)) - 0.1*thetasRange;
  yValM = max(max(obj.thetas)) + 0.1*thetasRange;
	axis(axHandle, [fs ff yValm yValM]);
	xlabel(axHandle, 'frame #');
	ylabel(axHandle, 'whisker theta (degrees)');
	title(axHandle,strrep(obj.basePathName,'_','-'));
	hold(axHandle, 'off');

