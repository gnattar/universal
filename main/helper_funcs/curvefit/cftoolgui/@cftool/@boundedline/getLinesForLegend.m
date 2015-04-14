function handles = getLinesForLegend( this )
% getLinesForLegend   Lines that should be shown on the legend

% Copyright 2013 The MathWorks, Inc.

if iShowBounds( this )
    handles = [double( this ), this.BoundLines(1)];
else
    handles = double( this );
end
end

function tf = iShowBounds( this )
tf = ~isempty( get( this.BoundLines(1), 'XData' ) );
end
