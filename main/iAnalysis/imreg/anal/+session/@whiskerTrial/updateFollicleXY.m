%
% SP Sept 2010
%
% This will update, for all whiskers, whiskerData.whisker(x).follicleXY.  It will
%  automatically then run updatePositionMatrix.
%
% If you decide to use the position of short whiskers to compute a follcile base
%  point, set obj.useFaceContour to 1.  This will BREAK if the face is not on the
%  screen.
%
function obj = updateFollicleXY (obj)

  % grab whisker data
  obj.enableWhiskerData();
 
  % --- update follicleXY - using face position -- this takes substantially longer but is more reliable
	if (obj.useFaceContour)
		shortWhiskerMaxLen = 20;

		% first pass - detect follicle contour - based on short whiskers
		obj.loadMovieFrames(1);
		imWidth = obj.whiskerMovieFrames{1}.width;
		imHeight = obj.whiskerMovieFrames{1}.height;
		tempIm = zeros(imHeight, imWidth);
		for f=1:obj.numFrames 
			for w=1:length(obj.whiskerData(f).whisker)
				if (length(obj.whiskerData(f).whisker(w).x) <= shortWhiskerMaxLen);
					fxy = round(obj.whiskerData(f).whisker(w).follicleXY); 
					fxy (find(fxy == 0)) = 1;
					tempIm(fxy(2),fxy(1)) = tempIm(fxy(2),fxy(1))+1; 
				end
			end
		end

		% exclude based on maxFollicleY
		if (obj.maxFollicleY > 0)
			tempIm(obj.maxFollicleY:imHeight,:) = 0;
		end


		% and compute COM off of 100 top points
		[val idx] = sort(reshape(tempIm,[],1),'descend');
		tempIm2 = zeros(size(tempIm));  
		tempIm2(idx(1:100)) = 1; 
		comX = mean(find(mean(tempIm2,1) >0));
		com = [comX 0];
		obj.faceCOM = com;
		if (obj.messageLevel >= 1) ; disp('updateFollicleXY::Current face detection scheme is LAME! UPDATE.') ; end
		% Better scheme: 1) take follicle track of all SHORT (<20 pix) whiskers across all frames
		%                2) cutoff above some Y to omit weird follicles
		%                3) dilate with increasing-size square/disk ...
		%                4) ... test to stop: create label matrix ; if corner with face 
		%                   has label different than all other corners, you are DONE
		%                5) take TRUE face contour -- the edge of the region with face-corner
		%                   (i.e., from labeled matrix) but omit true image edges
		%                6) now you can find points closest to this -- these are DEFINITELY follicles

    if ( 1 == 0 ) % debugZ
			figure
			imshow(tempIm, [0 10]);
			figure
			imshow(tempIm2);
			hold on;
			plot(comX,1,'rx');
			pause
		end

		% and the actual follicle position calculation
		for f=1:obj.numFrames
			for w=1:length(obj.whiskerData(f).whisker)
				% follicle XY based on face conventino
				distances = sqrt( (com(1)-obj.whiskerData(f).whisker(w).x).^2 ...
				                + (com(2)-obj.whiskerData(f).whisker(w).y).^2 );
				[minD minDIdx] = min(distances);
				obj.whiskerData(f).whisker(w).follicleXY =  ...
				  [obj.whiskerData(f).whisker(w).x(minDIdx) obj.whiskerData(f).whisker(w).y(minDIdx)];
			end
		end

  % --- update follicleXY - using minimal Y ; generally works, but above method is better
	else
		% simple
		for f=1:obj.numFrames
			for w=1:length(obj.whiskerData(f).whisker)
				% follicle XY based on face conventino
				[minY minYIdx] = min(obj.whiskerData(f).whisker(w).y);
				minYy = minY;
				minYx = obj.whiskerData(f).whisker(w).x(minYIdx);
				obj.whiskerData(f).whisker(w).follicleXY = [minYx minYy];
			end
		end
	end

	% --- finally, update position matrix if thsi is claled for
	if (obj.positionMatrixMode == 1)
	  obj.updatePositionMatrix();
	end
