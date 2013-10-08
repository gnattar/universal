%
% SP May 2010
%
% This defines a class for dealing with arrays of ROI groups
%
classdef roiGroupArray < handle
  % Properties
  properties 
	  % basic
		groups = {}; % stores individual groups
		groupIds = []; % keep track of group IDs

		% sets -- all have same indexing
		setIds= []; % numerical ID for sets
		setDescrStrs = {} ; % description of sets
		setMembers = {}; % cell with variable-sized arrays of group IDs in each set
  end

	% Methods -- public
  methods (Access = public)
	  %
	  % Constructor
		%
    function obj = roiGroupArray(newGroups, newSetIds, newSetDescrStrs, newSetMembers)
		  % empty?
			if (nargin == 4)
			  obj.groups = newGroups;
			  obj.setIds = newSetIds;
			  obj.setDescrStrs = newSetDescrStrs;
			  obj.setMembers = newSetMembers;
			elseif (nargin == 1)
			  obj.addGroups(newGroups);
			end
		end

		% 
		% Returns a copy of this roiGroupArray
		%
		function newRoiGroupArray = copy(obj)
		  for g=1:length(obj.groups)
			  newGroups{g} = obj.groups{g}.copy();
			end
			newRoiGroupArray = roi.roiGroupArray(newGroups, obj.setIds, obj.setDescrStrs, obj.setMembers);
		  
		end


    %
		% add group(s) to the group array
		%
		function obj = addGroups(obj, newGroups)
		  if (~ iscell(newGroups)) ; newGroups = {newGroups} ; end
		  % check for uniqueness ...
			for g=1:length(newGroups)
			  if (length(find(obj.groupIds == newGroups{g}.id)) == 0)
				  idx = length(obj.groups) + 1;
          obj.groups{idx} = newGroups{g};
          obj.groupIds(idx) = newGroups{g}.id;
				end
			end
		end

    %
		% This will merge this groupArray with the passed one, giving precedence to
		%  the current object (i.e., conflict means keep what you have)
		% 
		function obj = addFromOtherGroupArray(obj, otherGroupArray)
		  % groups
			for g=1:length(otherGroupArray.groups)
			  if (length(find(obj.groupIds == otherGroupArray.groups{g}.id)) == 0)
				  obj.addGroups(otherGroupArray.groups{g});
				end
			end

			% group sets
			for s=1:length(otherGroupArray.setIds)
			  if (length(find(obj.setIds == otherGroupArray.setIds(s))) == 0)
			    obj.addSet(otherGroupArray.setIds(s), otherGroupArray.setDescrStrs{s}, otherGroupArray.setMembers{s});
				end
			end
		end
	

		% 
		% add a new set
		% 
		function obj = addSet(obj, newSetId, newSetDescrStr, newSetMembers)
		  idx = length(obj.setIds) + 1;
			if (length(find(obj.setIds == newSetId)) == 0)
				obj.setIds(idx) = newSetId;
				obj.setDescrStrs{idx} = newSetDescrStr;
				if (nargin > 3)
					obj.setMembers{idx} = newSetMembers;
				end
			else
			  disp('roiGroupArray.addSet::set already present.');
			end
		end

    % 
		% Adds group(s) to set, by ID
		%
		function obj = addGroupsToSet(obj, setId, groupIds)
		  idx = find(obj.setIds == setId);
			for g=1:length(groupIds)
			  % make sure the group is in here ...
				gidx = find(obj.groupIds == groupIds(g));
				if (length(gidx) == 0)
				  disp('roiGroupArray.addGroupsToSet::group must be in roiGroupArray.');
				else
				  if (length(find(obj.setMembers{idx} == groupIds(g))) == 0)
					  obj.setMembers{idx}(length(obj.setMembers{idx})+1) = groupIds(g);
					end
				end
			end
		end

    % 
		% Remove group(s) from set, by ID
		%
		function obj = removeGroupsFromSet(obj, setId, groupIds)
		  idx = find(obj.setIds == setId);
			for g=1:length(groupIds)
			  % make sure the group is in here ...
				removeIdx = find(obj.setMembers{idx} == groupIds(g));
			  if (length(removeIdx) > 0)
			    keepIdx = setdiff(1:length(obj.setMembers{idx}), removeIdx);
					obj.setMembers{idx} = obj.setMembers{idx}(keepIdx);
				end
			end
		end

		% 
		% returns groups in given set
		%
		function groups = getGroupsInSet(obj, setId)
		  idx = find(obj.setIds == setId);
			groups = {};
			if (length(idx) > 0)
			  for g=1:length(obj.setMembers{idx})
				  gidx = find(obj.groupIds == obj.setMembers{idx}(g));
				  groups{g} = obj.groups{gidx};
				end
			end
		end

		%
		% Returns a group given group ID
		%
		function group = getGroup(obj, groupId)
		  idx = find(obj.groupIds == groupId);
			group = {};
			if (length(idx) > 0)
			  group = obj.groups{idx};
			end
		end
		  

		% 
		% returns indices of groups in set
		%
		function groupIds = getIdsOfGroupsInSet(obj, setId)
		  idx = find(obj.setIds == setId);
			groupIds = [];
			if (length(idx) > 0)
			  for g=1:length(obj.setMembers{idx})
				  groupIds(g) = obj.setMembers{idx}(g);
				end
			end
		end

	end

  % Static methods 
	methods (Static)
	  defaultGroupArray = generateDefaultGroupArray()
	end

  % Methods -- set/get/basic variable manipulation stuff
	methods 
	end
end

