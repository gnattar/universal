function plot_normSlope_phase(data,light)
sc = get(0,'ScreenSize');
figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w');
collected_ctrl = nan(200,11);
collected_mani = nan(200,11);
template = [-5:1:5];
numpts  = zeros(1,11);count =1;
for s = 1:size(data.PPI_ctrl,2)
    
    mS_c = data.slopes_ctrl{s};
    m_2_n = mean(mS_c,2);
    m_2_n = repmat(m_2_n,1,size(mS_c,2));
    norm_mS_c = mS_c./m_2_n;

    PrefPhid = data.PPid_ctrl{s}(:,1);
    PrefPh = data.PPh_ctrl{s}(:,1);
    xphid = zeros(size(norm_mS_c));
    numphid = size(norm_mS_c,2);
    for l = 1: size(xphid,2)
        xphid(:,l) = l;
    end
    prefphid = repmat(PrefPhid,1,size(xphid,2));
    xphid = xphid - prefphid;

    if light
        mS_m = data.slopes_mani{s};
        norm_mS_m = mS_m./m_2_n;
    end
    
    
    
    subplot(1,2,1);
    plot(xphid',norm_mS_c','color',[.5 .5 .5],'linewidth',.5,'fontsize',16);hold on;
    if light
    subplot(1,2,2);
    plot(xphid',norm_mS_m','color',[.85 .5 .5],'linewidth',.5,'fontsize',16);hold on;
    end
    
    for c= 1:size(xphid,1)
        for t = 1:length(xphid(c,:))
            collected_ctrl (count,find(template==xphid(c,t))) = norm_mS_c(c,t);
            if light
            collected_mani (count,find(template==xphid(c,t))) = norm_mS_m(c,t);
            end
            numpts(count,find(template==xphid(c,t))) = 1;
        end  
    count = count+1;
    end
end
 
collected_ctrl(count:end,:) = [];
if light
collected_mani(count:end,:) = [];
end
 temp = collected_ctrl;
 temp (find(temp==0)) = nan;
 temp2 = sqrt(sum(numpts));
 m_C = nanmean(temp);
 s_C = nanstd(temp)./temp2;
if light
    temp = collected_mani;
 temp (find(temp==0)) = nan;
 temp2 = sqrt(sum(numpts));
 m_M = nanmean(temp);
 s_M = nanstd(temp);
 s_M= nanstd(temp)./temp2;
end
     subplot(1,2,1);title('Phase Slope tuning ctrl')
     e1=errorbar(template,m_C,s_C,'ko-'); axis([-4 4 0 6]);
     set(e1,'linewidth',2);ylabel('Slope dFF vs. |dK|');xlabel ('touch phase')
     phaxis = [-5:5].*72;
set(gca,'Xtick',[-5 : 5]);
set(gca,'Xticklabel',phaxis);
     if light
    subplot(1,2,2);title('Phase Slope tuning mani')
     e2=errorbar(template,m_M,s_M,'ro-'); axis([-4 4 0 6])
     set(e2,'linewidth',2,'fontsize',16);ylabel('Slope dFF vs. |dK|');xlabel ('touch phase')
     end
 text(2,2,['n=' num2str(count-1) ' cells'])
phaxis = [-5:5].*72;
set(gca,'Xtick',[-5 : 5]);
set(gca,'Xticklabel',phaxis);

set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');
fnam = 'normRespPhase Tuning';
saveas(gcf,[pwd,filesep,fnam],'fig');
print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);

if light
 t = m_C-m_M;
 figure;
 plot([-5:5],t,'o-','markersize',10,'color',[.85 0 .2]);title('Diff in phase tuning')
 phaxis = [-5:5].*72;
set(gca,'Xtick',[-5 : 5]);
set(gca,'Xticklabel',phaxis);
end

set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');

fnam = 'normSlopeTuning Diff';
saveas(gcf,[pwd,filesep,fnam],'fig');
print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);

%% hist of PPIs
temp=arrayfun(@(x) x.PPI_ctrl, data,'uni',0)';
temp=temp{1}';
PPI_NL_list = cell2mat(temp);
if light
    temp=arrayfun(@(x) x.PPI_mani, data,'uni',0)';
    temp=temp{1}';
    PPI_L_list = cell2mat(temp);
end

bins = [0:.1:4];
sc = get(0,'ScreenSize');
figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w');
subplot(1,2,1);hnl=hist(PPI_NL_list(:,1),bins);plot(bins,hnl,'k');hold on ;
if light
    hl=hist(PPI_L_list(:,1),bins); plot(bins,hl,'r');
end
set(gca,'yscale','lin');
xlabel('norm Resp Amp at Pref Phase','Fontsize',16);title('Hist norm Resp Amp at Pref Phase','Fontsize',16);
set(gca,'Fontsize',16);


set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');


fnam = 'normRespPhase Hist';
saveas(gcf,[pwd,filesep,fnam],'fig');
print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);