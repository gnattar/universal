%
% This will compute deviation of curvature from baseline observed typically.
%
% This function is essentially a wrapper for the static
%  session.whiskerTrial.computeDeltaKappas.  Briefly, it figures out the typical
%  curvature for a given angle over the course of the session, then computes a
%  curvature indicating deviation from baseline at that angle.
%
% USAGE:
%
% (C) Mar 2012 S Peron
%
function obj = computeCurvatureChanges(obj)
  %% --- call the static method
	deltaKappas = session.whiskerTrial.computeDeltaKappas(obj.whiskerCurvatureTSA.valueMatrix,  ...
			obj.whiskerAngleTSA.valueMatrix, obj.whiskerBarInReachTS.value, 1)';

	%% --- assign TSA
	% instantiate?
	if (~isobject(obj.whiskerCurvatureChangeTSA))
	  for w=1:obj.numWhiskers
		  whCurCh{w} = session.timeSeries(obj.time, obj.timeUnit, deltaKappas(w,:), w, ['Curvature Change for ' obj.whiskerTags{w}], 0, []);
		end

 	  obj.whiskerCurvatureChangeTSA = session.timeSeriesArray(whCurCh);
    obj.whiskerCurvatureChangeTSA.trialIndices = obj.trialIndices;
	end

	obj.whiskerCurvatureChangeTSA.valueMatrix = deltaKappas; 
