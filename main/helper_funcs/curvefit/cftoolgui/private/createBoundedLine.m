function h = createBoundedLine(fit, bndsonoff, clev, ~, varargin)
% createBoundedLine   Create a "bounded line" object
%
%   H = createBoundedLine(FIT, BNDSONOFF, CLEV, USERARGS, ...) is a bounded line
%   object.
%
%   FIT is a CFTOOL.FIT object.
%
%   BNDSONOFF is either the string 'on' or the string 'off'.
%
%   CLEV is a number between 0 and 100 representing the confidence level to show.
%
%   USERARGS is a cell array of user arguments. Usually this is {FIT.dataset
%   FIT.dshandle}
%
%   The variable part of the argument list is parameter-value pairs for
%   properties of a line. These include line specification and parent.

%   Copyright 2010-2013 The MathWorks, Inc.

% Expected argument list:
%           fit, bndsonoff, clev, {fit.dataset fit.dshandle}, ...
%           'ButtonDownFcn', @cftips,... 1, 2
%           'Color', c, ... 3, 4
%           'Marker', m, ... 5, 6
%           'LineStyle', l, ... 7, 8
%           'LineWidth', w, ... 9, 10
%           'Parent', ax, ... 11, 12
%           'tag', 'curvefit' 13, 14

iGentlyAssertEqual( varargin{1}, 'ButtonDownFcn', '1st varargin should be ''ButtonDownFcn''.' );
buttonDownFcn = varargin{2};

iGentlyAssertEqual( varargin{3}, 'Color', '3rd varargin should be ''Color''.' );
color = varargin{4};

iGentlyAssertEqual( varargin{7}, 'LineStyle', '7th varargin should be ''LineStyle''.' );
style = varargin{8};

iGentlyAssertEqual( varargin{9}, 'LineWidth', '9th varargin should be ''LineWidth''.' );
width = varargin{10};

iGentlyAssertEqual( varargin{11}, 'Parent', '11th varargin should be ''Parent''.' );
anAxes = varargin{12};

contextMenu = iFindContextMenu( anAxes );

h = cftool.BoundedFunctionLine.create( anAxes, ...
    'Fit', fit, ...
    'ShowBounds', bndsonoff, ...
    'ConfLev', clev, ...
    'ContextMenu', contextMenu, ...
    'ButtonDownFcn', buttonDownFcn, ...
    'Color', color, ...
    'LineStyle', style, ...
    'LineWidth', width );

addlistener( h, 'ShowBounds', 'PostSet', iUpdateLegendFcn( anAxes ) );
end

function iGentlyAssertEqual( a, b, diagnostic )
if ~isequal( a, b )
    warning( 'curvefit:createBoundedLine:gentleAssert', ...
        '%s', diagnostic );
end
end

function contextMenu = iFindContextMenu( anAxes )
% iFindContextMenu   Find the context menu to use for the bounded line
%
% The context menu to use for the bounded line is stored in the figure.
aFigure = ancestor( anAxes, 'figure' );
contextMenu = findall( aFigure, 'Type', 'UIContextMenu', 'Tag', 'fitcontext' );
end

function fcn = iUpdateLegendFcn( anAxes )
cffig = ancestor( anAxes, 'figure' );
fcn = @(~,~) cfswitchyard( 'cfupdatelegend', cffig );
end