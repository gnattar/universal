%
% S PEron May 2010
%
% Fills the ROI upto border via MATLAB's inpolygon.  Must pass
%  roiArray.workingImageXMat and YMat.
%
% USAGE:
%
%   roi.fillToBorder(XMat, YMat)
%    
% PARAMS:
%
%   XMat, YMat: matrices where the value represents the x, y coordinate 
%               respectively (roiArray.workingImageXMat and YMat, e.g.)
%
function obj = fillToBorder(obj, XMat, YMat)
	xv = obj.corners(1,:);
	xv = [xv xv(1)]';
	yv = obj.corners(2,:);
	yv = [yv yv(1)]';
	in = inpolygon(XMat, YMat, xv, yv);
	obj.indices = find(in == 1);
