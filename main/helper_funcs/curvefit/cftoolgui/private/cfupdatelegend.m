function cfupdatelegend(cffig,reset,leginfo,rleginfo)
%CFUPLDATELEGEND Update legend in curve fitting plot

%   Copyright 2000-2013 The MathWorks, Inc.

if nargin<2,
    reset=false;
end
if nargin<3,
    leginfo={};
end
if nargin<4,
    rleginfo={};
end

% If figure not passed in, find figure that contains this thing
cffig = ancestor(cffig,'figure');

% Remember info about old legend, if any
ax = findall(cffig,'Type','axes','Tag','main');
[leginfo,havelegendloc,relpos] = localgetlegendinfo(cffig,ax,reset,leginfo);
legend(ax, 'off');

% Remember info about old residuals legend, if any
ax2 = findall(cffig,'Type','axes','Tag','resid');
if ~isempty(ax2)
    [rleginfo,haverlegendloc,rrelpos] = localgetlegendinfo(cffig,ax2,reset,rleginfo);
    legend(ax2, 'off');
end

% Maybe no legend has been requested
if isequal(cfgetset('showlegend'),'off')
    return
end

% Get the line handles and labels (captions) for the legend
[h,c] = iHandlesAndLabelsForLegend();

% Create the legend
if ~isempty( h )
   ws = warning;
   lw = lastwarn;
   warning('off', 'all');
   legh = [];
   try
      legh = legend(ax,h,c,leginfo{:});
      if ~havelegendloc && ~isempty(relpos)
          setrelativelegendposition(relpos,cffig,ax,legh);
      end
      localFixContextMenu( legh );
   catch ignore %#ok<NASGU>
   end
   warning(ws);
   lastwarn(lw);
   
   % Avoid treating ds/fit names as TeX strings
   set(legh,'Interpreter','none');
else
    legend(ax,'off');
end

% Set a resize function that will handle legend and layout
set(cffig,'ResizeFcn','cftool(''adjustlayout'');');

% Fix residual legend; this is a lot simpler
if ~isempty(ax2)
    h = flipud(findobj(ax2,'Type','line'));
    c = cell(length(h),1);
    for j=length(h):-1:1
        t = get(h(j),'UserData');
        if iscell(t) && ~isempty( t ) && ischar(t{1}) && ~isempty(t{1})
            c{j} = t{1};
        else
            c(j) = [];
            h(j) = [];
        end
    end
    
    if ~isempty( h )
        ws = warning;
        lw = lastwarn;
        warning('off', 'all');
        legh = [];
        try
            legh = legend(ax2,h,c,rleginfo{:});
            if ~haverlegendloc && ~isempty(rrelpos)
                setrelativelegendposition(rrelpos,cffig,ax2,legh);
            end
            localFixContextMenu( legh );
        catch ignore %#ok<NASGU>
        end
        warning(ws);
        lastwarn(lw);
        
        % Avoid treating ds/fit names as TeX strings
        if ~isempty(legh)
            set(legh,'Interpreter','none');
        end
    else
        legend(ax2,'off');
    end
end
end  

function [leginfo,havelegendloc,relpos] = localgetlegendinfo(cffig,ax,reset,leginfo)
% Get legend information

legh = legend(ax);
relpos = [];
if isempty(leginfo)
    if ~isempty(legh) && ishandle(legh) && ~reset
        leginfo = cfgetlegendinfo(legh);
    else
        leginfo = {};
    end
end

% Loop to find 'Location', as some non-text entries make ismember fail
havelegendloc = false;
for j=1:length(leginfo)
    if isequal('Location',leginfo{j})
        havelegendloc = true;
        break
    end
end
if ~havelegendloc && ~isempty(legh) && ishandle(legh) && ~reset
    relpos = getrelativelegendposition(cffig,ax,legh);
end
end  

function localFixContextMenu( hLegend )
% The legend gets created with a context menu. However this context menu
% has some features that have a destructive affect on CFTOOL. In this
% little function, we remove those features....
cmh = get( hLegend, 'UIContextMenu' );
% The children (menu entries) of the context menu are hidden so we need
% to get around that
h = allchild( cmh );
% Our actions are based on tags of items that appear in the context menu so
% we need to get all of those tags.
tags = get( h, 'Tag' );

% Delete the entries that cause bad things to happen
% Find tags of entries to delete.
TAGS_TO_DELETE = {'scribe:legend:mcode', 'scribe:legend:propedit', 'scribe:legend:interpreter'};
tf = ismember( tags, TAGS_TO_DELETE );
delete( h(tf) );

% For the 'Delete' item, we want to redirect the call to the CFTOOL
% legend toggle function
tf = ismember( tags, 'scribe:legend:delete' );
set( h(tf), 'Callback', @(s, e) cftool( 'togglelegend', 'off' ) );

% For the 'Refresh' item, we want to redirect the callback to reset the
% properties of the legend, e.g., the colour and font.
tf = ismember( tags, 'scribe:legend:refresh' );
set( h(tf), 'Callback', @(s, e) cfupdatelegend( cfgetset( 'cffig' ), true ) );
end  

function [lines, labels] = iHandlesAndLabelsForLegend()
lines = iLinesInLegendOrder();
labels = arrayfun( @iGetDisplayName, lines, 'UniformOutput', false );
end

function name = iGetDisplayName( aLine ) 
name = get( aLine, 'DisplayName' );
end

function lines = iLinesInLegendOrder()
lines = gobjects( 0 );

% For each data set,
% ... add its line to the list
% ... add the lines for its fits
aDataset = iFirstDataset();
while ~isempty( aDataset )
    lines = [lines, aDataset.line, iLinesForFitsTo( aDataset )]; %#ok<AGROW>
    aDataset = aDataset.right;
end
end

function aDataset = iFirstDataset()
fitDB = getdsdb();
aDataset = fitDB.down;
end

function lines = iLinesForFitsTo( aDataset )
lines = gobjects( 0 );

aFit = iFirstFit();
while ~isempty( aFit ) 
    if isequal( aFit.dshandle, aDataset )
        lines = [lines, iGetFitLinesForLegend( aFit )]; %#ok<AGROW>
    end
    aFit = aFit.right;
end
end

function aFit = iFirstFit()
fitDB = getfitdb();
aFit = fitDB.down;
end

function lines = iGetFitLinesForLegend( aFit )
% iGetFitLinesForLegend   Call getLinesForLegend with protection against an empty
% line.
if isempty( aFit.line )
    lines = [];
else
    lines = getLinesForLegend( aFit.line );
end
end
