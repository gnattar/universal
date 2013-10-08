%
% S PEron MAy 2010
%
% This will dilate the specified roi's indices by given amount.
%
% USAGE:
%
%  roi.dilateRoiIndices(numPixels, XMat, YMat)
%
% PARAMS:
%
%  numPixels: by how many pixels?
%  XMat, YMat: matrices where the value represents the x, y coordinate 
%               respectively (roiArray.workingImageXMat and YMat, e.g.)
%
%  
%
function obj = dilateRoiIndices(obj, numPixels, XMat, YMat)
  % --- sanity/arguments
	if (obj.imageBounds(1) == 0 | obj.imageBounds(2) == 0)
	  error('roi.dilateRoiIndices::imageBounds undefined.');
	end

  % --- construct morphological operator
	s1 = obj.imageBounds(1)/min(obj.imageBounds);
	s2 = obj.imageBounds(2)/min(obj.imageBounds);
	cg = customdisk([2*round(numPixels*s2)+1 2*round(numPixels*s1)+1], ...
	  [round(numPixels*s2) round(numPixels*s1)], [round(numPixels*s2) round(numPixels*s1)]+1, 0);

	% --- apply
	base_im = zeros(obj.imageBounds(1), obj.imageBounds(2));

  % dilate it
	base_im = 0*base_im;
	base_im(obj.indices) = 1;
	f_im = imdilate(base_im,cg);
	obj.indices = find(f_im == 1);

  % We fit tight borders in case indices grEWWW
	obj.fitRoiBordersToIndices(XMat, YMat);


