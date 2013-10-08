%
% SP Sept 2010
%
% This will first fit a polynomial to the set of points polynomialDistanceFromFace 
%  away from face for all whiskers.  Then, at each frame, whiskers that 
%  intersect the polynomial have their point of intersection (closest to the
%  follicle in case of multiples) recorded. 
%
% updates:
%  obj.polynomialIntersectXY
%  obj.polynomialArcPosition
%
function obj = updatePolynomialIntersectXY (obj)
	if (obj.messageLevel >= 1) ; disp(['updatePolynomialIntersectXY::processing ' obj.basePathName]); end
  obj.enableWhiskerData();

  % --- make sure face is in place(!)
	if (length(obj.faceCOM) < 2)
	  if (obj.messageLevel >= 1) ; disp('updatePolynomialIntersectXY::No face COM ; calling face detector in updateFollicleXY. Setting useFaceContour=1.'); end
    obj.useFaceContour = 1;
    obj.updateFollicleXY();
	end

  % --- first, fit the polynomial ...
	if (length(obj.polynomial) == 0)
		obj.polynomial = fitWhiskersToPolynomial(obj); 
	else
	  if (obj.messageLevel >= 1) ; disp('updatePolynomialIntersectXY::obj.polynomial already populated; will not refit it.  To force refit, set obj.polynomial=[].'); end
	end
	poly = obj.polynomial;
	imWidth = obj.whiskerMovieFrames{1}.width;
	polyX = 0:0.1:imWidth;
	polyY = polyval(poly,polyX);

	if ( 1 == 0)
	  figure;
		obj.plotFrame(1);
		hold on;
		plot(polyX, polyY, 'b-');
    pause;
	end

	% --- now construct path integral so that you measure displacement ALONG ARC
	val = find(polyY >=0);
	polyX = polyX(val);
	polyY = polyY(val);
	i1 = 1:length(polyX)-1;
	i2=i1+1;
  d = sqrt((polyX(i1)-polyX(i2)).^2 + (polyY(i1)-polyY(i2)).^2);
  arclen = cumsum(d);
	L = length(arclen);
	arclen(L+1) = arclen(L)+abs(arclen(L)-arclen(L-1)); % interpolate last points

	% --- now go thru and assign folliclePositionMat if this is the method ...
	if (obj.messageLevel >= 1) ; disp(['updatePolynomialIntersectXY::polynomial fit complete ; now finding arc intersect for all whiskers.']); end
	if (obj.waitBar) ; wb = waitbar(0, 'Finding whisker-polynomial intersects ...'); end
	for f=1:length(obj.frames)
		if (obj.waitBar) ; waitbar(f/length(obj.frames), wb, 'Finding whisker-polynomial intersects ...'); end
		for w=1:length(obj.whiskerData(f).whisker); 

			% find intersection on-the-cheap -- evaluate the polynomial at all x values, then 
			%  look at distance between y of polynomial fit to whisker x values and actualy
			%  y of whisker ; minimum is your best fit.
			y = poly(1)*obj.whiskerData(f).whisker(w).x.*obj.whiskerData(f).whisker(w).x + poly(2)*obj.whiskerData(f).whisker(w).x + poly(3);
%			y = polyval(poly, obj.whiskerData(f).whisker(w).x);
			D = abs(y-obj.whiskerData(f).whisker(w).y);
			[bestVal bestIdx] = min(D);
			% only accept true intersections -- < 2 pixels
			if (length(bestVal) > 0)
				if (bestVal < 2)
				  % compute arc integral
					Darc = abs(obj.whiskerData(f).whisker(w).x(bestIdx) - polyX);
			    [bestArcVal bestArcIdx] = min(Darc);

					% assign
					obj.whiskerData(f).whisker(w).polynomialIntersectXY = [obj.whiskerData(f).whisker(w).x(bestIdx) obj.whiskerData(f).whisker(w).y(bestIdx)];
					obj.whiskerData(f).whisker(w).polynomialArcPosition = arclen(bestArcIdx);
				else
					obj.whiskerData(f).whisker(w).polynomialIntersectXY = [nan nan]; % the default
					obj.whiskerData(f).whisker(w).polynomialArcPosition = nan;
				end
			else
				obj.whiskerData(f).whisker(w).polynomialIntersectXY = [nan nan]; % the default
				obj.whiskerData(f).whisker(w).polynomialArcPosition = nan;
			end
		end
	end
	if (obj.waitBar) ; delete(wb) ; end

	% --- finally, update position matrix if thsi is claled for
	if (obj.positionMatrixMode == 2 | obj.positionMatrixMode == 3)
	  obj.updatePositionMatrix();
	end

%
% This will fit whiskers to a polynomial.  Returns poly, the results of polyfit.
%
function poly = fitWhiskersToPolynomial(obj)
  fittedPointThresh = 10; % how many times must a point be crossed by whisker to be in the set of fitted poitns?

	% -- build the points to fit

	% build a matrix where points will be counted
	obj.loadMovieFrames(1);
	imWidth = obj.whiskerMovieFrames{1}.width;
	imHeight = obj.whiskerMovieFrames{1}.height;
	wm = zeros(imHeight, imWidth);

  % populate it
  com = obj.faceCOM;
	rangeIdx = obj.polynomialDistanceFromFace;
	if (obj.waitBar) ; wb = waitbar(0, 'Gathering polynomial points ...'); end
	for f=1:length(obj.frames)
	  if (obj.waitBar) ; waitbar(f/length(obj.frames), wb, 'Gathering polynomial points ...'); end
    wdata = obj.whiskerData(f);
	  for w=1:length(wdata.whisker); 
      % does the follicle BASE exceed maxFollicleY ? then ignore it
			if (wdata.whisker(w).follicleXY(2) > obj.polynomialFitMaxFollicleY) ; continue ; end

      % also, exclude whiskers that don't meet length critieria
  		if (length(wdata.whisker(w).x) < obj.minWhiskerLength) ; continue ; end

		  % proceed
		  xv = round(wdata.whisker(w).x);
			yv = round(wdata.whisker(w).y);
		  V = find(xv > 0 & yv > 0 & xv <= imWidth & yv <= imHeight); % screen the crazy ...
if(length(V) < length(xv) | length(V) < length(yv)) ; disp(['WEIRDNESS: ' obj.basePathName]); end
		  xv = xv(V);
		  yv = yv(V);

      % compute distances to face COM
			distances = sqrt( (com(1)-xv).^2 + (com(2)-yv).^2 );
			[nan DIdx] = sort(distances);

			% select poitns obj.polynomialDistanceFromFace away from face
			L = length(DIdx);
      if (L > rangeIdx(1))
			  vals = DIdx(rangeIdx(1):min(L,rangeIdx(2)));
	      for v=1:length(vals) 
			    wm(yv(vals(v)),xv(vals(v))) = wm(yv(vals(v)),xv(vals(v)))+1; 
			  end
			end
    end
	end
	if (obj.waitBar) ; delete(wb) ; end
  
	% exclude based on polynomialFitMaxFollicleY
	if (obj.polynomialFitMaxFollicleY > 0)
	  % zero out above polynomialFitMaxFollicleY
		wm(obj.polynomialFitMaxFollicleY:imHeight,:) = 0;

		% zero out anything that is too close to top - this happens when whisker's origin is edge of screen ; the range then breaks down and should be unused
		maxX = 0;
		for x=1:imWidth
		  if (length(find(wm(1:rangeIdx(1),x) > 1)) > 1)
			  maxX = x;
			end
		end
		if (maxX > 0)
		  wm(:,1:maxX) = 0; 
		end
	end

  if ( 1 == 0)
	  figure;
	  global wimage;
		wimage = wm;
	  imshow(wm,[0 100]);
	  pause
	end

  % -- actual fitting
	
	% apply threshold
	wmb = zeros(size(wm));
	wmb(find(wm > fittedPointThresh)) = 1;

	% vertex: y = 0 ; x is point of min y
%  Ysum = sum(wmb,2); % sum along x dimension, to get, for each y, a sum
%	minY = min(find(Ysum > 0));
%	vertexX = min(find(wmb(minY,:) > 0));
%	vertex = [vertexX 0];

  % extract the points
	idx = find(wmb > 0);
  X = ceil(idx/imHeight);
	Y = idx - (X-1).*imHeight;

  % and the parabolic fit ... lsqnonlin-based fit to enforce signange on coefficients
% NEW PARAMS ON 1/29/2012
  init = [-.003 3 -300];
  lb = [-.1 0 -1*imWidth]; % - + -
	ub = [0 10 -50]; 
% OLD:
%  lb = [-1 0 -2000];
%  yb = [0 100 0];

  % turn data into a single trace so that it is a function (unique y for each x)
  ux = unique(X);
	uy = 0*ux;
	for u=1:length(ux)
	  idx = find(X == ux(u));
     
    % old way: use mean
%	  uy(u) = mean(Y(idx));
     
    % now: use ksdensity peak
    [dens yvals] = ksdensity(Y(idx));
    [irr maxdensidx] = max(dens);
    uy(u) = yvals(maxdensidx);
	end

  % don't go too crazy -- this need not be ultra precise
  options = optimset('MaxFunEvals', 1000);
      
  % fitting ...      
  realY = uy;
  realX = ux;
  p = lsqnonlin(@parabfit, init, lb, ub, options, realX, realY);
  poly = p;
	if (length(obj.polynomialOffset) == length(poly)) ; poly = poly + obj.polynomialOffset ; end

%
% for parabolic fitting -- coefficients should be - + - 
%
function F = parabfit(p, x, trace)
  F = trace - (p(1)*(x.^2) + p(2)*x + p(3));



