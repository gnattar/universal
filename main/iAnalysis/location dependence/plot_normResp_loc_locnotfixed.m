function plot_normResp_loc_locnotfixed(data)
figure;
collected_ctrl = nan(200,11);
collected_mani = nan(200,11);
template = [-5:1:5];
numpts  = zeros(1,11);count =1;inccount = 0;
for s = 1:size(data.meanResp_ctrl,2)
    signals_ctrl = data.meanRespPrefLoc_ctrl{s};
    signals_mani = data.meanRespPrefLoc_mani{s};
    d_signals = signals_ctrl-signals_mani;
    inc = find(d_signals<0);
    mR_c = data.meanResp_ctrl{s};
    mR_m = data.meanResp_mani{s};
    m_2_n = mean(mR_c,2);
    m_2_n = repmat(m_2_n,1,size(mR_c,2));
    norm_mR_c = mR_c./m_2_n;
    norm_mR_m = mR_m./m_2_n;
%     PrefPos = data.LP_ctrl{s}(:,2);
    [v,i] = max(norm_mR_c');
    PrefPos_ctrl = i';
        [v,i] = max(norm_mR_m');
    PrefPos_mani = i';
    %     xpos = data.TouchTh_ctrl{s};
    xpos = zeros(size(norm_mR_c));
    numpos = size(norm_mR_c,2);
    for l = 1: size(xpos,2)
        xpos(:,l) = l;
    end
    prefpos_C = repmat(PrefPos_ctrl,1,size(xpos,2));
    xpos_C = xpos - prefpos_C;
    
    prefpos_M = repmat(PrefPos_mani,1,size(xpos,2));
    xpos_M = xpos - prefpos_M;
%     norm_mR_c(inc,:) = [];
%     norm_mR_m(inc,:) = [];
%     xpos(inc,:) = [];
    inccount = inccount+length(inc);
    subplot(1,2,1);
    plot(xpos_C',norm_mR_c','color',[.5 .5 .5],'linewidth',.5);hold on;
    subplot(1,2,2);
    plot(xpos_M',norm_mR_m','color',[.85 .5 .5],'linewidth',.5);hold on;

    for c= 1:size(xpos,1)
        for t = 1:length(xpos(c,:))
            collected_ctrl (count,find(template==xpos_C(c,t))) = norm_mR_c(c,t);
            collected_mani (count,find(template==xpos_M(c,t))) = norm_mR_m(c,t);
            numpts_C(count,find(template==xpos_C(c,t))) = 1;
            numpts_M(count,find(template==xpos_M(c,t))) = 1;
        end  
    count = count+1;
    end
end
 
collected_ctrl(count:end,:) = [];
collected_mani(count:end,:) = [];

 temp = collected_ctrl;
 temp (find(temp==0)) = nan;
 temp2 = sqrt(sum(numpts_C));
 m_C = nanmean(temp);
 s_C = nanstd(temp)./temp2;
 
 temp = collected_mani;
 temp (find(temp==0)) = nan;
 temp2 = sqrt(sum(numpts_M));
 m_M = nanmean(temp);
 s_M = nanstd(temp);
 s_M= nanstd(temp)./temp2;
 
 %  FracChange = (m_C-m_M)./m_C;
CP=collected_ctrl(:,6);
MP=collected_mani(:,6);
CNP=collected_ctrl(:,[1:5,7:11]);
MNP= collected_mani(:,[1:5,7:11]);
Pref_reduction = (CP-MP)./CP;
NonPref_reduction = (nanmean(CNP,2) - nanmean(MNP,2))./nanmean(CNP,2);


     subplot(1,2,1);
     e1=errorbar(template,m_C,s_C,'ko-'); axis([-5 5 0 3])
    set(e1,'linewidth',1.5);title('loc tuning','fontsize',16);
    subplot(1,2,2);
     e2=errorbar(template,m_M,s_M,'ro-'); axis([-5 5 0 3])
     set(e2,'linewidth',1.5);
          tb = text(1,2.5,['FracChange Pref ' num2str(round(mean(Pref_reduction)*1000)/10) '+/- ' num2str(round(std(Pref_reduction)./sqrt(200)*1000)/10)]);
set(tb,'color','r');
          tb = text(1,2.1,['FracChange NPref ' num2str(round(mean(NonPref_reduction)*1000)/10) '+/- ' num2str(round(std(NonPref_reduction)./sqrt(200)*1000)/10)]);
set(tb,'color','r');
 text(2,2,['n=' num2str(count-1) ' cells']);title('loc tuning','fontsize',16);


 t = m_C-m_M;
 figure;plot([-5:5],t,'o-','markersize',10,'color',[.5 1 .7]);

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

