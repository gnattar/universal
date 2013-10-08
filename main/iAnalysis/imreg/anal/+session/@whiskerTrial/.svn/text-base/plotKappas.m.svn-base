%
% SP Sept 2010
%
% This will plot the kappas for the whiskers.
%
% USAGE: 
%
%  plotKappas(whiskerIds, axHandle, showContacts)
%
% PARAMS:
%
%  whiskerIds: whiskers plotted -- only 1:numWhiskers
%  axHandle: axis handle ; if none is provided, makes new figure
%  showContacts: if 0, will not; otherwise it will (default 1)
%
function plotKappas(obj, whiskerIds, axHandle, showContacts)

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
  if (nargin < 4)
	  showContacts = 1;
	end
	if (length(axHandle) == 0) ; figure; axHandle = gca; end

  % use median-filtered kappas
	mfKappas = medfilt1(obj.kappas);
	mfKappasRange = range(reshape(mfKappas,[],1));

  % actual plot
  axes(axHandle);
	hold on;
	legStr={};

  % frame constraint
	fidx = obj.frames;
	
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
		plot( fidx, mfKappas(fidx,wi), 'Color', col, 'LineWidth', 2);
		plot( fidx, mfKappas(fidx,wi), '.', 'Color', col);

    % contacts -- red dots
		if (showContacts & length(obj.whiskerContacts) > 0)
		  contactFrames = find(obj.whiskerContacts(:,wi)> 0);
			contactFrames = intersect(fidx,contactFrames);
		  plot( contactFrames, mfKappas(contactFrames,wi), 'o', 'MarkerFaceColor', [1 0 0], 'MarkerSize', 5, 'MarkerEdgeColor', [0 0 0]);
		end

    % label
		if (obj.whiskerIds <= obj.numWhiskers) % pop id # for valids
			text (fidx(round(length(fidx)/10)), .1*mfKappasRange+mfKappas(fidx(ceil(length(fidx)/10)),wi), num2str(whiskerIds(w)), 'Color', col);
		end


  end
%legStr
 
  % finish
	A = axis;
	fs = obj.frames(1);
	ff = obj.frames(length(obj.frames));
  yValm = min(min(mfKappas)) - 0.1*mfKappasRange;
  yValM = max(max(mfKappas)) + 0.1*mfKappasRange;
	axis([fs ff yValm yValM]);
	xlabel('frame #');
	ylabel('whisker kappa (1/pixels)');
	title(strrep(obj.basePathName,'_','-'));
	hold off;

