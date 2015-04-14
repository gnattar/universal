function cfduplicatefigure( cffig )
%CFDUPLICATEFIGURE Make a duplicate, editable copy of the curve fitting figure
%
%   CFDUPLICATEFIGURE(CFFIG)
%
%   The datasets get plotted in order they are in the database. The fits
%   get plotted just after the dataset they fit and then in the order
%   they are in the database. The residuals get plotted in the order of
%   the fits in the database.

%   Copyright 2000-2013 The MathWorks, Inc.

% For each line in CFTOOL, we create a new line in the generated figure. This
% cell array lists the properties whose values are copied from the CFTOOL lines
% to the lines in the generated figure.
LINE_PROPERTIES_TO_COPY  = {'Color', 'LineStyle', 'LineWidth', ...
    'Marker', 'MarkerSize', 'MarkerEdgeColor', 'MarkerFaceColor', 'XData', 'YData'};

% We're going to plot the data and fits from what's in the databases.
% Hence we need to get hold of those databases.
dsdb = getdsdb;
fitdb = getfitdb;

% We need to ensure that the appropriate properties of the axes we're
% about to create agree with those in CFTOOL. Hence we need to get the
% handles to those axes
hCftoolMainAxes = findall( cffig, 'Type', 'axes', 'Tag', 'main' );
hCftoolResidualAxes= findall( cffig, 'Type', 'axes', 'Tag', 'resid' );
if numel( hCftoolMainAxes ) ~= 1
    % If we hit this case then CFTOOL has got itself into some funny
    % state.
    errordlg( ...
        getString(message('curvefit:cftoolgui:ThereShouldBeExactlyOneAxes')), ...
        getString(message('curvefit:cftoolgui:ErrorPrintingToFigure')), 'modal' );
    return
end

% Get some status information from CFTOOL
isShowLegend = isequal( cfgetset( 'showlegend' ), 'on' );
residualType = cfgetset( 'residptype' );
isShowResiduals = ~strcmpi( residualType, 'none' );
renderer = get( cffig, 'Renderer' );

% If we're showing the residual then we need to check that the we have
% the residual axes from CFTOOL
if isShowResiduals && numel( hCftoolResidualAxes) ~= 1
    % If we hit this case then CFTOOL has got itself into some funny
    % state.
    errordlg( ...
        getString(message('curvefit:cftoolgui:ThereShouldBeExactlyOneResidualAxes')), ...
        getString(message('curvefit:cftoolgui:ErrorPrintingToFigure')), 'modal' );
    return
end

% Setup new figure and axes
hFigure = figure( 'Visible', 'off', 'Renderer', renderer );
AXES_PROPERTIES = {
    'Parent', hFigure, 'NextPlot', 'Add', 'Box', 'On', ...
    'XGrid', cfgetset( 'showgrid' ), 'YGrid', cfgetset( 'showgrid' ), ...
    'Units', 'Normalized'
    };
if isShowResiduals
    hMainAxes     = subplot( 2, 1, 1, AXES_PROPERTIES{:} );
    hResidualAxes = subplot( 2, 1, 2, AXES_PROPERTIES{:} );
    linkaxes( [hMainAxes, hResidualAxes], 'x' );
else
    hMainAxes = axes( AXES_PROPERTIES{:} );
    hResidualAxes = [];
end

% Set the axes X limits
% -- we'll do the Y limits after the plots to prevent them getting reset
% by the plots
% -- we need to do the X limits before the plots because the plot method
% of CFIT will use the axis limits to generate evaluation points
% -- don't have to worry about the X limits of the residual plot because
% that is taken care of by the linkaxes
iCopyProperties( 'Xlim', hCftoolMainAxes, hMainAxes );

% Set up the legend builders -- we use these to keep track of all the
% things that need to be put on the legends and then to create the
% legend at the end.
MainLegend     = iLegendBuilder( isShowLegend );
ResidualLegend = iLegendBuilder( isShowLegend && isShowResiduals );

%
% Plot the data sets with their fits, any other fits and residuals
%
nPlotAllDataSetsAndFits();
if isShowResiduals
    nPlotAllResiduals();
end
%

% Set the Y limits after all the plots have been done
iCopyProperties( 'Ylim', hCftoolMainAxes, hMainAxes );
if isShowResiduals
    iCopyProperties( 'Ylim', hCftoolResidualAxes, hResidualAxes );
end

% Display the legend
MainLegend.Show(     cffig, hCftoolMainAxes,     hFigure, hMainAxes     );
ResidualLegend.Show( cffig, hCftoolResidualAxes, hFigure, hResidualAxes );

% Make everything look nice
if isShowResiduals
    iTidyAxes( hMainAxes, getString(message('curvefit:cftoolgui:DataAndFits')) );
    iTidyAxes( hResidualAxes, getString(message('curvefit:cftoolgui:Residuals')) );
else
    % There is no axes title if there is only the main plot
    iTidyAxes( hMainAxes, '' );
end

% Only when we're finished do we show the figure
set( hFigure, 'Visible', 'On' );

%
% Effective end of "cfduplicatefigure" -- everything below here is a nested
% function
%-----------------------------------------------------------------------
    function nPlotAllDataSetsAndFits
        % Plot all of the datasets in CFTOOL. Also plot the fits associated with each
        % dataset
        ds = down( dsdb );
        while ~isempty( ds )
            if iIsDataSetPlotted( ds )
                nPlotDataSet( ds );
            end
            
            % Plot associated data sets
            nPlotFitsForDataSet( ds );
            
            % Get the next data set
            ds = right( ds );
        end
    end % of nPlotAllDataSetsAndFits

%-----------------------------------------------------------------------
    function nPlotFitsForDataSet( ds )
        % Plots the fits associated with a given dataset
        ft = down( fitdb );
        while ~isempty( ft )
            if ft.plot && isequal( ds, ft.dshandle ) 
                nPlotFit( ft )
            end
            % Get the next fit from the database
            ft = right( ft );
        end
    end % of nPlotFitsForDataSet

%-----------------------------------------------------------------------
    function nPlotAllResiduals
        % Plot the residuals in fit order
        ft = down( fitdb );
        while ~isempty( ft )
            if ft.plot
                nPlotResidual( ft )
            end
            % Get the next fit from the database
            ft = right( ft );
        end
    end % of nPlotAllResiduals

%-----------------------------------------------------------------------
    function nPlotDataSet( ds )
        % Plot a single dataset
        
        % Copy the data line from CFTOOL to the new plot
        nCopyLine( ds.line, ds.name );
    end % of nPlotDataSet

%-----------------------------------------------------------------------
    function nPlotFit( ft )
        % Plot line (or lines if bounds are required) for a single fit.

        [mainLine, lowerBound] = copyLines( ft.line, hMainAxes );
        
        MainLegend.AddItem( mainLine, ft.name );
        
        if ~isempty( lowerBound )
            boundDisplayName = iDisplayNameForBounds( ft );
            MainLegend.AddItem( lowerBound, boundDisplayName );
        end
    end % of nPlotFit

%-----------------------------------------------------------------------
    function nCopyLine( hSourceLine, displayName )
        % Copy a line from the CFTOOL Main Axes to the new Main Axes
        
        % Create the new line
        hNewLine = line( 'Parent', hMainAxes );
        % ... and copy properties from the CFTOOL plot
        iCopyProperties( LINE_PROPERTIES_TO_COPY, hSourceLine, hNewLine );
        
        if ~isempty( displayName )
            % Set the display name for use in the legend
            set( hNewLine, 'DisplayName', displayName );
            MainLegend.AddItem( hNewLine, displayName );
        else
            % If there is no display name then the line shouldn't appear in the
            % legend. To make this happen, hide the handle
            set( hNewLine, 'HandleVisibility', 'Off' );
        end
    end

%-----------------------------------------------------------------------
    function nPlotResidual( ft )
        % Plot a single residual curve
        
        % This function is a modfied version of nCopyLine. The main difference
        % is that this function puts the newline in the axes for the residual
        % plot and registers the line with the legend for the residual plot. 
        %
        % Also, the inputs as they would be for nCopyLine are determined direct
        % from the cftoolgui.fit:
        hSourceLine = ft.rline;
        displayName = ft.name;
        
        % Create the new line
        hNewLine = line( 'Parent', hResidualAxes );
        % ... and copy properties from the CFTOOL plot
        iCopyProperties( LINE_PROPERTIES_TO_COPY, hSourceLine, hNewLine );
                
        % Tell the legend about the residual line
        set( hNewLine, 'DisplayName', displayName );
        ResidualLegend.AddItem( hNewLine, displayName );
    end % of nPlotResidual

%-----------------------------------------------------------------------
end % of cfduplicatefigure

%-----------------------------------------------------------------------
function tf = iIsDataSetPlotted( ds )
dsline = ds.line;
tf =  ds.plot && ~isempty( dsline ) && ishandle( dsline );
end

%-----------------------------------------------------------------------
function iTidyAxes( hAxes, titleText )
set( hAxes, 'NextPlot', 'Replace' ); % hold off
xlabel( hAxes, '' );               % remove x label
ylabel( hAxes, '' );               % remove y label
title( hAxes, titleText );
end % of iTidyAxes

%-----------------------------------------------------------------------
function iCopyProperties( properties, src, tgt )
% Copy the values of a list of properties from one HG object (src) to
% another (tgt)
if ~iscell( properties )
    properties = {properties};
end
for i = 1:length( properties ),
    set( tgt, properties{i}, get( src, properties{i} ) );
end
end % of iCopyProperties

%-----------------------------------------------------------------------
function obj = iLegendBuilder( tf )
% A fake object to build a legend. This object allows you to add one
% handle at time to the list of handles to be displayed in the legend
% and then display the legend at some delayed point, e.g., 
%
%     obj = legendBuilder( tf )
%     ...
%     h1 = line( 1:10, sin( 1:10 ) )
%     obj.AddItem( h1, 'Sine' )
%     ...
%     h2 = line( 1:10, cos( 1:10 ) )
%     obj.AddItem( h2, 'Cosine' )
%     ...
%     obj.Show( ... )
%
% The TF flags indicates whether a true builder of a fake (false)
% builder should be built. For fake builder the methods do nothing.

% Public Methods
if tf,
    obj = struct( ...
        'AddItem', @nAddItem, ...
        'Show',    @nDisplayLegend );
else
    obj = struct( ...
        'AddItem', @(varargin) [], ...
        'Show',    @(varargin) [] );
end    

% Private Properties
fHandles = []; % vector of handles to objects to put in legend
fLabels  = {}; % cell-string of labels for legend items

%-----------------------------------------------------------------------
    function nAddItem( handle, label )
        %NADDITEM Add an item to the legend.
        %   NADDITEM( H, L ) adds the handle H to list of items to be
        %   displayed in the legend. This item will be given the label
        %   L (char array).
        fHandles(end+1) = handle;
        fLabels{end+1}  = label;
    end
%-----------------------------------------------------------------------
    function nDisplayLegend( ...
            cftFigure, cftAxes, ... % CFTOOL figure & axes
            ptfFigure, ptfAxes )    % destination figure & axes for print-to-figure
        % Display a legend for the print-to-figure (PTF) axes based on the
        % settings in the CFTOOL axes.

        % If there are any lines in the PTF axes,
        %   Display the legend for the PTF axes
        %   Get the properties and values from the CFTOOL legend that needs to be
        %       copied to the PTF legend
        %   Set these properties in the PTF legend
        %   Set the position of the PTF legend to match the CFTOOL legend
        %   Set the Interpreter to none (as done in CFUPLDATELEGEND)

        % If there are any lines in the PTF axes,
        if ~isempty( findall( ptfAxes, 'Type', 'Line' ) )
            % Display the legend for the PTF axes
            ptfLegend = legend( ptfAxes, fHandles, fLabels{:}  );
            % Get the properties and values from the CFTOOL legend that needs to
            % be copied to the PTF legend
            cftLegend = legend( cftAxes );
            legendProperties = cfgetlegendinfo( cftLegend );
            % Set these properties in the PTF legend
            set( ptfLegend, legendProperties{:} );
            % Set the position of the PTF legend to match the CFTOOL legend
            iSetLegendPosition( ...
                cftFigure, cftAxes, cftLegend, ...
                ptfFigure, ptfAxes, ptfLegend );
            % Set the Interpreter to none (as done in CFUPLDATELEGEND)
            set( ptfLegend, 'Interpreter', 'none' );
        end
    end % of nDisplayLegend
%-----------------------------------------------------------------------
end % of LegendBuilder

%-----------------------------------------------------------------------
function iSetLegendPosition( ...
    cftFigure, cftAxes, cftLegend, ... % CFTOOL figure, axes & legend
    ptfFigure, ptfAxes, ptfLegend )    % destination figure, axes & legend for print-to-figure
% Set the position of the print-to-figure legend based on the position
% of the CFTOOL legend position.

% If the location of the CFTOOL legend is set to 'None' then
%   Get the position of the CFTOOL legend relative to its axis
%   Set the position of the figure legend to the same position relative
%       to its axis
% Otherwise,
%   Set the location of the figure legend to be same as that for the
%       CFTOOL legend

% If the location of the CFTOOL legend is set to 'None' then
cftLocation = get( cftLegend, 'Location' );
if strcmpi('none', cftLocation )
    % Get the position of the CFTOOL legend relative to its axis
    position = getrelativelegendposition( cftFigure, cftAxes, cftLegend );
    % Set the position of the figure legend to the same position
    % relative to its axis
    setrelativelegendposition( position, ptfFigure, ptfAxes, ptfLegend );
else
    % Set the location of the figure legend to be same as that for the
    % CFTOOL legend
    set( ptfLegend, 'Location', cftLocation );
end
end % of iSetLegendPosition

%-----------------------------------------------------------------------
function name = iDisplayNameForBounds( ft )
name = getString( message( 'curvefit:cftoolgui:PredBnds', ft.name ) );
end
