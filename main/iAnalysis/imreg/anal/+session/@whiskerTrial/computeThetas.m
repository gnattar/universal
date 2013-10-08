%
% SP Oct 2010
%
% This will compute theta for each whisker at each time point.  You must first
%  call computeWhiskerPolys to populate the polyfits.  Populates whiskerThetas.
%  Only works on 1:obj.numWhiskers whiskers.
%
% theta = -atand(x'(l)/y'(l)) -- angle of the whisker
%
% USAGE:
%  
%   wt.computeThetas (positionType, position)
%
%   positionType: 1 - compute at intersect of positional polynomial used for 
%                     position tracking (see updatePolynomialIntersectXY).
%                 2 - at follicle 
%                 3 - at some specified length (must then give position)
%                     from follicle
%                 4 - at some specified length from polynomialIntersectXY
%                 5 - at some specified *fraction* [0,1] of length, from foll.
%                 6 - at some specified *fraction* [0,1] of distance from 
%                     polynomialIntersectXY. NOTE that 0 is
%                     polynomialIntersectXY and 1 is the total length.
%
%                 If this parameter is left blank, thetaPositionType and
%                   thetaPosition, having same meaning as positionType and
%                   positino, are used instead
%
%   position: if mode 3-6, the length or length fraction to measure @
%
function computeThetas (obj, positionType, position)
  % --- sanity checks
  if (obj.messageLevel >= 1) ; disp(['computeThetas::processing ' obj.basePathName]); end
	if (length(obj.whiskerPolysX) == 0)
	  disp('computeThetas: must first run computeWhiskerPolys');
		return;
	end
	if (nargin < 2) % assign object-wide value
	  positionType = obj.thetaPositionType;
	  position = obj.thetaPosition;
	end
	if (length(positionType) == 0)
	  disp('computeThetas: must specify valid positionType.');  return;
	end
	if (positionType > 2 & length(position) == 0)
	  disp('computeThetas: must specify valid position.');  return;
	end

  % --- set things up
 lengthMatrix = nan*zeros(obj.numFrames,obj.numWhiskers); % length values used in parameteric solution
	for w=1:obj.numWhiskers
	  vi = find(obj.positionMatrix(:,2) == w);
		lengthMatrix(obj.positionMatrix(vi,1),w) = obj.lengthVector(vi);
	end

	% --- Make call to static method
  obj.thetas = session.whiskerTrial.computeThetasS(obj.numFrames, obj.numWhiskers, positionType, position, ...
                         obj.lengthAtPolyXYIntersect, lengthMatrix, obj.whiskerPolyDegree, ...
												 obj.whiskerPolysX, obj.whiskerPolysY);

	% --- populate whiskerAngleTSA
	for w=1:obj.numWhiskers
	  TSs{w} = session.timeSeries(obj.frameTimes, obj.frameTimeUnit, obj.thetas(:,w), w, ...
		  ['Angle for ' num2str(w)], 0, obj.matFilePath);
	end
	trialIndices = ones(1,length(obj.frameTimes))*obj.trialId;
  obj.whiskerAngleTSA = session.timeSeriesArray(TSs, trialIndices);

	% --- clear dependent arrays
	obj.whiskerContacts = [];
	obj.deltaKappas = [];
	obj.whiskerBarContactESA = [];
	obj.distanceToBarCenter = [];
