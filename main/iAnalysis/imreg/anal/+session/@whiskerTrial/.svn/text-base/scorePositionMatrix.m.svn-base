%
% SP Oct 2010
%
% This will return several scoring metrics about positionMatrix.  Note that 
%   it runs applyLengthThreshold and applyMaxFollicleY. 'b' whiskers (i.e.,
%   anytime you have c3 c3b, or A2 A2x, the one that is part of the other is
%   considered redundant and is not scored)
%
% USAGE:
%   scores = wt.scorePositionMatrix()
%
%   scores: 1 - fraction of frames with ALL whiskers 
%   scores: 2 - fraction of frames where not all whiskers are BUT some whiskers
%               not assigned 1:numWhiskers but meeting length, maxFollicleY
%               criteria are present
function scores = scorePositionMatrix(obj)

  % 0) prepare data
  obj.enableWhiskerData();
  nFrames = length(obj.whiskerData);
	obj.updateFramesPresent();

  % 1) find 'b' whiskers -- these are redundant, and should be folded in with main whisker
	redundant = zeros(1,length(obj.whiskerTag));
	framesPresent = obj.framesPresent;
	for w=1:length(obj.whiskerTag)
	  if (sum(strncmp(obj.whiskerTag,obj.whiskerTag{w},length(obj.whiskerTag{w}))) > 1) 
			redIdx = setdiff(find(strncmp(obj.whiskerTag,obj.whiskerTag{w},length(obj.whiskerTag{w}))), w);
			redundant(redIdx) = 1;
			framesPresent(w,:) = max(framesPresent(w,:),framesPresent(redIdx,:));
		end
	end
	framesPresent = framesPresent(find(~redundant),:);
	whiskerTag = obj.whiskerTag(find(~redundant));
	numWhiskers = length(whiskerTag);

  % 2) get frames where all whiskers appear to be present
	if (obj.numWhiskers > 1)
		allPresentFrames = find(sum(framesPresent) == numWhiskers);
	else
	  allPresentFrames = find(framesPresent);
	end
	notAllPresentFrames = setdiff(1:length(obj.whiskerData), allPresentFrames);
	scores(1)  = length(allPresentFrames)/nFrames;

	% 3) get frames where *not* all are present that DO have stray whiskers
	obj.applyLengthThreshold();
	obj.applyMaxFollicleY();
	numExcess = 0;
  for F=1:length(notAllPresentFrames)
	  f = notAllPresentFrames(F);
		fpmi = find(obj.positionMatrix(:,1) == f);
		if (length(find(obj.positionMatrix(fpmi,2) > numWhiskers)) > 0) ; numExcess = numExcess + 1; end
	end
	scores(2) = numExcess/nFrames;

