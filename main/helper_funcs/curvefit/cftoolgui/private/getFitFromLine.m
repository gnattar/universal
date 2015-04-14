function f = getFitFromLine( h )
% getFitFromLine   Get a fit object (cftool.fit) from a line
%
% Syntax:
%   aFitf = getFitFromLine( aLine )

% Copyright 2013 The MathWorks, Inc.

try
    f = iGetFitDirectFromLine( h );
catch
    f = iFindFitThatHoldsLine( h );
end
end

function f = iGetFitDirectFromLine( h )
h = handle( h );
f = h.fit;
end

function aFit = iFindFitThatHoldsLine( theLine )
aFit = iFirstFit();
while ~isempty( aFit ) && ~iFitHoldsLine( aFit, theLine )
    aFit = aFit.right;
end
end

function aFit = iFirstFit()
fitDB = cfgetset( 'thefitdb' );
aFit = fitDB.down;
end

function tf = iFitHoldsLine( aFit, theLine )
try
    tf = aFit.line.isComposedOf( theLine );
catch
    % By default, the fit does NOT hold the line
    tf = false;
end
end