%
% SP Sept 2010
%
% This will detect bad frames based on follicle base motion being too sudden.
%  Additionally, it will flag as bad frames windowSize following a bad Frame.  
%  It will use obj.correctionTemporalDirection to determine in which direction
%  to pad badFrames.
%
% USES:
%
%  obj.badFrameCriteria to decide which detection criteria to run.
%  obj.correctionTemporalDirection: which way to pad with windowSize?
%
% USAGE:
%
%  obj.detectBadFrames(windowSize)
%
%
function obj = detectBadFrames(obj, windowSize)

  % --- prelims
  if (nargin == 1)
	  windowSize = 0; % by default, no additional frames are tagged
	end
	if (sum(obj.badFrameCriteria) == 0)
	  disp('detectBadFrames::no bad frame criteria set ; no bad frames detected.');
	end

	obj.badFrames = [];

	% --- criteria 1: large jumps in whisker 1-d positon 
	if (obj.badFrameCriteria(1))
	  
		% for each whisker, sd
		sd = nan*ones(1,length(obj.whiskerIds));
		thresh = sd;
		for w=1:length(obj.whiskerIds)
		  pmi = find(obj.positionMatrix(:,2) == obj.whiskerIds(w));
			frames = obj.positionMatrix(pmi,1);
			diffVec = abs(diff(obj.positionMatrix(pmi,2)));

			% determine threshold for each whisker considered
			sd(w) = 1.4826*mad(diffVec);
			thresh(w) = 5*sd(w);

			% find frames that are bad -- threshold in single-frame displacement crossed 
			%  always the pre AND post cross
			bf = find(diffVec > thresh(w));
			bf2 = [bf bf+1];
			obj.badFrames = union(obj.badFrames, frames(bf));
    end

		% assign up 
		if (length(find(sd > 0)) < 1)
		  overallSD = 1; % a value that is quite common
		else
			tmpSD = sd(find(sd > 0));
			overallSD = min(tmpSD); % take mean of SDs > 0
		end
		obj.badFrameDPositionThresh = min(10,5*overallSD); % do not allow > 10
	end

	% --- criteria 2: missing whiskers in a frame relative nWhiskers
	if (obj.badFrameCriteria(2))
	  widVec = 1:obj.numWhiskers;
		for F=1:length(obj.frames)
			f = obj.frames(F);
	    nw = 0;
	    for w=1:length(widVec)
			  if (length(find(obj.positionMatrix(:,1) == f & obj.positionMatrix(:,2) == widVec(w))) > 0) ; nw = nw+1; end
			end
			if( nw < obj.numWhiskers)
				obj.badFrames = union(obj.badFrames, f);
			end
		end
  end

	% --- criteria 3: order violations
	if (obj.badFrameCriteria(3))
    for F=1:length(obj.frames)
		  % determine order ...
			f = obj.frames(F);
			thisOrdering = obj.getWhiskerOrdering(f, 1:obj.numWhiskers);
			thisOrdering = thisOrdering(find(thisOrdering > 0));
 
      % position violation detectino from obj.positionDirection
			diffOrdering = diff(thisOrdering);
			if (obj.positionDirection == 1 & length(find(diffOrdering <0)) > 0) % left-to-right
				obj.badFrames = union(obj.badFrames, f);
			elseif (obj.positionDirection == -1 & length(find(diffOrdering >0)) > 0) % rtl
				obj.badFrames = union(obj.badFrames, f);
			end
		end
  end

  % --- pad from whindowSize
	oBadFrames = obj.badFrames;
	minFrame = min(obj.frames);
	maxFrame = max(obj.frames);
	for f=1:length(oBadFrames)
		bf = oBadFrames(f);
		bf2 = [];
		if (obj.correctionTemporalDirection == 1) % movign forward in time -- use time poitns BEFORE
			bf2 = [bf2 bf:bf+windowSize];
		else % move back
			bf2 = [bf2 bf:-1:bf-windowSize];
		end
		bf2 = unique(bf2);
		bf2 = bf2(find(bf2 > obj.overlapNFramesUsed+minFrame)); % make sure you don't use early frames
		bf2 = bf2(find(bf2 <= maxFrame)); % make sure you didn't overrun end
		obj.badFrames = union(obj.badFrames, bf2);
	end


	if (obj.messageLevel >= 2) 
		disp(['detectBadFrames::found ' num2str(length(obj.badFrames)) ' of ' ...
	      num2str(length(obj.frames)) ' frames to be bad.']); 
	end
