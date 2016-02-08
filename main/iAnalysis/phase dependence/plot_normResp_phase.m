function plot_normResp_phase(data,light)
sc = get(0,'ScreenSize');
figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w');
collected_ctrl = nan(200,11);
collected_mani = nan(200,11);
template = [-5:1:5];
numpts  = zeros(1,11);count =1;inccount = 0;
for s = 1:size(data.meanResp_phase_ctrl,2)
    
    mR_c = data.meanResp_phase_ctrl{s};
    m_2_n = mean(mR_c,2);
    m_2_n = repmat(m_2_n,1,size(mR_c,2));
    norm_mR_c = mR_c./m_2_n;

    PrefPhid = data.PPid_ctrl{s}(:,1);
    PrefPh = data.PPh_ctrl{s}(:,1);
    xphid = zeros(size(norm_mR_c));
    numphid = size(norm_mR_c,2);
    for l = 1: size(xphid,2)
        xphid(:,l) = l;
    end
    prefphid = repmat(PrefPhid,1,size(xphid,2));
    xphid = xphid - prefphid;

    if light %% mean for each condition within that set
        mR_m = data.meanResp_phase_mani{s};
        m_2_n = mean(mR_m,2);
        m_2_n = repmat(m_2_n,1,size(mR_c,2));
        norm_mR_m = mR_m./m_2_n;
    end
    
    
    
    subplot(1,2,1);
    plot(xphid',norm_mR_c','color',[.5 .5 .5],'linewidth',.5);hold on;
    if light
    subplot(1,2,2);
    plot(xphid',norm_mR_m','color',[.85 .5 .5],'linewidth',.5);hold on;
    end
    
    for c= 1:size(xphid,1)
        for t = 1:length(xphid(c,:))
            collected_ctrl (count,find(template==xphid(c,t))) = norm_mR_c(c,t);
            if light
            collected_mani (count,find(template==xphid(c,t))) = norm_mR_m(c,t);
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

temp = arrayfun(@(x) x.PPid_ctrl, data,'uni',0);
PPid=cell2mat(temp{1});
for i = 1:123
NPid(i,:)=setxor([1:5],PPid(i));
end
temp = arrayfun(@(x) x.FrCh, data,'uni',0);
frCh=cell2mat(temp{1});

temp = arrayfun(@(x) x.NormCh, data,'uni',0);
NormCh=cell2mat(temp{1});

for i = 1:size(frCh,1)
    PCh(i,1) = frCh(i,PPid(i));
    NPCh(i,1) = mean(frCh(i,NPid(i,:)));
end

m_PCh = round([nanmean(PCh), nanstd(PCh)].*10000)./100;
m_NPCh = round([nanmean(NPCh),nanstd(NPCh)].*10000)./100;


     subplot(1,2,1);title('Phase tuning ctrl')
     e1=errorbar(template,m_C,s_C,'ko-'); axis([-5 5 0 3])
     phaxis = [-5:5].*72;
set(gca,'Xtick',[-5 : 5]);
set(gca,'Xticklabel',phaxis);
 text(2,2,['n=' num2str(count-1) ' cells'])
     if light
    subplot(1,2,2);title('Phase tuning mani')
     e2=errorbar(template,m_M,s_M,'ro-'); axis([-5 5 0 3])
     tb= text(0,2.8,['FrCh P' num2str(m_PCh(1)) '+/-' num2str(m_PCh(2))]);
     tb= text(0,2.5,['FrCh NP' num2str(m_NPCh(1)) '+/-' num2str(m_NPCh(2))]);
     end

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

% if light
%  t = m_C-m_M;
%  figure;
%  plot([-5:5],t,'o-','markersize',10,'color',[.85 0 .2]);title('Diff in phase tuning')
%  phaxis = [-5:5].*72;
% set(gca,'Xtick',[-5 : 5]);
% set(gca,'Xticklabel',phaxis);
% end
% 
% set(gcf,'PaperUnits','inches');
% set(gcf,'PaperPosition',[1 1 24 18]);
% set(gcf, 'PaperSize', [10,24]);
% set(gcf,'PaperPositionMode','manual');
% 
% fnam = 'normRespPhase Tuning Diff';
% saveas(gcf,[pwd,filesep,fnam],'fig');
% print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);

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