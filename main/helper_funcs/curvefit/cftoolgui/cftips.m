function cftips(varargin)
% CFTIPS is a helper function for CFTOOL

% CFTIPS Display data and fit tips for CFTOOL

%   Copyright 2000-2013 The MathWorks, Inc.

% Only regular click should display tips, not shift-click
f = gcbf;
if ~isequal(get(f,'SelectionType'),'normal')
    return;
end
h = hittest;

cftip = findobj(f,'Tag','cftip');
cfdot = findobj(f,'Tag','cfdot');
%cfbox = findobj(f,'tag','cfbox');

% Figure out if the cursor is on something we know how to label
msg = '';
if (~isempty(h)) && ishandle(h) && isequal(get(h,'Type'),'line')
    ax = get(h,'Parent');
    if isempty(ax) || ~isequal(get(ax,'Type'),'axes')
        ax = get(f,'CurrentAxes');
    end
    pt = get(ax,'CurrentPoint');
    x = pt(1,1);
    y = pt(1,2);
    htag = get(h,'Tag');
    xlim = get(ax,'XLim');
    ylim = get(ax,'YLim');
    x = max(xlim(1), min(xlim(2),x));
    y = max(ylim(1), min(ylim(2),y));
    dx = diff(xlim) * 0.02;
    dy = 0;
    
    % Label the scattered points with the row number and coordinates
    if iIsTagForLineOfPoints(htag)
        xd = get(h,'XData');
        yd = get(h,'YData');
        xyd = abs((xd-x)/diff(xlim)) + abs((yd-y)/diff(ylim));
        [~,j] = min(xyd);
        if (~isempty(j))
            j = j(1);
            x = xd(j);
            y = yd(j);
            ds = [];
            if isequal(htag,'cfresid')
                % Residuals are sorted by x; get original row number
                ud = get(h,'UserData');
                if iscell(ud) && length(ud)>=3
                    idx = ud{3};
                    if j<=length(idx)
                        j = idx(j);
                    end
                    ds = ud{2};
                end
            else
                ds = get(h,'UserData');
            end
            xStr = sprintf('%g', x);
            yStr = sprintf('%g', y);
            if ~isempty(ds) && ishandle(ds)
                if isempty(ds.weight)
                    msg = getString(message('curvefit:cftoolgui:PointWithData',ds.name,j,xStr,yStr));
                else
                    weightStr = sprintf('%g', ds.weight(j));
                    msg = getString(message('curvefit:cftoolgui:PointWithDataAndWeights',...
                        ds.name,j,xStr,yStr,weightStr));
                end
            else
                msg = getString(message('curvefit:cftoolgui:PointWithNoData',j,xStr,yStr));
            end
        end
    elseif iIsTagForBoundLine(htag)
        % Try to label fitted curve, but label conf bounds as a last resort
        msg = getString(message('curvefit:cftoolgui:ConfidenceBounds'));
        ud = get(h,'UserData');
        if ishandle(ud)
            h = ud;
            htag = get(ud,'Tag');
        end
    end
    
    if iIsTagForFitLine( htag );
        fitdev = getFitFromLine( h );
        
        if ~isempty( fitdev )
            msg = get( h, 'DisplayName' );
            fun = fitdev.fit;
            bounded = isequal( fitdev.line.ShowBounds, 'on' );
            
            % Round x a bit
            xrange = diff(xlim);
            if xrange>0
                pwr = floor(log10(0.005 * xrange));
                mult = 10 ^ -pwr;
                x = round(mult * x) / mult;
            end
            
            if bounded
                try
                    % Position marker at closest curve and create label
                    oldy = y;
                    [ci,y] = predint(fun, x, fitdev.line.ConfLev);
                    msg = sprintf('%s\nf(%g) = %g +/- %g',msg,x,y,abs(ci(2)-y));
                    yy = [ci(:);y];
                    [~,yidx] = min(abs(yy-oldy));
                    y = yy(yidx);
                catch ignore %#ok<NASGU>
                    bounded = 0;
                end
            end
            if ~bounded
                y = feval(fun,x);
                msg = sprintf('%s\nf(%g) = %g',msg,x,y);
            end
            dy = feval(fun,x+dx) - y;
        else
            msg = getString(message('curvefit:cftoolgui:FittedCurve'));
        end
    end
end

% If we can't label this thing, delete the label components
if isempty(msg)
    removetips(f);
    
    % Otherwise we need to create the proper label
else
    if ~isempty(cfdot) && ishandle(cfdot)
        if isequal(x,get(cfdot,'XData')) && isequal(y,get(cfdot),'YData')
            return;
        end
    end
    
    % Create the text and line components of the label if missing
    if isempty(cftip) || ~ishandle(cftip)
        yellow = [1 1 .85];
        cftip = text(x,y,'','Color','k','VerticalAlignment','bottom',...
            'Parent',ax, 'Tag','cftip','Interpreter','none',...
            'HitTest','off','FontWeight','bold',...
            'BackgroundColor',yellow,'Margin',3,...
            'EdgeColor','k');
    end
    if isempty(cfdot) || ~ishandle(cfdot)
        cfdot = line(x,y,'Marker','o','LineStyle','none','Color','k',...
            'Tag','cfdot','Parent',ax,'HitTest','off');
    end
    % Position the text so it is not clipped, then write the label
    if (x<sum(xlim)/2)
        ha = 'left';
    else
        ha = 'right';
        dx = - dx;
    end
    if sign(dx)==sign(dy)
        va = 'top';
    else
        va = 'bottom';
    end
    set(cftip,'Position',[x+dx y 0],'String',msg,...
        'HorizontalAlignment',ha,'VerticalAlignment',va);
    set(cfdot,'XData',x,'YData',y);
    
    
    set(f, 'WindowButtonMotionFcn',@cftips);
    set(f, 'WindowButtonUpFcn',@disabletips);
end

function disabletips(varargin)
cffig = gcbf;
removetips(cffig);
set(cffig, 'WindowButtonUpFcn','');
set(cffig, 'WindowButtonMotionFcn','');

function removetips(cffig)
delete(findobj(cffig,'Tag','cftip'));
delete(findobj(cffig,'Tag','cfdot'));

function tf = iIsTagForBoundLine( tag )
boundTags = {
    'cfconf'
    'curvefit.gui.FunctionLine.LowerLine'
    'curvefit.gui.FunctionLine.UpperLine'
    };
tf = ismember( tag, boundTags );

function tf = iIsTagForFitLine( tag )
fitTags = {
    'curvefit'
    'curvefit.gui.FunctionLine.MainLine'
    };
tf = ismember( tag, fitTags );

function tf = iIsTagForLineOfPoints(htag)
tf = isequal( htag, 'cfdata' ) || isequal( htag, 'cfresid' );
