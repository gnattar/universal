%
% SP Sept 2010
%
% This will plot change in Kappa relative theta-based baseline; basically it
%  is a wrapper for plotKappas.
%
% USAGE: 
%
%  plotDeltaKappas(whiskerIds, axHandle, showContacts)
%
% PARAMS:
%
%  whiskerIds: whiskers plotted -- only 1:numWhiskers
%  axHandle: axis handle ; if none is provided, makes new figure
%  showContacts: if 0, will not; otherwise it will (default 1)
%
function obj = plotDeltaKappas(obj, whiskerIds, axHandle, showContacts)

  % sanity
	if (length(obj.deltaKappas) < 1) 
	  disp('plotDeltaKappas::run computeDeltaKappasWrapper first.');
		return
	end
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
 

  % Offset baseline since we *know* everyone is ~ 0
	dkappas = obj.deltaKappas;
	zoffs = zeros(1,obj.numWhiskers);
	for w=2:obj.numWhiskers
	  lastRange = range(dkappas(:,w-1));
	  thisRange = range(dkappas(:,w));
	  lastMin = min(dkappas(:,w-1));
	  thisMin = min(dkappas(:,w));

    zoffs(w) = lastMin - thisMin - 1.1*thisRange;
%		dkappas(:,w) = dkappas(:,w) - thisMin; % zero it
%		dkappas(:,w) = dkappas(:,w) + lastMin - 1.1*thisRange; % separate
		dkappas(:,w) = dkappas(:,w) + zoffs(w);
	end

	% Now the wrapper for plotKappas ...
	okappas = obj.kappas;
	obj.kappas = dkappas;
	obj.plotKappas(whiskerIds, axHandle, showContacts);
	obj.kappas = okappas;

	% add some things
	if (obj.numWhiskers > 1)
		hold on;
		ylabel('Whisker delta-kappa (1/pixels)');
		for w=1:obj.numWhiskers
			plot([obj.frames(1) obj.frames(end)], zoffs(w)*[1 1], 'k:');
		end
		text (obj.frames(1)+range(obj.frames)*0.1, min(zoffs)+range(zoffs)*0.8, 'Black dotted line is zero for given whisker');
		hold off;
  end

