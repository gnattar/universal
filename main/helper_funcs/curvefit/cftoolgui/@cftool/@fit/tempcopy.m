function f2 = tempcopy(f1)
%TEMPCOPY Create a temporary copy of a fit for saving to a file
%   Omit the lines, which don't save well.
%   This is a temporary copy that should not be added to the database.

% Copyright 2001-2013 The MathWorks, Inc.

% Create a new empty object, not connected to the database
f2 = cftool.fit;
f2 = constructorhelper(f2);

% Remove its listeners
f2.listeners = [];

% Copy fields from the original, except the ones listed here
fields = fieldnames(f1);
toskip = {'line','rline'};
for i=1:length(fields)
   if ~ismember(fields{i},toskip)
      set(f2,fields{i},get(f1,fields{i}));
   end
end
