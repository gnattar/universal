function h_fig1 = plot_CaTraces_ROIs(F, ts, ROIs)
%
%
%
% - NX 5/2009
% edited - GR 082012

y_lim = [min(min(F))/2 max(max(F))];
x_lim = [min(ts)-1 max(ts)+1];

nROI = size(F,1); % total number of ROIs in the Result file
% if ~exist('ROIs','var')
    ROIs = (1:nROI);
% end;

spacing = 1/(length(ROIs)+3.5); % n*x + 3.5x = 1, space between plottings;

 sc = get(0,'ScreenSize');

h_fig1 = figure('position', [1000, sc(4)/14-100, sc(3)*3/14, sc(4)*3/4], 'color','w');
hold on;
% delete(get(h_fig,'Children'));
% h_axes1 = axes('Position',[0 0 1 1], 'Visible','off', 'Color', 'none');
cmap = colormap('HSV');
colorstep = floor(size(cmap,1)/(nROI+1));

 ht = title('CaTraces over ROIs', 'Color', 'w', 'FontSize', 21, 'Position',[.5 .94 0], 'Interpreter','none');
% uistack(gca, 'top');

% plot Ca signals for all ROIs to multiple axes in the same figure.
set(gca, 'visible', 'off');
for i = 1:length(ROIs)
%      h(i) = axes('position',[0.028, i*0.06, 0.97, 0.22]);
     %  axes(h_axes1);

    h(i) = axes('position',[0.03, i*spacing, 0.96, 3.5*spacing]);
    plot(ts,F(ROIs(i),:), 'color', cmap((ROIs(i)-1)*colorstep +1,:),'linewidth',2);
    vline([1 1.5 2 2.5 ],'k-');
    set(h(i),'visible','off', 'color','none','YLim',y_lim,...
        'XLim',x_lim);
end;
set(h(1),'visible','on', 'box','off','XColor','k','YColor','k','FontSize',15);

% scalebar;

%plot Ca signal as color scaled rows in image
% % % % axes(imaxes);
  figure('position', [1400, sc(4)/14-100, sc(3)*3/14, sc(4)*3/4], 'color','w');
%  imagesc(ts,[1:size(F,1)],flipud(F)); colormap('jet');
 imagesc(ts,[1:size(F,1)],F); colormap('jet');
 set(gca,'YDir','normal');
%  set(gca,'YDir','reverse');
 vline([1 1.5 2 2.5],'k-');
 caxis([0 300]);
 
%  axis([0 size(F,1) 0 ts(length(ts))]); 

