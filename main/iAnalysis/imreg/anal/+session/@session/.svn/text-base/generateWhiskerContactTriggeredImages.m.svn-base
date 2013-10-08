%
% SP May 2011
%
% This will generate pro/re contract-triggered images when possible (i.e., enuff
%  contacts exist) and populate roiArray therewith.
%
% USAGE:
%
%  s.generateWhiskerContactTriggeredImages(o, baselineTimeWindow, responseTimeWindow, saveToRoiFile)
%
% PARAMS:
%
%  baselineTimeWindow: in seconds, relative contact (t=0), what time to use for baselien (e.g., [-1 0]).
%  responseTimeWindow: in seconds, relative contact (t=0), what epoch to use for contact
%  saveToRoiFile: default 0 ; if 1, will write roiArray object
%
function obj = generateWhiskerContactTriggeredImages(obj, baselineTimeWindow, responseTimeWindow, saveToRoiFile)
  % --- input
	if (nargin < 3)
	  help('session.session.generateWhiskerContactTriggeredImages');
		return;
	end
	if (nargin < 4) ; saveToRoiFile = 0; end

  % --- do it ...
	for c=1:length(obj.whiskerBarContactClassifiedESA.esa)
  	im = obj.caTSA.getEventTriggeredImage(obj.whiskerBarContactClassifiedESA.esa{c}, responseTimeWindow, ...
		       baselineTimeWindow, 0, obj.whiskerBarContactClassifiedESA.getExcludedCellArray(c),[-2 2]);
		imageName = ['Exclusive ' obj.whiskerBarContactClassifiedESA.esa{c}.idStr];
	  if (length(find(isnan(im))) == prod(size(im))) % try again ...
			im = obj.caTSA.getEventTriggeredImage(obj.whiskerBarContactClassifiedESA.esa{c}, responseTimeWindow, ...
						 baselineTimeWindow, 0);
		  imageName = [obj.whiskerBarContactClassifiedESA.esa{c}.idStr];
		end

	  if (length(find(isnan(im))) < prod(size(im))) % add it
		  obj.caTSA.roiArray.addAccessoryImage(im, imageName);
	  end
	end

	% save?
	if (saveToRoiFile)
	  obj.caTSA.roiArray.saveToFile(obj.caTSA.roiArray.roiFileName, 1);
	end

