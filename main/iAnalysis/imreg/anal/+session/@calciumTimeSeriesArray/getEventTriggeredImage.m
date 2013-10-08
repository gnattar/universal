%
% SP May 2011
%
% Returns a "dF/F" image of frames around an event specified by an eventSeries.
%   Specifically, (R-B)/B where R is response and B is baseline (B can be blank).  
%   The core is implemented by session.timeSeries.getIndexWindowsAroundEventsS.
%   IF multiple fields-of-view, it will return either specified or all FOVs.
%
% USAGE:
%
%   etim = caTSA.getEventTriggeredImage(iES, responseTimeWindow, fov,...
%                                       baselineTimeWindowOrImage, allowOverlap, ...
%                                       xES, xTimeWindow)
%
% PARAMS:
%    
%   etim: the image (or cell array of images if fov is vector)
%   
%   iES: included eventSeries ; cell array if multiple
%   responseTimeWindow: In seconds.  0 is time of event, and so [0 2] would mean 
%                       that response, R, is average of frames between event and
%                       2 seconds after.
%   fov: indices of FOV's to use; if blank, all are used
%   baselineTimeWindowOrImage: If a 2 element vector, again, in seconds, and
%                              dictates where to compute baseline.  That is,
%                              [-2 -1] would mean frames 2 to 1 second before 
%                              event are considered as "B".  You can also pass 
%                              image directly.
%   allowOverlap: if 1, iES events can stagger; of not, no.  Default is 0.
%   xES: excluded event series, if passed.
%   xTimeWindow: exclusion time window for excluded event series, in seconds.
%
function etim = getEventTriggeredImage(obj, iES, responseTimeWindow, fov, baselineTimeWindowOrImage, ...
                                       allowOverlap, xES, xTimeWindow)

  % --- parse inputs

  % defaults
	baselineTimeWindow = [];


	if (nargin < 3) 
	  help('session.calciumTimeSeriesArray.getEventTriggeredImage');
		disp('getEventTriggeredImage::Must at least specify iES, resposneTimeWindow.');
		return;
	end

	if (nargin < 4 || length(fov) == 0)
	  fov = 1:obj.numFOVs;
	end

  baselineImage = [];
	if (nargin >= 5)
	  if (prod(size(baselineTimeWindowOrImage)) == 2)
		  baselineTimeWindow = baselineTimeWindowOrImage;
    else
		  baselineImage =  baselineTimeWindowOrImage;
		end
	end

	if (nargin < 6 || length(allowOverlap) == 0) ; allowOverlap = 0 ; end
	if (nargin < 7 || length(xES) == 0) ; xES = {} ; end
	if (nargin < 8 || length(xTimeWindow) == 0) ; xTimeWindow = [] ; end


	% --- get times

  % conver iES to a vector of times ...
	includeEventTimes = [];
	ieTimeUnit = 1;
	if (~iscell(iES)) ; iES = {iES} ; end
	for i=1:length(iES)
		% in case it be type 2
		st = iES{i}.getStartTimes();
		includeEventTimes = union(includeEventTimes, st);
		ieTimeUnit = iES{i}.timeUnit;
	end

	% xES?
	excludeEventTimes = [];
	eeTimeUnit = 1;
	if (~iscell(xES)) ; xES = {xES} ; end
  for x=1:length(xES)
		% in case it be type 2
		st = xES{x}.getStartTimes();
		excludeEventTimes = union(excludeEventTimes, st);
		eeTimeUnit = xES{x}.timeUnit;
	end

	% call to getIndexWindowsAroundEventsS
  [rIdxMat rTimeMat rTimeVec rIeIdxVec] = session.timeSeries.getIndexWindowsAroundEventsS( ...
	    obj.time, obj.timeUnit, responseTimeWindow, 2, ...
		  includeEventTimes, ieTimeUnit, xTimeWindow, excludeEventTimes, eeTimeUnit, allowOverlap) ;
  rIdxMat = reshape(rIdxMat,[],1);
	rIdxMat = rIdxMat(find(~isnan(rIdxMat)));
	responseFrameIdxVec = sort(unique(rIdxMat));

	if (length(baselineTimeWindow) == 2)
		[bIdxMat bTimeMat bTimeVec bIeIdxVec] = session.timeSeries.getIndexWindowsAroundEventsS( ...
				obj.time, obj.timeUnit, baselineTimeWindow, 2, ...
				includeEventTimes, ieTimeUnit, xTimeWindow, excludeEventTimes, eeTimeUnit, allowOverlap) ;
		bIdxMat = reshape(bIdxMat,[],1);
		bIdxMat = bIdxMat(find(~isnan(bIdxMat)));
		baselineFrameIdxVec = sort(unique(bIdxMat));
  end
 
  % --- build image(s)
  for f=1:length(fov)
		% pull images
		responseImage = obj.getRawImageFrames(responseFrameIdxVec, fov(f));
		if (length(baselineFrameIdxVec) > 0)
			baselineImage = obj.getRawImageFrames(baselineFrameIdxVec, fov(f));
		end

		% final image
		if (prod(size(baselineImage)) > 0)
	%	  finalImage = nanmean(responseImage,3)-nanmean(baselineImage,3);
			finalImage = (nanmean(responseImage,3)-nanmean(baselineImage,3))./nanmean(baselineImage,3);
			nidx = find(isnan(finalImage));
			finalImage(nidx) = 0;
		else
			finalImage = nanmean(responseImage,3);
		end
		etim{f} = finalImage;
	end
	if (length(fov) == 1) ; etim = etim{1}; end


