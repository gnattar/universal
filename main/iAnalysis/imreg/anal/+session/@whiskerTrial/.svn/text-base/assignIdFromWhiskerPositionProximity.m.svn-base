%
% SP Aug 2010
%
% This will assign Ids (link) whiskers based on proximity of follicle base 
%  from frame to frame.
%
% Note that ONLY whiskers with ID > 0 are considered because otherwise all the 
%  hairs around the face make this not work too well.
%
function obj = assignIdFromWhiskerPositionProximity(obj)
disp(['assignIdFromWhiskerPositionProximity::BROOOOKEN !!! DOES NOT SUPPORT NEW positionMatrix']);return;

  % --- prelimes
	if (obj.messageLevel >= 1) ; disp(['assignIdFromWhiskerPositionProximity::processing ' obj.basePathName]); end
  obj.enableWhiskerData();

  % --- initial bad frame detection, variable setting
	obj.detectBadFrames();

  % --- main loop
	if (obj.waitBar) ; wb = waitbar(0, 'Assigning ID from follicle base proximity ...'); end
	for F=1:length(obj.frames) % loop thru frames
	  f = obj.frames(F);
		f2 = f+1;
	  if (obj.waitBar) 
		  waitbar(F/length(obj.frames), wb, ['Assigning ID from follicle base proximity ... frame: ' num2str(f)]); 
		end
		if (length(find (obj.badFrames == f)) == 0) ; continue ; end % skip if this is NOT a bad frame
		if (f2 > obj.numFrames) ; break ; end % done
  
    % whisker loop
		bestDist = [];
		bestId = [];

    % indices that you will look at for this and the next frame -- whiskers
		%  of id < 0 are rejected 
    w1 = unique(obj.whiskerData(f).whiskerId);
		w1 = w1(find(w1 > 0));
    w2 = unique(obj.whiskerData(f2).whiskerId);
		w2 = w2(find(w2 > 0));
    distMat = nan*ones(length(w1), length(w2));

		for i1=1:length(w1);
		  w1i = find(obj.whiskerData(f).whiskerId == w1(i1));
      X1 = obj.whiskerData(f).whisker(w1i).follicleXY(1);
      Y1 = obj.whiskerData(f).whisker(w1i).follicleXY(2);

			% for each whisker, determine best match in NEXT frame
			for i2=1:length(w2)
		    w2i = find(obj.whiskerData(f2).whiskerId == w2(i2));
				X2 = obj.whiskerData(f2).whisker(w2i).follicleXY(1);
				Y2 = obj.whiskerData(f).whisker(w2i).follicleXY(2);
			  
				% distance ...
				distMat(i1,i2) = sqrt( (X1-X2)^2 + (Y1-Y2)^2);
%				distMat(i1,i2) = sqrt( (X1-X2)^2 );
			end
		end

		% reject pairings where distance is too large
		distMat(find(distMat > obj.positionDeltaMax)) = nan;

		% for now easy . . .
		newIds = 0*obj.whiskerData(f2).whiskerId;
		newDists = 0*obj.whiskerData(f2).whiskerId;
		for i1=1:length(w1)
		  % new whisker ID
		  w1i = find(obj.whiskerData(f).whiskerId == w1(i1));
			newWhiskerId = obj.whiskerData(f).whiskerId(w1i);

      % idx to apply it to
		  [minDist minDistIdx] = min (distMat(i1,:));
		  w2i = find(obj.whiskerData(f2).whiskerId == w2(minDistIdx));

      if (newIds(w2i) == 0)
				newIds(w2i) = newWhiskerId;
				newDists(w2i) = minDist;
			elseif (minDist < newDists(w2i))
				newIds(w2i) = newWhiskerId;
				newDists(w2i) = minDist;
			end
		end
		obj.whiskerData(f2).whiskerId = newIds;

		% recalculate to see if next frame is now a bad frame
		obj.updateBadFramesByDisplacementCriterion([f f+1]);
	end

	if (obj.waitBar) ; delete(wb) ; end


