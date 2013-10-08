%
% SP May 2010
%
% This defines a class for dealing with ROI groups; basically a data storage
%  class that roiGroupArray talks to.  That class is where the action lies.
%
classdef roiGroup < handle
  % Properties
  properties 
	  % basic
		id = -1; % this is the ID of the group ; UNIQUE
		descrStr = ''; % description
    color = ''; % color for Rois when this groups is highlighted
  end

	% Methods -- public
  methods (Access = public)
	  %
	  % Constructor
		%
    function obj = roiGroup(newId, newDescrStr, newColor)
		  % empty?
			if (nargin == 3)
			  obj.id = newId;
			  obj.descrStr = newDescrStr;
			  obj.color = newColor;
			end
		end

    %
		% Returns a new copy of this roiGroup
		%
		function newRoiGroup = copy(obj)
		  newRoiGroup = roi.roiGroup(obj.id, obj.descrStr, obj.color);
		end
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
	end
end

