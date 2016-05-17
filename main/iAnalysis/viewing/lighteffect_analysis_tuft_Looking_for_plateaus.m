function [cd]=lighteffect_analysis_tuft_Looking_for_plateaus(pooled_contact_CaTrials,corr_dend,n)
%% plotting trials 
a =find(corr_dend==n);
obj=pooled_contact_CaTrials(a);

rois= obj;
put_plat = find((rois{1}.intarea>20))
plat = zeros(length(put_plat),2);
plat(:,1) = put_plat;
events =0;
% figure;
% for i = 1:length(put_plat)
%     for r = 1:length(rois)
%         subplot(length(rois),1,r)
%         plot([1:size(rois{r}.rawdata_smth,2)].*rois{r}.FrameTime,rois{r}.rawdata_smth(put_plat(i),:),'linewidth',2);
%         title(['trial ' num2str(put_plat(i)) ' Event ' num2str(rois{r}.eventsdetected(put_plat(i))) ' Light '  num2str(rois{r}.lightstim(put_plat(i)))]);
%         axis([0 2 -30 250]);
%         hline(30,'k');
%         events=events + rois{r}.eventsdetected(put_plat(i)); 
%     end
%     if events < length(rois)
%         plat(i,1) = nan;
%     end
%     plat(i,2) = rois{r}.lightstim(put_plat(i));
%     events = 0;
%     
%         set(gcf,'PaperUnits','inches');
%         set(gcf,'PaperPosition',[1 1 5 20]);
%         set(gcf, 'PaperSize', [24,10]);
%         set(gcf,'PaperPositionMode','manual');
%           saveas(gcf,['Corr Dend ' num2str(n) ' Trial ' num2str(put_plat(i))] ,'jpg');
% %         print( gcf ,'-depsc2','-painters','-loose',['Corr Dend ' num2str(n) ' Trial ' num2str(put_plat(i))]);
%         
% 
% end
rejects = find(isnan(plat(:,1)));
plat(rejects,:) = [];

     plat_L_trials =plat(find(plat(:,2)==1),1)
    plat_NL_trials =plat(find(plat(:,2)==0),1)
   
    intarea_plat_L = [];
    intarea_plat_NL = [];
     
 for r = 1:length(rois)
     intarea_plat_L(:,r)= rois{r}.intarea(plat_L_trials);
     intarea_plat_NL(:,r)= rois{r}.intarea(plat_NL_trials);    
 end
 
        l_trialscount = sum((rois{1}.lightstim==1),1);
        nl_trialscount = sum((rois{1}.lightstim==0),1);
     
        all_trials_rois =  cell2mat(cellfun(@(x) x.intarea,pooled_contact_CaTrials,'uni',0));
        
        cd.avg_resp_L = nanmean(nanmean(all_trials_rois((rois{1}.lightstim==1),corr_dend==n)));
        cd.avg_resp_NL =  nanmean(nanmean(all_trials_rois((rois{1}.lightstim==0),corr_dend==n)));
        
        cd.corr_dend_ID = n;
        cd.rois = a;
        cd.put_plat = put_plat;
        cd.lightstim = plat(:,2);
        cd.plat = plat(:,1);

        cd.plat_L_trials = plat_L_trials;
        cd.plat_NL_trials=plat_NL_trials;
        
        cd.plat_L_trialscount = size(plat_L_trials,1);
        cd.plat_NL_trialscount=size(plat_NL_trials,1);
        
        cd.l_trialscount =  l_trialscount ;
        cd.nl_trialscount =  nl_trialscount ;
        
        cd.intarea_plat_L = intarea_plat_L;
        cd.intarea_plat_NL = intarea_plat_NL;
        
        cd.plat_rate_L = size(plat_L_trials,1)./l_trialscount;
        cd.plat_rate_NL = size(plat_NL_trials,1)./nl_trialscount;
        
          cd.plat_avgmag_L= [];
            cd.plat_avgmag_NL = [];
        cd.plat_avgmag_L(1,:) = mean(intarea_plat_L,1);
        cd.plat_avgmag_NL(1,:) = mean(intarea_plat_NL,1);
        
        cd.plat_avgmag_L(2,:) = std(intarea_plat_L,1)
        cd.plat_avgmag_NL(2,:) = std(intarea_plat_NL,1)
        
        save(['cd_' num2str(n) '_final2'], 'cd');


%%        %% plotting raw data
 k = 1;
 clim = [0 150];
 
% cd = corr_dend_data{k};
n = cd.corr_dend_ID;
% a =find(corr_dend==n);
a = cd.rois;
obj=pooled_contact_CaTrials(a);



rawdata= cellfun(@(x) x.rawdata(cd.plat_NL_trials,:), obj,'uniformoutput',0);
plat_NL_data= cellfun(@(x) x.rawdata(cd.plat_NL_trials,:), obj,'uniformoutput',0);
plat_L_data= cellfun(@(x) x.rawdata(cd.plat_L_trials,:), obj,'uniformoutput',0);
ltrials = find(obj{1}.lightstim==1);
nltrials = find(obj{1}.lightstim==0);


temp = jet(clim(1,2));

rawdata_trials = cellfun(@(x) x.rawdata(:,:), obj,'uniformoutput',0);

rawdata_l_trials = cellfun(@(x) x.rawdata(ltrials,:), obj,'uniformoutput',0);

rawdata_nl_trials = cellfun(@(x) x.rawdata(nltrials,:), obj,'uniformoutput',0);

rawdata_l = zeros(size(rawdata_l_trials{1},1),size(rawdata_l_trials{1},2),length(a));
rawdata_nl = zeros(size(rawdata_nl_trials{1},1),size(rawdata_nl_trials{1},2),length(a));
rawdata = zeros(size(rawdata_trials{1},1),size(rawdata_trials{1},2),length(a));
for i = 1:length(a)
    rawdata_l (:,:,i) = rawdata_l_trials{i};
    rawdata_nl (:,:,i) = rawdata_nl_trials{i};
    rawdata (:,:,i) = rawdata_trials{i};
end
avg_rawdata_l = mean(rawdata_l,3);
avg_rawdata_nl = mean(rawdata_nl,3);

tempnl= mean(avg_rawdata_nl,3);
templ= mean(avg_rawdata_l,3);

xt = [1:size(avg_rawdata_l,2)].*obj{1}.FrameTime;
if size(a,1)>1 a=a'; end
figure;subplot(1,2,1); imagesc(xt,[1:size(templ,1)],tempnl);colorbar ;caxis(clim);
subplot(1,2,2);imagesc(xt,[1:size(templ,1)],templ);caxis(clim); colorbar 
title([num2str(k)  ' Avg_traces ID ' num2str(n)  ' mean of rois ' num2str(a)]);
print( gcf ,'-depsc2','-painters','-loose',[num2str(k)  ' Avg_traces ID ' num2str(n)  ' mean of rois ' num2str(a)]);

figure;subplot(1,2,1); plot(xt, nanmean(tempnl),'b','linewidth',2); axis([0 2 -20 50]);hline(0,'k--');vline(0.5,'k--');vline(2.0,'k--');
subplot(1,2,2); plot(xt, nanmean(templ),'b','linewidth',2); axis([0 2 -20 50]);
hline(0,'k--');vline(0.5,'k--');vline(2.0,'k--');
title([num2str(k)  ' Avg_traces ID ' num2str(n)  ' mean of rois ' num2str(a)]);
print( gcf ,'-depsc2','-painters','-loose',[num2str(k)  ' Avg  ID ' num2str(n)  ' mean of rois ' num2str(a)]);

%% plot example traces from all rois
% trial = [ 15, 123 ];  % nl nl l l 21 , ,65
% figure;
% for i = 1:length(a)
%     subplot(length(a),2,i*2);
%     plot(xt,rawdata(trial(2),:,i),'b','linewidth',1.5); axis([0 2 -50 250]);
% end
% 
% for i = 1:length(a)
%     subplot(length(a),2,i*2-1);
%     plot(xt,rawdata(trial(1),:,i),'b','linewidth',1.5); axis([0 2 -50 250]);
% end
% print( gcf ,'-depsc2','-painters','-loose',[num2str(k)  ' Traces T ' num2str(trial) ' ID ' num2str(n)  ' mean of rois ' num2str(a)]);
