%% plot_phase_at_touch
function plot_phase_at_touch(pooled_contactCaTrials_locdep,d)
  phase_bins = linspace(-pi,pi,6);

%     phase_bins = [-pi:pi/2:pi];
    contactPhase =  pooled_contactCaTrials_locdep{d(1)}.contactPhase;
    [num edges mid id] = histcn(contactPhase,phase_bins);
    sc = get(0,'ScreenSize');
%     figure('position', [1000, sc(4)/10-100, sc(3)/2.5, sc(4)], 'color','w');
    h_fig1 = figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w');
    count = 1;
    numcols = length(unique(id));
for i = 1:length(d)
sigpeak = pooled_contactCaTrials_locdep{d(i)}.sigpeak;
touchmag = abs(pooled_contactCaTrials_locdep{d(i)}.re_totaldK);
touchphase = pooled_contactCaTrials_locdep{d(i)}.contactPhase;

    for ph =1:length(unique(id))
        inds = find(id==ph);
        subplot(length(d),numcols,count);
        plot(touchmag(inds),sigpeak(inds),'o');
        title(['D' num2str(d(i)) ' ph ' num2str(mid{1}(ph))]); 
        set(gca,'xscale','log');%set(gca,'ticklength',[.05 .05]);
        axis ([.001 2.5 0 800]);
        count= count+1;
    end
end   


% print(h,'-dtiff','-painters','-loose',['D ' num2str(d)])

set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');
print( gcf ,'-depsc2','-painters','-loose',['D ' num2str(d)]);
saveas(gcf,['D ' num2str(d)],'jpg');