%
% Computes whisker curvatures for entire session, resetting wta.whiskerCurvatureTSA.
%
% USAGE:
%
%   wta.computeCurvatures()
%
% NOTES:
%
%   Set the parameters kappaPosition and kappaPositionType prior to running 
%   this.  This is basically a wrapper for session.whikserTrial.computeThetasS.
%
%   Settings for kappaPositon and kappaPositionType:  
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
%   position: if mode 3-6, the length or length fraction to measure @
%
% (C) S Peron Mar 2012
%
function obj = computeCurvatures(obj)
  %% --- call the static method
	numFrames = length(obj.fileIndices);
	
	% no parabola? straight gangsta
	if (length(obj.kappaParabolaHalfLength) == 0 || obj.kappaParabolaHalfLength == 0) 
		kappas = session.whiskerTrial.computeKappasS (numFrames, obj.numWhiskers, ...
			obj.kappaPositionType, obj.kappaPosition, ...
			obj.whiskerLengthAtTrackPolyIntersectTSA.valueMatrix', ...
			obj.whiskerLengthTSA.valueMatrix',...
			obj.whiskerPolyDegree, ...
			obj.whiskerPolysX', obj.whiskerPolysY');
	else % Parabola case  -- nasty dawg
	  kappas = zeros(obj.numWhiskers,numFrames);
	  fileIndices = obj.fileIndices; % use the *initial* indexing
	  for t=1:obj.numTrials
		  wt = obj.wtArray{t}.lightCopy(); % so we don't clutter memory with whiskerData
			wt.whiskerData = [];
		  wt.enableWhiskerData();
      ti = find(fileIndices == t);
      kappas(:,ti) = session.whiskerTrial.computeKappasS (length(ti),obj.numWhiskers, ...
			  obj.kappaPositionType, obj.kappaPosition, ...
				obj.whiskerLengthAtTrackPolyIntersectTSA.valueMatrix(:,ti)', ...
				obj.whiskerLengthTSA.valueMatrix(:,ti)',...
				obj.whiskerPolyDegree, ...
				obj.whiskerPolysX(:,ti)', obj.whiskerPolysY(:,ti)', ...
		  	obj.kappaParabolaHalfLength, wt);
		end
	end

  %% --- assign TSA
	obj.whiskerCurvatureTSA.valueMatrix = kappas';

