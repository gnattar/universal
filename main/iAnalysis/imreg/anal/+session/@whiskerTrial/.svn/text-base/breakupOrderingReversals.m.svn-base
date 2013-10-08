%
% SP Sept 2010
%
% This will break whisker trajectories at places where order is changed between
%  two consecutive frames.  Violation of ordering depends on positionDirection.
%
% USAGE
%
%  obj.breakupOrderingReversals()
%
function obj = breakupOrderingReversals(obj)

  % --- prelims
	if (length(find(diff(obj.frames) < 0)) > 0) ; disp('breakupOrderingReversals::cannot have descending obj.frames.'); return ; end
	if (obj.messageLevel >= 1) ; disp(['breakupOrderingReversals::processing ' obj.basePathName]); end

  % --- fix first frame ...
	obj.forceOrderingAtFrame(obj.frames(1));
 
	% --- detect order flips
	newId = max(obj.whiskerIds)+1;
	for F=2:length(obj.frames) % loop thru ALL frames but then test if bad ...
	  % grab frame
    f = obj.frames(F);
   
	  % start the while loop
		repeatFrame = 1;
    while (repeatFrame)
		  repeatFrame = 0;

			% get the ordering of this frame
			thisOrdering = obj.getWhiskerOrdering(f);
			thisOrdering = thisOrdering(find(thisOrdering > 0));

			% for each (sequential) pair, travel back to last frame w/ both present
			for t=1:length(thisOrdering)-1
				pair = [thisOrdering(t) thisOrdering(t+1)];
      
			  frames1 = unique(obj.positionMatrix(find(obj.positionMatrix(:,2) == pair(1)),1));
			  frames2 = unique(obj.positionMatrix(find(obj.positionMatrix(:,2) == pair(2)),1));
				overlapFrames = intersect(frames1,frames2);
				lastOverlapFrame = max(overlapFrames(find(overlapFrames < f)));


				% get orderings at both frames if available
				if (length(lastOverlapFrame) >0 & length(find(pair == 0)) == 0)
					thisPairOrdering = obj.getWhiskerOrdering(f, pair);
					lastPairOrdering = obj.getWhiskerOrdering(lastOverlapFrame, pair);

					% If there is a discrepancy, break them up and repeat the frame
					if (sum(thisPairOrdering == lastPairOrdering) < 2)
%		disp(['Frame: ' num2str(f) ' last frame: ' num2str(lastOverlapFrame) ' last order: ' num2str(lastPairOrdering) ' this order: ' num2str(thisPairOrdering)]);
						obj.breakupIdSegment (f, pair(1), newId);
						newId = newId+1;
						obj.breakupIdSegment (f, pair(2), newId);
						newId = newId+1;
						repeatFrame = 1;
					end
				end

				% repeatFrame? then break for loo
				if (repeatFrame) ; break ; end
			end
		end
	end


  % --- Update things that need updating and give some messages
	obj.refreshWhiskerIds();
	obj.updateFramesPresent();

