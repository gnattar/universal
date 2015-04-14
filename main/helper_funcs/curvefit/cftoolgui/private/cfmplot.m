function cfmplot(ds)
%CFMPLOT Create plot for curve fitting gui

%   Copyright 2000-2013 The MathWorks, Inc.

% Re-create figure if it does not exist
cffig = cftool('makefigure');

ax = findall(cffig,'Type','axes','Tag','main');

if ds.plot
    if isempty(ds.line) || ~ishandle(ds.line)
        if isequal(size(ds.x(:)), size(ds.y(:)))
           x = ds.x;
           y = ds.y;
        else
           x = [];
           y = [];
        end
        [c,m,l,w] = cfswitchyard('cfgetcolor',ax,'data',ds);
        ds.line=line('XData',x, 'YData',y, 'Parent',ax,'ButtonDownFcn',@cftips,...
                     'Marker',m,'LineStyle',l,'Color',c,...
                     'LineWidth',w,'Tag','cfdata','UserData',ds, ...
                     'DisplayName', ds.name );
        
        if isequal(m,'.')
           set(ds.line, 'MarkerSize',12);
        end
        savelineproperties(ds);

        % Give it a context menu
        c = findall(ancestor(ax,'figure'),'Type','uicontextmenu',...
                    'Tag','datacontext');
        if ~isempty(c)
           set(ds.line,'UIContextMenu',c);
        end

        if ~isempty(ds.x)
           cfupdatexlim([min(ds.x) max(ds.x)]);
           cfupdateylim;
        end
        cfupdatelegend(cffig);
    end
else
    if (~isempty(ds.line)) && ishandle(ds.line)
        savelineproperties(ds);
        
        delete(ds.line);
        ds.line=[];
        zoom(cffig,'reset');
        
        % Update axis limits
        if ~isempty(ds.x)
           cfupdatexlim;
           cfupdateylim;
        end

        cfupdatelegend(cffig);
    end
end
