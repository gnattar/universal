%
% SP Aug 2010
%
% Will assign to the obj.numWhiskers longest whiskers ID based on the x coordinate
%  of the point with the lowest y value (top).  Lowest x is 1, then 2, and
%  so on.  All other whiskers get ID 0.
%
% Retrieves obj.numWhiskers whiskers; excludes follicles whose min Y exceeds
%  obj.maxFollicleY.
%
% USAGE:
%
%   assignIdFromPosition()
%
% Uses: 
%   obj.positionDirection
%            1: from left to right [direction of numbering] 
%           -1: from right to left
%           This is useful if a whisker often drops out - for instance, if the
%           leftmost whisker often drops out, number from right to left.
%
function obj = assignIdFromPosition(obj)
  % sanity
	if (obj.messageLevel >= 1) ; disp(['assignIdFromPosition::processing ' obj.basePathName]); end
	obj.refreshWhiskerIds();

  % main loop
	if (obj.waitBar) ; wb = waitbar(0, 'Assigning ID from position ...'); end
	for F=1:length(obj.frames) % loop thru frames
	  f = obj.frames(F);
	  if (obj.waitBar) ; waitbar(F/length(obj.frames), wb, 'Assigning ID from position ...'); end
    obj.forceOrderingAtFrame(f,3);
	end
	if (obj.waitBar) ; delete(wb) ; end

	obj.refreshWhiskerIds();
	obj.updateFramesPresent();


