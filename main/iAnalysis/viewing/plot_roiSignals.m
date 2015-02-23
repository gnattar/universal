function plot_roiSignals(obj,fov,rois,roislist,tag_trialtypes,trialtypes,sfx,nam,overlay)
% plot signals arranged by rois : to check roi selection in fovs
roisperfig = 6;
% s_time = 1.0 ;
s_time = 0;
e_time = 5.0;
cscale=[0 250];
fovname = [nam 'fov ' fov 'rois ' roislist]; 
frametime=obj.FrameTime;
rois_trials  = arrayfun(@(x) x.dff, obj,'uniformoutput',false);
if (strcmp(sfx , 'Csort') || strcmp(sfx , 'CSort_barpos'))
    wsk_frametime =1/500;
    dKappa = cell2mat(arrayfun(@(x) x.deltaKappa{1}, obj,'uniformoutput',false)');
    velocity =cell2mat(arrayfun(@(x) x.Velocity{1}, obj,'uniformoutput',false)');
    ts_wsk = cell2mat(arrayfun(@(x) x.ts_wsk{1}, obj,'uniformoutput',false)');
    totalTouchKappa = cell2mat(arrayfun(@(x) x.total_touchKappa, obj,'uniformoutput',false)');
    s_time = 0; 
end

if (strcmp(sfx , 'T') || strcmp(sfx , 'Tbarpos'))


end
    
if strcmp(sfx , 'Tsort')
    btt = ['T';'N']; 
elseif strcmp(sfx , 'Csort')
    btt = 'C';
elseif strcmp(sfx , 'T')
    btt = 'T';
elseif strcmp(sfx , 'Csort_barpos')
    if numel(overlay)>1
        btt = num2str(sort(unique(overlay(overlay>0)),'descend'));
    else
        btt = num2str(sort(unique(trialtypes),'descend'));
    end
elseif strcmp(sfx , 'Tbarpos')
    if numel(overlay)>1
        btt = num2str(sort(unique(overlay(overlay>0)),'descend'));
    else
        btt = num2str(sort(unique(trialtypes),'descend'));
    end
elseif (strcmp(sfx , 'Bsort'))
    btt = ['H';'M';'C';'F'];
elseif (strcmp(sfx , 'Tsort_barpos'))
    if numel(overlay)>1
        btt = num2str(sort(unique(overlay(overlay>0)),'descend'));
    else
        btt = num2str(sort(unique(trialtypes),'descend'));
    end
elseif (strcmp(sfx , 'Tsort'))
    btt = ['T';'N'];
else
     btt = ['A'];
end
if max(overlay)>0
    curr_btt = btt(overlay(overlay>0),:);
else
    curr_btt = btt(unique(trialtypes),:);
end
numtrials = length(rois_trials);
numrois = size(rois_trials{1},1);
numframes =size(rois_trials{1},2);
ts = frametime:frametime:frametime*numframes;
temprois = zeros(numrois,numframes,numtrials);
for i= 1:numtrials
        tempmat = zeros(size(rois_trials,1),size(rois_trials,2));
        tempmat = rois_trials{i};
      if (size(tempmat,2)>size(temprois,2))
       temprois(:,:,i) = tempmat(1:numrois,1:numframes);
      else
        temprois(:,1:size(tempmat,2),i) = tempmat(:,:);
      end
      
end

% a = round(linspace(1,300,20));
a = round(linspace(1,200,34));
if (max(overlay)>0)
    if(max(trialtypes) > 8) 
        b = [3 1 16 18  5 7 21 23 10 8  6 9 11 4 26 22 12 14 28 25 34 32 17 15 29 24 33 31 2 13 30 26 19 20];
    else
        b = [ 10    5  26  34   16  8   28  18];
    end
else
    if(max(trialtypes) > 8)
        b = [ 3 16 5 21  10 6 11 26 12 28 34 17 29  33 2 30 19 1 18 7 8 9 23 4 22 14 25 32 15 24 31 13 26 20];

    else
        b = [ 10  26  16 28 5   34   8  18];
    end

end
scaledcol = a(b);
scaledcol = a(b);
temp = jet(cscale(1,2));
% temp = othercolor('Mrainbow',300);
col = temp(scaledcol,:);

if(tag_trialtypes ==1)
    temp = permute(temprois,[3,2,1]);
    newrois=zeros(size(temp,1),size(temp,2)+1,size(temp,3));
    newrois(:,1:size(temp,2),:) = temp;
    windowSize = round(0.1/frametime);
%     filt_newrois  = filter(ones(1,windowSize)/windowSize,1, newrois);
%     newrois = filt_newrois;
    temp2 =repmat(scaledcol(trialtypes)',1,1,size(temp,3));
    temp2 = [temp2 temp2 temp2 temp2 temp2];
    newrois(:,size(temp,2)+1:size(temp,2)+5,:) = temp2;
else 
    newrois =permute(temprois,[3,2,1]);
end
if max(overlay)>0
    numcolstoplot = 1+max(overlay)*2;
else
    numcolstoplot = 1+max(unique(trialtypes))*2;% + 1* (strcmp(sfx , 'Csort') || strcmp(sfx , 'CSort_barpos'));
end
dt = ts(length(ts))-ts(length(ts)-1);
roicount = 1;
count =1;count1=1;
sc = get(0,'ScreenSize');
% h1 = figure('position', [1000, sc(4)/10-100, sc(3)*3/10, sc(4)*3/4], 'color','w');
h1 = figure('position', [1000, sc(4)/10-100, sc(3), sc(4)], 'color','w');
ah1=axes('Parent',h1); title( 'Ca_Signal traces' );
%  if (strcmp(sfx , 'Csort') || strcmp(sfx , 'CSort_barpos'))
%      h2 = figure('position', [300, sc(4)/10-100, sc(3), sc(4)], 'color','w');
%      ah2=axes('Parent',h2); title('dFF vs. totalKappa' );
%  end
rois_name_tag = '';
    for i = 1:length(rois)
               figure(h1);
            rois_name_tag = [rois_name_tag,num2str(rois(i)),','];
            %plot im
            subplot(roisperfig,numcolstoplot,count);
            count=count+1;
            xt=[ts ts(length(ts))+dt*1:dt:ts(length(ts))+dt*5];
            [y,temp]=min(abs(xt-s_time));

         ha1= imagesc(xt(temp:end),1:numtrials,newrois(:,temp:end,rois(i)));caxis(cscale);colormap(jet(300));xlabel('Time(s)'); ylabel('Trials');
%              ha1 = subimage(newrois(:,temp:end,rois(i)),jet(300));
%            caxis(cscale);xlabel('Time(s)'); ylabel('Trials');
%             set(ha1,'XData',xt(temp:end),'YData',1:numtrials);
% %             if(strcmp(sfx,'T') || strcmp(sfx,'Tbarpos'))
% %                 hold on; 
% %                 N = zeros(numtrials,size(xt,2),2);
% %                 for t = 1:numtrials
% %                     if(~isempty(obj(t).touchtimes{1}))
% %                      N(t,:,1) = hist(obj(t).touchtimes{1}{1},xt);
% %                     end
% %                     if(~isempty(obj(t).touchtimes{2}))
% %                      N(t,:,2) = hist(obj(t).touchtimes{2}{1},xt);
% %                     end
% %                 end
% %                 amap=(N(:,:,1)>1)*.9;
% %                 ha2 = subimage(N(:,:,1),copper(20));set(ha2,'AlphaData',amap);
% %                 amap=(N(:,:,2)>1)*.9;
% %                 ha3 = subimage(N(:,:,1),summer(30));set(ha3,'AlphaData',amap);
% %                 
% %             end

            vline([ 1 1.5 2 2.5 3],'k-');
           if (strcmp(sfx , 'Csort') || strcmp(sfx , 'Csort_barpos'))
            vline([ 0.5],'k--');
           end
            figure(h1);
            % plot traces
    % % %          if(tag_trialtypes ==1)         
                types= unique(trialtypes);  

                 
                for k = 1: max(types)
                    trials_ktype=(find(trialtypes==k)); 
                    if(~isempty(trials_ktype))
                        if (numel(overlay)>1 && overlay(k)>0)
                            subplot(roisperfig,numcolstoplot, overlay(k)+1 +(( mod(roicount,roisperfig)*1 +(mod(roicount,roisperfig)==0)*roisperfig ) -1)*numcolstoplot);
                            hold on;
                        else
                            subplot(roisperfig,numcolstoplot, count);
                            count = count+1;
                        end
                        
                        for j=1:length(trials_ktype)
                            plot(ts ,newrois(trials_ktype(j),1:length(ts),rois(i))','color',col(k,:),'linewidth',.5);
                            hold on;
                        end
                        xlabel('Time (s)'); ylabel('dFF');
                        axis([s_time ts(length(ts)) -100 cscale(2)+100]);set(gca,'YMinorTick','on','YTick', -100:100:cscale(2)+100);
                        vline([  1 1.5 2 2.5 3],'k-');
                    elseif isempty(trials_ktype) && (numel(overlay)>1 && overlay(k)==0)
                        count = count+1;
                    elseif isempty(trials_ktype) && numel(overlay)==1
                        
                        count = count+1;
                    else
                        
                    end
                    if (k+1) > max(types) && (strcmp(sfx , 'Tsort_barpos') || strcmp(sfx , 'Csort_barpos'))
                        if (max(overlay>0) )
                            temp = (mod(roicount,roisperfig)==0)*roisperfig + (mod(roicount,roisperfig)>0)*mod(roicount,roisperfig);
%                          count = (roicount-(roicount>roisperfig)*(floor(roicount/roisperfig)*roisperfig)-1)*numcolstoplot+max(overlay)+1+1;
                            count =(temp -1) * numcolstoplot + max(overlay)+1 +1;
                        end
                    end
                end

    % % %          else
    % % %             col=linspace(0,1,numtrials);
    % % %             for j=1:numtrials         
    % % %                  plot(ts,newrois(j,:,rois(i))','color',[.7 0 0]*col(j),'linewidth',.5);
    % % %                  axis([0 ts(length(ts)) -50 300]);set(gca,'YMinorTick','on','YTick', 0-50:200:700);
    % % %                  hold on;
    % % %             end
    % % %             hold off;  
    % % %             vline([.5 ],'r-');
    % % %             vline([1 1.5 2 2.5],'k:');
    % % %          end


%     if(max(overlay>0) && mod(roicount,roisperfig) >0)
% %         count = (roicount-(roicount>roisperfig)*roisperfig-1)*numcolstoplot+max(overlay)+1+1;
%         count = (roicount-(roicount>roisperfig)*(floor(roicount/roisperfig)*roisperfig)-1)*numcolstoplot+max(overlay)+1+1
% 
%     end
    % plot trace averages
    figure(h1);
    types= unique(trialtypes);
    temp_avg=zeros(length(types),length(ts));
    
    for k = 1:max(types)
        trials_ktype=(find(trialtypes==k));
        if(~isempty(trials_ktype))
            if (numel(overlay)>1 && overlay(k)>0)
                subplot(roisperfig,numcolstoplot, overlay(k)+max(overlay)+1 +((mod(roicount,roisperfig)*1 +(mod(roicount,roisperfig)==0)*roisperfig) -1)*numcolstoplot);
                hold on;
            else
                subplot(roisperfig,numcolstoplot, count);
                count = count+1;
            end
            
            temp_data=newrois(trials_ktype,1:length(ts),rois(i));
            threshold = 35; %% dF/F absolute
            [event_detected_data,events_septs,detected] = detect_Ca_events(temp_data,frametime,threshold);
%              detected_data= event_detected_data(find(detected),:);
            detected_data= temp_data(:,:);

            detected_avg=nanmean(detected_data ,1);%sum(detected_data ,1)./max(sum(detected,1),1);
            detected_sd=(detected_data.^2 + repmat(detected_avg.^2,size(detected_data,1),1) - 2*detected_data.*repmat(detected_avg,size(detected_data,1),1));
            detected_sd=(nanmean(detected_sd,1)).^0.5;
%             alltrials_avg = nanmean(temp_data,1);
            alltrials_avg = detected_avg;

            %                     plot([frametime:frametime:length(detected_avg)*frametime] ,detected_avg,'color',col(types(k),:),'linewidth',1.5);
            plot([frametime:frametime:length(alltrials_avg)*frametime] ,alltrials_avg,'color',col(k,:),'linewidth',1);
            
            axis([s_time ts(length(ts)) -30 round(cscale(2)+100)/2]);set(gca,'YMinorTick','on','YTick', -50:50:round(cscale(2)+100)/2);xlabel('Time(s)'); ylabel('mean_dFF');
            
            vline([ 1 1.5 2 2.5 3],'k-');
            text(3.5,200,[ num2str(sum(detected,1)) '/' num2str(size(event_detected_data,1)) '(' num2str(sum(detected,1)/size(event_detected_data,1)) ')']);%,'Location','NorthEast');
        elseif isempty(trials_ktype) && (numel(overlay)>1 && overlay(k)==0)
            count = count+1;
        elseif isempty(trials_ktype) && numel(overlay)==1
            
            count = count+1;
        end
        if(k+1) > max(types) && (strcmp(sfx , 'Tsort_barpos') || strcmp(sfx , 'Csort_barpos'))
            if(max(overlay>0) )
                 temp = (mod(roicount,roisperfig)==0)*roisperfig + (mod(roicount,roisperfig)>0)*mod(roicount,roisperfig);
%              count = ((roicount)-(roicount>roisperfig)*(floor(roicount/roisperfig)*roisperfig)-1)*numcolstoplot+max(overlay)+2+1+1;
               count =  (temp-1) * numcolstoplot + max(overlay)*2 +2;
            end
        end
    end
    
% % %     if(max(overlay>0))
% % %         
% % % %         count = (roicount-(roicount>roisperfig)*roisperfig-1)*numcolstoplot+max(overlay)*2+1+1;
% % %         count = (roicount-(roicount>roisperfig)*(floor(roicount/roisperfig)*roisperfig)-1)*numcolstoplot+max(overlay)+2+1+1;
% % % 
% % %     end   
    
%     % plot max(dFF) vs. dKappa
%     if (strcmp(sfx , 'Csort') || strcmp(sfx , 'CSort_barpos'))
%         figure(h2);
%         types= unique(trialtypes);
%         %                         subplot(roisperfig,numcolstoplot, count);
%         
%         for k = 1:max(types)
%             if (numel(overlay)>1 && overlay(k)>0)
%                 subplot(roisperfig,numcolstoplot, overlay(k)+max(overlay) +((mod(roicount,roisperfig)*1 +(mod(roicount,roisperfig)==0)*roisperfig) -1)*numcolstoplot);
%                 hold on;
%             else
%                 subplot(roisperfig,length(types), count1);
%                 count1=count1+1;
%             end
%             if(~isempty(trials_ktype))
%                 trials_ktype=(find(trialtypes==types(k)));
%                 temp_data=newrois(trials_ktype,1:length(ts),rois(i));
%                 temp_dKappa = dKappa(trials_ktype,:);
%                 temp_velocity = velocity(trials_ktype,:);
%                 temp_ts_wsk = ts_wsk(trials_ktype,:);
%                 temp_totalTouchKappa = totalTouchKappa(trials_ktype,:);
%                 [event_detected_data,events_septs,detected] = detect_Ca_events(temp_data,frametime,threshold);
% 
%                 max_dFF=zeros(size(temp_data,1),1);
% 
%                 for m = 1:size(events_septs,1)
%                     temp2 = temp_data(m,events_septs(m,1):events_septs(m,2));
%                     total_dFF(m,1) = sum(temp2);
%                     max_dFF(m,1) = nanmean(prctile(temp2,90));
%                 end
% 
%                 total_velocity = sum(temp_velocity,2);
%                 [X, outliers_idx] = outliers(temp_totalTouchKappa.*max_dFF);
%                 %                      plot(total_dKappa,max_dFF,'Marker','o','color',col(types(k),:),'Markersize',6);
%                 scatter(temp_totalTouchKappa,max_dFF,80,col(types(k),:),'fill');hold on;
%                 plot(temp_totalTouchKappa(outliers_idx),max_dFF(outliers_idx),'*','color',[1,1,1],'MarkerSize',6);
%                 %                           set(gca,'Xscale','log');
%                 %                           temp_totalTouchKappa(outliers_idx) = [];
%                 %                           total_dFF(outliers_idx)=[];
%                 P=polyfit(temp_totalTouchKappa,max_dFF,1);
%                 yfit = P(1)*temp_totalTouchKappa + P(2);
%                 hold on;
%                 plot(temp_totalTouchKappa,yfit,'color',col(types(k),:),'linewidth',2);hold off;
%                 grid on;xlabel('total_dKappa'); ylabel('peak_dFF');
%                 text(0 ,200,['b=' num2str(P(1))]);
% 
%                 %                           axis([min(temp_totalTouchKappa)-1 max(temp_totalTouchKappa)+1 -10 max(max_dFF) ]);
%                 axis([-10 40 -50 400 ]);
%                 set(gca,'YMinorTick','on','YTick', 0:100:500);
%                 %                     vline([.5 1 1.5 2 2.5],'k-');
%             end
%             
%         end
%         
%         
%     end
    if (mod(roicount,roisperfig)>0) && (roicount<length(rois))
        
    else
        
        fnam=[nam 'FOV' fov 'rois' rois_name_tag sfx 'CaTraces ' curr_btt' ];
        figure(h1);
        suptitle(fnam);
  
        set(gcf,'PaperUnits','inches');
        set(gcf,'PaperPosition',[1 1 24 10]);
        set(gcf, 'PaperSize', [24,10]);
        set(gcf,'PaperPositionMode','manual');
%         print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);
        saveas(gcf,[pwd,filesep,fnam],'jpg');
%          saveas(gcf,[pwd,filesep,fnam],'fig');
        [~,foo] = lastwarn;
        if ~isempty(foo)
            warning('off',foo);
        end
        close(h1);

%         if (strcmp(sfx , 'Csort') || strcmp(sfx , 'CSort_barpos'))
%             fnam=[nam 'FOV' fov 'rois' rois_name_tag sfx  'dKappa_dFF.jpg'];
%             figure(h2);
%             suptitle(fnam);
%             
%             set(gcf,'PaperUnits','inches');
%             set(gcf,'PaperPosition',[1 1 24 10]);
%             set(gcf, 'PaperSize', [24,10]);
%             set(gcf,'PaperPositionMode','manual');
%             
%             saveas(gcf,[pwd,filesep,fnam],'jpg');
%             [~,foo] = lastwarn;
%             if ~isempty(foo)
%                 warning('off',foo);
%             end
%             close(h2);
%         end
        if (roicount<length(rois))
            h1 = figure('position', [1000, sc(4)/10-100, sc(3), sc(4)], 'color','w');
            ah1=axes('Parent',h1); title( 'Ca_Signal traces' );           
%             if (strcmp(sfx , 'Csort') || strcmp(sfx , 'CSort_barpos'))
%                 h2 = figure('position', [300, sc(4)/10-100, sc(3), sc(4)], 'color','w');
%                 ah2=axes('Parent',h2); title('dFF vs. totalKappa' );
%             end
            count =1;count1=1;
            rois_name_tag = '';
        end
    end
    roicount = roicount+1;
    end
    end
    

