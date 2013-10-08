%
% SP Mar 2010
%
% This will detect contacts, using several possible approaches.
%
%
% USAGE:
%  
%   whiskerContacts = session.whiskerTrial.detectContacts(kappas, dtobar, barInReach, params) 
%
%     whiskerContacts(f,w): contact # for frame f, whisker w ; default is 0 -> NO contact @ this frame.
%                           This will be something like 00011100000002220000300000 and so on, where the
%                           0 means no contact, anything else is that contact #.  Values >0 will 
%                           appear sequentially.
%
%     kappas: kappa value to employ for contact detection (usually delta kappa, i.e., kappa rel baseline)
%             size is (f,w)
%     dtobar: how far from bar center @ every point? ; size (f,w)
%     barInReach: 1 if bar is in reach; 0 if not ; length # frames
%     params: additional parameters
%       barRadius: radius of the bar
%       trialIds: if you are processing multiple trials, you need to pass trial #s 
%       barTransitionDurationFrames: how long for bar to move in (1) and out (2) of reach, in FRAMES.
%       inReachSteps: which steps to do on bar-in-reach epoch? see runDetection in here for steps list.
%       transitionSteps: which steps to do on transition? see runDetection in here for steps list.
%       fillSkipSize: no touch for this many frames between touchign frames get coutned as touch
%       minTouchDuration: in frames, how long a touch has to be to count
%       distanceThreshold: bounds (low & up) in terms of *fraction of bar radius* that counts as touch
%                          for distance to bar; default is [0.95 1.05], used by mode 1
%       dToBarBoundsAllowed: scaling factor in fractions of bar radius that should be a looser version
%                            of distanceThreshold for a preliminary pass at contact detection. [step 3]
% 
function whiskerContacts = detectContacts(kappas, dtobar, barInReach, params)
	%% --- prelims & setup
  
  % input
	if (nargin < 4)
	  help('session.whiskerTrial.detectContacts');
		return;
	end

  % required so break if not!
  barRadius = params.barRadius;
	if (length(barRadius) > 1) % why you weird?
	  barRadius = mode(barRadius);
	end

	% not required
	inReachSteps = [0 1 1];
	transitionSteps = [0 0 1];
	trialIds = ones(1,size(kappas,1));
	barTransitionDurationFrames = [0 0];
	fillSkipSize = 1;
	minTouchDuration = 2; 
	distanceThreshold = [0.95 1.05];
	dToBarBoundsAllowed = [0.6 1.4];
	if(isfield(params,'trialIds')) ; trialIds = params.trialIds; end
	if(isfield(params,'distanceThreshold')) ; distanceThreshold = params.distanceThreshold; end
	if(isfield(params,'dToBarBoundsAllowed')) ; dToBarBoundsAllowed = params.dToBarBoundsAllowed; end
	if(isfield(params,'barTransitionDurationFrames')) ; barTransitionDurationFrames = round(params.barTransitionDurationFrames); end
	if(isfield(params,'transitionSteps')) ; transitionSteps = params.transitionSteps; end
	if(isfield(params,'inReachSteps')) ; inReachSteps = params.inReachSteps; end
	if(isfield(params,'fillSkipSize')) ; fillSkipSize = params.fillSkipSize; end
	if(isfield(params,'minTouchDuration')) ; minTouchDuration = params.minTouchDuration; end

	% some key variables ...
	numFrames = size(kappas,1);
	numWhiskers= size(kappas,2);

  % sanity checks
	if (length(kappas) == 0)
	  disp('detectContacts::must first run computeKappas');
		return;
	end
	if (length(barInReach) == 0)
	  disp('detectContacts::must first run trackBar');
		return;
	end
	if (length(dtobar) == 0)
	  disp('detectContacts::must first run computeDistanceToBarCenter');
		return;
	end

  % set things up: returned matrix, bar-in-reach periods
  whiskerContacts = zeros(numFrames, numWhiskers);
	valWhiskers = ones(1,numWhiskers);
	barPosition = getBarInReachEpochs(barInReach, barTransitionDurationFrames, trialIds);
	barOutReach = find(barPosition == 0);
	barInTransition = find(barPosition == 0.5);
	barInReach = find(barPosition == 1);

  %% --- compute statistics on kappa used for steps 2, 3 - in 
	%      kappa x distanceToBar space, build bounding V's for contact regions
	kappaBounds = zeros(numWhiskers,2);
	modeKappaNoBar = nan*ones(1,numWhiskers);
	sdKappaNoBar = nan*ones(1,numWhiskers);
	estimatedBarRadius = zeros(numWhiskers,2);
  dKappaSlopeRange = 0.01;
  barKappaSlope = (barRadius)/dKappaSlopeRange; % slope to build 'V's for step 2
  dToBarBoundsAllowed = barRadius*dToBarBoundsAllowed; % bounds for box for step 3
  kappaBoundsAllowed = zeros(numWhiskers,2);
	for w=1:numWhiskers
    % verify we have stuff to work with(!) -- @ least 20% valid
		if (length(find(~isnan(kappas(barOutReach,w)))) < 0.2*length(barOutReach) | ...
		    length(find(~isnan(kappas(barInReach,w)))) < 0.2*length(barInReach) | ...
        length(barOutReach) == 0 | length(barInReach) == 0)
			valWhiskers(w) = 0;
		  continue;
		end

	  % kappa statistics
		sdKappaNoBar(w) = abs(1.4826*mad(kappas(barOutReach,w)));

    [count value] = ksdensity(kappas(barOutReach,w));
    [irr idx] = max(count);
		modeKappaNoBar(w) = value(idx);
		kappaBoundsAllowed(w,:) = modeKappaNoBar(w) + [-5 5]*sdKappaNoBar(w);% bounds for box for step 3
 
    % estimate bar center on either side
		estimatedBarRadius(w,:) = [1 1]*barRadius;
		estimateThresh = modeKappaNoBar(w) + [-1 1]*sdKappaNoBar(w);
		estimateIdx = barInReach(find(kappas(barInReach,w) < estimateThresh(1) & ...
		                        dtobar(barInReach,w) > dToBarBoundsAllowed(1) & ...
		                        dtobar(barInReach,w) < dToBarBoundsAllowed(2)));
		if (length(estimateIdx) > 20)
			[count value] = ksdensity(dtobar(estimateIdx,w));
			[irr idx] = max(count);
			tempEstimate = value(idx);
			if (abs(tempEstimate-barRadius) < 0.3*barRadius) ; estimatedBarRadius(w,1) = tempEstimate; end
		end
		estimateIdx = barInReach(find(kappas(barInReach,w) > estimateThresh(2) & ...
		                        dtobar(barInReach,w) > dToBarBoundsAllowed(1) & ...
		                        dtobar(barInReach,w) < dToBarBoundsAllowed(2)));
		if (length(estimateIdx) > 20)
			[count value] = ksdensity(dtobar(estimateIdx,w));
			[irr idx] = max(count);
			tempEstimate = value(idx);
			if (abs(tempEstimate-barRadius) < 0.3*barRadius) ; estimatedBarRadius(w,2) = tempEstimate; end
		end

    % debug plot 
		if (0)  
      debugPlot(kappas, dtobar, w, barInReach, barOutReach, barInTransition, modeKappaNoBar, ...
			          estimatedBarRadius, kappaBoundsAllowed, dToBarBoundsAllowed, barKappaSlope, ...
								whiskerContacts);
			pause;
		end
	end

	% valid whiskers
	valWhiskers = find(valWhiskers);

	% generate detectionStats structure
	detectionStats.distanceThreshold = distanceThreshold;
	detectionStats.estimatedBarRadius = estimatedBarRadius;
	detectionStats.barKappaSlope = barKappaSlope;
	detectionStats.modeKappaNoBar = modeKappaNoBar;
	detectionStats.sdKappaNoBar = sdKappaNoBar;
	detectionStats.kappaBoundsAllowed = kappaBoundsAllowed; 
	detectionStats.dToBarBoundsAllowed = dToBarBoundsAllowed;

  %% --- detection
  
	% do core period (bar in reach FOR SURE)
  whiskerContacts = runDetection (whiskerContacts, valWhiskers, inReachSteps, barInReach, kappas, dtobar, detectionStats);
	
	% do bar transition period
  whiskerContacts = runDetection (whiskerContacts, valWhiskers, transitionSteps, barInTransition, kappas, dtobar, detectionStats);

	%  cleanup: 
  whiskerContacts = session.whiskerTrial.detectContactsCleanupS(whiskerContacts, kappas, fillSkipSize, minTouchDuration);
  
	% replace boolean whiskerContacts with actual #s
	whiskerContacts = number_from_binary(whiskerContacts);

  % last debug
	for w=1:numWhiskers
		if (0)  
      debugPlot(kappas, dtobar, w, barInReach, barOutReach, barInTransition, modeKappaNoBar, ...
			          estimatedBarRadius, kappaBoundsAllowed, dToBarBoundsAllowed, barKappaSlope, ...
								whiskerContacts);
			pause;
		end
	end

%
% Runs contact detection for the specified epoch, using specified modes
%
%  whiskerContacts: the whisker contact matrix ; it gets updated (should be pure binary now)
%  valWhiskers: which whiskers to do?
%  stepFlags: boolean telling which steps to do
%    1: pure distance threshold detector
%    2: X based detector a la Dr Hires
%    3: box for extremal kappas -- more permissive usually than Vs
%  framesDone: 1 implies method applied here
%  kappas, dtobar: kappa and distance to bar matrices
%  detectionStats: statistics used for detection
%	                 estimatedBarRadius
%	                 barKappaSlope
%	                 modeKappaNoBar 
%	                 sdKappaNoBar 
%	                 kappaBoundsAllowed 
%	                 dToBarBoundsAllowed 
%                  distanceThreshold
%
function whiskerContacts = runDetection (whiskerContacts, valWhiskers, stepFlags, framesDone, kappas, dtobar, detectionStats)
  % whisker loop
  for wi=1:length(valWhiskers)
	  w = valWhiskers(wi);
		% 1 === detector based on distance threshold ONLY
		if (stepFlags(1))
			% pull relevant detectionStats
			estimatedBarRadius = detectionStats.estimatedBarRadius;
			distanceThreshold = detectionStats.distanceThreshold;
			modeKappaNoBar = detectionStats.modeKappaNoBar;

			% convert to centeredKappas for ease
			centeredKappas = kappas(:,w)-modeKappaNoBar(w);

			% get thresholds
			negKIdx = find(centeredKappas < 0);
			posKIdx = find(centeredKappas >=0);

			negThresh = -1+0*centeredKappas;
			posThresh = -1+0*centeredKappas;

			negThresh(negKIdx) = distanceThreshold(1)*estimatedBarRadius(w,1);
			negThresh(posKIdx) = distanceThreshold(1)*estimatedBarRadius(w,2);
			posThresh(negKIdx) =  distanceThreshold(2)*estimatedBarRadius(w,1);
			posThresh(posKIdx) =  distanceThreshold(2)*estimatedBarRadius(w,2);

			% find threshold exceeders and tag
			contactIdx = find(dtobar(:,w) < posThresh & dtobar(:,w) > negThresh);
			contactIdx = intersect(contactIdx,framesDone);
			whiskerContacts(contactIdx,w) = 1;
		end

		% 2 === detector based on two sideways Vs
		if (stepFlags(2))
			% pull relevant detectionStats
			estimatedBarRadius = detectionStats.estimatedBarRadius;
			barKappaSlope = detectionStats.barKappaSlope;
			modeKappaNoBar = detectionStats.modeKappaNoBar;

			% convert to centeredKappas for ease
			centeredKappas = kappas(:,w)-modeKappaNoBar(w);

			% at each kappa compute +/- threshold:
			negKIdx = find(centeredKappas < 0);
			posKIdx = find(centeredKappas >=0);

			negThresh = -1+0*centeredKappas;
			posThresh = -1+0*centeredKappas;

			negThresh(negKIdx) = barKappaSlope*(centeredKappas(negKIdx)) + estimatedBarRadius(w,1);
			negThresh(posKIdx) = -1*barKappaSlope*(centeredKappas(posKIdx)) + estimatedBarRadius(w,2);
			posThresh(negKIdx) = -1*barKappaSlope*(centeredKappas(negKIdx)) + estimatedBarRadius(w,1);
			posThresh(posKIdx) = barKappaSlope*(centeredKappas(posKIdx)) + estimatedBarRadius(w,2);

			% find threshold exceeders and tag
			contactIdx = find(dtobar(:,w) < posThresh & dtobar(:,w) > negThresh);
			contactIdx = intersect(contactIdx,framesDone);
			whiskerContacts(contactIdx,w) = 1;
		end

		% 3 === detector based on box
		if (stepFlags(3))
			% pull relevant detectionStats
			kappaBoundsAllowed = detectionStats.kappaBoundsAllowed;
			dToBarBoundsAllowed = detectionStats.dToBarBoundsAllowed;

			% find threshold exceeders "left"
			contactIdx = find(kappas(:,w) < kappaBoundsAllowed(w,1) & ...
			   dtobar(:,w) > dToBarBoundsAllowed(1) & dtobar(:,w) < dToBarBoundsAllowed(2));

			% find threshold exceeders "right"
			contactIdx = union(contactIdx, ...
			  find(kappas(:,w) > kappaBoundsAllowed(w,2) & dtobar(:,w) > dToBarBoundsAllowed(1) & ...
				  dtobar(:,w) < dToBarBoundsAllowed(2)));

			% sendoff 
			contactIdx = intersect(contactIdx,framesDone);
			whiskerContacts(contactIdx,w) = 1;
			
		end
	end


%
% builds time epochs for bar-in-reach -- after this call, 1 is bar-in-reach,
%  0 is out, and 0.5 is in transition
%
function barInReach = getBarInReachEpochs(barInReach, barTransitionDurationFrames, trialIds)
  % trial-by-trial
  ut = unique(trialIds);
	for u=1:length(ut)
	  thisTrial = find(trialIds == ut(u));
    birStart = thisTrial(min(find(barInReach(thisTrial))));
    birEnd = thisTrial(max(find(barInReach(thisTrial))));
		barInReach(max(1,birStart-barTransitionDurationFrames(1)):min(length(barInReach),birEnd+barTransitionDurationFrames(2))) = 0.5;
		barInReach(birStart:birEnd) = 1;
	end


%
% debug plotter
%
function debugPlot(kappas, dtobar, w, barInReach, barOutReach, barInTransition, modeKappaNoBar, ...
			          estimatedBarRadius, kappaBoundsAllowed, dToBarBoundsAllowed, barKappaSlope, ...
								whiskerContacts)
	cla;
	hold on;

  % all points
	plot(kappas(barOutReach,w), dtobar(barOutReach,w),'ko');
	plot(kappas(barInTransition,w), dtobar(barInTransition,w),'mo');
	plot(kappas(barInReach,w), dtobar(barInReach,w),'bo');

  % contacts
	contactIdx = find(whiskerContacts(:,w) > 0);
	plot(kappas(contactIdx,w), dtobar(contactIdx,w),'ro', 'MarkerFaceColor', [1 0 0]);

	% center
	plot(modeKappaNoBar(w), estimatedBarRadius(w,1), 'rx', 'MarkerSize',10, 'LineWidth',3);
	plot(modeKappaNoBar(w), estimatedBarRadius(w,2), 'rx', 'MarkerSize',10, 'LineWidth', 3);

  % for plot niceness
  Mdkappa = max(kappas(:,w));
	mdkappa = min(kappas(:,w));

	% allow boxes 
	plot ([mdkappa+kappaBoundsAllowed(w,1) kappaBoundsAllowed(w,1) kappaBoundsAllowed(w,1) mdkappa+kappaBoundsAllowed(w,1)], ...
				[dToBarBoundsAllowed(1) dToBarBoundsAllowed(1) dToBarBoundsAllowed(2) dToBarBoundsAllowed(2)], ...
				'm-');

	% Vs
	centeredKappas = kappas(:,w)-modeKappaNoBar(w);
	mk = min(centeredKappas);
	Mk = max(centeredKappas);
	mkd = barKappaSlope*[-1 1]*mk + estimatedBarRadius(w,1);
	Mkd = barKappaSlope*[-1 1]*Mk + estimatedBarRadius(w,2);

	plot([mk 0] + modeKappaNoBar(w), [mkd(1) estimatedBarRadius(w,1)], 'b-');
	plot([mk 0] + modeKappaNoBar(w), [mkd(2) estimatedBarRadius(w,1)], 'b-');

	plot([Mk 0] + modeKappaNoBar(w), [Mkd(1) estimatedBarRadius(w,2)], 'b-');
	plot([Mk 0] + modeKappaNoBar(w), [Mkd(2) estimatedBarRadius(w,2)], 'b-');

