function [data]=plot_normResp_loc(data,light,txt)
sc = get(0,'ScreenSize');
figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w');
collected_ctrl = nan(200,11);
collected_mani = nan(200,11);
template = [-5:1:5];
numpts  = zeros(1,11);count =1;inccount = 0;n=0;
siginds=[];
for s = 1:size(data.meanResp_loc_ctrl,2)
    signals_ctrl = data.meanResp_loc_ctrl{s};
    signals_mani = data.meanResp_loc_mani{s};
    d_signals = signals_ctrl-signals_mani;
    inc = find(d_signals<0);
    mR_c = data.meanResp_loc_ctrl{s};
    mR_m = data.meanResp_loc_mani{s};
    m_2_n = min(mR_c')';
    m_2_n = repmat(m_2_n,1,size(mR_c,2));
    norm_mR_c = (mR_c-m_2_n)./m_2_n;
    m_2_n = min(mR_m')';
    m_2_n = repmat(m_2_n,1,size(mR_m,2));  
    norm_mR_m = (mR_m-m_2_n)./m_2_n;
%     PrefPos = data.LP_ctrl{s}(:,2);
%     PrefPos = data.PL_ctrl{s}(:,1); % for pcopy
    PrefPos = data.PLid_ctrl{s}(:,1); 
    %     xpos = data.TouchTh_ctrl{s};
    xpos = zeros(size(norm_mR_c));
    numpos = size(norm_mR_c,2);
    for l = 1: size(xpos,2)
        xpos(:,l) = l;
    end
    prefpos = repmat(PrefPos,1,size(xpos,2));
    xpos = xpos - prefpos;
    
%     norm_mR_c(inc,:) = [];
%     norm_mR_m(inc,:) = [];
%     xpos(inc,:) = [];
    inccount = inccount+length(inc);
    selneurons = max(norm_mR_c')'>.4;
    tempinds = find(selneurons); %% just the cells with selectivity > 0.4    
    siginds(n+1:n+size(selneurons,1))=selneurons; n = n+size(selneurons,1);
    subplot(1,2,1);
    plot(xpos(tempinds,:)',norm_mR_c(tempinds,:)','color',[.5 .5 .5],'linewidth',.5);hold on;
    subplot(1,2,2);
    plot(xpos(tempinds,:)',norm_mR_m(tempinds,:)','color',[.85 .5 .5],'linewidth',.5);hold on;

%     for c= 1:size(xpos,1)
%         for t = 1:length(xpos(c,:))
%             collected_ctrl (count,find(template==xpos(c,t))) = norm_mR_c(c,t);
%             collected_mani (count,find(template==xpos(c,t))) = norm_mR_m(c,t);
%             numpts(count,find(template==xpos(c,t))) = 1;
%         end
%     end
    
     for c= 1:size(tempinds,1)
        for t = 1:length(xpos(tempinds(c),:))
            collected_ctrl (count,find(template==xpos(tempinds(c),t))) = norm_mR_c(tempinds(c),t);
            collected_mani (count,find(template==xpos(tempinds(c),t))) = norm_mR_m(tempinds(c),t);
            numpts(count,find(template==xpos(tempinds(c),t))) = 1;
        end
         count = count+1;
    end   



end
 
collected_ctrl(count:end,:) = [];
collected_mani(count:end,:) = [];

 temp = collected_ctrl;
%  temp (find(temp==0)) = nan;
 temp2 = sqrt(sum(numpts));
 m_C = nanmean(temp);
 s_C = nanstd(temp)./temp2;
 
 temp = collected_mani;
%  temp (find(temp==0)) = nan;
 temp2 = sqrt(sum(numpts));
 m_M = nanmean(temp);
 s_M = nanstd(temp);
 s_M= nanstd(temp)./temp2;
 
 temp = arrayfun(@(x) x.PLid_ctrl, data,'uni',0);
 if size(temp{1},2>1)
%      PPid=cell2mat(temp{1}');
PPid=temp{1}';
 else
    PPid=cell2mat(temp{1});
 end
for i = 1:size(PPid,1)
    for d = 1:size(PPid{i},1)
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

% 
% for i = 1:size(frCh,1)
%     PCh(i,1) = frCh(i,PPid(i));
%     NPCh(i,1) = mean(frCh(i,NPid(i,:)));
% end
% count = 1;
% for i = 1:size(frCh,1)
%     n = size(frCh{i},1);
%     for d = 1:n
% %     PCh(d,1) = frCh{i}(d,PPid{i}(d));
% %     NPCh(d,1) = mean(frCh{i}(d,NPid{i}(d,:)));
%     
%     PCh(count,1) = frCh{i}(d);
%     count = count+1;
% %     temp =frCh{i}(d,NPid{i}(d,:));
% %     temp(temp==0) = nan;
% %     NPCh(d,1) = 
%     end
% end


 
count = 1;
for i = 1:size(frCh,1)
    n = size(frCh{i},1);
    for d = 1:n
    PCh(count,1) = frCh{i}(d,PPid{i}(d));
    NPCh(count,1) = mean(frCh{i}(d,NPid{i}(d,:)));
    
%     PCh(count,1) = frCh{i}(d);
    count = count+1;
%     temp =frCh{i}(d,NPid{i}(d,:));
%     temp(temp==0) = nan;
%     NPCh(d,1) = 
    end
end


m_PCh = round([nanmean(PCh(siginds==1)), nanstd(PCh(siginds==1))].*10000)./100;
 m_NPCh = round([nanmean(NPCh(siginds==1)),nanstd(NPCh(siginds==1))].*10000)./100;
 
     subplot(1,2,1);title(['Loc tuning ctrl' txt])
     e1=errorbar(template,m_C,s_C,'ko-'); set(e1,'linewidth',2);axis([-5 5 0 3])
     set(gca,'Xtick',[-5 : 5]);
 text(2,2,['n=' num2str(count-1) ' cells'])
    subplot(1,2,2);title(['Loc tuning mani' txt])
     e2=errorbar(template,m_M,s_M,'ro-');  set(e2,'linewidth',2);axis([-5 5 0 3])
     tb= text(0,2.8,['FrCh P' num2str(m_PCh(1)) '+/-' num2str(m_PCh(2))]);
     tb= text(0,2.5,['FrCh NP' num2str(m_NPCh(1)) '+/-' num2str(m_NPCh(2))]);

set(gca,'Xtick',[-5 : 5]);

set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');
fnam = ['normRespLoc Tuning' txt];
saveas(gcf,[pwd,filesep,fnam],'fig');
print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);


%  t = m_C-m_M;
%  figure;plot([-5:5],t,'o-','markersize',10,'color',[.8 1 .8]);
%%%% hist of LPIs
temp=arrayfun(@(x) x.LPI_ctrl, data,'uni',0)';
temp=temp{1}';
LPI_NL_list = cell2mat(temp);

    temp=arrayfun(@(x) x.LPI_mani, data,'uni',0)';
    temp=temp{1}';
    LPI_L_list = cell2mat(temp);

    temp=arrayfun(@(x) x.LNPI_ctrl, data,'uni',0)';
temp=temp{1}';
count = 1;for i = 1:size(temp,1)
t=temp{i};
n=size(t,1)*size(t,2);
LNPI_NL_list(count+1:count+n,1) = reshape(t,n,1);
count = count+n;
end
    
    temp=arrayfun(@(x) x.LNPI_mani, data,'uni',0)';
temp=temp{1}';
count = 1;for i = 1:size(temp,1)
t=temp{i};
n=size(t,1)*size(t,2);
LNPI_L_list(count+1:count+n,1) = reshape(t,n,1);
count = count+n;
end
    

inds = find(LPI_NL_list>0.4);
bins = [0:.1:4];
sc = get(0,'ScreenSize');
figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w');
subplot(1,2,1);hnl=hist(LPI_NL_list(inds,1),bins);plot(bins,hnl,'k');hold on ;
if light
    hl=hist(LPI_L_list(inds,1),bins); plot(bins,hl,'r');
end
ms_nl = round([mean(LPI_NL_list(inds,:)) std(LPI_L_list(inds,:))]*100)./100;
ms_l=round([mean(LPI_L_list(inds,:)) std(LPI_L_list(inds,:))]*100)./100;
tb = text(2,10,[num2str(ms_nl(1)) '+/-' num2str(ms_nl(2))]);
tb = text(2,5,[num2str(ms_l(1)) '+/-' num2str(ms_l(2))]);set(tb,'color','r');
set(gca,'yscale','lin');
xlabel('norm Resp Amp at Pref Loc','Fontsize',16);title(['Hist norm Resp Amp at Pref Loc' txt],'Fontsize',16);
set(gca,'Fontsize',16);

 tempnl = LNPI_NL_list;
templ = LNPI_L_list;
tempnl(tempnl==0) = nan;
templ(templ==0) = nan;
subplot(1,2,2);hnl=hist(tempnl(inds,1),bins);plot(bins,hnl,'k');hold on ;
if light
    hl=hist(templ(inds,1),bins); plot(bins,hl,'r');
end
set(gca,'yscale','lin');
xlabel('norm Resp Amp at NonPref Loc','Fontsize',16);title(['Hist norm Resp Amp at NonPref Loc' txt],'Fontsize',16);
set(gca,'Fontsize',16);
ms_nl = round([nanmean(LNPI_NL_list(inds,:)) nanstd(LNPI_L_list(inds,:))]*100)./100;
ms_l=round([nanmean(LNPI_L_list(inds,:)) nanstd(LNPI_L_list(inds,:))]*100)./100;
tb = text(2,10,[num2str(ms_nl(1)) '+/-' num2str(ms_nl(2))]);
tb = text(2,5,[num2str(ms_l(1)) '+/-' num2str(ms_l(2))]);set(tb,'color','r');

set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');


fnam = ['normRespLoc Hist' txt];
saveas(gcf,[pwd,filesep,fnam],'fig');
print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);

data.LPI_NL_list=LPI_NL_list;
data.LPI_L_list=LPI_L_list;
data.LNPI_NL_list=LNPI_NL_list;
data.LNPI_L_list=LNPI_L_list;

%%
% figure;
% collected_ctrl = zeros(200,11);
% collected_mani = zeros(200,11);
% template = [-5:1:5];
% numpts  = zeros(1,11);count =1;inccount = 0;
% for s = 1:13
% %     signals_ctrl = data.meanRespPrefLoc_ctrl{s};
% %     signals_mani = data.meanRespPrefLoc_mani{s};
% %     d_signals = signals_ctrl-signals_mani;
% %     inc = find(d_signals<0);
%     mS_c = data.Slopes_ctrl{s};
%     mS_m = data.Slopes_mani{s};
%     m_2_n = mean(mS_c,2);
%     m_2_n = repmat(m_2_n,1,size(mS_c,2));
%     norm_mS_c = mS_c./m_2_n;
%     norm_mS_m = mS_m./m_2_n;
%     PrefPos = data.LP_ctrl{s}(:,1);
%     xpos = data.TouchTh_ctrl{s};
%     for l = 1: size(xpos,2)
%         xpos(:,l) = l;
%     end
%     prefpos = repmat(PrefPos,1,size(xpos,2));
%     xpos = xpos - prefpos;
%     
% %     norm_mR_c(inc,:) = [];
% %     norm_mR_m(inc,:) = [];
% %     xpos(inc,:) = [];
% %     inccount = inccount+length(inc);
%     subplot(1,2,1);
%     plot(xpos',norm_mS_c','color',[.5 .5 .5],'linewidth',.5);hold on;
%     subplot(1,2,2);
%     plot(xpos',norm_mS_m','color',[.85 .5 .5],'linewidth',.5);hold on;
% 
%     for c= 1:size(xpos,1)
%         for t = 1:length(xpos(c,:))
%             collected_ctrl (count,find(template==xpos(c,t))) = norm_mS_c(c,t);
%             collected_mani (count,find(template==xpos(c,t))) = norm_mS_m(c,t);
%             numpts(count,find(template==xpos(c,t))) = 1;
%         end  
%     count = count+1;
%     end
% end
%  
% collected_ctrl(count:end,:) = [];
% collected_mani(count:end,:) = [];s
% 
%  temp = collected_ctrl;
%  temp (find(temp==0)) = nan;
%  temp2 = sqrt(sum(numpts));
%  m_C = nanmean(temp);
%  s_C = nanstd(temp)./temp2;
%  
%  temp = collected_mani;
%  temp (find(temp==0)) = nan;
%  temp2 = sqrt(sum(numpts));
%  m_M = nanmean(temp);
%  s_M = nanstd(temp);
%  s_M= nanstd(temp)./temp2;
%  
%      subplot(1,2,1);
%      e1=errorbar(template,m_C,s_C,'ko-'); axis([-5 5 0 3])
%     subplot(1,2,2);
%      e2=errorbar(template,m_M,s_M,'ro-'); axis([-5 5 0 3])
%  text(2,2,['n=' num2str(count-1) ' cells'])
% 


 %%
%  figure;
% collected_ctrl = zeros(200,11);
% template = [-5:1:5];
% numpts  = zeros(1,11);count =1;inccount = 0;
% for s = 1:size(data.TouchTh_ctrl,2)
%     signals_ctrl = data.meanRespPrefLoc_ctrl{s};
%     mR_c = data.meanResp_ctrl{s};
%     m_2_n = mean(mR_c,2);
%     m_2_n = repmat(m_2_n,1,size(mR_c,2));
%     norm_mR_c = mR_c./m_2_n;
%     PrefPos = data.LP_ctrl{s}(:,2);
%     xpos = data.TouchTh_ctrl{s};
%     for l = 1: size(xpos,2)
%         xpos(:,l) = l;
%     end
%     prefpos = repmat(PrefPos,1,size(xpos,2));
%     xpos = xpos - prefpos;
%     
% %     norm_mR_c(inc,:) = [];
% %     norm_mR_m(inc,:) = [];
% %     xpos(inc,:) = [];
%     subplot(1,2,1);
%     plot(xpos',norm_mR_c','color',[.5 .5 .5],'linewidth',.5);hold on;
% 
% 
%     for c= 1:size(xpos,1)
%         for t = 1:length(xpos(c,:))
%             collected_ctrl (count,find(template==xpos(c,t))) = norm_mR_c(c,t);
%             numpts(count,find(template==xpos(c,t))) = 1;
%         end  
%     count = count+1;
%     end
% end
%  
% collected_ctrl(count:end,:) = [];
% 
%  temp = collected_ctrl;
%  temp (find(temp==0)) = nan;
%  temp2 = sqrt(sum(numpts));
%  m_C = nanmean(temp);
%  s_C = nanstd(temp)./temp2;
%  
%  
%      subplot(1,2,1);
%      e1=errorbar(template,m_C,s_C,'ko-'); axis([-5 5 0 3])
% 
%  text(2,2,['n=' num2str(count-1) ' cells'])

% %%
% figure;
% collected_ctrl = zeros(88,11);
% collected_mani = zeros(88,11);
% template = [-5:1:5];
% numpts  = zeros(1,11);count =1;
% for s = 1:size(data.TouchTh_ctrl,2)
% 
%     mS_c = data.Slopes_ctrl{s};
%     m_2_n = mean(mS_c,2);
%     m_2_n = repmat(m_2_n,1,size(mS_c,2));
%     norm_mS_c = mS_c./m_2_n;
%     PrefPos = data.LP_ctrl{s}(:,1);
%     xpos = data.TouchTh_ctrl{s};
%     for l = 1: size(xpos,2)
%         xpos(:,l) = l;
%     end
%     prefpos = repmat(PrefPos,1,size(xpos,2));
%     xpos = xpos - prefpos;
% 
%     subplot(1,2,1);
%     plot(xpos',norm_mS_c','color',[.5 .5 .5],'linewidth',.5);hold on;
% 
% 
%     for c= 1:size(xpos,1)
%         for t = 1:length(xpos(c,:))
%             collected_ctrl (count,find(template==xpos(c,t))) = norm_mS_c(c,t);
% 
%             numpts(count,find(template==xpos(c,t))) = 1;
%         end  
%     count = count+1;
%     end
% end
%  
% collected_ctrl(count:end,:) = [];
% 
% 
%  temp = collected_ctrl;
%  temp (find(temp==0)) = nan;
%  temp2 = sqrt(sum(numpts));
%  m_C = nanmean(temp);
%  s_C = nanstd(temp)./temp2;
%  
% 
%      subplot(1,2,1);
%      e1=errorbar(template,m_C,s_C,'ko-'); axis([-5 5 0 3])
% 
%  text(2,2,['n=' num2str(count-1) ' cells'])

