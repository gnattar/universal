function plotclr(x,y,v,prn,marker)
% clement.ogaja@gmail.com

if nargin <5
    marker='.';
end

map=colormap;
miv=min(min(v));
mav=max(max(v));

[row col]=size(x);

% Plot the points
hold on
for j=1:col,
    for i=1:row%length(x)
        in=round((v(i,j)-miv)*(length(map)-1)/(mav-miv));
        %--- Catch the out-of-range numbers
        if in==0;in=1;end
        if in > length(map);in=length(map);end
        if isnan(in);in=1;end
        plot3(x(i,j),y(i,j),v(i,j),marker,'color',map(in,:),'markerfacecolor',map(in,:))
        if i==row,
            if prn(j) < 10,
                ht=text(x(i,j),y(i,j),[' S0',num2str(prn(j))]);set(ht,'fontsize',8);
            else
                ht=text(x(i,j),y(i,j),[' S',num2str(prn(j))]);set(ht,'fontsize',8);
            end
        end
    end
end
hold off

% Re-format the colorbar
%h=colorbar;
cbar('v',[miv mav],'[m]');

%set(h,'fontsize',8);
%set(get(h,'ylabel'),'string','[m]');
%set(h,'ylim',[1 length(map)]);
%yal=linspace(1,length(map),6);
%set(h,'ytick',yal);
% Create the yticklabels
%ytl=linspace(miv,mav,6);
%s=char(6,4);
%for i=1:6
%    if min(abs(ytl)) >= 0.001
%        B=sprintf('%4.2f',ytl(i));
%    else
%        B=sprintf('%4.2E',ytl(i));
%    end
%    s(i,1:length(B))=B;
%end
%set(h,'yticklabel',s);
grid on
view(2)




function CB=cbar(loc,range,label);

% .............................................................
% CB = cbar(loc,range,label)
%   places a colorbar at:
%   loc = 'v' in vertical or 'h' in horizontal
%           position in current figure scaled between:
%   range = [min max] with a:
%   label = 'string'.
%
%   fontsize is reduced to 10 and width of bar is half default.
%   
%   Example:    [X,Y,Z]=peaks(25);
%               range=[min(min(Z)) max(max(Z))];
%               pcolor(X,Y,Z);
%               cbar('v',range,'Elevation (m)')
% .............................................................

caxis([range(1) range(2)]);
switch loc
    case 'v'
        CB=colorbar('vertical');
        set(CB,'ylim',[range(1) range(2)]);
        %POS=get(CB,'position');
        %set(CB,'position',[POS(1) POS(2) 0.03 POS(4)]);
        set(CB,'fontsize',8);
        set(CB,'box','on')
        % Create the yticklabels
        ytl=linspace(range(1),range(2),6);
        set(CB,'ytick',ytl);
        s=char(6,4);
        for i=1:6
            if min(abs(ytl)) >= 0.001
                B=sprintf('%4.2f',ytl(i));
            else
                B=sprintf('%4.2E',ytl(i));
            end
            s(i,1:length(B))=B;
        end
        set(CB,'yticklabel',s);
        set(get(CB,'ylabel'),'string',label);

    case 'h'
        CB=colorbar('horizontal');
        set(CB,'xlim',[range(1) range(2)]);
        %POS=get(CB,'position');
        %set(CB,'position',[POS(1) POS(2) POS(3) 0.03]);
        set(CB,'fontsize',8);
        set(CB,'box','on')
        % Create the xticklabels
        xtl=linspace(range(1),range(2),6);
        set(CB,'xtick',xtl);
        s=char(6,4);
        for i=1:6
            if min(abs(xtl)) >= 0.001
                B=sprintf('%4.2f',xtl(i));
            else
                B=sprintf('%4.2E',xtl(i));
            end
            s(i,1:length(B))=B;
        end
        set(CB,'xticklabel',s);
        set(get(CB,'xlabel'),'string',label)
end
