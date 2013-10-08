% 
% This will look for overlapping rois and process them according to specified
%  parameters.
%
% USAGE:
%
%   rA.resolveOverlaps(method, params)
%
% PARAMS:
%
%   method: 'com' - points are assigned based on proximity to ROI center, and
%                   on lowid for equidistant points
%           'lowid' - assign based on id primacy, lowest ID getting first dibs
%           'remove' - removes overlap pixels from all ROIs
%
%   params: structure of optional parameters with following fields:
%
% SP Feb 2012
%
function obj = resolveOverlaps (obj, method, params)

  % --- input process
	if (nargin < 2)
	  help ('roi.roiArray.resolveOverlaps');
	  error('resolveOverlaps::must pass method.');
	end

	% --- look for overlaps 

	% generate matrix of size image where first ROI will put its idx (NOT ID
	%  in case of 0 IDs!)
	idxMat = zeros(obj.imageBounds);

	% overlap tracking vector/cell array -- they will have same size, with
	%  overlapIndices storing indices of points within matrix that have multiple
	%  rois, and overlapRoiIds{x} storing corresponding roiIds
	overlapIndices = [];
	overlapRoiIndex = {}; 
	roiIdsAffected = [];
	oL = 1;

	% for each pixel, assign ID of roi that you first encounter with that pixel
  for r=1:length(obj.roiIds)
	  roi = obj.rois{r};

	  firstTime = find(idxMat(roi.indices) == 0);
	  nonZero = find(idxMat(roi.indices) ~= 0);
		
    % first timers
    idxMat(roi.indices(firstTime)) = r;

	  % if nonzero entry, add to overlap list
    if (length(nonZero) > 0)
		  for i=1:length(nonZero)
			  nzi = roi.indices(nonZero(i));
			  oi = find(overlapIndices == nzi);
        if (length(oi) == 0)
				  overlapIndices(oL) = nzi; 
					oi = oL;
					oL = oL+1;
					overlapRoiIndex{oi} = idxMat(nzi);
				  roiIdsAffected = union(roiIdsAffected, obj.roiIds(idxMat(nzi)));
				end
				overlapRoiIndex{oi} = [overlapRoiIndex{oi} r];
				roiIdsAffected = union(roiIdsAffected, obj.roiIds(r));
			end
		end

	end

	% --- resolve them based on method
	switch method
	  case 'com' % center-of-mass -- closest wins
		  % for each roi, get COM -- take MEDIAN to prevent undue influence of outlier points
      com = zeros(2,length(obj.rois));
			for r=1:length(obj.rois)
			  com(1,r) = median(obj.workingImageXMat(obj.rois{r}.indices));
			  com(2,r) = median(obj.workingImageYMat(obj.rois{r}.indices));
			end

			% now resolve conflict points by computing com distance
		  for o=1:length(overlapIndices)
			  distance = zeros(1,length(overlapRoiIndex{o}));
			  ox = obj.workingImageXMat(overlapIndices(o));
			  oy = obj.workingImageYMat(overlapIndices(o));
			  for r=1:length(overlapRoiIndex{o})
				  distance(r) = sqrt((ox-com(1,overlapRoiIndex{o}(r)))^2 + (oy-com(2,overlapRoiIndex{o}(r)))^2 );
				end

			  % find min distance ... 
				[irr mdi] = min(distance);
				mdi = mdi(1); % in case multiples ...

				% remove from all others
				overlapRoiIndex{o};
				remFromIdx = setdiff(overlapRoiIndex{o}, overlapRoiIndex{o}(mdi));
				for r=1:length(remFromIdx)
				  roi = obj.rois{remFromIdx(r)};
					roi.indices = setdiff(roi.indices,overlapIndices(o));
				end
			end

		case 'remove' % remove anything that is shared
		  for o=1:length(overlapIndices)
			  for r=1:length(overlapRoiIndex{o})
				  roi = obj.rois{overlapRoiIndex{o}(r)};
					roi.indices = setdiff(roi.indices,overlapIndices(o));
				end
			end

		case 'lowid' % give to lowest id
		  for o=1:length(overlapIndices)
			  for r=2:length(overlapRoiIndex{o})
				  roi = obj.rois{overlapRoiIndex{o}(r)};
					roi.indices = setdiff(roi.indices,overlapIndices(o));
				end
			end


    otherwise
		  disp('roi.roiArray.resolveOverlaps::invalid method specified.');
	end

	% --- cleanup

	% tight borders
  obj.fitRoiBordersToIndices(roiIdsAffected);

	if (0)
		idxMat (find(idxMat > 1)) = 1;
		idxMat(overlapIndices) = 2;
		figure ; imshow(idxMat, [0 max(max(idxMat))]) ; 
		%hold on ; plot(com(1,:), com(2,:), 'rx');
	end
