
%
% Computes the score of particular whisker combo relative last frame -- ONLY
%  considers missingIds in computing score.  Displacement and length change is
%  penalized.  You can pass expected position instead, and then displacement 
%  will be compared to that.
% 
% USAGE:
%  score = wt.getLengthPositionCompositeScore(newIdVec, originalIdVec, missingIds, f)
% 
% originalIdVec: current id
% newIdVec: what the new Id will be
% missingIds: the whiskers evaluated
% f: tested frame -- will look for LAST frame where whisker was present
% posBounds: if present, this is a positional bounds nx3 matrix where column 1 
%         is id and the other 2 are positional bounds that *must* be obeyed or
%         a minimal score is assigned.  Leave blank if not desired.
% expectedPos: vector corresponding to missingIds with expected positions for each
%              whisker; values of nan mean that whisker gets minimal score.
%
function score = getLengthPositionCompositeScore(obj, newIdVec, originalIdVec, missingIds, f, posBounds, expectedPos)
  % --- prelims

  % If a missing whisker is NOT in newIdVec -- i.e., we are testing the 
	%  situation where it is dropped -- this is the equivalent displacement and
	%  change in length that it is being assigned.  Basically, since we want
	%  to maximize score, yet make whisker-dropping possible due to excessive
	%  displacement, a cutoff needs to be set beyond which whiskers are 
	%  simply dropped.  Note that these are NOT rigid cutoffs since it is not 
	%  displacement or length change alone - but rather their combination -
	%  that dictates score.
  dPdefault = 25; % 50 before
	dLdefault = 100; 

  score = 0;

  % --- process inputs
	if (nargin < 6) ; posBounds = [] ; end
	if (nargin < 7) ; expectedPos = [] ; end

  % --- get score for each (missing) whisker
	for m=1:length(missingIds)
	  % default values -- score is going to be 1 divided by this
		%  if these numbers were infinite, whisker absence would never be option
		dP = dPdefault;
		dL = dLdefault;

	  ni = find(newIdVec == missingIds(m));
		% present:
	  if (length(ni) == 1)
		  % get candidate position and length

		  candPosition = obj.getWhiskerPosition(originalIdVec(ni),f);
      candLength= obj.getWhiskerLength(originalIdVec(ni),f);
  
	    % verify that candidate does not violate bounds if they exist
			posValid = 1;
			if (length(posBounds) > 0)
			  ri = find(posBounds(:,1)  == missingIds(m));
				if (length(ri) == 0)% not considered  
				  posValid = 0;
				else
					if (candPosition < posBounds(ri,2) | candPosition > posBounds(ri,3)) ; posValid = 0 ;end % bounds exceeded condition
					if (isnan(posBounds(ri,2)) | isnan(posBounds(ri,3))) ; posValid = 0 ;end % nan bounds condition
				end
		  end
     
		  % get last pos/len
			if (posValid)
			  if (length(expectedPos) > 0) % use EXPECTED position instead of last position
          lastPosition = expectedPos(m);
        else
					lastPosition = obj.getLastWhiskerPosition(missingIds(m), f);
				end
				lastLength = obj.getLastWhiskerLength(missingIds(m), f);
			   
				% nan?
				if (~isnan(lastPosition))
					% dP: bounded by 1
					dP = max(1,abs(lastPosition - candPosition)); 

					% dL: bounded by 1 and 50
					dL = max(1,abs(lastLength - candLength));
%	  			dL = min(dL,50);
				end
			else % this ensures that if posValid is violated, absence will score higher
			  dL = dLdefault+1;
				dP = dPdefault+1;
			end
		end
%if (f == 1341) ; disp([num2str(f) ': id: ' num2str(originalIdVec(ni)) ' assigned to ' num2str(missingIds(m)) ' dp: ' num2str(dP) ' dL: ' num2str(dL)]); end
		% and score . . . 
		%score = score + (1/dP/sqrt(dL));
		score = score + (1/dP/dL);
	end
