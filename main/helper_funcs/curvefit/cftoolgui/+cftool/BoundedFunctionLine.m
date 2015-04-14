classdef BoundedFunctionLine < curvefit.Handle & hgsetget
    % BoundedFunctionLine   FunctionLine with confidence bounds
    %
    %   Construction
    %       anAxes = axes();
    %       aLine = cftool.BoundedFunctionLine.create( anAxes );
    %
    %   See also curvefit.gui.FunctionLine
    
    %   Copyright 2013 The MathWorks, Inc.
    
    properties(Dependent)
        % Fit   (cftool.fit)
        Fit
        
        % String   Display name for the line (char array)
        String
        
        % ConfLev   Prediction level (scalar double between 0 and 1)
        ConfLev
        
        % LineWidth
        LineWidth
        
        % LineStyle
        LineStyle
        
        % Color
        Color
        
        % ContextMenu   (uicontextmenu)
        ContextMenu
        
        % ButtonDownFcn   (function handle or cell array)
        ButtonDownFcn
    end
    
    properties(SetObservable, Dependent)
        % ShowBounds   ('on' or 'off')
        ShowBounds
    end
    
    properties(SetAccess = private, Dependent)
        % YLim   The y-limits (extent) of the line (1-by-2 double or empty?)
        YLim
        
        % YData
        YData
    end
    
    properties
        % Marker   (ignored)
        Marker = 'none';
        
        % MarkerSize   (ignored)
        MarkerSize = 2;
    end
    
    properties(Access = private)
        % FunctionLine   (curvefit.gui.FunctionLine)
        FunctionLine
        
        % PrivateFit   Private storage for public Fit property
        PrivateFit
    end
    
    methods(Hidden)
        function this = BoundedFunctionLine( aFunctionLine )
            % BoundedFunctionLine
            %
            %   aLine = BoundedFunctionLine( aFunctionLine )
            this.FunctionLine = aFunctionLine;
            
            iSetUserDataOnBounds( this.FunctionLine );
            iSetPickableParts( this.FunctionLine );
        end
    end
    
    methods
        function aFit = get.Fit( this )
            % get.Fit   Get method for Fit
            aFit = this.PrivateFit;
        end
        
        function set.Fit( this, aFit )
            % set.Fit   Set method for Fit
            this.FunctionLine.FitObject = aFit.fit;
            this.FunctionLine.DisplayName = aFit.name;
            this.FunctionLine.XData = aFit.dshandle.x;
            
            this.PrivateFit = aFit;
        end
        
        function string = get.String( this )
            % get.String   Get method for String
            string = this.FunctionLine.DisplayName;
        end
        
        function set.String( this, string )
            % set.String   Set method for String
            this.FunctionLine.DisplayName = string;
        end
        
        function ylim = get.YLim( this )
            % get.YLim   Get method for YLim (y-limits or extent)
            ydata = [
                get( this.FunctionLine.MainLine,  'YData' ), ...
                get( this.FunctionLine.LowerLine, 'YData' ), ...
                get( this.FunctionLine.UpperLine, 'YData' )
                ];
             ylim = [min( ydata ), max( ydata )];
        end
        
        function ydata = get.YData( this )
            % get.YData   Get method for YData
            ydata = get( this.FunctionLine.MainLine, 'YData' );
        end

        function show = get.ShowBounds( this )
            % get.ShowBounds   Get method for ShowBounds
            show = this.FunctionLine.PredictionBounds;
        end
        
        function set.ShowBounds( this, show )
            % set.ShowBounds   Set method for ShowBounds
            %
            % Syntax
            %   aLine.ShowBounds = 'on';
            %   aLine.ShowBounds = 'off';
            this.FunctionLine.PredictionBounds = show;
        end
        
        function level = get.ConfLev( this )
            % get.ConfLev   Get method for confidence level
            functionLine = this.FunctionLine;
            options = functionLine.PredictionBoundsOptions;
            level = options.Level;
        end
        
        function set.ConfLev( this, level )
            % set.ConfLev   Set method for confidence level
            this.FunctionLine.PredictionBoundsOptions.Level = level;
        end
        
        function width = get.LineWidth( this )
            % get.LineWidth   Get method for LineWidth
            width = this.FunctionLine.LineWidth;
        end
        
        function set.LineWidth( this, width )
            % set.LineWidth   Set method for LineWidth
            this.FunctionLine.LineWidth = width;
        end  
        
        function style = get.LineStyle( this )
            % get.LineStyle   Get method for LineStyle
            style = this.FunctionLine.LineStyle;
        end
        
        function set.LineStyle( this, style )
            % set.LineStyle   Set method for LineStyle
            this.FunctionLine.LineStyle = style;
        end  
        
        function color = get.Color( this )
            % get.Color   Get method for Color
            color = this.FunctionLine.Color;
        end
        
        function set.Color( this, color )
            % set.Color   Set method for Color
            this.FunctionLine.Color = color;
        end
        
        function menu = get.ContextMenu( this )
            % get.ContextMenu   Get method for context menu
            menu = get( this.FunctionLine.MainLine, 'UIContextMenu' );
        end
        
        function set.ContextMenu( this, menu )
            % set.ContextMenu   Set method for context menu
            set( this.FunctionLine.MainLine, 'UIContextMenu', menu );
        end
        
        function fcn = get.ButtonDownFcn( this )
            % get.ButtonDownFcn   Get method for button down callback
            fcn = get( this.FunctionLine.MainLine, 'ButtonDownFcn' );
        end
        
        function set.ButtonDownFcn( this, fcn )
            % set.ButtonDownFcn   Set method for button down callback
            set( this.FunctionLine.MainLine,  'ButtonDownFcn', fcn );
            set( this.FunctionLine.LowerLine, 'ButtonDownFcn', fcn );
            set( this.FunctionLine.UpperLine, 'ButtonDownFcn', fcn );
        end
        
        function tf = isComposedOf( this, aLine )
            % isComposedOf   True if this bounded line is composed of the given line
            tf = isequal( this.FunctionLine.MainLine, aLine );
        end
        
        function handles = getLinesForLegend( this )
            aFunctionLine = this.FunctionLine;
            if this.isShowingBounds()
                handles = [aFunctionLine.MainLine, aFunctionLine.LowerLine];
            else
                handles = aFunctionLine.MainLine;
            end
        end
        
        function [mainLine, lowerBound] = copyLines( this,  targetAxes )
            aFunctionLine = this.FunctionLine;
            
            mainLine = iCopyLine( targetAxes, aFunctionLine.MainLine );
            
            if this.isShowingBounds()
                lowerBound = iCopyLine( targetAxes, aFunctionLine.LowerLine );
                iCopyLine( targetAxes, aFunctionLine.UpperLine );
            else
                lowerBound = [];
            end
        end
    end
    
    methods(Access = private)
        function tf = isShowingBounds( this )
            tf = isequal( this.ShowBounds, 'on' ) && iBoundHasXData( this.FunctionLine );
        end
    end
    
    methods(Static)
        function aLine = create( anAxes, varargin )
            % create   Create a BoundedFunctionLine in an axes
            %
            %   aLine = cftool.BoundedFunctionLine.create( anAxes, ... ) is a bounded line
            %   object.
            %
            %   Parameter-value pairs:
            %       'Fit'               cftool.fit
            %       'ShowBounds'        'on' or 'off'
            %       'ConfLev'           confidence level (scalar double between 0 and 1)
            %       'Color'             line color
            %       'LineStyle'         line color
            %       'LineWidth'         line width
            %       'ContextMenu'       context menu
            %       'ButtonDownFcn'     button down callback function
            %
            %   See also: cftool.BoundedFunctionLine
            inputs = iParseInputs( varargin{:} );
            
            aFunctionLine = curvefit.gui.FunctionLine( anAxes );

            aLine = cftool.BoundedFunctionLine( aFunctionLine );
            set( aLine, inputs );
        end
    end
end

function inputs = iParseInputs( varargin )
parser = inputParser();
parser.addParameter( 'Fit', [] );
parser.addParameter( 'ShowBounds', 'off' );
parser.addParameter( 'ConfLev', 0.95 );
parser.addParameter( 'Color', 'k' );
parser.addParameter( 'LineStyle', '--' );
parser.addParameter( 'LineWidth', 7 );
parser.addParameter( 'ContextMenu', [] );
parser.addParameter( 'ButtonDownFcn', {} );
parser.parse( varargin{:} );
inputs = parser.Results;
end

function iSetUserDataOnBounds( aFunctionLine )
try
    set( aFunctionLine.LowerLine, 'UserData', aFunctionLine.MainLine );
    set( aFunctionLine.UpperLine, 'UserData', aFunctionLine.MainLine );
catch ignore %#ok<NASGU>
end
end

function iSetPickableParts( aFunctionLine )
try
    set( [aFunctionLine.MainLine, aFunctionLine.LowerLine, aFunctionLine.UpperLine], ...
        'PickableParts', 'visible' );
catch ignore %#ok<NASGU>
end
end

function tf = iBoundHasXData( aFunctionLine )
tf = ~isempty( get( aFunctionLine.LowerLine, 'XData' ) );
end

function newLine = iCopyLine( targetAxes, oldLine )
PROPERTIES_TO_COPY = {'Color', 'LineStyle', 'LineWidth', ...
    'Marker', 'MarkerSize', 'MarkerEdgeColor', 'MarkerFaceColor', 'XData', 'YData'};

newLine = line( 'Parent', targetAxes );
set( newLine, PROPERTIES_TO_COPY, get( oldLine, PROPERTIES_TO_COPY ) );
end
