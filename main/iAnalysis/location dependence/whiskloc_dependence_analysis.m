function [pooled_contactCaTrials_locdep] = whiskloc_dependence_pooldata (collected_data,collected_summary)
pooled_contactCaTrials_locdep = [];
count =1;
pxlpermm = 24.38; %% 18-7.5 mm = 298-42 pixels
for i = 1: size(collected_summary,2) 
    d = length(collected_summary{1,i}.dends);
    
        temp_solotrial = cell2mat(arrayfun(@(x) x.solo_trial(1), collected_data{1,i},'uniformoutput',0)');
        temp_contactdir = arrayfun(@(x) x.contactdir{1}, collected_data{1,i},'uniformoutput',0)';
        temp_contacts = arrayfun(@(x) x.contacts{1}, collected_data{1,i},'uniformoutput',0);
        temp_tws = arrayfun(@(x) x.ts_wsk{1}, collected_data{1,i},'uniformoutput',0)';
        temp_touchSetpoint = arrayfun(@(x) x.Setpoint{1}, collected_data{1,i},'uniformoutput',0)'; 
        temp_touchdeltaKappa = arrayfun(@(x) x.deltaKappa{1}, collected_data{1,i},'uniformoutput',0)';         
        
    for j = 1:d
        data = cell2mat(arrayfun(@(x) x.dff(j,:), collected_data{1,i},'uniformoutput',0)');
        sampling_time = collected_data{1,i}(1).FrameTime;
        winsize = round(.2/sampling_time);
        temp_data = data;
        temp_data_filt = filter(ones(1,winsize)/winsize,1,data,[],2);

        temp_totalKappa = cell2mat(arrayfun(@(x) x.total_touchKappa(1), collected_data{1,i},'uniformoutput',0)');

        temp_poleloc = cell2mat(arrayfun(@(x) x.barpos(1), collected_data{1,i},'uniformoutput',0)');
        temp_lightstim = cell2mat(arrayfun(@(x) x.lightstim(1), collected_data{1,i},'uniformoutput',0)');

        polelocs = unique(temp_poleloc);
       
        if max(temp_lightstim) >0
          CaSig_mag = cell(length(polelocs),2); %% NL, L
          CaSig_peak = cell(length(polelocs),2);
          CaSig_dur = cell(length(polelocs),2); %fwhm 
          wSig_totmodKappa = cell(length(polelocs),2);
          num_trials =  zeros(length(polelocs),2);          
        else
          CaSig_mag = cell(length(polelocs),1); %NL
          CaSig_peak = cell(length(polelocs),1);
          CaSig_dur = cell(length(polelocs),1); %fwhm 
          wSig_totmodKappa = cell(length(polelocs),1);
          num_trials =  zeros(length(polelocs),1);
        end
        
        for k = 1: length(polelocs)
            curr_poleloc_trials = (temp_poleloc == polelocs(k));
            if max(temp_lightstim) >0
                curr_loc_L_trials = temp_data (find(curr_poleloc_trials & temp_lightstim),:);
                curr_loc_NL_trials = temp_data (find(curr_poleloc_trials & ~temp_lightstim),:);
                curr_loc_L_Kappa = temp_totalKappa (find(curr_poleloc_trials & temp_lightstim));
                curr_loc_NL_Kappa = temp_totalKappa (find(curr_poleloc_trials & ~temp_lightstim));
                num_trials (2,k) = size(curr_loc_L_Kappa ,1);
                num_trials (1,k) = size(curr_loc_NL_Kappa ,1);
                CaSig_mag{k,1} = nansum(curr_loc_NL_trials,2);
                CaSig_mag{k,2} = nansum(curr_loc_L_trials,2);
                CaSig_peak{k,1} = prctile(curr_loc_NL_trials,90,2);
                CaSig_peak{k,2} = prctile(curr_loc_L_trials,90,2);
                wSig_totmodKappa{k,1} = curr_loc_NL_Kappa.*pxlpermm;
                wSig_totmodKappa{k,2} = curr_loc_L_Kappa .*pxlpermm;

            else
                curr_loc_NL_trials = temp_data (find(curr_poleloc_trials & ~temp_lightstim),:);
                curr_loc_NL_Kappa = temp_totalKappa (find(curr_poleloc_trials & ~temp_lightstim));
                CaSig_mag{k,1} = nansum(curr_loc_NL_trials,2);
                CaSig_peak{k,1} = prctile(curr_loc_NL_trials,90,2);
                wSig_totmodKappa{k,1} = curr_loc_NL_Kappa.*pxlpermm;               
            end

        end

        
        pooled_contactCaTrials_locdep {count}.rawdata = temp_data;
        pooled_contactCaTrials_locdep {count}.sigmag = nansum(temp_data,2);
        pooled_contactCaTrials_locdep {count}.sigpeak = prctile(temp_data,90,2);
        pooled_contactCaTrials_locdep {count}.FrameTime = sampling_time;
        pooled_contactCaTrials_locdep {count}.totalKappa = temp_totalKappa.*pxlpermm;
        pooled_contactCaTrials_locdep {count}.touchSetpoint = temp_touchSetpoint;
        pooled_contactCaTrials_locdep {count}.touchdeltaKappa = temp_touchdeltaKappa;
        pooled_contactCaTrials_locdep{count}.poleloc= temp_poleloc ;
        pooled_contactCaTrials_locdep{count}.lightstim=   temp_lightstim ;
        pooled_contactCaTrials_locdep{count}.num_trials=   num_trials;
        pooled_contactCaTrials_locdep{count}.CaSig_mag = CaSig_mag;
        pooled_contactCaTrials_locdep{count}.CaSig_peak= CaSig_peak;
        pooled_contactCaTrials_locdep{count}.wSig_totmodKappa = wSig_totmodKappa;
        pooled_contactCaTrials_locdep{count}.mousename= collected_summary{i}.mousename;
        pooled_contactCaTrials_locdep{count}.sessionname= collected_summary{i}.sessionname;
        pooled_contactCaTrials_locdep{count}.reg= collected_summary{i}.reg;
        pooled_contactCaTrials_locdep{count}.fov= collected_summary{i}.fov;
        pooled_contactCaTrials_locdep{count}.dend= collected_summary{i}.dends(j);
        pooled_contactCaTrials_locdep{count}.trialnum= temp_solotrial;
        pooled_contactCaTrials_locdep{count}.contactdir= temp_contactdir;
        pooled_contactCaTrials_locdep{count}.contacts= temp_contacts;
        pooled_contactCaTrials_locdep{count}.timews=temp_tws;      
        count = count+1;
    end
end
save('pooled_contactCaTrials_locdep','pooled_contactCaTrials_locdep');

function whiskloc_dependence_correlatedata(pooled_contactCaTrials_locdep,dends)

function whiskloc_dependence_plotdata(pooled_contactCaTrials_locdep,dends)
   sc = get(0,'ScreenSize');
    h_fig1 = figure('position', [1000, sc(4)/10-100, sc(3)*1/2.5, sc(4)*1], 'color','w');
    count =1;
for d=1:length(dends)
    n = dends(d);
    xcol =4;
    polelocs = unique(pooled_contactCaTrials_locdep{n}.poleloc);
    numloc =length(polelocs);    
    a = 1;
    z = numloc;
    for i = 1:numloc 
        NL_ind = ( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.lightstim ==0);
        L_ind =  ( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.lightstim ==1);
        subplot(length(dends),numloc+xcol,count); 
        retract = find(pooled_contactCaTrials_locdep{n}.totalKappa(NL_ind) <0);
        protract =  find(pooled_contactCaTrials_locdep{n}.totalKappa(NL_ind) >0);
        
        plot(abs(pooled_contactCaTrials_locdep{n}.totalKappa(NL_ind(retract))),pooled_contactCaTrials_locdep{n}.sigmag(NL_ind(retract)),'ko','Markersize',4); hold on; 
        plot(abs(pooled_contactCaTrials_locdep{n}.totalKappa(NL_ind(protract))),pooled_contactCaTrials_locdep{n}.sigmag(NL_ind(protract)),'ko','Markersize',4, 'Markerfacecolor','k'); hold on; 
        
        retract = find(pooled_contactCaTrials_locdep{n}.totalKappa(L_ind) <0);
        protract =  find(pooled_contactCaTrials_locdep{n}.totalKappa(L_ind) >0);
        
        plot(abs(pooled_contactCaTrials_locdep{n}.totalKappa(L_ind(retract))),pooled_contactCaTrials_locdep{n}.sigmag(L_ind(retract)),'ro','Markersize',4);%axis( [0 5 -50 150]);
        plot(abs(pooled_contactCaTrials_locdep{n}.totalKappa(L_ind(protract))),pooled_contactCaTrials_locdep{n}.sigmag(L_ind(protract)),'ro','Markersize',4);
       
        
        mx = max([abs(pooled_contactCaTrials_locdep{n}.totalKappa(NL_ind)); abs(pooled_contactCaTrials_locdep{n}.totalKappa(L_ind))]);
        my = max([pooled_contactCaTrials_locdep{n}.sigmag(NL_ind); pooled_contactCaTrials_locdep{n}.sigmag(L_ind)]);
        title([ 'D ' num2str(n) '  '  num2str(pooled_contactCaTrials_locdep{n}.num_trials(1,i)) ' NL ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(2,i)) ' L ' ]);
%         axis([0  mx+5 -50 my+100]);
         axis([0 50 0 12000]);
        count = count+1;
    
        x=abs(pooled_contactCaTrials_locdep{n}.totalKappa(NL_ind));
        y =pooled_contactCaTrials_locdep{n}.sigmag(NL_ind);
        sigmag_kappa_L(i,1) = nanmean(y)./nanmean(x);
        sigmag_kappa_L(i,2) = nanstd(y)./nanmean(x);
        sigmag_kappa_L(i,3) = (nanstd(y)./nanmean(x))/sqrt(length(x)+1);
        p_NL(i,:) = polyfit(x,y,1);
        sigmag_kappa_L_trials{n,i} = y./x;
        
        x=abs(pooled_contactCaTrials_locdep{n}.totalKappa(L_ind));
        y =pooled_contactCaTrials_locdep{n}.sigmag(L_ind);
        sigmag_kappa_NL(i,1) = nanmean(y)./nanmean(x);
        sigmag_kappa_NL(i,2) = nanstd(y)./nanmean(x);
        sigmag_kappa_NL(i,3) = (nanstd(y)./nanmean(x))/sqrt(length(x)+1);
        p_L(i,:) = polyfit(x,y,1);
         
        sigmag_kappa_NL_trials{n,i} = y./x;
       
        
        plot([1:50],polyval(p_NL(i,:) ,[1:50]),'k-');
        plot([1:50],polyval(p_L(i,:),[1:50]),'r-');
        
% %         x=pooled_contactCaTrials_locdep{n}.totalKappa(NL_ind);
% %         y =pooled_contactCaTrials_locdep{n}.sigmag(NL_ind);
% %         yy = y(x<0);%% retraction touches
% %         xx = x(x < 0);        
% %         p_NL(i,:,1) = polyfit(xx,yy,1);
% %         yy = y(x>0);%% protraction touches
% %         xx = x(x > 0);        
% %         p_NL(i,:,2) = polyfit(xx,yy,1);
% %         
% %         x=pooled_contactCaTrials_locdep{n}.totalKappa(L_ind);
% %         y =pooled_contactCaTrials_locdep{n}.sigmag(L_ind);
% %         yy = y(x<0);%% retraction touches
% %         xx = x(x < 0);        
% %         p_L(i,:,1) = polyfit(xx,yy,1);
% %         yy = y(x>0); %% protraction touches
% %         xx = x(x > 0);        
% %         p_L(i,:,2) = polyfit(xx,yy,1);
% %             
% %         plot([-20:-1],polyval(p_NL(i,:,1) ,[-20:-1]),'k-'); hold on ; plot([1:20],polyval(p_NL(i,:,2) ,[1:20]),'k-');
% %        plot([-20:-1],polyval(p_L(i,:,1),[-20:-1]),'r-'); hold on; plot([1:20],polyval(p_L(i,:,2),[1:20]),'r-'); 
    end 

     subplot(length(dends),numloc+xcol,count:count+1);
    h= plot([1:numloc],p_NL(:,1),'k-o'); set(h,'linewidth',1.5);hold on; 
    h= plot([1:numloc],p_L(:,1),'r-o');set(h,'linewidth',1.5);
    hline(0,'k:');
     title( ' slopes'); axis([0 6 min(min(p_NL([a:z],1)),min(p_L([a:z],1)))-50  max(max(p_NL([a:z],1)),max(p_L([a:z],1)))+50]);

      count = count+2;   
     
% % % % % % % % %      
% % % % % % % % %     sigmag_kappa_anova = anova2(
% % % % % % % %   
% % % % % % % %      subplot(length(dends),numloc+xcol,count:count+1);
% % % % % % % %     h= errorbar([1:numloc],temp_sigmagNL,std_sigmagNL,'k-o'); set(h,'linewidth',1.5);hold on; 
% % % % % % % %     h= errorbar([1:numloc],temp_sigmagL,std_sigmagL,'r-o');set(h,'linewidth',1.5);
% % % % % % % %      title( ' mean SigMag / mean TotalKappa'); 
% % % % % % % %      
% % % % % % % % %      text(0.1,200,['E' num2str(round(nansum(temp_sigmagL)/nansum(temp_sigmagNL)*100)/100)]); 
% % % % % % % %     t= text(0.1,-20,[ num2str((max(temp_sigmagNL)-min(temp_sigmagNL))/(min(temp_sigmagNL)))]); set(t,'Color' ,[0 0 0]);
% % % % % % % %     t =text(4.1,-20,[ num2str((max(temp_sigmagL)-min(temp_sigmagL))/(min(temp_sigmagL)))]);  set(t,'Color' ,[1 0 0]);
% % % % % % % %     axis([0 numloc+1 -50 max([temp_sigmagNL([a:z]) ,temp_sigmagL([a:z])])+100]);
% % % % % % % %      
% % % % % % % %       count = count+2;        
% % % % % % % %      
% % % % % % % % 
% % % % % % % % % % % % %      subplot(length(dends),numloc+xcol,count:count+1);
% % % % % % % % % % % % %     h= errorbar([1:numloc],sigmag_kappa_NL(:,1),sigmag_kappa_NL(:,3)); set(h,'color','k','marker','o','linewidth',1.5);hold on; 
% % % % % % % % % % % % %     h= errorbar([1:numloc],sigmag_kappa_L(:,1),sigmag_kappa_L(:,3));set(h,'color','r','marker','o','linewidth',1.5);
% % % % % % % % % % % % %     hline(0,'k:');
% % % % % % % % % % % % %      title( ' mean(sigmag/kappa)'); 
% % % % % % % % % % % % %      axis([0 6 min(min(sigmag_kappa_NL(:,1)),min(sigmag_kappa_L(:,1)))-0.10  max(max(sigmag_kappa_NL(:,1)),max(sigmag_kappa_L(:,1)))+.1]);
% % % % % % % % % % % % %      
% % % % % % % % % % % % %      
% % % % % % % % % % % % % %     t= text(0.1,-20,[ num2str((max(temp_sigmagNL)-min(temp_sigmagNL))/(min(temp_sigmagNL)))]); set(t,'Color' ,[0 0 0]);
% % % % % % % % % % % % % %     t =text(4.1,-20,[ num2str((max(temp_sigmagL)-min(temp_sigmagL))/(min(temp_sigmagL)))]);  set(t,'Color' ,[1 0 0]);
% % % % % % % % % % % % %    
% % % % % % % % % % % % %      count = count+2;        
% % % % % % % %      
% % % % % % % %      
% % % % % % % %      
% % % % % % % %      
% % % % % % % %      pooled_contactCaTrials_locdep{n}.std_totmodKappa(isnan(pooled_contactCaTrials_locdep{n}.std_totmodKappa))= 0;
% % % % % % % %      subplot(length(dends),numloc+xcol,count);
% % % % % % % %      h=errorbar([1:numloc],pooled_contactCaTrials_locdep{n}.avg_totmodKappa(1,:),pooled_contactCaTrials_locdep{n}.std_totmodKappa(1,:)./sqrt(length(pooled_contactCaTrials_locdep{n}.std_totmodKappa(1,:))+1));
% % % % % % % %      set(h,'color','k','linewidth',1.5);hold on;
% % % % % % % %      h=errorbar([1:numloc],pooled_contactCaTrials_locdep{n}.avg_totmodKappa(2,:),pooled_contactCaTrials_locdep{n}.std_totmodKappa(2,:)./sqrt(length(pooled_contactCaTrials_locdep{n}.std_totmodKappa(2,:))+1)); title( 'Total Kappa'); 
% % % % % % % %     set(h,'color','r','linewidth',1.5);
% % % % % % % %      axis([0 numloc+1 -1 25]);
% % % % % % % %      count = count+1;
% % % % % % % %      
% % % % % % % %     subplot(length(dends),numloc+xcol,count);
% % % % % % % %     trials_L = pooled_contactCaTrials_locdep{n}.lightstim ==1;
% % % % % % % %     trials_NL = pooled_contactCaTrials_locdep{n}.lightstim == 0;
% % % % % % % %     temp_rawdata_L = pooled_contactCaTrials_locdep{n}.rawdata(trials_L,:);
% % % % % % % %     temp_rawdata_NL = pooled_contactCaTrials_locdep{n}.rawdata(trials_NL,:);    
% % % % % % % %     mean_rawdata_NL = nanmean(temp_rawdata_NL);
% % % % % % % %     mean_rawdata_L = nanmean(temp_rawdata_L);
% % % % % % % %    
% % % % % % % %     nancount= sum(isnan(temp_rawdata_NL));
% % % % % % % %     delpnts = find(nancount>size(temp_rawdata_NL,1)/3);
% % % % % % % %     mean_rawdata_NL(delpnts) = nan;
% % % % % % % %     
% % % % % % % %     nancount= sum(isnan(temp_rawdata_L));
% % % % % % % %     delpnts = find(nancount>size(temp_rawdata_L,1)/3);
% % % % % % % %     mean_rawdata_L(delpnts) = nan;
% % % % % % % %     
% % % % % % % %     plot([1:size(temp_rawdata_NL,2)]* pooled_contactCaTrials_locdep{n}.FrameTime,mean_rawdata_NL,'k','linewidth',1.5);hold on;
% % % % % % % %     plot([1:size(temp_rawdata_L,2)]* pooled_contactCaTrials_locdep{n}.FrameTime,mean_rawdata_L,'r','linewidth',1.5);
% % % % % % % % %     title([ 'D ' num2str(n) ' Net NL-L ' num2str(nansum(mean_rawdata_NL)-nansum(mean_rawdata_L)) ]);
% % % % % % % %     axis( [0 5 -50 150]);
% % % % % % % %     count = count + 1;
     
%      pooled_contactCaTrials_locdep{dends(d)}.thetadepNL = temp_sigmagNL ;
%      pooled_contactCaTrials_locdep{dends(d)}.thetadepL = temp_sigmagL ;
%      pooled_contactCaTrials_locdep{dends(d)}.effect_thetadep = temp_sigmagNL ;
end

       set(gcf,'PaperUnits','inches');
        set(gcf,'PaperPosition',[1 1 18 24]);
        set(gcf, 'PaperSize', [24,10]);
        set(gcf,'PaperPositionMode','manual');
        print( gcf ,'-depsc2','-painters','-loose',[' Theta Dep  reg temp D ' num2str(dends)]);
saveas(gcf,[' Theta Dep reg temp D ' num2str(dends)],'jpg');
% saveas(gcf,[' Theta Dep D ' num2str(dends)],'fig');
 
