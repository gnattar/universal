r=1:120;
array = reshape(r,5,24)';
for n = 1: 24
dends = array(n,:);
sc = get(0,'ScreenSize');
h_fig1 = figure('position', [1000, sc(4)/10-100, sc(3)*2/3, sc(4)], 'color','w');
ph=unique(pcopy{1}.phase);
count =1;
for d =1:length(dends)
    temp = pcopy{dends(d)}.sigpeak;
    for i = 1:5
        subplot(5,5+1,count);
        lind = find(pcopy{dends(d)}.loc == i & pcopy{dends(d)}.lightstim == 1);
        nlind = find(pcopy{dends(d)}.loc == i & pcopy{dends(d)}.lightstim == 0);
        mRNL(dends(d),i) = nanmean(pcopy{dends(d)}.sigpeak(nlind));
        sRNL(dends(d),i) = nanstd(pcopy{dends(d)}.sigpeak(nlind));
        mRL(dends(d),i) = nanmean(pcopy{dends(d)}.sigpeak(lind));
        sRL(dends(d),i) = nanstd(pcopy{dends(d)}.sigpeak(lind));
        plot(pcopy{dends(d)}.sigpeak(nlind),'ko','markerfacecolor',[.5 .5 .5]);
        hold on; plot(pcopy{dends(d)}.sigpeak(lind),'ro','markerfacecolor',[.85 .5 .5]);
        temp2 = [length(nlind); length(lind)];
        axis([0 max(temp2)+1 -10 max(temp)+5]);
        hline(mRNL(dends(d),i),'k');hline(mRL(dends(d),i),'r');
        set(gca,'tickdir','out','ticklength',[.02 .02]);
        title(['D ' num2str(dends(d)) ' Ph ' num2str(ph(i))]); 
        count = count+1;
    end
subplot(5,5+1,count);
plot(mRNL(dends(d),:),'ko-','linewidth',1.5);hold on;plot(mRL(dends(d),:),'ro-','linewidth',1.5);
set(gca,'tickdir','out','ticklength',[.02 .02]);
count = count+1;
end

set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');
print( gcf ,'-depsc2','-painters','-loose',[' Raw sig amp D ' num2str(dends)]);
saveas(gcf,[' Raw sig amp D ' num2str(dends)],'jpg');
saveas(gcf,[' Raw sig amp D ' num2str(dends)],'fig');
end


% %% plot tuning curves
% sc = get(0,'ScreenSize');
% h_fig1 = figure('position', [1000, sc(4)/10-100, sc(3)*2/3, sc(4)], 'color','w');
% count = 1;
% for i = 121:123
%     subplot(5,6,count);
%     plot(mRNL(i,:),'ko-','linewidth',1.5);hold on;plot(mRL(i,:),'ro-','linewidth',1.5);
%     set(gca,'tickdir','out','ticklength',[.02 .02]);
%     title( ['D ' num2str(i)]);
%     count = count+1;
% end

r=1:120;
array = reshape(r,5,24)';
for n = 1: 24
dends = array(n,:);
sc = get(0,'ScreenSize');
h_fig1 = figure('position', [1000, sc(4)/10-100, sc(3)*2/3, sc(4)], 'color','w');
ph=unique(pcopy{1}.theta);
count =1;
for d =1:length(dends)
    temp = pcopy{dends(d)}.sigpeak;
    for i = 1:4
        subplot(5,4+1,count);
        lind = find(pcopy{dends(d)}.loc == i & pcopy{dends(d)}.lightstim == 1);
        nlind = find(pcopy{dends(d)}.loc == i & pcopy{dends(d)}.lightstim == 0);
        mRNL(dends(d),i) = nanmean(pcopy{dends(d)}.sigpeak(nlind));
        sRNL(dends(d),i) = nanstd(pcopy{dends(d)}.sigpeak(nlind));
        mRL(dends(d),i) = nanmean(pcopy{dends(d)}.sigpeak(lind));
        sRL(dends(d),i) = nanstd(pcopy{dends(d)}.sigpeak(lind));
        plot(pcopy{dends(d)}.sigpeak(nlind),'ko','markerfacecolor',[.5 .5 .5]);
        hold on; plot(pcopy{dends(d)}.sigpeak(lind),'ro','markerfacecolor',[.85 .5 .5]);
        temp2 = [length(nlind); length(lind)];
        axis([0 max(temp2)+1 -10 max(temp)+5]);
        hline(mRNL(dends(d),i),'k');hline(mRL(dends(d),i),'r');
        set(gca,'tickdir','out','ticklength',[.02 .02]);
        title(['D ' num2str(dends(d)) ' Ph ' num2str(ph(i))]); 
        count = count+1;
    end
subplot(5,4+1,count);
plot(mRNL(dends(d),:),'ko-','linewidth',1.5);hold on;plot(mRL(dends(d),:),'ro-','linewidth',1.5);
set(gca,'tickdir','out','ticklength',[.02 .02]);
count = count+1;
end

set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');
print( gcf ,'-depsc2','-painters','-loose',[' Raw sig amp D ' num2str(dends)]);
saveas(gcf,[' Raw sig amp D ' num2str(dends)],'jpg');
saveas(gcf,[' Raw sig amp D ' num2str(dends)],'fig');
end
