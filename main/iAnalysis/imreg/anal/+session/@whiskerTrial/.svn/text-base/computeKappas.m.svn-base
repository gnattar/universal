%
% Wrapper for computeKappasS, allowing curvature calculation for single trial.
% 
% This will compute kappa for each whisker at each time point.  You must first
%  call computeWhiskerPolys to populate the polyfits.  Populates whiskerKappas.
%  Only works on 1:obj.numWhiskers whiskers.
%
% kappa = (x'y'' - y'x'')/(x'^2 + y'^2)^(3/2) - the CURVATURE of the whisker.
%
% USAGE:
%  
%   wt.computeKappas (positionType, position, parabolaHalfLength)
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
%                 If this parameter is left blank, kappaPositionType and
%                   kappaPosition, having same meaning as positionType and
%                   positino, are used instead
%
%   position: if mode 3-6, the length or length fraction to measure @
%   parabolaHalfLength: if specified, it will take this many PIXELS fo length
%                    ABOVE AND BELOW the position to fit a new parabola and
%                    compute curvature thereof at the midpoint
%
% (C) S Peron Oct 2010
%
function computeKappas (obj, positionType, position, parabolaHalfLength)
  % --- sanity checks
	if (length(obj.whiskerPolysX) == 0)
	  disp('computeKappas: must first run computeWhiskerPolys');
		return;
	end
	if (nargin < 4 ) % blank parabolaHalfLength
	  parabolaHalfLength = [];
  end
	if (nargin < 2) % assign object-wide value
	  positionType = obj.kappaPositionType;
	  position = obj.kappaPosition;
	  parabolaHalfLength = obj.kappaParabolaHalfLength;
	end
	if (length(positionType) == 0)
		  disp('computeKappas: must specify valid positionType.');  return;
	end
	if (positionType > 2 & length(position) == 0)
	  disp('computeKappas: must specify valid position.');  return;
	end
  if (obj.messageLevel >= 1) ; disp(['computeKappas::processing ' obj.basePathName]); end

  % --- set things up
  lengthMatrix = nan*zeros(obj.numFrames,obj.numWhiskers); % length values used in parameteric solution
	for w=1:obj.numWhiskers
	  vi = find(obj.positionMatrix(:,2) == w);
		lengthMatrix(obj.positionMatrix(vi,1),w) = obj.lengthVector(vi);
	end

	% --- call static method 
	if (length(parabolaHalfLength) == 0) % non-parabola case 
    obj.kappas = session.whiskerTrial.computeKappasS (obj.numFrames, obj.numWhiskers, positionType, position, ...
                         obj.lengthAtPolyXYIntersect, lengthMatrix, obj.whiskerPolyDegree, ...
												 obj.whiskerPolysX, obj.whiskerPolysY);
	else % Parabola case 
    obj.enableWhiskerData();
    obj.kappas = session.whiskerTrial.computeKappasS (obj.numFrames, obj.numWhiskers, positionType, position, ...
                         obj.lengthAtPolyXYIntersect, lengthMatrix, obj.whiskerPolyDegree, ...
												 obj.whiskerPolysX, obj.whiskerPolysY, parabolaHalfLength, obj);
	end


	% --- populate whiskerCurvatureTSA
	for w=1:obj.numWhiskers
	  TSs{w} = session.timeSeries(obj.frameTimes, obj.frameTimeUnit, obj.kappas(:,w), w, ...
		  ['Curvature for ' num2str(w)], 0, obj.matFilePath);
	end
	trialIndices = ones(1,length(obj.frameTimes))*obj.trialId;
  obj.whiskerCurvatureTSA = session.timeSeriesArray(TSs, trialIndices);

	% --- clear dependent arrays
	obj.whiskerContacts = [];
	obj.whiskerBarContactESA = [];

