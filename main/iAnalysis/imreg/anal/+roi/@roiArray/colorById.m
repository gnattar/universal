%
% S Peron Dec 2010
%
% This will color the passed Ids by the passed color(s).  If a single color is 
%  passed, all are colored that color.  If multiple colors are passed, they must
%  match roiIds and those Ids will be colored appropriately.
% 
% USAGE:
%  colorByFilled(obj, roiIds, color)
%
% PARAMS:
%  roiIds: the rois to color this way
%  color: colors to apply ; if only one, all are colored
%
function colorById(obj, roiIds, color)

  % argument handling
	if (nargin < 3)
	  disp('colorById::must pass all parameters.');
		help('roi.roiArray.colorById');
		return;
	end
	if (size(color,2) ~= 3)
	  disp('colorById::color must be a 3-column matrix');
	end

	% assign colors
	for r=1:length(roiIds)
	  ri = find(obj.roiIds == roiIds(r));
		if (size(color,1) == 1)
			obj.rois{ri}.color = color;
		else
			obj.rois{ri}.color = color(ri,:);
		end
	end

	% update image
	obj.updateImage();
