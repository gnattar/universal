function plot_roiSignals(obj,fov,rois,roislist,tag_trialtypes,trialtypes,sfx,nam)
% plot signals arranged by rois : to check roi selection in fovs
roisperfig = 5;
% s_time = 1.0 ;
s_time = 0;
e_time = 5.0;

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

if strcmp(sfx , 'Csort') 
    btt = ['T';'N']; 
elseif strcmp(sfx , 'CSort_barpos')
    btt = num2str([length(trialtypes):1]);
elseif (strcmp(sfx , 'Bsort'))
    btt = ['H';'M';'C';'F'];
else
     btt = [''];
end
curr_btt = btt(unique(trialtypes),:);
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
cscale=[0 300];
% col = [0 0 1; 0 .5 1; 0 1 1; 1 0 0;.5 0 0 ;.5 1 .5;1 1 0];
% scaledcol = [38;76;113;263;300;151;188];
    col = [0 0 .5 ;0 0 1; 0 .5 1; 1 .44 0; 1 0 0;.5 0 0 ;.5 1 .5]; %[0 0 1; 0 .5 1;.5 .5 1; 1 0 0;.5 0 0 ;0 0 0];
    scaledcol = [1;38;76;230;263;300;151];
if(tag_trialtypes ==1)
    temp = permute(temprois,[3,2,1]);
    newrois=zeros(size(temp,1),size(temp,2)+1,size(temp,3));
    newrois(:,1:size(temp,2),:) = temp;
    temp2=repmat(trialtypes,1,size(temp,3));
    temp2 = reshape(temp2,numtrials,1,numrois);
    for i=1:numtrials
        temp2(i,:,:)  = scaledcol(temp2(i,1));
    end
    %temp2=temp2*(1/length(unique(trialtypes))) *cscale(1,2);
    temp2 = [temp2 temp2 temp2 temp2 temp2];
    newrois(:,size(temp,2)+1:size(temp,2)+5,:) = temp2;
else 
    newrois =permute(temprois,[3,2,1]);
end

numcolstoplot = 1+length(unique(trialtypes))*2;% + 1* (strcmp(sfx , 'Csort') || strcmp(sfx , 'CSort_barpos'));
dt = ts(length(ts))-ts(length(ts)-1);
roicount = 1;
count =1;count1=1;
sc = get(0,'ScreenSize');
% h1 = figure('position', [1000, sc(4)/10-100, sc(3)*3/10, sc(4)*3/4], 'color','w');
h1 = figure('position', [1000, sc(4)/10-100, sc(3), sc(4)], 'color','w');
ah1=axes('Parent',h1); title( 'Ca_Signal traces' );
 if (strcmp(sfx , 'Csort') || strcmp(sfx , 'CSort_barpos'))
     h2 = figure('position', [300, sc(4)/10-100, sc(3), sc(4)], 'color','w');
     ah2=axes('Parent',h2); title('dFF vs. totalKappa' );
 end
rois_name_tag = '';
    for i = 1:length(rois)
               figure(h1);
            rois_name_tag = [rois_name_tag,num2str(rois(i)),','];
            %plot im
            subplot(roisperfig,numcolstoplot,count);
            count=count+1;
            xt=[ts ts(length(ts))+dt*1:dt:ts(length(ts))+dt*5];
            [y,temp]=min(abs(xt-s_time));
%             imagesc(xt(1:end),1:numtrials,newrois(:,:,rois(i)));caxis(cscale);colormap(jet);xlabel('Time(s)'); ylabel('Trials');
            imagesc(xt(temp:end),1:numtrials,newrois(:,temp:end,rois(i)));caxis(cscale);colormap(jet);xlabel('Time(s)'); ylabel('Trials');

            vline([.5 1 1.5 2 2.5 ],'k-');

            figure(h1);
            % plot traces
    % % %          if(tag_trialtypes ==1)         
                types= unique(trialtypes);  

                 
                for k = 1:length(types)
                    trials_ktype=(find(trialtypes==types(k)));  
                    subplot(roisperfig,numcolstoplot, count);
                    count = count+1;
                    for j=1:length(trials_ktype)           
                        plot(ts ,newrois(trials_ktype(j),1:length(ts),rois(i))','color',col(types(k),:),'linewidth',1);           
                     hold on;  
                    end   
                    xlabel('Time (s)'); ylabel('dFF');
                    axis([s_time ts(length(ts)) -100 500]);set(gca,'YMinorTick','on','YTick', -100:100:500);
                    vline([  1 1.5 2 2.5],'k-');
                end

    % % %          else
    % % %             col=linspace(0,1,numtrials);
    % % %             for j=1:numtrials         
    % % %                  plot(ts,newrois(j,:,rois(i))','color',[.7 0 0]*col(j),'linewidth',.5);
    % % %                  axis([0 ts(length(ts)) -50 700]);set(gca,'YMinorTick','on','YTick', 0-50:200:700);
    % % %                  hold on;
    % % %             end
    % % %             hold off;  
    % % %             vline([.5 ],'r-');
    % % %             vline([1 1.5 2 2.5],'k:');
    % % %          end



    % plot trace averages
    figure(h1);
    types= unique(trialtypes);
    temp_avg=zeros(length(types),length(ts));
    
    for k = 1:length(types)
        trials_ktype=(find(trialtypes==types(k)));
        subplot(roisperfig,numcolstoplot, count);
        count = count+1;
        temp_data=newrois(trials_ktype,1:length(ts),rois(i));
        threshold = 2; % in m.a.d
        [event_detected_data,events_septs,detected] = detect_Ca_events(temp_data,frametime,threshold);
        detected_data= event_detected_data(find(detected),:);
        detected_avg=mean(detected_data ,1);%sum(detected_data ,1)./max(sum(detected,1),1);
        detected_sd=(detected_data.^2 + repmat(detected_avg.^2,size(detected_data,1),1) - 2*detected_data.*repmat(detected_avg,size(detected_data,1),1));
        detected_sd=(mean(detected_sd,1)).^0.5;
        alltrials_avg = mean(temp_data,1);
        %                     plot([frametime:frametime:length(detected_avg)*frametime] ,detected_avg,'color',col(types(k),:),'linewidth',1.5);
        plot([frametime:frametime:length(alltrials_avg)*frametime] ,alltrials_avg,'color',col(types(k),:),'linewidth',1.5);
        
        axis([s_time ts(length(ts)) -50 250]);set(gca,'YMinorTick','on','YTick', -50:50:250);xlabel('Time(s)'); ylabel('mean_dFF');
        
        vline([ 1 1.5 2 2.5],'k-');
        text(1,100,[ num2str(sum(detected,1)) '/' num2str(size(event_detected_data,1)) '(' num2str(sum(detected,1)/size(event_detected_data,1)) ')']);%,'Location','NorthEast');
        
    end
    
    
    % plot max(dFF) vs. dKappa
    if (strcmp(sfx , 'Csort') || strcmp(sfx , 'CSort_barpos'))
        figure(h2);
        types= unique(trialtypes);
        %                         subplot(roisperfig,numcolstoplot, count);
        
        for k = 1:length(types)
            subplot(roisperfig,length(types), count1);
            count1=count1+1;
            trials_ktype=(find(trialtypes==types(k)));
            temp_data=newrois(trials_ktype,1:length(ts),rois(i));
            temp_dKappa = dKappa(trials_ktype,:);
            temp_velocity = velocity(trials_ktype,:);
            temp_ts_wsk = ts_wsk(trials_ktype,:);
            temp_totalTouchKappa = totalTouchKappa(trials_ktype,:);
            [event_detected_data,events_septs,detected] = detect_Ca_events(temp_data,frametime,threshold);
            
            
            max_dFF=zeros(size(temp_data,1),1);
            
            
            for m = 1:size(events_septs,1)
                temp2 = temp_data(m,events_septs(m,1):events_septs(m,2));
                total_dFF(m,1) = sum(temp2);
                max_dFF(m,1) = mean(prctile(temp2,90));
            end
            
            
            total_velocity = sum(temp_velocity,2);
            [X, outliers_idx] = outliers(temp_totalTouchKappa.*max_dFF);
            %                      plot(total_dKappa,max_dFF,'Marker','o','color',col(types(k),:),'Markersize',6);
            scatter(temp_totalTouchKappa,max_dFF,80,col(types(k),:),'fill');hold on;
            plot(temp_totalTouchKappa(outliers_idx),max_dFF(outliers_idx),'*','color',[1,1,1],'MarkerSize',6);
            %                           set(gca,'Xscale','log');
            %                           temp_totalTouchKappa(outliers_idx) = [];
            %                           total_dFF(outliers_idx)=[];
            P=polyfit(temp_totalTouchKappa,max_dFF,1);
            yfit = P(1)*temp_totalTouchKappa + P(2);
            hold on;
            plot(temp_totalTouchKappa,yfit,'color',col(types(k),:),'linewidth',2);hold off;
            grid on;xlabel('total_dKappa'); ylabel('peak_dFF');
            text(0 ,200,['b=' num2str(P(1))]);
            
            %                           axis([min(temp_totalTouchKappa)-1 max(temp_totalTouchKappa)+1 -10 max(max_dFF) ]);
            axis([-10 40 -50 400 ]);
            set(gca,'YMinorTick','on','YTick', 0:100:500);
            %                     vline([.5 1 1.5 2 2.5],'k-');
            
            
        end
        
        
    end
    if (mod(roicount,roisperfig)>0) && (roicount<length(rois))
        
    else
        
        fnam=[nam 'FOV' fov 'rois' rois_name_tag sfx 'CaTraces ' curr_btt' ];
        figure(h1);
        suptitle(fnam);
        set(gcf,'PaperUnits','inches');
        set(gcf,'PaperPosition',[1 1 24 10]);
        set(gcf, 'PaperSize', [24,10]);
        set(gcf,'PaperPositionMode','manual');
        
        saveas(gcf,[pwd,filesep,fnam],'jpg');
        [~,foo] = lastwarn;
        if ~isempty(foo)
            warning('off',foo);
        end
        close(h1);

        if (strcmp(sfx , 'Csort') || strcmp(sfx , 'CSort_barpos'))
            fnam=[nam 'FOV' fov 'rois' rois_name_tag sfx  'dKappa_dFF.jpg'];
            figure(h2);
            suptitle(fnam);
            
            set(gcf,'PaperUnits','inches');
            set(gcf,'PaperPosition',[1 1 24 10]);
            set(gcf, 'PaperSize', [24,10]);
            set(gcf,'PaperPositionMode','manual');
            
            saveas(gcf,[pwd,filesep,fnam],'jpg');
            [~,foo] = lastwarn;
            if ~isempty(foo)
                warning('off',foo);
            end
            close(h2);
        end
        if (roicount<length(rois))
            h1 = figure('position', [1000, sc(4)/10-100, sc(3), sc(4)], 'color','w');
            ah1=axes('Parent',h1); title( 'Ca_Signal traces' );           
            if (strcmp(sfx , 'Csort') || strcmp(sfx , 'CSort_barpos'))
                h2 = figure('position', [300, sc(4)/10-100, sc(3), sc(4)], 'color','w');
                ah2=axes('Parent',h2); title('dFF vs. totalKappa' );
            end
            count =1;count1=1;
            rois_name_tag = '';
        end
    end
    roicount = roicount+1;
    end
    end
    

