%
% SP Oct 2010
% 
% Tracks the bar provided a template file which should contain the variables
%  barCenter, barRadius, and barTemlpateIm.  Assigns variables barCenter, 
%  barInReach, barRadius, and barTemplateCorrelation for each frame.  Note that
%  the template image is *not* used.  Instead, a semicircle of the TOP of the bar
%  is used and max(max(barTemplateIm)) is used as surround.
%
% USAGE: 
%
%   wt.trackBar(barTemplatePath)
%
%   barTemplatePath: file from which template, radius, and center of bar are obtained
%
function trackBar(obj, barTemplatePath)
  % default settings
	df = 50; % how many frames are bar measurements taken intially?  later, fills in areas with change
  minCorr = 0.9; % minimal correlation
  maxChangePos = 7; % maximal displacement in terms of pixels per frame


	% load everything
	if (exist(barTemplatePath, 'file') ~= 2)
	  disp(['trackBar::could not find bar template file ' barTemplatePath '; aborting tracking of bar.']);
		return
	else
  	load (barTemplatePath);
	end
% OLD USE OFFSET
%	barCenterOffset = barCenter;

  % preset -- for now, barRadius is fixed
	obj.barCenter = nan*ones(obj.numFrames,2);
	obj.barInReach = zeros(obj.numFrames,1);
	obj.barTemplateCorrelation = nan*ones(obj.numFrames,1);
	obj.barRadius = barRadius*ones(obj.numFrames,1);

	% build the bar template image -- customdisk 
  barTemplateIm = double(max(max(barTemplateIm)))*~customdisk([1 1]*barRadius*3, [1 1]*barRadius, round([.5 .5]*barRadius*3), 0);
  barTemplateIm = barTemplateIm(1:round(barRadius*3/2),:); % only top part

  % --- round 1: coarse
	% go thru every df frames
  if (obj.messageLevel >= 1) ; disp(['trackBar::coarse fit']); end
	if (obj.waitBar) ; wb = waitbar(0, 'Detecting bar ...'); else ; wb = []; end
	frameVec = 1:df:obj.numFrames;
	allFrames = 1:obj.numFrames;
	if (frameVec(length(frameVec)) < obj.numFrames) ; frameVec = [frameVec obj.numFrames]; end
  scores = trackBarCore(obj, barTemplateIm, wb, frameVec) ;

  % --- round 2: refine or interpolate
  d1 = max(diff(obj.barCenter(find(~isnan(obj.barCenter(:,1))),1)));
  d2 = max(diff(obj.barCenter(find(~isnan(obj.barCenter(:,2))),2)));
  if (obj.messageLevel >= 1) ; disp(['trackBar::fine fit']); end
	if (length(obj.barInReachParameterUsed) == 0 | obj.barInReachParameterUsed <= 0 | obj.barInReachParameterUsed > 3)
	  % new default is just set to 3
	  obj.barInReachParameterUsed = 3;

		% OLD logic:
%		bciUsed = 1; 
%		if (d2 > d1) ; bciUsed = 2; end
%		if (d1 < 2 & d2 < 2)  
%		  obj.barInReachParameterUsed = 3;
%		else
%		  obj.barInReachParameterUsed = bciUsed;
%		end
	end
	% 
	if (obj.barInReachParameterUsed == 3) % correlation of image w/ template
	  disp('trackBar::either your bar is PERFECTLY centered or your df value is too low and consequently,');
		disp('  bar center position changes are too small to determine when bar is in range or not.  This');
		disp('  would also hold if your bar did not move at all ... Will attempt to base bar-in-range off of');
		disp('  score - the correlation between template and image.');

		% 1) threshold score -- only retain positions with some minimal correlation (0.9? -- should be passable)
		valScores = find(scores > minCorr);
    if (length(valScores) == 0) 
      minCorr = minCorr - 0.1;
    end
		valScores = find(scores > minCorr);
    if (length(valScores) == 0) 
      minCorr = minCorr - 0.1;
    end
		valScores = find(scores > minCorr);
    if (length(valScores) == 0) 
      disp('trackBar::min corr too low.  Your bar is srewed up.');
    end
    
    
		% determine minCorr by breaking into two peaks in histo
		valueVec = scores(find(~isnan(scores)));
  	[count values] = hist(valueVec,5);
	  [sortedCount idx] = sort(count, 'descend');
	  dPeaks = abs(values(idx(1))-values(idx(2)));
    minCorr = min(values(idx(1:2))) + dPeaks/2;


		% 2) do a 'fine walk' backward from first point (to first frame -- if needed  -- allowing displacement by minimal dp)
		% walk back...
		firstScoreFrame = min(valScores);
		nFrameVec = firstScoreFrame-1:-1:1;
		tscores = trackBarWithDisplacementConstraint(obj, barTemplateIm, wb, nFrameVec, ...
										obj.barCenter(firstScoreFrame,:), maxChangePos) ;
		scores(nFrameVec) = tscores(nFrameVec);

		% 3) do forward fine walks from other points
		scoredFrames = valScores(1:end);
		for f=1:length(scoredFrames)-1
			nFrameVec = scoredFrames(f)+1:scoredFrames(f+1)-1;
	  	tscores = trackBarWithDisplacementConstraint(obj, barTemplateIm, wb, nFrameVec, ...
										obj.barCenter(scoredFrames(f),:), maxChangePos) ;
	  	scores(nFrameVec) = tscores(nFrameVec);
		end
		nFrameVec = scoredFrames(end):obj.numFrames;
		tscores = trackBarWithDisplacementConstraint(obj, barTemplateIm, wb, nFrameVec, ...
										obj.barCenter(scoredFrames(end),:), maxChangePos) ;
  	scores(nFrameVec) = tscores(nFrameVec);
%figure;plot(obj.barCenter);
%pause; close;

	elseif (obj.barInReachParameterUsed == 4) % voltage -- 'gold standard' - just interpolate piecewise hermite
    % now do piecewise cubic hermite interpolation
    valFrames = find(~isnan(obj.barCenter(:,1)));

	  valPos1 = obj.barCenter(valFrames,1);
	  valPos2 = obj.barCenter(valFrames,2);
		invalFrames = setdiff(allFrames,valFrames);
		interpPos1 = interp1(valFrames,valPos1,invalFrames, 'pchip');
		interpPos2 = interp1(valFrames,valPos2,invalFrames, 'pchip');

		obj.barCenter(invalFrames,1) = interpPos1;
		obj.barCenter(invalFrames,2) = interpPos2;

	else % interpolate and also refine calculation for some areas
    bciUsed = obj.barInReachParameterUsed;

    % do explicit measurement in areas of motion
		for F=1:length(frameVec)-1
		  f1 = frameVec(F);
			f2 = frameVec(F+1);
%			if (obj.barCenter(f1,bciUsed) == obj.barCenter(f2,bciUsed)); % same as next? then don't redo
%			  obj.barCenter(f1+1:f2-1,1) = obj.barCenter(f1,1);
%			  obj.barCenter(f1+1:f2-1,2) = obj.barCenter(f1,2);
%			else % redo if different
			if (obj.barCenter(f1,bciUsed) ~= obj.barCenter(f2,bciUsed)); % different than next? then redo bc change
			  nFrameVec = f1+1:f2-1;
        trackBarCore(obj, barTemplateIm, wb, nFrameVec);
      end
		end

    % now do piecewise cubic hermite interpolation
    valFrames = find(~isnan(obj.barCenter(:,1)));

	  valPos1 = obj.barCenter(valFrames,1);
	  valPos2 = obj.barCenter(valFrames,2);
		invalFrames = setdiff(allFrames,valFrames);
		interpPos1 = interp1(valFrames,valPos1,invalFrames, 'pchip');
		interpPos2 = interp1(valFrames,valPos2,invalFrames, 'pchip');

		obj.barCenter(invalFrames,1) = interpPos1;
		obj.barCenter(invalFrames,2) = interpPos2;
	end

  if (obj.messageLevel >= 1) ; disp(['trackBar::finalizign']); end

	% --- apply offset
% OLD: IMAGE
%	barCenterOffset(1) = barCenterOffset(1) - (size(barTemplateIm,2)/2);
%	barCenterOffset(2) = barCenterOffset(2) - (size(barTemplateIm,1)/2);
% NEW : use bar semicircle
  barCenterOffset(1) = 0;%-1*size(barTemplateIm,2)/2;
  barCenterOffset(2) = size(barTemplateIm,1)/2;
	obj.barCenter(:,1) = obj.barCenter(:,1) + barCenterOffset(1);
	obj.barCenter(:,2) = obj.barCenter(:,2) + barCenterOffset(2)-1;

	% --- store score
	obj.barTemplateCorrelation = scores;

	% --- determine barInReach
	obj.computeBarInReach();

	% --- wrapup
%	figure ; plot(obj.frames, obj.barCenter(:,2), 'rx');
	if (obj.waitBar) ; delete(wb) ; end

	% --- clear dependent arrays
	obj.distanceToBarCenter = [];
	obj.whiskerContacts = [];
	obj.whiskerBarContactESA = [];

%
% detector of bar center constrained by maximal displacement 
%  
%  obj: your object
%  barTemplateIm: the template image
%  wb: waitbar handle
%  frameVec: frames for which displacement is computed
%  initPos: [x y] position that is assumed position immediately prior to frameVec(1)
%  maxChangePos: in pixels, what is the maximal displacement allowed per frameVec step
%
% returns scores for the fuck of it
%
function scores = trackBarWithDisplacementConstraint(obj, barTemplateIm, wb, frameVec, initPos, maxChangePos) 
  scores = nan*(1:max(frameVec));
	lastPos = round(initPos);
	tSize = ceil(size(barTemplateIm)/2);
	for f=frameVec
  	if (obj.waitBar) ; waitbar(f/obj.numFrames, wb, 'Detecting bar ...'); end
     
		% pull image
	  obj.loadMovieFrames(f);
		monoIm = obj.whiskerMovieFrames{f}.cdata;

		% compute the image that you will use for correlation based off maxChangePos and size of the template
    rangeY = max(1, lastPos(2)-tSize(1)-maxChangePos):min(size(monoIm,1), lastPos(2)+tSize(1)+maxChangePos);
    rangeX = max(1, lastPos(1)-tSize(2)-maxChangePos):min(size(monoIm,2), lastPos(1)+tSize(2)+maxChangePos);
% edge effects / case where size(monoIm) < size(barTemplateIm)

		% fit it
		nim = normxcorr2(barTemplateIm, monoIm(rangeY,rangeX));

		% grab peak 
		peakVal = max(max(nim));
		scores(f) = peakVal;

		peakIdx = find(nim == peakVal);
		[ypeak, xpeak] = ind2sub(size(nim),peakIdx);

    % determine what this means in terms of position
		fBarCenter(1) = xpeak-(size(nim,2)/2) + mean(rangeX); % x center
		fBarCenter(2) = ypeak-(size(nim,1)/2) + mean(rangeY); % y center

    obj.barCenter(f,:) = fBarCenter;
    lastPos = round(fBarCenter);
	end


%
% will detect bar for specified frames
%
%  obj: your object
%  barTemplateIm: the template image
%  wb: waitbar handle
%  frameVec: frames looped over
%
% scores: in case x/y cannot be used, scores is tried as last ditch effort
%         scores is correlation
%
function scores = trackBarCore(obj, barTemplateIm, wb, frameVec) 
  scores = nan*(1:max(frameVec));
	for f=frameVec
  	if (obj.waitBar) ; waitbar(f/obj.numFrames, wb, 'Detecting bar ...'); end
     
		% pull image
	  obj.loadMovieFrames(f);
		monoIm = obj.whiskerMovieFrames{f}.cdata;


		% fit it
		nim = normxcorr2(barTemplateIm, monoIm);

%	fh = figure; 	imshow(nim); 	title(num2str(f)); 	colormap jet; 	pause; 	close (fh);

		% grab peak
		peakVal = max(max(nim));
		scores(f) = peakVal;

		peakIdx = find(nim == peakVal);
		[ypeak, xpeak] = ind2sub(size(nim),peakIdx);
    
    if (length(xpeak) == 1 & length(ypeak) == 1)
      fBarCenter(1) = xpeak-((size(nim,2) - size(monoIm,2))/2); % x center
      fBarCenter(2) = ypeak-((size(nim,1) - size(monoIm,1))/2); % y center

      obj.barCenter(f,:) = fBarCenter;
    end
	end

