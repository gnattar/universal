%
% S PEron MAy 2010
%
% This will fit the borders of the ROI tightly to the indices.
%
% USAGE:
%
%  roi.fitRoiBordersToIndices(XMat,YMat)
%
% PARAMS:
%
%   XMat, YMat: matrices where the value represents the x, y coordinate 
%               respectively (roiArray.workingImageXMat and YMat, e.g.)
%
function obj = fitRoiBordersToIndices(obj, XMat, YMat)
	% --- come on do it
	oldIndices = obj.indices;

	% new corners, keep indices
	obj.corners = obj.computeBoundingPoly();

	% build filled 
  obj.fillToBorder(XMat, YMat);

	% index update .. shouldn't change but you neve know
	obj.indices = intersect(obj.indices,oldIndices);


