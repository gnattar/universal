%
% This will return a *range* of positions in which a particular whisker is likely
%  to reside based on the position of the present whisker(s).
%
% missingIds and presentIds should, upon intersect, constitute 1:numWhiskers. 
%  If this assumption is violated, this will not work right -- no checks are
%  in place because checking would make this slower.
%
% This will ONLY do this for the missing whisker(s) that are present in the
%  MOST RECENT frame relative f.  Thus, if one or more whisker dropped out 
%  prior to this most-recent frame, it will NOT be added.  The idea is to
%  call this method iteratively until it produces no changes.
%
% Depends on updated framesPresent.
%
% USAGE:
%
%   positionRange = wt.getPositionRangeForMissingFromMostRecentlyPresent(missingIds, presentIds, f)
%
%   missingIds: id(s) of missing whiskers ; 1:numWhiskers only.
%   presentIds: id(s) of present whiskers ; 1:numWhiskers only.
%   f: frame at which the range is estimated
%
%   positionRange: len(missing)+len(present)x3 matrix, where column 1 is whisker 
%                  id, and 2 and 3 represent the bounds on that whisker
%                  Note that ALL ids are returned, not just missing.
%
function positionRange = getPositionRangeForMissingFromMostRecentlyPresent (obj, missingIds, presentIds, f)
	minDp = 10; % applied to first and last whisker as range -- will add/subtract @ least this from the guessed position
	            %  important for whiskers that clump
 
	% for each missing ID, determine last frame present, then for the most recent
	%  whisker(s) determine consensus position
	lfp = nan*missingIds;
	for m=1:length(missingIds)
	  for p=1:length(presentIds)
			mrof = obj.getMostRecentOverlapFrame(missingIds(m), presentIds(p), f);
			if (mrof > 0)
			  if (obj.correctionTemporalDirection == 1)
					lfp(m) = max(lfp(m), mrof);
				else
					lfp(m) = min(lfp(m), mrof);
				end
			end
		end
	end

	% and now gather positons
	mp = nan*missingIds;
	pp_f = obj.getWhiskerPosition(presentIds, f);
	for m=1:length(missingIds)
	  if (~isnan(lfp(m)))
			mp_f = nan*presentIds;

			% loop thru present Ids 
			m_olf = obj.getWhiskerPosition(missingIds(m),lfp(m));
			for p=1:length(presentIds)
				% consider this whisker?
				if (obj.framesPresent(presentIds(p),lfp(m)))
					p_olf = obj.getWhiskerPosition(presentIds(p), lfp(m));
					mp_f(p) = m_olf + pp_f(p) - p_olf;
				end
			end

			% compute consessus
			mp(m) = nanmean(mp_f);
		end
	end


  % construct id composite
  if (size(missingIds,1) > 1) ; missingIds = missingIds' ; end
  if (size(presentIds,1) > 1) ; presentIds = presentIds' ; end
	allIds = sort([missingIds presentIds]);
	allPositions = nan*allIds;
	for a=1:length(allIds)
	  mi = find(missingIds == allIds(a));
		if (length(mi) > 0) % this is missing
		  allPositions(a) = mp(mi);
		else % present - so just grab position
		  allPositions(a) = obj.getWhiskerPosition(allIds(a),f);
		end
	end

  % and setup positionRange
	dEP = floor(abs(diff(allPositions)/2));
  positionRange = nan*ones(obj.numWhiskers,3);
	positionRange(:,1) = allIds;
	for w=1:obj.numWhiskers
	  mi = find(missingIds == w);
	  if (length(mi) == 1) % missing whisker? if NOT then don't mess with it!
		  if (~ isnan(allPositions(w))) % nan should be rejected
			  if (obj.positionDirection == 1) % L -> r
					if (w == 1) % first whisker -- left-to-right means this will be min ; r->L max
					  positionRange(w,:) = [w max(0, allPositions(w)-max(minDp,dEP(1))) allPositions(w)+max(minDp,dEP(1))];
					elseif (w == obj.numWhiskers) % last whisker: L->R this is max; R->L this is min
					  positionRange(w,:) = [w allPositions(w)-max(minDp,dEP(w-1)) allPositions(w)+max(minDp,dEP(w-1))];
					else % all others
					  positionRange(w,:) = [w allPositions(w)-max(minDp,dEP(w-1)) allPositions(w)+max(minDp,dEP(w))];
					end
				else % r -> l
					if (w == 1) % first whisker -- left-to-right means this will be min ; r->L max
					  positionRange(w,:) = [w allPositions(w)-max(minDp,dEP(w)) allPositions(w)+max(minDp,dEP(w))];
					elseif (w == obj.numWhiskers) % last whisker: L->R this is max; R->L this is min
					  positionRange(w,:) = [w max(0, allPositions(w)-max(minDp,dEP(w-1))) allPositions(w)+max(minDp,dEP(w-1))];
					else % all others
					  positionRange(w,:) = [w allPositions(w)-max(minDp,dEP(w)) allPositions(w)+max(minDp,dEP(w-1))];
					end
				end
			end
		else % present whisker?
		  positionRange(w,:) = [w allPositions(w) allPositions(w)];
		end
	end
