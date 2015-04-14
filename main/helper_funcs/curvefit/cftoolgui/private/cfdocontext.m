function cfdocontext(varargin)
% CFDOCONTEXT   Perform context menu actions for curve fitting tool

% Copyright 2001-2013 The MathWorks, Inc.

% Special action to create context menus
if isequal(varargin{1},'create')
    iMakeContextMenu(varargin{2});
    return
end

% Get information about what invoked this function
obj = gcbo;
action = get(obj,'Tag');
aLine = gco;
if isempty(aLine)
    return
end

aFit = getFitFromLine(aLine);

% Set up variables that define some menu items
[~, styles, markers] = iMenuItems();
styles{end+1} = getString(message('curvefit:cftoolgui:style_none'));

switch action
    case {'fitcontext' 'datacontext'}
        % This code is triggered when we display the menu
        iDisplayMenu(obj,aLine);
        return
        
        % Remaining cases are triggered by selecting menu items
    case 'color'
        iDoColor( aFit, aLine );
        
    case styles
        iDoStyle( aFit, action, aLine );
        
    case markers
        iDoMarkers(action,aLine);
        
    case {'hidecurve' 'deletefit'}
        % Either delete a fit, or a hide a fit or data set
        iDoHideOrDelete(aLine,action);
        return
        
    otherwise
        % If the menu item is a number, it is a line width
        iDoLineWidth( aFit, action, aLine );
end

iSaveLineProperties( aLine, aFit );
end


function iMakeContextMenuItems(hMenu, sizes, styles, slabels)
% iMakeContextMenuItems    Creates menu items for the curve fitting context menus
uimenu(hMenu,'Label',getString(message('curvefit:cftoolgui:menu_Color')),'Tag','color','Callback',@cfdocontext);
uwidth = uimenu(hMenu,'Label',getString(message('curvefit:cftoolgui:menu_LineWidth')),'Tag','linewidth');
ustyle = uimenu(hMenu,'Label',getString(message('curvefit:cftoolgui:menu_LineStyle')),'Tag','linestyle');

% Sub-menus for line widths
for i = 1:length(sizes)
    val = num2str(sizes(i));
    uimenu(uwidth,'Label',val,'Callback',@cfdocontext,'Tag',val);
end

% Sub-menus for line styles
for j=1:length(styles)
    uimenu(ustyle,'Label',slabels{j},'Callback',@cfdocontext,'Tag',styles{j});
end
end %iMakeContextMenuItems

function iMakeContextMenu(cffig)
% iMakeContextMenu   Creates context menu for curve fitting figure

    
% Get menu item labels and tags
[sizes, styles, markers, slabels, mlabels] = iMenuItems;
    
% First create the context menu for fit curves
c = uicontextmenu('Parent',cffig,'Tag','fitcontext','Callback',@cfdocontext);
iMakeContextMenuItems(c, sizes, styles, slabels);

% Create a similar context menu for data curves
cc = uicontextmenu('Parent',cffig,'Tag','datacontext','Callback',@cfdocontext);
iMakeContextMenuItems(cc, sizes, styles, slabels);

% Add items for fit menus only
uimenu(c,'Label',getString(message('curvefit:cftoolgui:menu_HideFit')),'Tag','hidecurve','Callback',@cfdocontext,...
    'Separator','on');
uimenu(c,'Label',getString(message('curvefit:cftoolgui:menu_DeleteFit')),'Tag','deletefit','Callback',@cfdocontext);

% Add items for data menus only
uimenu(cc,'Label',getString(message('curvefit:cftoolgui:menu_HideData')),'Tag','hidecurve','Callback',@cfdocontext,...
    'Separator','on');
umark = uimenu(cc,'Label',getString(message('curvefit:cftoolgui:menu_Marker')),'Tag','marker','Position',4);
for j=1:length(markers)
    uimenu(umark,'Label',mlabels{j},'Callback',@cfdocontext,'Tag',markers{j});
end

ustyle = findall(get(cc,'Children'),'Tag','linestyle');
uimenu(ustyle,'Label',getString(message('curvefit:cftoolgui:style_none')),'Callback',@cfdocontext,'Tag', 'none');
end

function [sizes,styles,markers,slabels,mlabels] = iMenuItems
% iMenuItems   Items for curve fitting context menus
sizes = [0.5 1 2 3 4 5 6 7 8 9 10];
styles = {'-' '--' ':' '-.'};
markers = {'+' 'o' '*' '.' 'x' 'square' 'diamond' ...
    'v' '^' '<' '>' 'pentagram' 'hexagram'};
slabels = {
    getString(message('curvefit:cftoolgui:style_solid')) ...
    getString(message('curvefit:cftoolgui:style_dash')) ...
    getString(message('curvefit:cftoolgui:style_dot')) ...
    getString(message('curvefit:cftoolgui:style_dashDot'))};
mlabels = {
    getString(message('curvefit:cftoolgui:marker_plus')) ...
    getString(message('curvefit:cftoolgui:marker_circle')) ...
    getString(message('curvefit:cftoolgui:marker_star')) ...
    getString(message('curvefit:cftoolgui:marker_point')) ...
    getString(message('curvefit:cftoolgui:marker_xMark')) ...
    getString(message('curvefit:cftoolgui:marker_square')) ...
    getString(message('curvefit:cftoolgui:marker_diamond')) ...
    getString(message('curvefit:cftoolgui:marker_triangleDown')) ...
    getString(message('curvefit:cftoolgui:marker_triangleUp')) ...
    getString(message('curvefit:cftoolgui:marker_triangleLeft')) ...
    getString(message('curvefit:cftoolgui:marker_triangleRight')) ...
    getString(message('curvefit:cftoolgui:marker_pentagram')) ...
    getString(message('curvefit:cftoolgui:marker_hexagram'))};
end

function iDisplayMenu(obj,h)

% Store a handle to the object that triggered this menu
set(obj,'UserData',h);

% Fix check marks on line width and line style cascading menus
c = findall(obj,'Type','uimenu');
set(c,'Checked','off');
w = get(h,'LineWidth');
u = findall(c,'flat','Tag',num2str(w));
if ~isempty(u)
    set(u,'Checked','on');
end
w = get(h,'LineStyle');
u = findall(c,'flat','Tag',w);
if ~isempty(u)
    set(u,'Checked','on');
end
w = get(h,'Marker');
u = findall(c,'flat','Tag',w);
if ~isempty(u)
    set(u,'Checked','on');
end

% Add object name to some other menu items
f = iGetFitOrDataset( h );

if ~isempty(f)
    u = findall(c,'flat','Tag','hidecurve');
    if ~isempty(u)
        set( u,'Label', getString(message('curvefit:cftoolgui:menu_Hide', f.name )));
    end
    u = findall(c,'flat','Tag','deletefit');
    if ~isempty(u)
        set( u,'Label', getString(message('curvefit:cftoolgui:menu_Delete', f.name )));
    end
end
end

function iDoColor( aFit, aLine )
oldcolor = get(aLine,'Color');
newcolor = uisetcolor(oldcolor);

if isequal(oldcolor,newcolor)
    % Do nothing
    dirty = cfgetset( 'dirty' );
elseif isempty( aFit )
    % clicked on dataset
    set( aLine, 'Color', newcolor );
    % session has changed since last save
    dirty = true;
else
    % Clicked on fit line
    iChangeMainPlot( aFit, 'Color', newcolor );
    iChangeColorOfOldBounds( aFit, newcolor );
    if ~iIsResidualType( 'none' )
        iChangeResdiaulsPlot( aFit, 'Color', newcolor );
    end
    % session has changed since last save
    dirty = true;
end
cfgetset( 'dirty', dirty );
end

function iDoStyle( aFit, newStyle, aLine )
if isempty( aFit )
    % clicked on datset
    set( aLine, 'LineStyle', newStyle );
else
    % Clicked on fit line
    iChangeMainPlot( aFit, 'LineStyle', newStyle );
    if iIsResidualType( 'line' )
        iChangeResdiaulsPlot( aFit, 'LineStyle', newStyle );
    end
end
cfgetset( 'dirty', true );
end

function iDoMarkers(action,h)
if isequal(action,'point')
    msize = 12;
else
    msize = 6;
end
set(h,'Marker',action,'MarkerSize',msize);
% session has changed since last save
cfgetset('dirty',true);
end

function iDoHideOrDelete(h,action)

import com.mathworks.toolbox.curvefit.*;

[f, isdataset] = iGetFitOrDataset( h );

if isempty(f)
    return
end

if isequal(action,'hidecurve')
    f.plot = 0;
    if ~isdataset
        FitsManager.getFitsManager.fitChanged(java(f));
    end
else
    FitsManager.getFitsManager.deleteFits(java(f));
end
end

function iDoLineWidth( aFit, stringWidth, aLine )
numericWidth = str2double( stringWidth );
if isempty( numericWidth )
    % Do nothing
    dirty = cfgetset( 'dirty' );
elseif isempty( aFit )
    % clicked on datset
    set( aLine, 'LineWidth', numericWidth );
    % session has changed since last save
    dirty = true;
else
    % Clicked on fit line
    iChangeMainPlot( aFit, 'LineWidth', numericWidth );
    % Do not change residuals, wide lines will be too obtrusive
    
    % session has changed since last save
    dirty = true;
end
cfgetset( 'dirty', dirty );

end

function [f, isdataset] = iGetFitOrDataset(h)
% iGetFitOrDataset   For the given line, get the corresponding for or data set
isdataset = false;
f = getFitFromLine(h);
if isempty( f )
    f = iGetDataset(h);
    isdataset = true;
end
end

function ds = iGetDataset(h)
% getds   get handle to dataset object for this line
ds = [];
dslist = cfgetalldatasets;
dh = double(h);
for j=1:length(dslist)
    dl = double(dslist{j}.line);
    if isequal(dl,dh)
        ds = dslist{j};
        return
    end
end
end

function iChangeMainPlot( aFit, property, value )
if ~isempty( aFit.line )
    set( aFit.line, property, value );
end
end

function iChangeResdiaulsPlot( aFit, property, value )
if ~isempty(aFit) && ~isempty(aFit.rline) && ishandle(aFit.rline)
    set(aFit.rline,property,value);
end
end

function tf = iIsResidualType( expectedType )
actualType = cfgetset('residptype');
tf = isequal( actualType, expectedType );
end

function iChangeColorOfOldBounds( aFit, color )
aLine = aFit.line;
if isa( aLine, 'cftool.boundedline' )
    set( get( aLine, 'BoundLines' ), 'Color', color );
end
end

function iSaveLineProperties( aLine, aFit )
if isempty( aFit )
    aDataset = iGetDataset( aLine );
    if ~isempty( aDataset )
        savelineproperties( aDataset );
    end
else
    savelineproperties( aFit );
end
end
