%
% SP Sept 2010
%
% This will update the whisker position matrix at frame f, where f is 
%  an indexing for obj.whiskerData (i.e., if obj.frames is NOT 
%  1:obj.numFrames, then use f = obj.frames(X)).
%
% Position matrix has 3 columns, [f, w, p] where f is frame #, w is whisker ID
%  and p is position.  f should never change, nor should p unless positionMatrixMode
%  is updated.  A given row should always be for a given whisker -- the 
%  whiskerData(f).whisker(w) order is respected for p.
%
% lengthVector is also updated - a vector that stores lengths of whiskers.
%
% USAGE:
%
%   obj.updatePositionMatrix(f)
%
%   If f is not specified, does ALL of them.
%
function obj = updatePositionMatrix(obj, f)
	mode = obj.positionMatrixMode;
	updateIWM = 0;
  obj.enableWhiskerData();

  if (nargin == 2) % single frame -- lengthVector need not be touched here
	  positionMatrix = obj.positionMatrix;
		lengthVector = obj.lengthVector; % copy so that assignment below works

		% populate positionMatrix, lengthVector
		pmi = min(find(positionMatrix(:,1) == f));
  	switch mode
		  case 1 % follicle XY
					for w=1:length(obj.whiskerData(f).whiskerId)
					  positionMatrix (pmi,:) = [f obj.whiskerData(f).whiskerId(w) obj.whiskerData(f).whisker(w).follicleXY(1)];
						pmi = pmi+1;
					end
 
			case 2 % intersect XY
					for w=1:length(obj.whiskerData(f).whiskerId)
					  positionMatrix (pmi,:) = [f obj.whiskerData(f).whiskerId(w) obj.whiskerData(f).whisker(w).polynomialIntersectXY(1)];
						pmi = pmi+1;
					end

			case 3 % polynomial arc
					for w=1:length(obj.whiskerData(f).whiskerId)
					  positionMatrix (pmi,:) = [f obj.whiskerData(f).whiskerId(w) obj.whiskerData(f).whisker(w).polynomialArcPosition(1)];
						pmi = pmi+1;
					end
		end

	else % ALL of them -- for some reason not accessing obj is faster so . . .
	  updateIWM = 1;
		if (obj.messageLevel >= 2) ; disp('updatePositionMatrix::This function DOES NOT recompute positions; call appropriate update functions first.'); end
    
		% create a blank matrix
		np = 0;
		for f=1:obj.numFrames ;  np=np+length(obj.whiskerData(f).whisker) ; end 
		positionMatrix = nan*ones(np,3);
		lengthVector = nan*ones(np,1);

		% check for < 0
		if (length(find(obj.whiskerIds < 0)) > 0)
		  disp('updatePositionMatrix::Found a whiskerId < 0 ; this is NOT allowed.');
			return;
		end

		% loop over frames
		pmi = 1;
  	switch mode
		  case 1 % follicle XY
				for f=1:obj.numFrames 
					for w=1:length(obj.whiskerData(f).whiskerId)
					  positionMatrix (pmi,:) = [f obj.whiskerData(f).whiskerId(w) obj.whiskerData(f).whisker(w).follicleXY(1)];
						lengthVector(pmi) = obj.whiskerData(f).whiskerLength(w);
						pmi = pmi+1;
					end
				end
 
			case 2 % intersect XY
				for f=1:obj.numFrames 
					for w=1:length(obj.whiskerData(f).whiskerId)
					  positionMatrix (pmi,:) = [f obj.whiskerData(f).whiskerId(w) obj.whiskerData(f).whisker(w).polynomialIntersectXY(1)];
						lengthVector(pmi) = obj.whiskerData(f).whiskerLength(w);
						pmi = pmi+1;
					end
				end

			case 3 % polynomial arc
				for f=1:obj.numFrames 
					for w=1:length(obj.whiskerData(f).whiskerId)
					  positionMatrix (pmi,:) = [f obj.whiskerData(f).whiskerId(w) obj.whiskerData(f).whisker(w).polynomialArcPosition(1)];
						lengthVector(pmi) = obj.whiskerData(f).whiskerLength(w);
						pmi = pmi+1;
					end
				end
		end
  end

  % clean up nan positions -- this automatically consigns you to ID 0!
	nanPositions = find(isnan(positionMatrix(:,3)));
	positionMatrix(nanPositions,2) = 0;

	% update the actual position matrix -- implement local copy above because it makes it faster
	%  (why?  I dont know but matlab is weird like that)
	obj.positionMatrix = positionMatrix;
	obj.lengthVector = lengthVector;

  % Make sure obj.whiskerIds is current
	obj.refreshWhiskerIds();

	% update interwhisker matrix
	if (updateIWM)
		obj.updateInterWhiskerDistanceMatrix();
	end
