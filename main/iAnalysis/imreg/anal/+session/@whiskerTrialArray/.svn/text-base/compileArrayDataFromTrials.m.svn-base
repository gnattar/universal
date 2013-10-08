%
% This takes the raw whiskerTrial objects and combines their data.
%
% This function takes individual components -- whisker length, polynomials,
%  etc. -- from the wtArray's whiskerTrial objects and makes large vectors
%  that span the entire dataset.  Note that derived values such as delta kappa
%  (AKA whiskerCurvatureChangeTSA) are not compiled here.  What is compiled:
%
%		wta.whiskerTrackPolyIntersectXYTSA
%		wta.whiskerLengthTSA
%		wta.whiskerLengthAtTrackPolyIntersectTSA
%		wta.whiskerPolysX
%		wta.whiskerPolysY
%		wta.barCenterTSA
%   wta.whiskerAngleTSA
%   wta.whiskerCurvatureTSA
%
%  Several singleton variables are also grabbed:
%
%   wta.barRadius
%   wta.whiskerPolyDegree
%   wta.kappaPosition
%   wta.kappaPositionType
%   wta.thetaPosition
%   wta.thetaPositionType
%		
% USAGE:
%
%  wta.compileArrayDataFromTrials()
%
function obj = compileArrayDataFromTrials(obj)
  %% --- prep work
	barRadius = zeros(1,obj.numTrials);
	whiskerPolyDegree = zeros(1,obj.numTrials);
	kappaPosition = zeros(1,obj.numTrials);
	kappaPositionType = zeros(1,obj.numTrials);
	thetaPosition = zeros(1,obj.numTrials);
	thetaPositionType = zeros(1,obj.numTrials);

	% how many time points? also, polynomial and bar radius check
	ntp = 0;
	for t=1:obj.numTrials
	  ntp = ntp + obj.wtArray{t}.numFrames;
		barRadius(t) = mean(obj.wtArray{t}.barRadius);
		whiskerPolyDegree(t) = obj.wtArray{t}.whiskerPolyDegree;
		kappaPosition(t) = obj.wtArray{t}.kappaPosition;
		kappaPositionType(t) = obj.wtArray{t}.kappaPositionType;
		thetaPosition(t) = obj.wtArray{t}.thetaPosition;
		thetaPositionType(t) = obj.wtArray{t}.thetaPositionType;
	end

	% consistency check
	if (sum(diff(barRadius)) > 0)
	  error('compileArrayDataFromTrials::bar radius not constant ; aborting.');
	elseif (sum(diff(whiskerPolyDegree)) > 0)
	  error('compileArrayDataFromTrials::whisker polynomial degree not constant ; aborting.');
	elseif (sum(diff(kappaPosition)) > 0)
	  error('compileArrayDataFromTrials::kappa pposition not constant ; aborting.');
	elseif (sum(diff(kappaPositionType)) > 0)
	  error('compileArrayDataFromTrials::kappa position type not constant ; aborting.');
	elseif (sum(diff(thetaPosition)) > 0)
	  error('compileArrayDataFromTrials::theta position not constant ; aborting.');
	elseif (sum(diff(thetaPositionType)) > 0)
	  error('compileArrayDataFromTrials::theta position type not constant ; aborting.');
	end
	obj.barRadius = barRadius(1);
	obj.whiskerPolyDegree = whiskerPolyDegree(1);
	obj.kappaPosition = kappaPosition(1);
	obj.kappaPositionType = kappaPositionType(1);
	obj.thetaPosition = thetaPosition(1);
	obj.thetaPositionType = thetaPositionType(1);

	% prebuild large vectors...
	trackPolyIntXY = zeros(obj.numWhiskers*2,ntp);
	len = zeros(obj.numWhiskers,ntp);
	lenAtPoly = zeros(obj.numWhiskers,ntp);
	polyX = zeros(obj.numWhiskers*(obj.whiskerPolyDegree+1),ntp);
	polyY = zeros(obj.numWhiskers*(obj.whiskerPolyDegree+1),ntp);
	barCenter = zeros(2,ntp);
	barInReach = zeros(1,ntp);
	trialIndices = zeros(1,ntp);
	timeVec = zeros(1,ntp);
	angle = nan*zeros(obj.numWhiskers,ntp);
	curvature = nan*zeros(obj.numWhiskers,ntp);

	%% --- main compilation

	% loop and gather
	i1 = 1;
	for t=1:obj.numTrials
	  wt = obj.wtArray{t};
		i2 = i1 + wt.numFrames - 1;

    % assign
		trialIndices(i1:i2) = t;
    barCenter(:,i1:i2) = wt.barCenter';
		barInReach(i1:i2) = wt.barInReach;
		timeVec(:,i1:i2) = max(timeVec) + wt.frameTimes;
    
    % per-whisker variables
		for w=1:obj.numWhiskers
			lenAtPoly(w,i1:i2) = wt.lengthAtPolyXYIntersect(:,w)';

			% polynomial
			poli = ((obj.whiskerPolyDegree+1)*w) - [obj.whiskerPolyDegree 0];
			poli=poli(1):poli(2);
			polyX(poli,i1:i2) = wt.whiskerPolysX(:,poli)';
			polyY(poli,i1:i2) = wt.whiskerPolysY(:,poli)';
      trackPolyIntXY((w*2)-1,i1:i2) = wt.polynomialIntersectX(w);
      trackPolyIntXY((w*2),i1:i2) = wt.polynomialIntersectY(w);

      % length is a pain bc we have to extract it from lengthVector which pools all whiskers
      wi = find(strcmp(wt.whiskerTag, obj.whiskerTags{w}));
			widx = find(wt.positionMatrix(:,2) == wi);
			wfi = wt.positionMatrix(widx,1);
			iL = i1 + wfi - 1;
			len(w,iL) = wt.lengthVector(widx);

			% curvature, angle -- pull TS
			if (strcmp(class(wt.whiskerAngleTSA), 'session.timeSeriesArray'))
			  angle(w,i1:i2) = wt.whiskerAngleTSA.getTimeSeriesByIdx(w).value;
			end
			if (strcmp(class(wt.whiskerCurvatureTSA), 'session.timeSeriesArray'))
			  curvature(w,i1:i2) = wt.whiskerCurvatureTSA.getTimeSeriesByIdx(w).value;
			end
		end
		i1 = i2+1;
	end

  timeUnit = obj.wtArray{1}.frameTimeUnit;

	% bar in reach
	dbir = diff(barInReach);
  sbti = find(dbir == 1);
  ebti = find(dbir == -1);
	birTimes = sort(timeVec([sbti ebti]));
	birTrials = sort(trialIndices([sbti ebti]));

  % convert relevant stuff to time series arrays
	bxyTS{1} = session.timeSeries(timeVec, obj.timeUnit, barCenter(1,:), 1, 'Bar X', 0, []);
	bxyTS{2} = session.timeSeries(timeVec, obj.timeUnit, barCenter(2,:), 2, 'Bar Y', 0, []);

	for w=1:obj.numWhiskers
	  whLen{w} = session.timeSeries(timeVec, obj.timeUnit, len(w,:), w, ['Length ' obj.whiskerTags{w}], 0, []);
	  whLenAtPoly{w} = session.timeSeries(timeVec, obj.timeUnit, lenAtPoly(w,:), w, ['Length at Poly Intersect ' obj.whiskerTags{w}], 0, []);
	  whAng{w} = session.timeSeries(timeVec, obj.timeUnit, angle(w,:), w, ['Angle for ' obj.whiskerTags{w}], 0, []);
	  whCurv{w} = session.timeSeries(timeVec, obj.timeUnit, curvature(w,:), w, ['Curvature for ' obj.whiskerTags{w}], 0, []);
		whPolIntXY{(w*2)-1} = session.timeSeries(timeVec, obj.timeUnit, trackPolyIntXY((w*2)-1,:), (w*2)-1, ['Polynomial intersect x for ' obj.whiskerTags{w}], 0, []);
		whPolIntXY{(w*2)} = session.timeSeries(timeVec, obj.timeUnit, trackPolyIntXY((w*2),:), (w*2), ['Polynomial intersect y for ' obj.whiskerTags{w}], 0, []);
	end

	% final assignment ...
  obj.whiskerPolysX = polyX;
  obj.whiskerPolysY = polyY;

	obj.whiskerBarInReachES = session.eventSeries(birTimes, birTrials, timeUnit, 1, ...
				['Bar-in-reach times'], 0, '', [], [0.5 0.5 0.5], 2);
  obj.whiskerBarInReachTS = session.timeSeries(timeVec, timeUnit, barInReach, 1, 'Bar In Reach', 0, []);

	obj.barCenterTSA = session.timeSeriesArray(bxyTS);

	obj.whiskerLengthAtTrackPolyIntersectTSA = session.timeSeriesArray(whLenAtPoly);
	obj.whiskerLengthTSA = session.timeSeriesArray(whLen);

	obj.whiskerTrackPolyIntersectXYTSA = session.timeSeriesArray(whPolIntXY);

	obj.whiskerAngleTSA = session.timeSeriesArray(whAng);
	obj.whiskerCurvatureTSA = session.timeSeriesArray(whCurv);

	obj.fileIndices = trialIndices;
	obj.trialIndices = trialIndices;
	obj.time = timeVec;
	obj.timeUnit = timeUnit;
