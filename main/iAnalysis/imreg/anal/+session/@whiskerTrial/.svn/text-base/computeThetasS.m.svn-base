%
% Static wrapper for computeThetas, which computes whisker angle.
%
% This will compute theta for each whisker at each time point.  You must first
%  call computeWhiskerPolys to populate the polyfits.  Populates whiskerThetas.
%  Only works on 1:obj.numWhiskers whiskers.
%
% theta = -atand(x'(l)/y'(l)) -- angle of the whisker
%
% USAGE:
%  
%   wt.computeThetas (numFrames, numWhiskers, positionType, position,
%                         lengthAtPolyXYIntersect, lengthMatrix, whiskerPolyDegree,
%												 whiskerPolysX, whiskerPolysY)
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
%
%                 If this parameter is left blank, thetaPositionType and
%                   thetaPosition, having same meaning as positionType and
%                   positino, are used instead
%   position: if mode 3-6, the length or length fraction to measure @
%   lengthAtPolyXYIntersect: how long is whisker where it intersects face poly
%   lengthMatrix: matrix with each row a frame, each column a whisker
%   whiskerPolyDegree: degree of polynomials fit to each whisker
%   whiskerPolysX,Y: X and Y versions of that polynomial
%
% (c) Simon Peron Oct 2010
%
function thetas = computeThetasS (numFrames, numWhiskers, positionType, position, ...
                         lengthAtPolyXYIntersect, lengthMatrix, whiskerPolyDegree, ...
												 whiskerPolysX, whiskerPolysY)
  % --- sanity checks
	if (length(positionType) == 0)
	  disp('computeThetasS: must specify valid positionType.');  return;
	end
	if (positionType > 2 & length(position) == 0)
	  disp('computeThetasS: must specify valid position.');  return;
	end

  % --- set things up
  thetas = nan*ones(numFrames, numWhiskers);
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
		  disp('computeThetas: must specify valid positionType.');  return;
	end

	% --- loop over frames
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
        thetas(f,w) = instantaneousTheta(xPoly, yPoly, l);
			end
    end
    if (rem(f,10000) == 0)
      dtime = toc;
      remFrames = numFrames -f;
            
      disp(['computeThetaS::estimated remaining computation time: ' num2str((dtime/f)*remFrames) ' s']);
    end
	end

%
% single theta evaluation given x and yPoly, length 
%
function theta = instantaneousTheta(xPoly, yPoly, l)
	% derive
	dxPoly = polyder(xPoly);
	dyPoly = polyder(yPoly);

	% solve instantaneous derivatives, second derivatives
	dx = polyval(dxPoly,l);
	dy = polyval(dyPoly,l);

	% plug into theta equation
	% theta = -atand(x'(l)/y'(l)) -- this is because face is @ top
	theta = -1*atand(dx/dy);
