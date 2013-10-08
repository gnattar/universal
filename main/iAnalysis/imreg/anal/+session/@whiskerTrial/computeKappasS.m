%
% This will compute kappa (curvature) for each whisker at each time point.
%
% kappa = (x'y'' - y'x'')/(x'^2 + y'^2)^(3/2) - the CURVATURE of the whisker.
%
% USAGE:
%  
%   kappas = session.whiskerTrial.computeKappasS (numFrames, numWhiskers, positionType, position,
%                         lengthAtPolyXYIntersect, lengthMatrix, whiskerPolyDegree,
%												 whiskerPolysX, whiskerPolysY, parabolaHalfLength, wt)
%
%   numFrames, numWhiskers: how many frames, whiskers?
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
%   position: if mode 3-6, the length or length fraction to measure @
%   lengthAtPolyXYIntersect: how long is whisker where it intersects face poly
%   lengthMatrix: matrix with each row a frame, each column a whisker
%   whiskerPolyDegree: degree of polynomials fit to each whisker
%   whiskerPolysX,Y: X and Y versions of that polynomial
%   parabolaHalfLength: if specified, it will take this many PIXELS fo length
%                    ABOVE AND BELOW the position to fit a new parabola and
%                    compute curvature thereof at the midpoint.  You need to 
%                    also pass whiskerTrial object to do tihs.
%   wt: whiskerTrial object if using parabolaHalfLength (because it has pixel
%       positions of whiskers)
%  
%
% (C) S Peron Oct 2010
%
function kappas = computeKappasS (numFrames, numWhiskers, positionType, position, ...
                         lengthAtPolyXYIntersect, lengthMatrix, whiskerPolyDegree, ...
												 whiskerPolysX, whiskerPolysY, parabolaHalfLength, wt)
  % --- sanity checks
  if (nargin < 9)
	  help('session.whiskerTrial.computeKappasS');
		error('Insufficient input arguments.  Only parabolaHalfLength and wt are optional arguments.');
	end

	if (length(positionType) == 0)
		  disp('computeKappasS: must specify valid positionType.');  return;
	end
	if (positionType > 2 & length(position) == 0)
	  disp('computeKappasS: must specify valid position.');  return;
	end
	if (nargin < 10) % blank parabolaHalfLength
	  parabolaHalfLength = [];
  end

  % --- set things up
  kappas = nan*ones(numFrames, numWhiskers);
	lMatrix = zeros(numFrames,numWhiskers); % length values used in parameteric solution
  switch positionType
    case 1 % just use length @ the position-measuring polynomial intersect, our makeshift mask
		  lMatrix = lengthAtPolyXYIntersect;

	  case 2 % at follicle - so do nothing and leave ZERO!

	  case 3 % at some specified length
      lMatrix(:) = position;

		case 4 % some distance from polynomial intersect
		  lMatrix = lengthAtPolyXYIntersect + position;

		case 5 % some *fraction* of distance from base
			for f=1:numFrames
	      for w=1:numWhiskers
					L = lengthMatrix(f,w);
					if (L > 0) % sanity check
					  lMatrix(f,w) = position*L;
					end
				end
			end

		case 6 % some fraction of length from polynomial intersect XY 
			for f=1:numFrames
	      for w=1:numWhiskers
					L = lengthMatrix(f,w);
		      baseL = lengthAtPolyXYIntersect(f,w);
					if (baseL >= 0 & L > 0) % sanity check
					  lMatrix(f,w) = baseL + position*(L-baseL);
					end
				end
			end

		otherwise
		  disp('computeKappas: must specify valid positionType.');  return;
	end

	% --- loop over frames 
	if (length(parabolaHalfLength) == 0) % non-parabola case 
    tic;
		for f=1:numFrames
			for w=1:numWhiskers
				% pull the relevant data from obj.whiskerPolysX and obj.whiskerPolysY
				i1 = (w-1)*(whiskerPolyDegree+1)+1;
				i2 = i1+whiskerPolyDegree;
				xPoly = whiskerPolysX(f,i1:i2);
				yPoly = whiskerPolysY(f,i1:i2);
				l = lMatrix(f,w);
				
				% make sure length at which you measure is not beyond whisker length
				if (isnan(l)) ; continue ; end
				if (lengthMatrix(f,w) < l) ; continue ; end

				% make sure this is okay - assume we can just check this and that is all
				if (~isnan(xPoly(1)))
					kappas(f,w) = instantaneousKappa(xPoly, yPoly, l);
				end
      end
      if (rem(f,10000) == 0)
        dtime = toc;
        remFrames = numFrames -f;
            
        disp(['computeKappaS::estimated remaining computation time: ' num2str((dtime/f)*remFrames) ' s']);
      end      
		end
	else % Parabola case 
	  disp('computeKappasS::using parabolic estimate; this takes some time.');
    wt.enableWhiskerData();

		wData = wt.whiskerData; % because MATLAAB is a bitch (accessing structure elements takes longer than just doing this)
    tic;
		for f=1:numFrames
			pmi = find(wt.positionMatrix(:,1) == f);
			for w=1:numWhiskers
				% pull the positino
				l = lMatrix(f,w);
				
				% make sure length at which you measure is not beyond whisker length
				if (isnan(l)) ; continue ; end
				L = [l-parabolaHalfLength l+parabolaHalfLength];
				if (lengthMatrix(f,w) < L(2)) ; continue ; end

				% --- fit the parabola

        % pull whisker
				wi = find(wt.positionMatrix(pmi,2) == w);
%        wi = wpmi - pmi(1) + 1
			  whisker = wData(f).whisker(wi);

  		  % by default we invert so that x(1),y(1) is our follicle
	  	  x = fliplr(whisker.x');
		    y = fliplr(whisker.y');

				% ensure that x(1),y(1) is follicle position (!) ; take advantage of our previous 
				%  measurement of the follicle site
				fxy = whisker.follicleXY;
				if (fxy(1) ~= x(1) | fxy(2) ~= y(1))
					x=fliplr(x);
					y=fliplr(y);
				end

				%  compute actual length, albeit crudely (using distance formula -- curve fit would be best)
				len = cumsum(sqrt([0 diff(x)].^2 + [0 diff(y)].^2));

				% Find what portion of the whisker we will use based on L
				startIdx = min(find(len > L(1)));
				endIdx = max(find(len < L(2)));

        % Fit the parabolas
				xPoly = polyfit(len(startIdx:endIdx), x(startIdx:endIdx), 2);
				yPoly = polyfit(len(startIdx:endIdx), y(startIdx:endIdx), 2);

				% and finally, get instantaneous kappa 
				if (~isnan(xPoly(1)))
					kappas(f,w) = instantaneousKappa(xPoly, yPoly, l);
				end
      end
      if (rem(f,10000) == 0)
        dtime = toc;
        remFrames = numFrames -f;
            
        disp(['computeKappaS::estimated remaining computation time: ' num2str((dtime/f)*remFrames) ' s']);
      end      
  	end
	end

%
% single kappa evaluation given x and yPoly, length 
%
function kappa = instantaneousKappa(xPoly, yPoly, l)
	% derive
	dxPoly = polyder(xPoly);
	dyPoly = polyder(yPoly);
	ddxPoly = polyder(dxPoly);
	ddyPoly = polyder(dyPoly);

	% solve instantaneous derivatives, second derivatives
	dx = polyval(dxPoly,l);
	ddx = polyval(ddxPoly,l);
	dy = polyval(dyPoly,l);
	ddy = polyval(ddyPoly,l);

	% plug into kappa equation
	% kappa = (x'y'' - y'x'')/(x'^2 + y'^2)^(3/2) - the CURVATURE of the whisker.
	kappa = (dx*ddy - dy*ddx)/((dx*dx + dy*dy)^(3/2));
