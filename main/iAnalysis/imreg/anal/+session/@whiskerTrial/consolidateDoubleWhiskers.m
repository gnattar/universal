%
% SP Jun 2011
%
% This method will take whiskers whose tags overlap - e.g., c1 c1b - and merge
%  them into one, always selecting the longest one.
%
% USAGE:
%
%   status = wt.consolidateDoubleWhiskers(cleanup)
%
% PARAMS:
%
%   status: 0 if nothing was done ; otherwise 1
%
%   cleanup: if 1, will rescore, run some other stuff ; default yes
%
function status = consolidateDoubleWhiskers(obj,cleanup)

  % --- inputs
	status = 1;
	if (nargin < 2) ; cleanup =1; end

  % --- redundancy locator
	redundantPairs = {};
	redundantPairKeptIdx = [];
	redundantPairDroppedIdx = [];
	for w=1:length(obj.whiskerTag)
	  if (sum(strncmp(obj.whiskerTag,obj.whiskerTag{w},length(obj.whiskerTag{w}))) > 1) 
	    idx = strncmp(obj.whiskerTag,obj.whiskerTag{w},length(obj.whiskerTag{w})); 
		  redundantPairs{length(redundantPairs)+1} = obj.whiskerTag(find(idx));
			redundantPairKeptIdx(length(redundantPairKeptIdx)+1) = w;
			redundantPairDroppedIdx(length(redundantPairDroppedIdx)+1) = setdiff(find(idx),w);
		end
	end

  % don't waste my time
  if (length(redundantPairs) == 0) 
	  disp('consolidateDoubleWhiskers::no doublets found.'); 
		status = 0;
		return;
	end

  % --- and process the pairs
	obj.removeExtraWhiskers([],1); % prepare position matrix ...
	for r=1:length(redundantPairs)
	  if (length(redundantPairs{r}) ~= 2) ; disp('consolidateDoubleWhiskers::only works for double whiskers, not n whiskers!') ; continue ; end
	  widx1 = find(strcmp(obj.whiskerTag, redundantPairs{r}{1}));
	  widx2 = find(strcmp(obj.whiskerTag, redundantPairs{r}{2}));
	  % update positionMatrix based on longest @ each frame ; remove redundant id from posMat altogether
		for F=1:obj.numFrames
		  f = obj.frames(F);
		  fidx = find(obj.positionMatrix(:,1) == f);
      
			cidx1 = fidx(find(obj.positionMatrix(fidx,2) == widx1));
			cidx2 = fidx(find(obj.positionMatrix(fidx,2) == widx2));

			% both?
			if (length(cidx1) == 1 & length(cidx2) == 1)
			  l1 = obj.lengthVector(cidx1);
				l2 = obj.lengthVector(cidx2);

        % remove one or the other
				if (l1 > l2) 
				  obj.positionMatrix(cidx2,2) = 0;
				  obj.positionMatrix(cidx1,2) = redundantPairKeptIdx(r);
				else
				  obj.positionMatrix(cidx1,2) = 0;
				  obj.positionMatrix(cidx2,2) = redundantPairKeptIdx(r);
				end
			elseif (length(cidx1) == 1)
			  obj.positionMatrix(cidx1,2) = redundantPairKeptIdx(r);
			elseif (length(cidx2) == 1)
				obj.positionMatrix(cidx2,2) = redundantPairKeptIdx(r);
			end
		end
	end

  % remap whiskerId/positionMatrix(:,2) so that you comply with 1:numWhiskers 
	%  with NEW # whiskers
	oldIds = sort(setdiff(1:obj.numWhiskers, redundantPairDroppedIdx));
	newIds = 1:(obj.numWhiskers - length(redundantPairDroppedIdx));
	for i=1:length(newIds)
	  oi = find(obj.positionMatrix(:,2) == oldIds(i));
	  wt.positionMatrix(oi,2) = newIds(i);
	end

	% new whiskerTag, numWhiskers
	obj.whiskerIds = sort(unique(obj.positionMatrix(:,2)));
	obj.whiskerTag = obj.whiskerTag(oldIds);
	obj.numWhiskers = length(obj.whiskerTag);

  % update frames present
	obj.updateFramesPresent();

	% compute whisker params
	obj.computeWhiskerParams(1);

	% --- cleanup?
  if (cleanup)
	  % rescore
	  obj.lastLinkPositionMatrixScore = obj.scorePositionMatrix;

    % clean
		obj.removeWhiskerIdDuplicates(); % remove dupes
		obj.removeExtraWhiskers([],1);
		obj.refreshWhiskerIds();
		obj.assignRandomColors();
		obj.updateWhiskerData(); 
	end
