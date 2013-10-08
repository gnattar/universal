%
% SP Sept 2010
%
% This will plot the kappas vs. distance of closest point to bar center 
%  for the whiskers.
%
% USAGE: 
%
%  plotKappasVBarDistance(whiskerIds,frames,  axHandle, showContacts)
%
% PARAMS:
%
%  whiskerIds: whiskers plotted -- only 1:numWhiskers
%  frames: which frames to plot for
%  axHandle: axis handle ; if none is provided, makes new figure
%  showContacts: if 0, will not; otherwise it will (default 1)
%
function plotKappasVBarDistance(obj, whiskerIds, frames, axHandle, showContacts)

  % sanity
	if (nargin < 2)
	  whiskerIds = 1:obj.numWhiskers;
	else
	  whiskerIds = whiskerIds(find(whiskerIds <= obj.numWhiskers));
	end
	if (nargin < 3)
	  frames = obj.frames;
	end
	if (nargin < 4) 
	  figure;
		axHandle = gca;
	end
  if (nargin < 5)
	  showContacts = 1;
	end
	if (length(axHandle) == 0) ; figure; axHandle = gca; end

  % use median-filtered kappas
	mfKappas = medfilt1(obj.kappas);
%	mfKappas = obj.kappas;
	mfKappasRange = range(reshape(mfKappas,[],1));
	distancesRange = range(reshape(obj.distanceToBarCenter,[],1));

  % actual plot
  axes(axHandle);
	hold on;
	legStr={};

  % frame constraint
	fidx = frames;

	% bar stuff for  curvature v kappa statistics
	[barInReach irr] = obj.getFractionCorrectedBarInReach();
	
  % loop over whiskers
	for w=1:length(whiskerIds)
    widx = find(obj.whiskerIds == whiskerIds(w));
    wi = whiskerIds(w);
		if (widx > length(obj.whiskerColors))
		  disp('plotKappaVBarDistance::whisker ID exceeds color count; make larger whiskerTrial.whiskerColors (displaying black)');
			col = [0 0 0];
		elseif (length(widx) == 1)
			col = obj.whiskerColors(widx,:);
		else
		  continue;
		end

		% plot
		plot( mfKappas(fidx,wi), obj.distanceToBarCenter(fidx,wi), '.', 'Color', col);

    % contacts -- red dots
		if (showContacts & length(obj.whiskerContacts) > 0)
		  contactFrames = find(obj.whiskerContacts(:,wi)> 0);
			contactFrames = intersect(fidx,contactFrames);
		  plot( mfKappas(contactFrames,wi), obj.distanceToBarCenter(contactFrames,wi), 'o', ...
			  'MarkerFaceColor', [1 0 0], 'MarkerSize', 5, 'MarkerEdgeColor', [0 0 0]);
		end

		% kappa and kappa range
		if (sum(diff(obj.barRadius)) == 0)
			br = obj.barRadius(1);

			% bar in/out of reach -- pad with 50
			firstInReach = min(find(obj.barInReach));
			lastInReach = max(find(obj.barInReach));
			barInReachLib = intersect(1:obj.numFrames,(firstInReach-50):(lastInReach+50));
			noBarInReachLib = setdiff(1:obj.numFrames,barInReachLib);
			nbidx = noBarInReachLib(find(obj.distanceToBarCenter(noBarInReachLib,wi) < 2*br));
			if (length(nbidx) < 100)
				nbidx = noBarInReachLib(find(obj.distanceToBarCenter(noBarInReachLib,wi) < 3*br));
			end

			% central kappa among out-of-reach but close-to-bar points
			if (length(nbidx) > 0)
				cenKappa = nanmedian(mfKappas(nbidx,wi));
				kappaRange = range(mfKappas(nbidx,wi));
				maxKappa = max(mfKappas(nbidx,wi))+0.2*kappaRange;
				minKappa = min(mfKappas(nbidx,wi))-0.2*kappaRange;
				
				% plots
				plot(cenKappa, br, 'x', 'Color', [1 1 1]-col, 'MarkerSize', 10, 'LineWidth', 3);
				plot([1 1]*minKappa, [0 br*2], '-', 'Color', [1 1 1]-col, 'LineWidth', 3);
				plot([1 1]*maxKappa, [0 br*2], '-', 'Color', [1 1 1]-col, 'LineWidth', 3);
			end
		end

    % label
		if (obj.whiskerIds <= obj.numWhiskers) % pop id # for valids
			text (.1*mfKappasRange+mfKappas(fidx(ceil(length(fidx)/10)),wi), ...
			      .1*distancesRange+obj.distanceToBarCenter(fidx(ceil(length(fidx)/10)),wi), ...
			      num2str(whiskerIds(w)), 'Color', col);
		end
  end

  % finish
	A = axis;
  xValm = min(min(mfKappas)) - 0.1*mfKappasRange;
  xValM = max(max(mfKappas)) + 0.1*mfKappasRange;
  yValm = min(min(obj.distanceToBarCenter)) - 0.1*distancesRange;
  yValM = max(max(obj.distanceToBarCenter)) + 0.1*distancesRange;
	axis([xValm xValM yValm yValM]);
	ylabel('distance to bar center (pixels)');
	xlabel('whisker kappa (1/pixels)');
	title(strrep(obj.basePathName,'_','-'));
	if (range(obj.barRadius) == 0)
	  plot([xValm xValM], [1 1]*obj.barRadius(1), 'k:');
	end
	hold off;

