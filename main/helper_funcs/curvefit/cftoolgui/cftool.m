function varargout=cftool(varargin)
% CFTOOL   Open Curve Fitting Tool.
%
%   CFTOOL opens Curve Fitting Tool or brings focus to the Tool if it is already
%   open.
%
%   CFTOOL( X, Y ) creates a curve fit to X input and Y output. X and Y must be
%   numeric, have two or more elements, and have the same number of elements.
%   CFTOOL opens Curve Fitting Tool if necessary.
%
%   CFTOOL( X, Y, Z ) creates a surface fit to X and Y inputs and Z output. X, Y,
%   and Z must be numeric, have two or more elements, and have compatible sizes.
%   Sizes are compatible if X, Y, and Z all have the same number of elements or X
%   and Y are vectors, Z is a 2D matrix, length(X) = n, and length(Y) = m where
%   [m,n] = size(Z). CFTOOL opens Curve Fitting Tool if necessary.
%
%   CFTOOL( X, Y, [], W ) creates a curve fit with weights W. W must be numeric
%   and have the same number of elements as X and Y.
%
%   CFTOOL( X, Y, Z, W ) creates a surface fit with weights W. W must be numeric
%   and have the same number of elements as Z.
%
%   CFTOOL( FILENAME ) loads the surface fitting session in FILENAME into Curve
%   Fitting Tool. The FILENAME should have the extension '.sfit'.
%
%   CFTOOL -v1 opens the legacy Curve Fitting Tool.
%
%   CFTOOL( '-v1', X, Y ) starts the legacy Curve Fitting Tool with an initial
%   data set containing the X and Y data you supply.  X and Y must be numeric
%   vectors having the same length.
%
%   CFTOOL( '-v1', X, Y, W ) also includes the weight vector W in the initial
%   data set.  W must have the same length as X and Y.

%   Copyright 2000-2014 The MathWorks, Inc.

% Handle call-back
if (nargin > 0 && ischar(varargin{1}))
    cffig = cfgetset('cffig');
    
    switch(varargin{1})
        case 'duplicate'
            cfduplicatefigure(cffig);
            return
        case 'clear session'
            delete(findall(cffig,'Tag','cfstarthint'));
            if asksavesession
                cfsession('clear');
            end
            return
        case 'save session'
            cfsession('save');
            return
        case 'load session'
            delete(findall(cffig,'Tag','cfstarthint'));
            if asksavesession
                cfsession('load');
            end
            return
        case 'clear plot'
            delete(findall(cffig,'Tag','cfstarthint'));
            cbkclear;
            return
        case 'import data'
            delete(findall(cffig,'Tag','cfstarthint'));
            javaMethodEDT('showDataManager', 'com.mathworks.toolbox.curvefit.DataManager', 0);
            return
        case 'delete dataset'
            try
                javaMethodEDT('showDataManager', 'com.mathworks.toolbox.curvefit.DataManager', 0);
            catch ignore %#ok<NASGU>
            end
            return
        case 'customeqn'
            customeqn;
            return
        case 'setconflev'
            setconflev(cffig,varargin{2});
            return
        case 'togglebounds'
            togglebounds(cffig);
            return
        case 'togglelegend'
            togglelegend(cffig,varargin{2:end});
            return
        case 'togglegrid'
            togglegrid(cffig);
            return
        case 'toggleaxlimctrl'
            delete(findall(cffig,'Tag','cfstarthint'));
            toggleaxlimctrl(cffig);
            return
        case 'defaultaxes'
            zoom( cffig, 'out' );
            return
        case 'toggleresidplot'
            toggleresidplot(cffig,varargin{2});
            return
        case 'adjustlayout'
            cfadjustlayout(cffig);
            cfgetset('oldposition',get(cffig,'Position'));
            cfgetset('oldunits',get(cffig,'Units'));
            
            % If we get resize callbacks, get rid of the position listener
            if ~ispc
                list = cfgetset('figposlistener');
                if ~isempty(list) && ishandle(list(1))
                    delete(list(1));
                    cfgetset('figposlistener',[]);
                end
            end
            return
        case 'adjustlayout2'
            % adjust via listener, done on some platforms where the resize
            % function is not reliable
            cffig = cfgetset('cffig');
            oldpos = cfgetset('oldposition');
            oldunits = get(cffig,'Units');
            figunits = cfgetset('oldunits');
            set(cffig,'Units',figunits);
            newpos = get(cffig,'Position');
            if length(oldpos)~=4 || ~isequal(oldpos(3:4),newpos(3:4))
                cfgetset('oldposition',newpos);
                cfadjustlayout(cffig);
            end
            set(cffig,'Units',oldunits);
            return
        case 'makefigure'
            if isempty(cffig) || ~ishandle(cffig)
                % Create the plot window
                cffig = createplot;
            end
            varargout = {cffig};
            return
    end
end

% Get the names of the input arguments
names = cell( nargin, 1 );
for i = 1:nargin
    names{i} = inputname( i );
end

if usingLegacyTool( varargin{:} )
    cftool.warnAboutRemoval();
    theApplication = cftool_v1( varargin(2:end), names(2:end) );
else
    theApplication = iStartSFTOOL( varargin, names );
end

if nargout
    varargout = {theApplication};
end

% ---------------- Start Curve & Surface Fittng Tool
function application = iStartSFTOOL( varaibles, names )
try
    application = sftool_v1( varaibles, names );
catch exception
    throwAsCaller( exception );
end

% ---------------- Does the syntax request legacy v1 Curve Fitting Tool
function tf = usingLegacyTool( varargin )
% usingLegacyTool   True if using legacy v1 Curve Fitting Tool

% If there are no input arguments, then using current tool
if ~nargin
    tf = false;
    
    % If the first argument is '-v1', then using legacy tool
elseif strcmpi( '-v1', varargin{1} )
    tf = true;
    
    % Otherwise, using the current tool
else
    tf = false;
end

% ---------------- legacy v1 Curve Fitting Tool
function cft = cftool_v1( arguments, names )


numArguments = length( arguments );

iLicenseCheck();

import com.mathworks.toolbox.curvefit.*;


% Can't proceed unless we have desktop java support
if ~usejava('swing')
    error(message('curvefit:cftool:missingJavaSwing'));
end

% Get handle of the figure with the curve fitting tag
cffig = cfgetset('cffig');

cfgetset('dirty',true);   % session has changed since last save

% If the handle is empty, create the object and save the handle
if (isempty(cffig) || ~ishandle(cffig))
    % create the plot window
    cffig = createplot;
else % already exists, bring it forward
    figure(cffig);
end

% Get the java window handle
cft = cfgetset('cft');
startup = isempty(cft);
if startup
    dsdb = getdsdb;
    % create the Curve Fitting Tool window
    
    CurveFitting.showCurveFitting;
    cft = CurveFitting.getCurveFitting;
    cfgetset('cft',cft);
    
    % There could be problems if the user types "clear classes".
    % To avoid having the curve fitting classes clear, create and store
    % empty instances that are disconnected from the databases.
    clear temp;
    temp(2) = cftool.dataset('disconnected');
    temp(1) = cftool.fit('disconnected');
    cfgetset('fitcount',1);
    
    %init (behind the scenes) analysis and plot
    javaMethodEDT('initAnalysis', 'com.mathworks.toolbox.curvefit.Analysis');
    javaMethodEDT('initPlotting', 'com.mathworks.toolbox.curvefit.Plotting');

    cfgetset('classinstances',temp);
end

% Create initial dataset using input data, if any
emsg = '';
x = [];
if numArguments>=2 && numArguments<=3 && isa(arguments{1}, 'double') ...
        && isa(arguments{2}, 'double')
    x = arguments{1};
    xname = names{1};
    y = arguments{2};
    yname = names{2};
    if length(x)~=numel(x) || length(y)~=numel(y) || length(x)~=length(y)
        emsg = getString(message('curvefit:cftoolgui:XAndYMustBeVectorsWithTheSameLength'));
    elseif length(x)==1
        emsg = getString(message('curvefit:cftoolgui:XAndYMustHaveAtLeastTwoValues'));
    end
    if isempty(emsg) && numArguments==3
        w = arguments{3};
        if isempty(w)
            wname = cfGetNoneString;
        else
            if length(w)~=length(x) || length(w)~=numel(w) || ~isa(w, 'double')
                emsg = getString(message('curvefit:cftoolgui:WeightArgumentMustBeAVectorWithTheSameLengthAsX'));
            else
                wname = names{3};
            end
        end
    elseif isempty(emsg)
        w = [];
        wname = cfGetNoneString;
    end
elseif numArguments>0
    emsg = getString(message('curvefit:cftoolgui:CFTOOLRequiresTwoOrThreeDoubleVectorsAsArguments'));
end
if isempty(emsg) && ~isempty(x)
    delete(findall(cffig,'Tag','cfstarthint'));
    cftool.dataset(xname,yname,wname,'',x(:),y(:),w(:));
elseif startup && isempty(down(dsdb))
    text(.5,.5,getString(message('curvefit:cftoolgui:SelectDataToBeginCurveFitting')),...
        'Parent',get(cffig,'CurrentAxes'),'Tag','cfstarthint',...
        'HorizontalAlignment','center');
end
if ~isempty(emsg)
    uiwait(warndlg(emsg,getString(message('curvefit:cftoolgui:CurveFitting')),'modal'));
end

% ---------------- helper to set up plot window
function cffig = createplot
%CREATEPLOT Create plot window for CFTOOL

% Get some screen and figure position measurements
tempFigure=figure('Visible','off','Units','pixels');
dfp=get(tempFigure,'Position');
dfop=get(tempFigure,'OuterPosition');
diffp = dfop - dfp;
xmargin = diffp(3);
ymargin = diffp(4);
close(tempFigure)
oldu = get(0,'Units');
set(0,'Units','pixels');
screenSize=get(0,'ScreenSize');
screenWidth=screenSize(3);
screenHeight=screenSize(4);
set(0,'Units',oldu');

% Get the desired width and height
width=dfp(3)*1.2 + xmargin;
height=dfp(4)*1.2 + ymargin;
if width > screenWidth
    width = screenWidth-10-xmargin;
end
if height > screenHeight;
    height = screenHeight-10-ymargin;
end

% Calculate the position on the screen
leftEdge=min((screenWidth/3)+10+xmargin/2, screenWidth-width-10-2*xmargin);
bottomEdge=(screenHeight-height)/2;

% Make an invisible figure to start
cffig=figure('Visible','off','IntegerHandle','off',...
    'HandleVisibility','callback',...
    'MenuBar', 'figure', ...
    'ToolBar', 'none', ...
    'Color',get(0,'DefaultUicontrolBackgroundColor'),...
    'Name',getString(message('curvefit:cftoolgui:CurveFittingToolVersion1')),...
    'NumberTitle','off',...
    'Units','pixels',...
    'WindowStyle', 'Normal', ...
    'Position',[leftEdge bottomEdge width height], ...
    'CloseRequestFcn',@closefig, ...
    'DeleteFcn', @deletefig, ...
    'PaperPositionMode','auto',...
    'DockControls', 'off' );
cfgetset('cffig',cffig);

% Set default print options
pt = printtemplate;
pt.PrintUI = 0;
pt.DriverColor = true;
set(cffig,'PrintTemplate',pt)

% Add buttons along the top
cfaddbuttons(cffig);

% We want a subset of the usual toolbar
toggletoolbar(cffig,'on');

% We want a subset of the usual menus and some more toolbar icons
adjustmenu(cffig);

% Create containers for the axes
u1 = uicontainer('Parent',cffig,'Units','normalized','Position',[0 0 1 1], ...
    'Tag','axescontainer');
uicontainer('Parent',cffig,'Units','normalized','Position',[0 0 1 .5], ...
    'Tag','residcontainer','Visible','off');

% Set up axes the way we want them
ax=axes('Parent',u1, 'Box','on','Tag','main');

% Adjust layout of buttons and graph
if ~ispc    % some unix platforms seem to require this
    set(cffig,'Visible','on');
    drawnow;
end
cfadjustlayout(cffig);

% Define the colors to be used here
a = [3 0 2 1 3 3 3 2 2 0 2 3 0 1 2 1 0 1 0 1 1
    0 0 1 1 0 3 2 2 1 2 0 1 3 2 3 0 1 3 0 2 0
    0 3 0 1 3 0 1 2 3 1 1 2 0 3 1 2 2 2 0 0 2]'/3;
set(ax,'ColorOrder',a);

% Remember current position
cfgetset('oldposition',get(cffig,'Position'));
cfgetset('oldunits',get(cffig,'Units'));

% Now make the figure visible
if ispc
    set(cffig,'Visible','on');
end
set(cffig, 'ResizeFcn','cftool(''adjustlayout'')');
drawnow;

% Add any fits with a plotting flag on
a = cfgetallfits;
for j=1:length(a)
    b = a{j};
    if b.plot == 1
        updateplot(b);
    end
end

% Add any datasets with a plotting flag on
a = cfgetalldatasets;
for j=1:length(a)
    b = a{j};
    if b.plot == 1
        cfmplot(b);
    end
end

% Create context menus for data and fit lines
cfdocontext('create', cffig);

% Listen for figure position changes if resize function is questionable
if ~ispc
    list = curvefit.listener( cffig, 'SizeChanged', @adjustLayout2Callback );
    cfgetset( 'figposlistener', list );
end

% ---------------------- Callback for adjustlayout2
function adjustLayout2Callback( ~, ~ )
% adjustLayout2Callback   Call 'adjustlayout2'
%   adjustLayout2Callback( SRC, EVT )
cftool( 'adjustlayout2' );

% ---------------------- helper to invoke custom equation dlg
function customeqn
%CUSTOMEQN Invoke custom equation dialog
cei = javaMethodEDT('getInstance', 'com.mathworks.toolbox.curvefit.CustomEquation');
javaMethodEDT('defaults', cei);

% ---------------------- helper to toggle toolbar state
function toggletoolbar(varargin)
%TOGGLETOOLBAR Toggle curve fit plot toolbar on or off

if (nargin>0 && ishandle(varargin{1}) && ...
        isequal(get(varargin{1},'Type'),'figure'))
    cffig = varargin{1};
else
    cffig = gcbf;
end

tbstate = get(cffig,'ToolBar');
h = findall(cffig,'Type','uitoolbar');
if isequal(tbstate,'none') || isempty(h)
    % Create toolbar for the first time
    set(cffig,'ToolBar','figure');
    iAdjustToolbar(cffig);
elseif nargin>1 && isequal(varargin{2},'on')
    % Hide toolbar
    set(h,'Visible','on');
else
    % Show toolbar
    set(h,'Visible','off');
end

% ---------------------- helper to toggle confidence bound on/off
function togglebounds(~)
%TOGGLEBOUNDS Toggle curve fit plot confidence bounds on or off

% Get new state
wason = isequal(get(gcbo,'Checked'),'on');
if wason
    onoff = 'off';
else
    onoff = 'on';
end

% Change curves
iSetShowBoundsOnLines(onoff);

% Change menu state
set(gcbo,'Checked',onoff);
cfgetset('showbounds',onoff);

% Adjust y limits if necessary
cfupdateylim;

cfgetset('dirty',true);   % session has changed since last save

function iSetShowBoundsOnLines(onoff)
fitDB = cfgetset( 'thefitdb' );
aFit = fitDB.down;
while ~isempty( aFit )
    if ~isempty( aFit.line )
        aFit.line.ShowBounds = onoff;
    end
    aFit = aFit.right;
end

% ---------------------- helper to set confidence level
function setconflev(cffig,clev)
%SETCONFLEV Set confidence level for curve fitting

% Get new value
oldlev = cfgetset('conflev');
if isempty(clev)
    ctxt = inputdlg({getString(message('curvefit:cftoolgui:ConfidenceLevelinPercent'))},...
        getString(message('curvefit:cftoolgui:SetConfidenceLevel')),1,{num2str(100*oldlev)});
    if isempty(ctxt)
        clev = oldlev;
    else
        ctxt = ctxt{1};
        clev = str2double(ctxt);
        if ~isfinite(clev) || ~isreal(clev) || clev<=0 || clev>=100
            badLevelStr = getString(message('curvefit:cftoolgui:BadConfidenceLevel', ctxt));
            mustBeStr = getString(message('curvefit:cftoolgui:MustBeAPercentage'));
            oldLevStr = sprintf('%g', 100*oldlev);
            keepingStr = getString(message('curvefit:cftoolgui:KeepingOldValue', oldLevStr));
            errordlg(sprintf('%s\n%s\n%s', badLevelStr, mustBeStr, keepingStr), ...
                getString(message('curvefit:cftoolgui:Error')),'modal');
            clev = oldlev;
        else
            clev = clev/100;
        end
    end
end
if oldlev~=clev
    cfgetset('conflev',clev);
    
    % Update any existing fits
    iSetConfidenceLevelOnLines(clev);
    
    % Check the appropriate menu item
    h = findall(cffig,'Type','uimenu','Tag','conflev');
    set(h,'Checked','off');
    verysmall = sqrt(eps);
    if abs(clev-.95)<verysmall
        txt = '9&5%';
    elseif abs(clev-.9)<verysmall
        txt = '9&0%';
    elseif abs(clev-.99)<verysmall
        txt = '9&9%';
    else
        txt = getString(message('curvefit:cftoolgui:Other'));
    end
    h1 = findall(h,'flat','Label',txt);
    if ~isempty(h1)
        set(h1,'Checked','on');
    end
    cfgetset('dirty',true);   % session has changed since last save
end

function iSetConfidenceLevelOnLines( level )
fitDB = cfgetset( 'thefitdb' );
aFit = fitDB.down;
while ~isempty( aFit )
    if ~isempty( aFit.line )
        aFit.line.ConfLev = level;
    end
    aFit = aFit.right;
end

% ---------------------- helper to toggle legend on/off
function togglelegend(cffig,onoff,leginfo,rleginfo)
%TOGGLELEGEND Toggle curve fit plot legend on or off

% Get new state if not passed in -- note uimenu state reflects
% old state, and uitoggletool state reflects new state
if nargin<2 || isempty(onoff)
    h = gcbo;
    if isequal(get(h,'Type'),'uimenu')
        onoff = on2off(get(h,'Checked'));
    else
        onoff = get(h,'State');
    end
end
cfgetset('showlegend',onoff);
if nargin<3
    leginfo = {};
end
if nargin<4
    rleginfo = {};
end

% Change menu state
h = findall(cffig,'Type','uimenu','Tag','showlegend');
if ~isempty(h), set(h,'Checked',onoff); end

% Change button state
h = findall(cffig,'Type','uitoggletool','Tag','showlegend');
if ~isempty(h), set(h,'State',onoff); end

% Change legend state
cfupdatelegend(cffig,false,leginfo,rleginfo);

% ---------------------- helper to toggle grid on/off
function togglegrid(cffig)
%TOGGLEGGRID Toggle x and y axes grid on or off

% Get new state -- note uimenu state reflects old state, and
% uitoggletool state reflects new state
h = gcbo;
if isequal(get(h,'Type'),'uimenu')
    onoff = on2off(get(h,'Checked'));
else
    onoff = get(h,'State');
end
cfgetset('showgrid',onoff);

% Change grid
ax = findall(cffig,'Type','axes');
for j=1:length(ax)
    if ~isequal(get(ax(j),'Tag'),'legend')
        set(ax(j),'XGrid',onoff,'YGrid',onoff)
    end
end

% Change menu state
h = findall(cffig,'Type','uimenu','Tag','showgrid');
if ~isempty(h), set(h,'Checked',onoff); end

% Change button state
h = findall(cffig,'Type','uitoggletool','Tag','showgrid');
if ~isempty(h), set(h,'State',onoff); end

% ---------------------- helper to toggle axis limit controls on/off
function toggleaxlimctrl(cffig)
%TOGGLEAXLIMCTRL Toggle x and y axis limit controls on or off

% Get new state
h = gcbo;
onoff = on2off(get(h,'Checked'));
cfgetset('showaxlimctrl',onoff);

% Add or remove controls
cfaxlimctrl(cffig,onoff)

% Remove effects of controls on layout
if isequal(onoff,'off')
    cfadjustlayout(cffig);
end

% Change menu state
set(h,'Checked',onoff);

% ---------------------- helper to toggle residual plot on/off
function toggleresidplot(cffig,ptype)
%TOGGLERESIDPLOT Toggle residual plot on or off

% Turn off all siblings, then turn on this menu item
h = gcbo;
if ~isequal(get(h,'Tag'),'residmenu')
    % Not called from the menu, so search for the menu
    hParent = findall(cffig,'Type','uimenu','Tag','residmenu');
    h = findall(hParent,'Tag',ptype);
end
h1 = get(get(h,'Parent'),'Children');
set(h1,'Checked','off');
set(h,'Checked','on');
cfgetset('residptype',ptype);

% Add or remove the axes from the figure and adjust layout
needaxes = ~isequal(ptype,'none');
axh = findall(cffig,'Type','axes','Tag','resid');
ax1 = findall(cffig,'Type','axes','Tag','main');
hcontr = findall(cffig,'Type','uicontainer','Tag','residcontainer');

if needaxes && isempty(axh)
    set(hcontr,'Visible','on');
    ax1 = findall(cffig,'Type','axes','Tag','main');
    
    gridonoff = cfgetset('showgrid');
    axh = axes('OuterPosition',[0 0 1 1],'Units','normalized','Tag','resid',...
        'Box','on','XLim',get(ax1,'XLim'),'Parent',hcontr,...
        'XGrid',gridonoff,'YGrid',gridonoff);
    
    % Link the main and residual plot so that when the user zooms on one,
    % they zoom on the other as well. These two axes have different
    % y-scales so we only link the x-zoom.
    linkaxes( [axh, ax1], 'x' );
    
    htitle = get(axh,'Title');
    set(htitle,'String',getString(message('curvefit:cftoolgui:Residuals')));
    htitle = get(ax1,'Title');
    set(htitle,'String',getString(message('curvefit:cftoolgui:DataAndFits')));
elseif ~needaxes && ~isempty(axh)
    delete(axh);
    htitle = get(ax1,'Title');
    set(htitle,'String','');
    set(hcontr,'Visible','off');
end
cfadjustlayout(cffig);

% Now plot the residuals if toggling on
if needaxes
    a = cfgetallfits;
    for j=1:length(a)
        b = a{j};
        if b.plot == 1
            updateplot(b)
        end
    end
end

% Update legend
cfupdatelegend(cffig);
cfgetset('dirty',true);   % session has changed since last save

% ---------------------- helper to fix toolbar contents
function iAdjustToolbar(cffig)
% iAdjustToolbar   Adjust contents of curve fit plot toolbar

theToolbar = findall( cffig, 'Type', 'uitoolbar' );
oldButtons = allchild( theToolbar );

% We want to keep the print button, the zoom buttons and the pan button
printButton   = findall( oldButtons, 'Tag', 'Standard.PrintFigure' );
zoomInButton  = findall( oldButtons, 'Tag', 'Exploration.ZoomIn' );
zoomOutButton = findall( oldButtons, 'Tag', 'Exploration.ZoomOut' );
panButton     = findall( oldButtons, 'Tag', 'Exploration.Pan' );

% All other  toolbar buttons get deleted
keep = ismember( oldButtons, [printButton zoomOutButton zoomInButton panButton] );
delete( oldButtons(~keep) );

% Add buttons for toggling the legned and grid.
legendButton = iCreateLegendToolbarButton( theToolbar );
gridButton = iCreateGridToolbarButton( theToolbar );

% Set of the order of the buttons along the toolbar.
newButtons = [printButton zoomInButton zoomOutButton panButton legendButton gridButton]';
set( theToolbar, 'Children', newButtons(end:-1:1) );

% ---------------------- helper to fix menu contents
function adjustmenu(cffig)
%ADJUSTMENU Adjust contents of curve fit plot menus

% Remove some menus entirely
h = findall(cffig, 'Type','uimenu', 'Parent',cffig);
removelist = {'figMenuEdit' 'figMenuInsert' 'figMenuDesktop'};
for j=1:length(removelist)
    h0 = findall(h,'flat', 'Tag',removelist{j});
    if (~isempty(h0))
        h(h==h0) = [];
        delete(h0);
    end
end

% Add or remove some items from other menus

% Fix FILE menu
h0 = findall(h,'flat', 'Tag','figMenuFile');
h1 = findall(h0, 'Type','uimenu', 'Parent',h0);
for j=length(h1):-1:1
    switch get( h1(j), 'Tag' )
        case 'figMenuFileClose' 
            fileCloseMenu = h1(j);
        case  'printMenu'
            printMenu = h1(j);
        case 'figMenuFilePrintPreview'
            printPreviewMenu = h1(j);
        otherwise
            delete(h1(j));
            h1(j) = [];
    end
end
uimenu( h0, 'Position', 1, ...
    'Label',getString(message('curvefit:cftoolgui:menu_ImportData')),  ...
    'Callback', 'cftool(''import data'')', ...
    'Tag', 'ImportDataMenu' );

uimenu( h0, 'Position', 2, 'Separator', 'on', ...
    'Label', getString(message('curvefit:cftoolgui:menu_ClearSession')), ...
    'Callback', 'cftool(''clear session'')', ...
    'Tag', 'ClearSessionMenu' );

uimenu( h0, 'Position', 3, ...
    'Label',getString(message('curvefit:cftoolgui:menu_LoadSession')), ...
    'Callback', 'cftool(''load session'')', ...
    'Tag', 'LoadSessionMenu' );

uimenu( h0, 'Position', 4,...
    'Label', getString(message('curvefit:cftoolgui:menu_SaveSession')), ...
    'Callback', 'cftool(''save session'')', ...
    'Tag', 'SaveSessionMenu' );

uimenu( h0, 'Position', 5, ...
    'Label', getString(message('curvefit:cftoolgui:menu_GenerateCode')), ...
    'Callback', 'cfswitchyard(''cffig2m'')', ...
    'Tag', 'GenerateCodeMenu' );

uimenu( h0, 'Position', 6, 'Separator','on', ...
    'Label', getString(message('curvefit:cftoolgui:menu_PrintToFigure')), ...
    'Callback', 'cftool(''duplicate'')', ...
    'Tag', 'PrintToFigureMenu' );

set( printPreviewMenu, 'Position', 7 );
set( printMenu, 'Position', 8 );

set( fileCloseMenu, 'Position', 9, 'Separator', 'on', ...
    'Label',getString(message('curvefit:cftoolgui:menu_CloseCurveFitting')) )

% Fix VIEW menu
h0 = findall(h,'flat', 'Tag','figMenuView');
h1 = findall(h0, 'Type','uimenu', 'Parent',h0);
delete(h1);
uimenu(h0, 'Label',getString(message('curvefit:cftoolgui:menu_PredictionBounds')), 'Position',1,...
    'Callback','cftool(''togglebounds'')', 'Checked','off');
cfgetset('showbounds','off');
h1 = uimenu(h0, 'Label',getString(message('curvefit:cftoolgui:menu_ConfidenceLevel')),'Position',2);
uimenu(h1, 'Label','9&0%', 'Position',1, ...
    'Callback','cftool(''setconflev'',.90)','Tag','conflev');
uimenu(h1, 'Label','9&5%', 'Position',2, 'Checked','on',...
    'Callback','cftool(''setconflev'',.95)','Tag','conflev');
uimenu(h1, 'Label','9&9%', 'Position',3, ...
    'Callback','cftool(''setconflev'',.99)','Tag','conflev');
uimenu(h1, 'Label',getString(message('curvefit:cftoolgui:Other')), 'Position',4, ...
    'Callback','cftool(''setconflev'',[])','Tag','conflev');
cfgetset('conflev',0.95);
h1 = uimenu(h0, 'Label',getString(message('curvefit:cftoolgui:menu_Residuals')), 'Position',3,'Separator','on',...
    'Tag','residmenu');
uimenu(h1, 'Label',getString(message('curvefit:cftoolgui:menu_None')), 'Position',1, 'Tag','none',...
    'Callback','cftool(''toggleresidplot'',''none'')', 'Checked','on');
uimenu(h1, 'Label',getString(message('curvefit:cftoolgui:menu_ScatterPlot')), 'Position',2, 'Tag','scat',...
    'Callback','cftool(''toggleresidplot'',''scat'')', 'Checked','off');
uimenu(h1, 'Label',getString(message('curvefit:cftoolgui:menu_LinePlot')), 'Position',3, 'Tag','line',...
    'Callback','cftool(''toggleresidplot'',''line'')', 'Checked','off');
cfgetset('residptype','none');
uimenu(h0, 'Label',getString(message('curvefit:cftoolgui:menu_ClearPlot')), 'Position',4,...
    'Callback','cftool(''clear plot'')');

% Fix TOOLS menu
h0 = findall(h,'flat', 'Tag','figMenuTools');
h1 = findall(h0, 'Type','uimenu', 'Parent',h0);
for j=length(h1):-1:1
    thisTag = get(h1(j),'Tag');
    if ~ismember( thisTag, {'figMenuZoomIn', 'figMenuZoomOut', 'figMenuPan'} )
        delete(h1(j));
        h1(j) = [];
    end
end
uimenu(h0, 'Label',getString(message('curvefit:cftoolgui:menu_NewCustomEquation')), 'Position',1,...
    'Callback','cftool(''customeqn'')');
uimenu(h0, 'Label',getString(message('curvefit:cftoolgui:menu_Legend')), 'Position',2,'Separator','on',...
    'Callback','cftool(''togglelegend'')', 'Checked','on',...
    'Tag','showlegend');
cfgetset('showlegend','on');
uimenu(h0, 'Label',getString(message('curvefit:cftoolgui:menu_Grid')), 'Position',3,...
    'Callback','cftool(''togglegrid'')', 'Checked','off', ...
    'Tag','showgrid');
cfgetset('showgrid','off');
uimenu(h0, 'Label',getString(message('curvefit:cftoolgui:menu_AxisLimitControl')), 'Position',7, 'Separator','on', ...
    'Callback','cftool(''toggleaxlimctrl'')', 'Checked','off', ...
    'Tag','showaxlimctrl');
cfgetset('showaxlimctrl','off');
uimenu(h0, 'Label',getString(message('curvefit:cftoolgui:menu_DefaultAxisLimits')), 'Position',8, ...
    'Callback','cftool(''defaultaxes'')');

% Fix HELP menu
h0 = findall(h,'flat', 'Tag','figMenuHelp');
h1 = findall(h0, 'Type','uimenu', 'Parent',h0);
delete(h1);
uimenu(h0, 'Label', getString(message('curvefit:cftoolgui:menu_CurveFittingToolHelp')), 'Position',1,'Callback',...
    'cfswitchyard(''cfcshelpviewer'', ''cftool'', ''cftool'')');
uimenu(h0, 'Label',getString(message('curvefit:cftoolgui:menu_CurveFittingToolboxHelp')), 'Position',2,'Callback',...
    'doc curvefit/');
uimenu(h0, 'Label',getString(message('curvefit:cftoolgui:menu_Demos')), 'Position',3,'Separator','on','Callback',...
    'demo toolbox curve');
uimenu(h0, 'Label', getString(message('curvefit:cftoolgui:menu_AboutCurveFitting')), 'Position',4,'Separator','on',...
    'Callback', @helpabout);

% ---------------------- helper to display "about curve fitting" help
function helpabout(varargin)

a = ver('curvefit');
str = sprintf( 'Curve Fitting Toolbox %s\nCopyright 2001-%s The MathWorks, Inc.', ...
    a.Version, a.Date(end-3:end));

msgbox(str,getString(message('curvefit:cftoolgui:AboutTheCurveFittingToolbox')),'modal');

% ---------------------- helper to verify closing of figure
function closefig(varargin)
%CLOSEFIG Verify intention to close curve fitting figure

if asksavesession()
    h = cfgetset( 'cffig' );
    if ~isempty( h ) && ishandle( h )
        delete( h )
    end
end

% ---------------------- helper for deleting of figure
function deletefig(varargin)
% Need to ensure all CFTOOL windows are closed and the session info is cleared
% out.

% Clear current session
cfsession( 'clear' );

% Delete any cftool-related figures
h = cfgetset( 'analysisfigure' );
if ~isempty( h ) && ishandle( h )
    delete( h );
end

% close graphical exclude figure if it is open.
cfnewexcludeds();

% --------------------- change on to off and vice versa
function a = on2off(b)

if isequal(b,'on')
    a = 'off';
else
    a = 'on';
end

% ---------------------- callback for Clear button
function cbkclear
%CBKCLEAR Callback for Clear button

import com.mathworks.toolbox.curvefit.*;

% Clear all saved fits from the plot and notify fits manager
a = cfgetallfits;
for j=1:length(a)
    b = a{j};
    b.plot = 0;
    FitsManager.getFitsManager.fitChanged(java(b));
end

% Clear all datasets from the plot and notify data sets manager
a = cfgetalldatasets;
for j=1:length(a)
    b = a{j};
    b.plot = 0;
    DataSetsManager.getDataSetsManager.dataSetListenerTrigger(...
        java(b), DataSetsManager.DATA_SET_CHANGED, '', '');
end

% ---------------------- Clear session
function ok = asksavesession

allds = cfgetalldatasets;
allfits = cfgetallfits;

% Offer to save session unless there's nothing to save
if ~cfgetset('dirty') || isempty(allds) && isempty(allfits)
    resp = getString(message('curvefit:cftoolgui:No'));
else
    resp = questdlg(getString(message('curvefit:cftoolgui:SaveThisCurveFittingSession')), ...
        getString(message('curvefit:cftoolgui:CurveFitting')), ...
        getString(message('curvefit:cftoolgui:Yes')), ...
        getString(message('curvefit:cftoolgui:No')), ...
        getString(message('curvefit:cftoolgui:Cancel')), ...
        getString(message('curvefit:cftoolgui:Yes')));
end

if isempty(resp)
    resp = getString(message('curvefit:cftoolgui:Cancel'));
end

if isequal(resp, getString(message('curvefit:cftoolgui:Yes')))
    ok = cfsession('save');
    if ~ok
        resp = getString(message('curvefit:cftoolgui:Cancel'));
    end
end

ok = ~isequal(resp,getString(message('curvefit:cftoolgui:Cancel')));

% ---------------------- License Check
function iLicenseCheck()
% iLicenseCheck -- Check for a license for curve fitting toolbox. Throw an
% error if no license.


if ~builtin( 'license', 'test', 'Curve_Fitting_Toolbox' )
    error(message('curvefit:cftool:noLicense'));
else
    [canCheckout, checkoutMsg] = builtin( 'license', 'checkout', 'Curve_Fitting_Toolbox' );
    if ~canCheckout
        error(message('curvefit:cftool:cannotCheckOutLicense', checkoutMsg));
    end
end

% ---------------------- Create legend toolbar button
function button = iCreateLegendToolbarButton( parent )
% iCreateLegendToolbarButton   Create the legend button for the toolbar
state = cfgetset('showlegend');
if isempty(state),
    state = 'on';
end

button = uitoolfactory(parent,'Annotation.InsertLegend');
set(button, 'State',state,...
    'TooltipString', getString(message('curvefit:cftoolgui:LegendOnOff')),...
    'Separator','on',...
    'ClickedCallback','cftool(''togglelegend'')',...
    'Tag','showlegend');

% ---------------------- Create grid toolbar button
function gridButton = iCreateGridToolbarButton( parent )
% iCreateGridToolbarButton   Create the grid button for the toolbar
if exist('cficons.mat','file')==2
    icons = load('cficons.mat','icons');
    
    state = cfgetset('showgrid');
    if isempty(state),
        state = 'off';
    end
    
    gridButton = uitoggletool(parent, ...
        'CData', icons.icons.grid,...
        'State', state,...
        'TooltipString', getString(message('curvefit:cftoolgui:GridOnOff')),...
        'Separator','off',...
        'ClickedCallback', 'cftool(''togglegrid'')',...
        'Tag', 'showgrid' );
else
    gridButton = [];
end

