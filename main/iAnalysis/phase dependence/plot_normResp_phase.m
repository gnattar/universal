function [data] = plot_normResp_phase(data,light,txt,norm_cond)
sc = get(0,'ScreenSize');
figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w');
collected_ctrl = nan(200,11);
collected_mani = nan(200,11);
template = [-5:1:5];
numpts  = zeros(1,11);count =1;inccount = 0;n=0;
siginds = [];
for s = 1:size(data.meanResp_phase_ctrl,2)
    
    mR_c = data.meanResp_phase_ctrl{s};
    m_2_n = min(mR_c')';
    m_2_n = repmat(m_2_n,1,size(mR_c,2));
    m_2_n2 = repmat(mean(mR_c')',1,size(mR_c,2));
%     norm_mR_c = (mR_c-m_2_n)./m_2_n2;
    norm_mR_c = (mR_c)./m_2_n2;
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
        m_2_n = min(mR_m')';
        m_2_n = repmat(m_2_n,1,size(mR_m,2));
        if strcmp(norm_cond,'ctrl_norm')
            m_2_n2 = repmat(mean(mR_c')',1,size(mR_m,2));
        elseif strcmp(norm_cond,'self_norm')
            m_2_n2 = repmat(mean(mR_m')',1,size(mR_m,2));
        end
%         norm_mR_m = (mR_m - m_2_n)./m_2_n2;
        norm_mR_m = (mR_m )./m_2_n2;
    end
    
    
%      selneurons = max(norm_mR_c')'>.5;
        selneurons = [1:size(norm_mR_c,1)]';
      tempinds = find(selneurons); %% just the cells with selectivity > 0.5  
        siginds(n+1:n+size(selneurons,1))=selneurons; n = n+size(selneurons,1);
    subplot(1,2,1);
    plot(xphid(tempinds,:)',norm_mR_c(tempinds,:)','color',[.5 .5 .5],'linewidth',.5);hold on;
    if light
    subplot(1,2,2);
    plot(xphid(tempinds,:)',norm_mR_m(tempinds,:)','color',[.85 .5 .5],'linewidth',.5);hold on;
    end
    
    for c= 1:size(tempinds,1)
        for t = 1:length(xphid(tempinds(c),:))
            collected_ctrl (count,find(template==xphid(tempinds(c),t))) = norm_mR_c(tempinds(c),t);
            if light
                collected_mani (count,find(template==xphid(tempinds(c),t))) = norm_mR_m(tempinds(c),t);
            end
            numpts(count,find(template==xphid(tempinds(c),t))) = 1;
        end
        
    count = count+1;
    end
    


end
 
collected_ctrl(count:end,:) = [];
if light
collected_mani(count:end,:) = [];
end
 temp = collected_ctrl;
%  temp (find(temp==0)) = nan;
 temp2 = sqrt(sum(numpts));
 m_C = nanmean(temp);
 s_C = nanstd(temp)./temp2;
if light
    temp = collected_mani;
%  temp (find(temp==0)) = nan;
 temp2 = sqrt(sum(numpts));
 m_M = nanmean(temp);
 s_M = nanstd(temp);
 s_M= nanstd(temp)./temp2;
end

temp = arrayfun(@(x) x.PPid_ctrl, data,'uni',0);
if size(temp{1},2>1)
    PPid=temp{1}';
else
    PPid=cell2mat(temp{1});
end

for i = 1:size(PPid,1)
    for d = 1:size(PPid{i},1)
%         NPid(i,:)=setxor([1:5],PPid(i));
        NPid{i}(d,:)= setxor([1:max(PPid{i})],PPid{i}(d,1));
    end
end
temp = arrayfun(@(x) x.FrCh, data,'uni',0);
if size(temp{1},2>1)
%      frCh=cell2mat(temp{1}');
    frCh=temp{1}';
 else
    frCh=cell2mat(temp{1});
 end

temp = arrayfun(@(x) x.PrefCh, data,'uni',0);
 if size(temp{1},2>1)
     PrefCh=temp{1}';
 else
 PrefCh=cell2mat(temp{1});
 end
 
 
 count = 1;
for i = 1:size(frCh,1)
    n = size(frCh{i},1);
    for d = 1:n
    PCh(count,1) = frCh{i}(d,PPid{i}(d));
    NPCh(count,1) = mean(frCh{i}(d,NPid{i}(d,:)));
    count = count+1;
%     
%     PCh(d,1) = frCh{i}(d);
% %     temp =frCh{i}(d,NPid{i}(d,:));
% %     temp(temp==0) = nan;
% %     NPCh(d,1) = 
    end
end

m_PCh = round([nanmean(PCh(siginds==1)), nanstd(PCh(siginds==1))].*10000)./100;
m_NPCh = round([nanmean(NPCh(siginds==1)),nanstd(NPCh(siginds==1))].*10000)./100;


     subplot(1,2,1);title(['Phase tuning ctrl ' txt],'Fontsize',16)
     e1=errorbar(template,m_C,s_C,'ko-'); set(e1,'linewidth',2); axis([-5 5 -.5 3])
     phaxis = [-5:5].*72;
set(gca,'Xtick',[-5 : 5]);
set(gca,'Xticklabel',phaxis);
 text(2,2,['n=' num2str(count-1) ' cells'])
     if light
    subplot(1,2,2);title(['Phase tuning mani ' txt],'Fontsize',16)
     e2=errorbar(template,m_M,s_M,'ro-'); set(e2,'linewidth',2); axis([-5 5 -.5 3])
%      tb= text(0,2.8,['FrCh P' num2str(m_PCh(1)) '+/-' num2str(m_PCh(2))]);
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
fnam = ['normRespPhase Tuning' txt];
saveas(gcf,[pwd,filesep,fnam],'fig');
set(gcf,'PaperPositionMode','manual');
print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);

%%
 t = m_C-m_M;
 figure;plot([-5:5],t,'o-','markersize',10,'color',[.25 .7 .25]); axis([-5 5 0 .6]);
 saveas(gcf,[pwd,filesep,'diffTuning'],'fig');
 set(gcf,'PaperPositionMode','manual');
 print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,'diffTuning']);
%% hist of PPIs
temp=arrayfun(@(x) x.PPI_ctrl, data,'uni',0)';
temp=temp{1}';
PPI_NL_list = cell2mat(temp);
if light
    temp=arrayfun(@(x) x.PPI_mani, data,'uni',0)';
    temp=temp{1}';
    PPI_L_list = cell2mat(temp);
end

 temp=arrayfun(@(x) x.PNPI_ctrl, data,'uni',0)';
temp=temp{1}';
count = 1;for i = 1:size(temp,1)
t=temp{i};
n=size(t,1)*size(t,2);
PNPI_NL_list(count+1:count+n,1) = reshape(t,n,1);
count = count+n;
end
    
    temp=arrayfun(@(x) x.PNPI_mani, data,'uni',0)';
temp=temp{1}';
count = 1;for i = 1:size(temp,1)
t=temp{i};
n=size(t,1)*size(t,2);
PNPI_L_list(count+1:count+n,1) = reshape(t,n,1);
count = count+n;
end

inds = find(PPI_NL_list>0.5);
bins = [0:.1:4];
sc = get(0,'ScreenSize');
figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w');
subplot(1,2,1);hnl=hist(PPI_NL_list(inds,1),bins);plot(bins,hnl,'k');hold on ;
if light
    hl=hist(PPI_L_list(inds,1),bins); plot(bins,hl,'r');
end
ms_nl = round([mean(PPI_NL_list(inds,:)) std(PPI_L_list(inds,:))]*100)./100;
ms_l=round([mean(PPI_L_list(inds,:)) std(PPI_L_list(inds,:))]*100)./100;
tb = text(2,10,[num2str(ms_nl(1)) '+/-' num2str(ms_nl(2))]);
tb = text(2,5,[num2str(ms_l(1)) '+/-' num2str(ms_l(2))]);set(tb,'color','r');
set(gca,'yscale','lin');
xlabel('norm Resp Amp at Pref Phase','Fontsize',16);title(['Hist norm Resp Amp at Pref Phase ' txt],'Fontsize',16);
set(gca,'Fontsize',16);

tempnl = PNPI_NL_list;
templ = PNPI_L_list;
tempnl(tempnl==0) = nan;
templ(templ==0) = nan;
subplot(1,2,2);hnl=hist(tempnl(inds,1),bins);plot(bins,hnl,'k');hold on ;
if light
    hl=hist(templ(inds,1),bins); plot(bins,hl,'r');
end
set(gca,'yscale','lin');
xlabel('norm Resp Amp at NonPref Phase','Fontsize',16);title(['Hist norm Resp Amp at NonPref Phase ' txt],'Fontsize',16);
set(gca,'Fontsize',16);
ms_nl = round([nanmean(PNPI_NL_list(inds,:)) nanstd(PNPI_L_list(inds,:))]*100)./100;
ms_l=round([nanmean(PNPI_L_list(inds,:)) nanstd(PNPI_L_list(inds,:))]*100)./100;
tb = text(2,10,[num2str(ms_nl(1)) '+/-' num2str(ms_nl(2))]);
tb = text(2,5,[num2str(ms_l(1)) '+/-' num2str(ms_l(2))]);set(tb,'color','r');


set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');


fnam = ['normRespPhase Hist' txt];
saveas(gcf,[pwd,filesep,fnam],'fig');
print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);

data.PPI_NL_list=PPI_NL_list;
data.PPI_L_list=PPI_L_list;
data.PNPI_NL_list=PNPI_NL_list;
data.PNPI_L_list=PNPI_L_list;