%
% S Peron May 2010
%
% Loads from an "old fashioned" rtrk structure format.
%
function obj = loadFromRtrkFile(obj, sourceFilePath)
  % use extern_rtrk2roi
	oldRois.roi = extern_rtrk2roi(sourceFilePath);

	% parse and construct ...
	for r=1:length(oldRois.roi)
		newRoi = roi.roi(r, oldRois.roi(r).corners, oldRois.roi(r).indices, ...
		  oldRois.roi(r).color, [0 0], oldRois.roi(r).groups);
		obj.addRoi(newRoi);
  end
