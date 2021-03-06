function cfexcludetableupdated(excl)
%CFEXCLUDETABLEUPDATED  Update exclusion graph in response to a table update
%
%   CFEXCLUDETABLEUPDATED(EXCL) updates the exclusion vector and the
%   graph to reflect the new settings EXCL in the java panel.

% Copyright 2001-2005 The MathWorks, Inc.

% Find the exclusion graph's figure window
t = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
c = get(0,'Child');
f = findobj(c,'flat','Type','figure','Tag','cfexcludegraph');
set(0,'ShowHiddenHandles',t);

if ~isempty(f) && ishandle(f)
   % Call the function that can perform this method
   ud = get(f,'UserData');
   cb = ud{2};
   feval(cb,f,excl,'java');
end

