function schema
%
% Copyright 1999-2004 The MathWorks, Inc.

pk = findpackage('cftool');

% Create a new class

c = schema.class(pk, 'outlierdb');

schema.prop(c, 'current', 'string');
p=schema.prop(c, 'listeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
