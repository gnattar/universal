%
% S PEron May 2010
%
% This will color ROIs by one of the basic schemes.  
%  schemeId:
%    1: randomly 
%    2: all cyan
%
function obj = colorByBaseScheme(obj, schemeId)
  
	% --- arg chec
	if (nargin == 1)
	  schemeId = 2; % default cyan
	end

	% --- do it

  % preset colors off scheme
  switch (schemeId)
	  case 1 % random
		  colors = [1 0 0 ; 0 1 0 ; 0 0 1 ; 1 0 1 ; 0 1 1];
		case 2
		  colors = [0 0.5 1];
	end

	% loop over rois and set
	c = 1;
	for r=1:length(obj.rois)
	  obj.rois{r}.color = colors(c,:);
		c = c+1;
		if (c > size(colors,1)) ; c = 1 ; end
	end

	% update image
	obj.updateImage();


