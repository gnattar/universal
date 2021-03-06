function hPanel = createEtchedPanel(hParent)
%createEtchedPanel Create a uipanel with etched border
%
%   createEtchedPanel(hParent) creates a uipanel that is correctly set up
%   with the 'etchedin' border type and pixel units.

%   Copyright 2011-2013 The MathWorks, Inc.

hPanel = uipanel(...
    'Parent', hParent, ...
    'Units', 'pixels', ...
    'BorderType', 'etchedin', ...
    'BorderWidth', 1, ...
    'BackgroundColor', sftoolgui.util.backgroundColor() );
end

