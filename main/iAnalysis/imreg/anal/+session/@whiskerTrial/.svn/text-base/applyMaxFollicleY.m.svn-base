%
% This will apply maxFollicleY threshold to all whiskers id > 0 -- thus, all
%  whiskers where their MINIMAL Y (i.e., follicle Y) > maxFollicleY are 
%  assigned ID 0
%
function obj = applyMaxFollicleY (obj)
  obj.enableWhiskerData();

	% THIS IS THE RIGHT WAY, but SLOW -- to FIX you should store follicleXY 
	%     in a 2xn matrix indexed a la positionMatrix
if ( 1 == 0 )
	for f=1:obj.numFrames
		fpmi = find (obj.positionMatrix(:,1) == f);
	  for w=1:length(obj.whiskerData(f).whisker)
		  if (obj.whiskerData(f).whisker(w).follicleXY(2) > obj.maxFollicleY)
			  obj.positionMatrix(fpmi(w)-1,2) = 0;
			end
		end
  end
	% old way, but fast (though above would be super fast if we had it in a matrix)
else
	for f=1:obj.numFrames
    startIdx = min(find(obj.positionMatrix(:,1) == f));
    endIdx = max(find(obj.positionMatrix(:,1) == f));
		frameIdx = startIdx:endIdx;
		ws = find(obj.positionMatrix(frameIdx,2) > 0);
		for w=1:length(ws)
			minY = min(obj.whiskerData(f).whisker(ws(w)).y);
			if (minY > obj.maxFollicleY) 
				obj.positionMatrix(frameIdx(ws(w)),2) = 0;
			end
		end
	end
end
