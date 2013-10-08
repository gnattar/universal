%
% This defines a class for dealing with ROIs in imaging data.
%
% CONSTRUCTOR:
%
%   obj = roi.roi(newId, newCorners, newIndices, newColor, newImageBounds, newGroups)
%
% PROPERTIES
%
%   corners: 2xn matrix with coordinates of corners ; corners(1,:) is x
%   id: numerical id of the roi
%
%   indices: indices, within the image, that consitute the pixels of the roi.  
%            This is ultimately all that matters to fluo computations.
%   borderIndices: where the border is ; for display split up.  
%   color: how to display the roi.
%   imageBounds: how big is the image that this roi is part of?
%
%   groups: group IDs of groups that this roi is part of
%   loading: see notes.
%
% NOTES
%
% The class has a loading property that is set to 1 to avoid calling set
%  methods during load.  
%
% (C) Simon Peron May 2010
%
classdef roi < handle
  % Properties
  properties 
	  % basic
	  corners = []; % this is a 2xn matrix storing all the corners of the border ; corners(1,:) is X
		id = -1; % this is the ID of the roi, in context of a roiArray ; -1 implies needs ID

		% image-specific
		indices = []; % these are the indices, within the image, that are used for df/f
		borderIndices = []; % indices of the border; for rapid image rendering
		color = []; % color of the roi for plotting
		imageBounds = [0 0]; % size of the image (imageBounds(1) in Y, imagebounds(2) in x)
		
		% other
		groups = []; % groups that thsi ROI belongs to
		loading;
  end

	% Methods -- public
  methods (Access = public)
	  %
	  % Constructor
		%
    function obj = roi(newId, newCorners, newIndices, newColor, newImageBounds, newGroups)

		  obj.loading = 0;
		  % empty?
			if (nargin == 0)
			elseif(nargin == 1) % just ID
			  obj.id = newId;
			else % everything
			  obj.id = newId;
				obj.corners = newCorners;
				obj.indices = newIndices;
				obj.color = newColor;
				obj.imageBounds = newImageBounds;
				obj.groups = newGroups;
			end
		end

		%
		% Returns a new copy of this roi -- same ID and everything
		%
		function newRoi = copy(obj)
		  newRoi = roi.roi(obj.id, obj.corners, obj.indices, obj.color, obj.imageBounds, obj.groups);
		end

		% 
		% Compares this to another roi object, returning true (1) if they are same, 0 otherwise
		%
		function retVal = isEqual(obj, roiB)
		  retVal = 0;
			if (isobject(roiB) & strcmp(class(roiB),'roi.roi'))
			  retVal = 1;
				if (obj.id ~= roiB.id) ; retVal = 0; end
				vA = reshape(obj.corners,[],1);
				vB = reshape(roiB.corners,[],1);
				if (length(vB) ~= length(vA)) 
				  retVal = 0;
				elseif (sum(vB ~= vA) > 0)
				  retVal = 0;
				end
				if (length(obj.indices) ~= length(roiB.indices)) ; retVal = 0; elseif (sum(obj.indices ~= roiB.indices) > 0) ; retVal = 0 ; end
			end
		end

		% fits ROI border to indices so no space between ROI's index and border
    obj = fitRoiBordersToIndices(obj, XMat, YMat)

		% dilates ROI
    obj = dilateRoiIndices(obj, numPixels, XMat, YMat)
	end

  % Methods -- set/get/basic variable manipulation stuff
	methods 
	  % -- ID ; nothing for now
	  function obj = set.id (obj, newId)
		  obj.id = newId;
		end
	  function value = get.id (obj)
		  value = obj.id;
		end

		% -- corners -- make sure 2 x n, and that the final point is NOT repeat of the first point
		function obj = set.corners (obj, newCorners)
		  if (~obj.loading)
				% sanity checks
				if (size(newCorners,1) ~= 2 & size(newCorners,2) == 2)
					disp('roi.set.corners:corners must be 2xn matrix, not nx2; assuming you meant transpose.');
					obj.corners = newCorners';
					if (obj.imageBounds(1) > 0 & obj.imageBounds(2) > 0)
						obj.assignBorderIndices();
					end
				elseif (size(newCorners,1) ~= 2)
	%			  if (size(newCorners,1) ~= 0 & size(newCorners,2) ~= 0)
	%					disp('roi.set.corners:corners must be 2xn matrix ; setting to nothing.');
	%				end
					obj.corners = [];
				else
					obj.corners = newCorners;
				end

				% check that final point ~= first point
				nc = size(obj.corners,2);
				if (nc > 2)
					if (obj.corners(1,1) == obj.corners(1,nc) & obj.corners(2,1) == obj.corners(2,nc))
						obj.corners = obj.corners(:,1:nc-1);
					end
				end

				% check @ least 3 points
				if (size(obj.corners,2) < 3)
					obj.corners = [];
				else
					% assign borders
					if (obj.imageBounds(1) > 0 & obj.imageBounds(2) > 0)
						obj.assignBorderIndices();
					end
				end
			else % just assign if loading
			  obj.corners = newCorners;
			end
		end

		function value = get.corners(obj)
		  value = obj.corners;
	  end

		% -- indices - just take it
    function obj = set.indices(obj, newIndices)
		  obj.indices = newIndices;
		end
		function value = get.indices(obj)
		  value = obj.indices;
		end

		% -- border indices 
    function obj = set.borderIndices(obj, newBorderIndices)
		  obj.borderIndices = newBorderIndices;
		end
		function value = get.borderIndices(obj)
		  value = obj.borderIndices;
		end

	  % -- color; nothing for now
	  function obj = set.color (obj, newColor)
		  obj.color = newColor;
		end
	  function value = get.color (obj)
		  value = obj.color;
		end

		% -- image bounds -- run assignBorderIndices if new
		function obj = set.imageBounds(obj, newImageBounds)
		  if (~obj.loading) % MATLAB is dumb and callss set methods on load ... dont want that
				if (length(size(newImageBounds)) < 2)
					disp('roi.set.imageBounds::must have at least 2 image dimensions.');
				elseif (size(newImageBounds,1) == 1 & size(newImageBounds,2) == 1)
					disp('roi.set.imageBounds::must have at least 2 image dimensions.');
				elseif (newImageBounds(1) > 0 && newImageBounds(2) > 0 && ...
								(newImageBounds(1) ~= obj.imageBounds(1) | ...
								 newImageBounds(2) ~= obj.imageBounds(2)))
					% assign new image bounds
					obj.imageBounds = newImageBounds(1:2);
					obj.assignBorderIndices();
					obj.updateIndices(obj.imageBounds);
				end
			else % just assign if loading
			  obj.imageBounds = newImageBounds;
			end
		end

	  % -- groups
	  function obj = set.groups (obj, newGroups)
		  obj.groups = newGroups;
		end

	  function value = get.groups (obj)
		  value = obj.groups;
		end

		function inGroup = isInGroup(obj, groupId)
		  inGroup = 0;
		  if (length(find(obj.groups == groupId)) > 0)
			  inGroup = 1;
			end
		end

		function obj = addToGroup(obj, groupId)
		  if (length(find(obj.groups == groupId)) == 0)
			  obj.groups = [obj.groups groupId];
			end
		end

		function obj = removeFromGroup(obj, groupId)
		  if (length(obj.groups) > 0)
				all = 1:length(obj.groups);
				remove = find(obj.groups == groupId);
				newGroups = setdiff(all,remove);
			  obj.groups = obj.groups(newGroups);
			end
		end
	end

  % Static -- file loading
  methods (Static)
		% loading from file
		function obj = loadobj(a)
		  a.loading = 1;
		  obj = a;
			obj.loading = 0;
		end
	end


end

