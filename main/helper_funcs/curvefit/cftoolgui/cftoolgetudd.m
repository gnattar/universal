function javaudd=cftoolgetudd(uddcmd,varargin)
% CFTOOLGETUDD is a helper function for CFTOOL

% CFTOOLGETUDD Get UUD objects for Java

%   Copyright 2000-2007 The MathWorks, Inc.


% unwrap any UDD objects
for i=1:length(varargin)
   if isa(varargin{i}, 'com.mathworks.jmi.bean.UDDObject')
      varargin{i}=handle(varargin{i});
   end
end

% wrap the return UDD object
if nargin == 1
   javaudd=java(eval(uddcmd));
else
   javaudd=java(feval(uddcmd,varargin{:}));
end
