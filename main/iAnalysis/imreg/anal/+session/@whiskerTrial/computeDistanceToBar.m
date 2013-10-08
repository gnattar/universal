%
% SP Oct 2010
%
% This will compute the distance to the bar CENTER at each time point for each
%  whisker.  Must have a tracked bar and polynomials done.  Will also populate
%  things needed to compute directional contacts:
%    correctedBarCenter
%    polynomialIntersectX,Y
%    whiskerPointNearestBarX,Y
% 
%  Uses tip extrapolation off of the polyfit polygon in frames where the 
%  whisker is aberrantly truncated.
%
% USAGE:
%  
%   wt.computeDistanceToBar()
%
function computeDistanceToBar(obj)
  % --- settings
	maxAddToTip = 20; % how many pixels AT MOST will it add to tip -- note that
	                  % it estimates the LONGEST the whisker can be at this theta,
										% and uses this as the UPPER BOUND of how long the whisker
										% can be made, in addition to this number + the whisker length.
	thetaRangeHalfSize=5; % will go +/- this much theta, taking mean of top fraction
	                      % of lengths for this theta as what it expects length to be
	lengthFractionalCutoff = 0.2; % take the TOP this x 100% lengths at each theta interval


  % --- sanity checks
	if (length(obj.whiskerPolysX) == 0 | length(obj.barCenter) == 0 | length(obj.thetas) == 0)
	  disp('computeDistanceToBar: must first run computeWhiskerPolys, computeThetas and trackBar.');
		return;
	end

  % --- set things up
  obj.distanceToBarCenter = nan*ones(obj.numFrames, obj.numWhiskers);
	[barInReach barCenterAtFirstContact] = obj.getFractionCorrectedBarInReach();

  % --- setup matrices that will store info for direction-of-contact detection
	obj.correctedBarCenter = obj.barCenter;
	if (~isnan(barCenterAtFirstContact))
  	obj.correctedBarCenter(find(barInReach),:) = ...
		  repmat(barCenterAtFirstContact, length(find(barInReach)),1);
	end
	obj.polynomialIntersectX = nan*ones(obj.numFrames, obj.numWhiskers);
	obj.polynomialIntersectY = obj.polynomialIntersectX;
	obj.whiskerPointNearestBarX = obj.polynomialIntersectX;
	obj.whiskerPointNearestBarY = obj.polynomialIntersectX;

	% --- loop over frames 
	if (obj.waitBar) ; wb = waitbar(0, 'Computing distance to bar ctr ...'); end
	for w=1:obj.numWhiskers
		if (obj.waitBar) ; waitbar(w/obj.numWhiskers, wb, 'Computing distance to bar ctr ...'); end
		% some indexing prelinms
		wr = [(w-1)*2 (w-1)*2+1]+1;
		wi = find(obj.positionMatrix(:,2) == w);

		% collect max lengths for each whisker at a given theta range ..
		fi = obj.positionMatrix(wi,1);
		wLens = obj.lengthVector(wi);
		th = obj.thetas(fi, w);
		thv = floor(min(th)):ceil(max(th));
		maxLens =0*thv; 
		for t=1:length(thv) ; 
			vi = find(th > thv(t)-5 & th < thv(t) + 5 ) ; 
			sl = sort(wLens(vi), 'descend'); 
			NL = length(sl) ;  
			maxLens(t) = nanmean(sl(1:ceil(NL*lengthFractionalCutoff))) ; 
		end

		for f=1:obj.numFrames
			if (~isnan(barCenterAtFirstContact))
				barCOM = barCenter; % new : use fraction-corrected frame
			else
				barCOM = obj.barCenter(f,:); % OLD: Use frame
			end

		  % indexing
			pmi = find(obj.positionMatrix(:,1) == f);
			wpmi = pmi(find(obj.positionMatrix(pmi,2) == w));

			% pull the relevant data from obj.whiskerPolysX and obj.whiskerPolysY
			lens = 0:obj.lengthVector(wpmi);
			i1 = (w-1)*(obj.whiskerPolyDegree+1)+1;
			i2 = i1+obj.whiskerPolyDegree;
			xPoly = obj.whiskerPolysX(f,i1:i2);
			yPoly = obj.whiskerPolysY(f,i1:i2);

			% add maxAddToTip or less? need some to interpolate off of -- 50
			thIdx = find(thv == round(obj.thetas(f,w)));
			if (length(thIdx) > 0)
				dL = maxLens(thIdx)-obj.lengthVector(wpmi);
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
				obj.distanceToBarCenter(f,w) = minD;

				obj.polynomialIntersectX(f,w) = xv(1);
				obj.polynomialIntersectY(f,w) = yv(1);

        obj.whiskerPointNearestBarX(f,w) = xv(minDi);
        obj.whiskerPointNearestBarY(f,w) = yv(minDi);
			end
		end
	end
	if (obj.waitBar) ; delete(wb) ; end

	% --- clear dependent arrays (contacts, contact ESA)
	obj.whiskerContacts = [];
	obj.whiskerBarContactESA = [];

