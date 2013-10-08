%
% S Peron May 2010
%
% Loads from an "old fashioned" structure format.
%
function obj = loadFromStructFile(obj, sourceFilePath)
  % load it from file in original format
	%  should have n_rois (#rois) and roi struct
	%  roi.color, roi.corners, roi.n_corners, roi.indices, roi.poly_indices,
	%   roi.raw_fluo, roi.groups, roi.misc_vals are members
	oldRois = load(sourceFilePath, '-mat');

	% parse and construct ...
	for r=1:oldRois.n_rois
	  % backward compatibility
	  if(~isfield(oldRois.roi(r),'groups'))
		  oldRois.roi(r).groups = [];
		end

		% and create object
		newRoi = roi.roi(r, oldRois.roi(r).corners, oldRois.roi(r).indices, ...
		  oldRois.roi(r).color, [0 0], oldRois.roi(r).groups);
		obj.addRoi(newRoi);
  end

