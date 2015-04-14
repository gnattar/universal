function schema
% @cftool/@boundedline/schema.m   Schema for this UDD object.
%
% See also @cftool/@boundedline/boundedline.m

%   Copyright 2000-2013 The MathWorks, Inc.

pkg = findpackage('cftool');  % get handle to cftool package
hgpkg = findpackage('hg');    % get handle to hg package

% Create a new subclass of the HG line object
c = schema.class(pkg, 'boundedline', hgpkg.findclass('line'));

% Add hidden property 'Function'
% Must be function, e.g. inline object, function handle,
%   or name (string) of function
p = schema.prop(c, 'Function', 'mxArray');
p.AccessFlags.PublicSet = 'off';            % No listener since not settable
schema.prop(c,'fit','MATLAB array');         % cftool/fit object

% Add hidden property 'BoundLines'
% Vector of handles to two confidence bound lines
p = schema.prop(c, 'BoundLines', 'mxArray');
p.AccessFlags.PublicSet = 'off';            % No listener since not settable

% Add hidden properties 'XLim' and 'YLim'
% Vector of min and max X and Y values
p = schema.prop(c, 'XLim', 'mxArray');
p.AccessFlags.PublicSet = 'off';            % No listener since not settable
p = schema.prop(c, 'YLim', 'mxArray');
p.AccessFlags.PublicSet = 'off';            % No listener since not settable

% Add visible property Granularity
% which determines how many data points are used
p = schema.prop(c, 'Granularity', 'int');
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.Init = 'on';

% Add visible property UserArgs
% because some functions have extra params: fun(xdata, UserArgs{:})
p = schema.prop(c, 'UserArgs', 'mxArray');
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.Init = 'on';

% Add visible property String
% used to provide text for data tips
p = schema.prop(c, 'String', 'string');
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.Init = 'on';
p.SetFunction = @iSetString;

% Add visible property ShowBounds
% controls whether the confidence bounds are shown
p = schema.prop(c, 'ShowBounds', 'on/off');
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.Init = 'on';

% Add visible property ConfLevel
% controls the confidence level
p = schema.prop(c, 'ConfLevel', 'double');
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.Init = 'on';

% Add visible property DFE
% controls the degrees of freedom for error
p = schema.prop(c, 'DFE', 'double');
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.Init = 'on';

% Add visible property sse
% controls the sum of squares due to error
p = schema.prop(c, 'SSE', 'double');
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.Init = 'on';

% Add visible property R
% controls the R factor of a qr decomposition of the Jacobian
p = schema.prop(c, 'R', 'MATLAB array');
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.Init = 'on';

% Listeners for Public Properties:
p = schema.prop(c, 'Listeners', 'MATLAB array');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

function string = iSetString(this, string)
set( this, 'DisplayName', string );
if ~isempty( this.BoundLines )
    set( this.BoundLines, 'DisplayName', iNameForPredictionBounds( string ) );
end

function name = iNameForPredictionBounds( fitName )
name = getString( message( 'curvefit:cftoolgui:PredBnds', fitName ) );
