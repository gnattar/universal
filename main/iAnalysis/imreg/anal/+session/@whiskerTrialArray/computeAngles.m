%
% Computes whisker angles for entire session, resetting wta.whiskerAngleTSA.
%
% USAGE:
%
%   wta.computeAngles()
%
% NOTES:
%
%   Set the parameters thetaPosition and thetaPositionType prior to running 
%   this.  This is basically a wrapper for session.whikserTrial.computeThetasS.
%
%   Settings for thetaPositon and thetaPositionType:  
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
%   position: if mode 3-6, the length or length fraction to measure @
%
% (C) S Peron Mar 2012
%
function obj = computeAngles(obj)
  %% --- call the static method
	numFrames = length(obj.whiskerLengthTSA.trialIndices);
  thetas = session.whiskerTrial.computeThetasS (numFrames, obj.numWhiskers, ...
	  obj.thetaPositionType, obj.thetaPosition, ...
		obj.whiskerLengthAtTrackPolyIntersectTSA.valueMatrix', ...
		obj.whiskerLengthTSA.valueMatrix',...
		obj.whiskerPolyDegree, ...
		obj.whiskerPolysX', obj.whiskerPolysY');

  %% --- assign TSA
	obj.whiskerAngleTSA.valueMatrix = thetas';

