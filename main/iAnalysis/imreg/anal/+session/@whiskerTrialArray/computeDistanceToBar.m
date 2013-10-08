%
% Computes distance to bar for whisker as well as nearest point.
%
% Specifically, this method first goes through and computes the length of a
%  whisker as a function of theta for non-bar-in-reach epochs.  It then uses
%  this to determine how far to interpolate the whisker because the bar often
%  obscures the whisker.  This interpolated whisker is used to determine the
%  point along the whisker that is closest to the bar.  This point is stored
%  in whiskerPointNearestBarXYTSA, with two vectors per whisker, first one being
%  x, other y.  The distance between this point and the bar center is then
%  put into whiskerDistanceToBarTSA.
%
% USAGE:
%
%   wta.computeDistanceToBar(params)
%
% ARGUMENTS:
%
%   params: A structure with the following optional fields:
%
%     params.maxAddToTips: how many pixels AT MOST will be added to the tip;
%                          default 20
%     params.thetaRangeHalfSize: how to partition theta when doign length vs
%                                theta calculation; default 5 degrees.
%     params.lengthFractionalCutoff: For each theta, a length distribution is 
%                                    obtained.  It will use this fractional 
%                                    quantile of the TOP length values. dflt .2
%
% (C) 2012 Simon Peron
%
function obj = computeDistanceToBar (obj, params)

  %% --- input processing
%	if (nargin < 2)
%	  help('session.whiskerTrialArray.computeDistanceToBar');
%	  error('Must at least give ');
%	end
 
  % default params
	maxAddToTip = 20; 
	thetaRangeHalfSize=5; 
	lengthFractionalCutoff = 0.2; 

  % params 
  if (nargin >= 2 && isstruct(params))
	  pfields = fieldnames(params);
	  for p=1:length(pfields)
		  eval([pfields{p} ' = params.' pfields{p} ';']);
		end
	end

  %% --- set things up

	% preblank everything
	numFrames = length(obj.fileIndices);
  whiskerDistanceToBarCenter = nan*ones(numFrames, obj.numWhiskers);
  whiskerPointNearestBarXY = nan*ones(numFrames, obj.numWhiskers*2);
  
	% pull bar center
	barCenter = obj.barCenterTSA.valueMatrix;

	%% --- main loop
	disp('session.whiskerTrialArray.computeDistanceToBar::this will take a while ...');
  for w=1:obj.numWhiskers
		% some indexing prelinms
		wr = (w-1)*2 + [1 2];

		% collect max lengths for each whisker at a given theta range ..
		wLens = obj.whiskerLengthTSA.valueMatrix(w,:);
		th = obj.whiskerAngleTSA.valueMatrix(w,:);
		thv = floor(min(th)):ceil(max(th));
		maxLens =0*thv; 
		for t=1:length(thv) ; 
			vi = find(th > thv(t)-5 & th < thv(t) + 5 ) ; 
			sl = sort(wLens(vi), 'descend'); 
			NL = length(sl) ;  
			maxLens(t) = nanmean(sl(1:ceil(NL*lengthFractionalCutoff))) ; 
		end

		for f=1:numFrames
			barCOM = barCenter (:,f);

			% pull the relevant data from obj.whiskerPolysX and obj.whiskerPolysY
			lens = 0:wLens(f);
			i1 = (w-1)*(obj.whiskerPolyDegree+1)+1;
			i2 = i1+obj.whiskerPolyDegree;
			xPoly = obj.whiskerPolysX(i1:i2,f);
			yPoly = obj.whiskerPolysY(i1:i2,f);

			% add maxAddToTip or less? need some to interpolate off of -- 50
			thIdx = find(thv == round(th(f)));
			if (length(thIdx) > 0)
				dL = maxLens(thIdx)-wLens(f);
				if (dL > 0 & length(lens) > 50)
					lens = [lens max(lens)+1:max(lens)+dL-1];
				end
			end

			% compute minimal distance to bar using interpolated polynomial whisker
			xv = polyval(xPoly, lens);
			yv = polyval(yPoly, lens);
			distances = sqrt( (barCOM(1)-xv).^2 + (barCOM(2)-yv).^2 );
			[minD minDi] = min(distances);

			% assign if valid
			if (length(minD) > 0)
				whiskerDistanceToBarCenter(f,w) = minD;

% maybe add in future?
%				obj.polynomialIntersectX(f,w) = xv(1);
%				obj.polynomialIntersectY(f,w) = yv(1);

        whiskerPointNearestBarXY(f,wr) = [xv(minDi) yv(minDi)];
			  if (mod(f,10000)==0) ; disp([8 '.']); end
			end
		end

	end

	%% --- assign TSAs
	for w=1:obj.numWhiskers
	  whDToBar{w} = session.timeSeries(obj.time, obj.timeUnit, whiskerDistanceToBarCenter(:,w), w, ['Distance to bar ' obj.whiskerTags{w}], 0, []);
		whPNBXY{(w*2)-1} = session.timeSeries(obj.time, obj.timeUnit, whiskerPointNearestBarXY(:,(w*2)-1), (w*2)-1, ['Point nearest bar x for ' obj.whiskerTags{w}], 0, []);
		whPNBXY{(w*2)} = session.timeSeries(obj.time, obj.timeUnit, whiskerPointNearestBarXY(:,(w*2)), (w*2), ['Point nearest bar y for ' obj.whiskerTags{w}], 0, []);
	end

	obj.whiskerPointNearestBarXYTSA= session.timeSeriesArray(whPNBXY);
	obj.whiskerPointNearestBarXYTSA.trialIndices = obj.trialIndices;

	obj.whiskerDistanceToBarTSA= session.timeSeriesArray(whDToBar);
	obj.whiskerDistanceToBarTSA.trialIndices = obj.trialIndices;

