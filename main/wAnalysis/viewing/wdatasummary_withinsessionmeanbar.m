
function[w_thetaenv]...
    =  wdatasummary(sessionInfo,obj,block_tags,block_trialnums,avg_trials,gopix,nogopix,restrictTime,pd,plot_whiskerfits,str,timewindowtag)
%% new version : compare within block & with top 90% percentile of setpoint values
% w_setpoint_trials % all setpoint values from all trials  entire length
% w_setpoint_early % within the restricted time window from early trials
% w_setpoint_late % within the restricted time window from late trials
% w_setpoint_trials_med % mean of 90th percentile of setpoint values within window
% w_setpoint_trials_width std of the points avgd over

    w_thetaenv = struct('trials',[],'time',[],'dist',[],'bins',[],'med',[],'medbinned',[],'meanbarcross',[],'peak',[],'peakbinned',[],'meanbarcrossbinned',[],'prepole',[],'prepolebinned',[],'prcpastmeanbar',[],'pval',[],'mean_barpos',[]);
    numblocks = size(block_tags,2);
    
%% get mean bar theta cut off


    y  =sessionInfo.go_bartheta;
    x = sessionInfo.gopos;
    ind = find(~isnan(y));
     y = y(ind);
     x = x(ind);
    
      y = sort(y ,'ascend');

     p=polyfit(x,y,1);
     mean_selecttrials = nanmedian(sessionInfo.goPosition_runmean(block_trialnums{1}));
     mean_bartheta = polyval(p,mean_selecttrials*10000);
     shoulder = 2.5; % avg 5 deg between pole positions , should = 2.5 deg

    point = max(gopix);
    gopix(:,2) = point(1,2);
    nogopix(1,2) = point(1,2);

      
    frames_list=arrayfun(@(x) size(x{:}.time{1},2), obj,'uniformoutput',false);
    maxframes = max(cell2mat(frames_list));
   numpoleframes = (restrictTime(2)-restrictTime(1))*500;

    if~(exist([pd '/plots/'],'dir'))
       mkdir (pd,'plots') ;
    end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
    
    fpath = [pd '/plots/'];
    if ~(exist([fpath timewindowtag],'dir'))
       mkdir (fpath,timewindowtag) ;
    end
    
    fpath = [pd '/plots/' timewindowtag '/'];
    if ~(exist([fpath str],'dir'))
       mkdir (fpath,str) ;
    end

       fpath = [pd '/plots/' timewindowtag '/' str];
   
%     fnam=[str 'thetaEnv.tif'];
%     h1=figure('Name','Set point plot'); 
%     set(0,'CurrentFigure',h1);
%     suptitle(['M:' obj{1}.mouseName ' S:' obj{1}.sessionName ' B: ' str ]);

    
    for(blk=1:numblocks)
        trialnums = block_trialnums{blk};
         col=jet(length(trialnums));  
        thetaenv_bins = -50:1:50;
        nbins=length(thetaenv_bins);
        thetaenv_dist = nan(length(trialnums),nbins);
        thetaenv_trials = nan(length(trialnums)+1,numpoleframes);

        thetaenv_med = nan(length(trialnums),2);
        thetaenv_peak = nan(length(trialnums),2);
        thetaenv_meanbarcross = nan(length(trialnums),2);
        thetaenv_prcpastmeanbar = nan(length(trialnums),1);
        thetaenv_prepole = nan(length(trialnums),2);    
         ref_time = restrictTime(1)+.002:.002:restrictTime(2);ref_time=round(ref_time.*1000)./1000;
         thetaenv_time =   ref_time; 
         numpoleframes = length(ref_time);
         
%        count =1;
        for(i=1:1:length(trialnums))

            t = trialnums(i);
            frames = length(obj{t}.theta{1,1});
            if(frames<1500)
                disp(['delete trial' obj{t}.trackerFileName num2str(trialnums(i))])     
                frameTime = obj{t}.framePeriodInSec;
            else
                frameTime = obj{t}.framePeriodInSec;
                xt = [1:frames]*frameTime;

%                     setpoint = obj{t}.Setpoint{1,1};
%                     amp     = obj{t}.Amplitude{1,1};
                    theta = obj{t}.theta{1,1};
                    thetaenv = envelope(theta,'linear');                
                    xt = obj{t}.time{1,1};xt = round( xt.*1000)./1000;

                    poleinds =  find( (restrictTime(1)< xt) & (xt<=restrictTime(2)) );
                    prepoleinds = find( (xt>restrictTime(1)-.2) & (xt<=restrictTime(1)));

                    thetaenv_pole = thetaenv( poleinds);
                    xt_pole = xt( poleinds);

                    [lia,matchedinds]= ismember( xt_pole,ref_time);
                    thetaenv_trials(i,matchedinds>0) =   thetaenv_pole;                 
                   
                    thetaenv_dist(i,:) = histnorm(thetaenv_pole,thetaenv_bins);%./length(thetaenv_pole);
                    past_meanbar= find(thetaenv_bins>mean_bartheta - shoulder);
                    thetaenv_med(i,1) = mean(thetaenv_pole);
                    thetaenv_med(i,2) =  std(thetaenv_pole);
                    
                    prc = prctile(thetaenv_pole,95);
                    temp = thetaenv_pole(thetaenv_pole>prc);
                    thetaenv_peak(i,1) = mean(temp); %% change it to prctile later
                    thetaenv_peak(i,2) = std(temp);
                    
                    thetaenv_prcpastmeanbar(i,1) = sum(thetaenv_dist(i,past_meanbar));
                    temp = thetaenv_pole(thetaenv_pole > mean_bartheta- shoulder);
                    if ~isempty(temp)
                        thetaenv_meanbarcross(i,1) = mean(temp);
                        thetaenv_meanbarcross(i,2) = std(temp);
                    else
                        
                    end

                    temp = thetaenv(prepoleinds);
                    thetaenv_prepole(i,1) = mean(temp);
                    thetaenv_prepole(i,2) = std(temp);
            end
        end

        hold off;
        avg_trials = floor(length(trialnums)/3);
        if(i-1<=avg_trials)
             avg_trials = i-2;
             disp ([ 'there are only' num2str(i-1) ' good trials , reduced trialstoavg to ' num2str(i-2)]);
        end

        earlyinds= [1:avg_trials] ;             
        lateinds= [i-1-avg_trials : i-1] ;

        

%% plot thetaenv _med,meanbarcross,prepole  
       fnam=[str 'thetaenv PkMprep.tif'];
        h1a=figure('Name','Theta Envelope plot'); 
        set(0,'CurrentFigure',h1a);
        suptitle(['M:' obj{1}.mouseName ' S:' obj{1}.sessionName ' B: ' str ' Thetaenvelope Peak Med Prepole']);
    

%        subplot(numblocks*2,3,(blk-1)*2+1);
            up = thetaenv_med(:,1)+thetaenv_med(:,2);
            low=thetaenv_med(:,1)-thetaenv_med(:,2);
            up(isnan(up)) = 0;
            low(isnan(low)) = 0;
%             jbfill(trialnums',up',low',[.8 .8 .8],[.8 .8 .8],1,.5);hold on;
%              plot(trialnums,thetaenv_med(:,1),'linewidth',.25,'color','k'); hold on;
            windowSize=25;
            grid on;

            data =thetaenv_med(:,1);
            binned= arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
            binned=cat(1,binned{:});
            data =thetaenv_med(:,2);
            binned_sdev = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
            binned_sdev=cat(1,binned_sdev{:});
            xbins = arrayfun( @(x) mean(x:min(x+windowSize-1,size(data,1))), 1:windowSize:size(data,1), 'UniformOutput', false);
            xbins=floor(cat(1,xbins{:}));         
    %        plot(trialnums(xbins),binned,'linewidth',1.5,'color','k','Marker','o');hold on;
            errorbar(trialnums(xbins),binned,binned_sdev,'linewidth',1,'color','k','Marker','o');hold on;
            grid on; 
            hline(mean_bartheta,'r',['mb ' num2str(mean_bartheta)]);
            s = regstats(binned,trialnums(xbins),'linear','tstat');
            pval(1)  = s.tstat.pval(2); % test for non-zero slope of med
            s = regstats(binned_sdev,trialnums(xbins),'linear','tstat');
            pval(2) = s.tstat.pval(2);

            w_thetaenv.med{blk} = {horzcat(trialnums,thetaenv_med(:,1),thetaenv_med(:,2))}; %%median for restricted time window
            w_thetaenv.medbinned{blk} = {horzcat(trialnums(xbins),binned,binned_sdev)}; %%median binned withi n restricted time window


            data = thetaenv_prepole(:,1);
%             plot(trialnums,thetaenv_prepole(:,1),'linewidth',.25,'color',[.5 .5 .8]); hold on;
            binned = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
            binned=cat(1,binned{:}); 
            data =thetaenv_prepole(:,2);
            binned_sdev = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
            binned_sdev=cat(1,binned_sdev{:});
            
            errorbar(trialnums(xbins),binned,binned_sdev,'color',[.5 .5 1],'linewidth',1,'Marker','o');  grid on;      
            s = regstats(binned,trialnums(xbins),'linear','tstat');
            pval(3)  = s.tstat.pval(2); % test for non-zero slope of prepole
            s = regstats(binned_sdev,trialnums(xbins),'linear','tstat');
            pval(4) = s.tstat.pval(2);
            
            w_thetaenv.prepole{blk}= {horzcat(trialnums,thetaenv_prepole(:,1),thetaenv_prepole(:,2))};
            w_thetaenv.prepolebinned{blk}= {horzcat(trialnums(xbins),binned,binned_sdev)};

            data = thetaenv_peak(:,1);
%             plot(trialnums,thetaenv_peak(:,1),'linewidth',.25,'color',[.8 .5 .5]); hold on;
            binned = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
            binned=cat(1,binned{:}); 
            data =thetaenv_peak(:,2);
            binned_sdev = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
            binned_sdev=cat(1,binned_sdev{:});
            errorbar(trialnums(xbins),binned,binned_sdev,'color',[1 .5 .5],'linewidth',1,'Marker','o');  grid on;   

            axis([min(trialnums) max(trialnums) -40 40]);
            s = regstats(binned,trialnums(xbins),'linear','tstat');
            pval(5)  = s.tstat.pval(2); % test for non-zero slope of peak
            s = regstats(binned_sdev,trialnums(xbins),'linear','tstat');
            pval(6) = s.tstat.pval(2);
           title('Thetaenv Med stdev,  Prepole ,Peak,(K.B.R) ');
           ylabel('Theta Env (deg)');xlabel('Trials');

%             text(.5,.02,'Thetaenv Med stdev,  Prepole ,Peak,(K.B.R) ','VerticalAlignment','bottom','HorizontalAlignment','center');

            w_thetaenv.peak{blk}= {horzcat(trialnums,thetaenv_peak(:,1),thetaenv_peak(:,2))};
            w_thetaenv.peakbinned{blk}= {horzcat(trialnums(xbins),binned,binned_sdev)};  
           
         saveas(gcf,[fpath,filesep,fnam],'tif');
         close(h1a);
%% plot Dist and mean past bartheta         
         fnam=[str 'thetaEnv.tif'];
         h1b=figure('Name','Theta Envelope Distribution'); 
         set(0,'CurrentFigure',h1b);
         suptitle(['M:' obj{1}.mouseName ' S:' obj{1}.sessionName ' B: ' str ' Mean, prc beyond mean barpos, Dist' ]);
 
             subplot(numblocks*2,2,(blk-1)*2+1);
             data = thetaenv_meanbarcross(:,1);
             
             up = thetaenv_meanbarcross(:,1)+thetaenv_meanbarcross(:,2);
            low=thetaenv_meanbarcross(:,1)-thetaenv_meanbarcross(:,2);

             windowSize=25; 
%              plot(trialnums,data,'linewidth',.5,'color', [.8 , .5,.5]);hold on;
             binned = arrayfun( @(x) nanmean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
             binned=cat(1,binned{:}); 
             data =thetaenv_meanbarcross(:,2);
             binned_sdev = arrayfun( @(x) nanmean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
             binned_sdev=cat(1,binned_sdev{:});   
    %        plot(trialnums(xbins),binned,'color','r','linewidth',1,'Marker','o');  grid on;   

             jbfill(trialnums',up',low', [.5 , .5,.5], [.5 , .5,.5],1,.3);hold on;
             plot(trialnums,thetaenv_meanbarcross(:,1),'linewidth',1,'color', [.5 , .5,.5]); hold on;
             hline(mean_bartheta,'r',['mb ' num2str(mean_bartheta)]);
                          
             errorbar(trialnums(xbins),binned,binned_sdev,'linewidth',1.5,'color','k','Marker','o');hold on;     
%              title('Mean theta beyond bartheta');
             ylabel('mThetaEnv beyond mbarpos (deg)');xlabel('Trials');
%                  axis([min(trialnums) max(trialnums) -40 40]);
                 s = regstats(binned,trialnums(xbins),'linear','tstat');
                 pval(7)  = s.tstat.pval(2); % test for non-zero slope of meanbarthetacross
                 s = regstats(binned_sdev,trialnums(xbins),'linear','tstat');
                 pval(8) = s.tstat.pval(2);

             %['Theta envelope pval ' num2str(pvalsetpoint)
             w_thetaenv.meanbarcross{blk}= {horzcat(trialnums,thetaenv_meanbarcross(:,1),thetaenv_meanbarcross(:,2))};
             w_thetaenv.meanbarcrossbinned{blk}= {horzcat(trialnums(xbins),binned,binned_sdev)};    


             w_thetaenv.trials{blk} = {thetaenv_trials};
             w_thetaenv.time {blk}= {thetaenv_time};

    %% plot dist   

    %         subplot(numblocks*2,3,(blk-1)*2+3);
             subplot(numblocks*2,2,(blk-1)*2+(3));
             set(gcf,'DefaultAxesColorOrder',jet(size(thetaenv_dist,1)));  
             plot(thetaenv_bins',thetaenv_dist','linewidth',0.25);hold on; grid on; 
             set(gcf,'DefaultAxesColorOrder',jet(size(thetaenv_meanbarcross,1)));
             line([thetaenv_meanbarcross(:,1)'; thetaenv_meanbarcross(:,1)'], [ones(1,length(thetaenv_meanbarcross(:,1)'))*.9; ones(1,length(thetaenv_meanbarcross(:,1)))*.95],'linewidth',1);         
             line([thetaenv_med(:,1)'; thetaenv_med(:,1)'], [ones(1,length(thetaenv_med(:,1)))*.8; ones(1,length(thetaenv_med(:,1)))*.85],'linewidth',1);
             vline(mean_bartheta,'r');
             axis ([-50 50 0 1]);grid on;
%              text(.5,.02,'Thetaenv_dist ','VerticalAlignment','bottom','HorizontalAlignment','center');
             title('Thetaenv_dist ');
             subplot(numblocks*2,2,(blk-1)*2+(4));
             cummu_dist = histnorm(reshape(thetaenv_trials,prod(size(thetaenv_trials)),1),thetaenv_bins);
             plot(thetaenv_bins',cummu_dist','linewidth',0.5,'color',[.5 .5 .5]); hold on;
             vline(mean_bartheta,'r', num2str(mean_bartheta));grid on;

%             text(.5,.02,'Thetaenv_dist Cummulative ','VerticalAlignment','bottom','HorizontalAlignment','center');
            title('Thetaenv_dist Cummulative ');
            ylabel('Normalized Dist');xlabel('Trials');
            
%% plot prc dist past mean bartheta
            subplot(numblocks*2,2,(blk-1)*2+2);
    % % %         temp= [thetaenv_med(:,1) thetaenv_meanbarcross(:,1) ];
    % % %         set(gcf,'DefaultAxesColorOrder',copper(size(temp,1)));  
    % % %         plot(temp','linewidth',1); axis ([0 3 -50 50]);

            plot(trialnums,thetaenv_prcpastmeanbar(:,1),'linewidth',1,'color',[.5 .5 .5]); hold on;
            windowSize=25;
            grid on;

            data = thetaenv_prcpastmeanbar(:,1);
            binned = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
            binned=cat(1,binned{:}); 

            binned_sdev = arrayfun( @(x) std(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
            binned_sdev=cat(1,binned_sdev{:});

            errorbar(trialnums(xbins),binned,binned_sdev,'linewidth',1.5,'color','k','Marker','o');hold on;
            ylabel('% Theat Env Dist past mbarpos(shoulder 2.5 deg)');xlabel('Trials');
            s = regstats(binned,trialnums(xbins),'linear','tstat');
            pval(9)  = s.tstat.pval(2); % test for non-zero slope of prc tiem spent beyond mean bar theta

         saveas(gcf,[fpath,filesep,fnam],'tif');
         close(h1b);
         
         w_thetaenv.dist {blk}= {thetaenv_dist};
         w_thetaenv.bins {blk}= {thetaenv_bins};
         
         w_thetaenv.prcpastmeanbar{blk}= {horzcat(trialnums,thetaenv_prcpastmeanbar)};
         w_thetaenv.prcpastmeanbarbinned{blk}= {horzcat(trialnums(xbins),binned)};    

         w_thetaenv.pval {blk}={pval};
          w_thetaenv.mean_barpos{blk} = {mean_bartheta};


    
     %%plot thetaenv first and last n trials
         fnam=[str 'Theta_env trials.tif'];
         h1c=figure('Name','Theta Envelope Trials'); 
         set(0,'CurrentFigure',h1b);
         suptitle(['M:' obj{1}.mouseName ' S:' obj{1}.sessionName ' B: ' str ' Trials Early - Late']);
          
         xt = thetaenv_time;
%          subplot(numblocks*2,3,(blk-1)*2+4);
         subplot(numblocks*1,2,(blk-1)*2+1);
         plot(xt,thetaenv_trials(earlyinds(1:2:end),:),'color',[.5 .5 .5],'linewidth',1); hold on; 
         hline(mean_bartheta,'r',['mb ' num2str(mean_bartheta)]);
         avg_thetaenv = nanmean(thetaenv_trials(earlyinds,:));plot(xt,avg_thetaenv,'linewidth',1.5,'color','k');hold off;
         axis([restrictTime(1),restrictTime(2),-30,30]);set(gca,'YGrid','on');
         set(gca,'YTick',-30:10:30);
%          subplot(numblocks*2,3,(blk-1)*2+5); 
         subplot(numblocks*1,2,(blk-1)*2+2);
         plot(xt,thetaenv_trials(lateinds(1:2:end),:),'color',[1 .5 .5],'linewidth',1); hold on;  
          hline(mean_bartheta,'r',['mb ' num2str(mean_bartheta)]);
         avg_thetaenv = nanmean(thetaenv_trials(lateinds,:),1); plot(xt,avg_thetaenv,'linewidth',1.5,'color','r'); grid on;   hold off;
         axis([restrictTime(1),restrictTime(2),-30,30]);set(gca,'YGrid','on');
         set(gca,'YTick',-30:10:30);
         freezeColors;    
 
          saveas(gcf,[fpath,filesep,fnam],'tif');
         close(h1c);
    end           
 
      
        h1b= figure;count =1
        for trl = 1:20: size(thetaenv_dist,1)
               endtrl  = count*20;
               strtrl = endtrl -19;  
            if (trl +20 >  size(thetaenv_dist,1))
                endtrl  =size(thetaenv_dist,1);
            end  
           subplot ( ceil(size(thetaenv_dist,1)/20 ), 1,count);
            set(gcf,'DefaultAxesColorOrder',copper(20));  
           plot(thetaenv_bins(1,:),thetaenv_dist(strtrl:endtrl,:),'linewidth',1.5); grid on;hold on;
           line([thetaenv_meanbarcross(strtrl:endtrl,1)'; thetaenv_meanbarcross(strtrl:endtrl,1)'], [ones(1,endtrl-strtrl+1)*.8; ones(1,endtrl-strtrl+1)*.95],'linewidth',1.5);         

           count = count +1;
        end
        fnam = [ str 'Thetaenv_Dist'];
        saveas(gcf,[fpath,filesep,fnam],'tif');
        close(h1b);
     
% % %         if strcmp(str,'nogo')
% % %            h1c =  figure;
% % %             for p = 1:size(thetaenv_dist,1)
% % %               plot(thetaenv_bins(1,:),thetaenv_dist(p,:),'linewidth',1.5); grid on;hold on;line([thetaenv_meanbarcross(p,1)'; thetaenv_meanbarcross(p,1)'], [ones(1,1)*.05; ones(1,1)*.15],'linewidth',1.5);hold off; title(['Dist of trial' num2str(p) str timewindowtag]);saveas (gcf,[fpath,filesep,'Dist' num2str(p)],'tif');
% % %             end
% % %            close (h1c);
% % %         end
        
    %% plot kappa
 
    fnam=[str 'fkappa.tif'];
    h2=figure('Name','Kappa');
     set(0,'CurrentFigure',h2);
     
    for(blk=1:numblocks)
    
        trialnums = block_trialnums{blk};
        kappa_trials= zeros(length(trialnums),maxframes);
         col=jet(length(trialnums));
        count =1;
        for(i=1:length(trialnums))
            t = trialnums(i);
            frames = length(obj{t}.kappa{1,1});
            if(frames<2500)
                disp(['delete trial' obj{t}.trackerFileName num2str(trialnums(i))]);             
            else
            frameTime = obj{t}.framePeriodInSec;
            xt = [1:frames]*frameTime;
            temp=obj{t}.kappa{1,1};
            baseline = mean(temp(round(0.3/frameTime):round(0.5/frameTime)));
            temp=temp-baseline;
            windowSize = 1;
            filtkappa= filter(ones(1,windowSize)/windowSize,1,temp);  
            subplot(numblocks*2,2,(blk-1)*2+1);
             
%             plot(xt(round(.3/frameTime):round(4/frameTime)),filtkappa(round(.3/frameTime):round(4/frameTime)),'color',col(i,:),'linewidth',1); axis ([.3 4 -.01 0.01]) ;
             plot(xt(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),filtkappa(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),'color',col(i,:),'linewidth',1.5); axis ([restrictTime(1) restrictTime(2) -.01 0.01]) ;
            hold on;
            kappa_trials(count,[1:frames])=filtkappa;
            count=count+1;
            end 
        end
        hold off;

%         colorbar('location','EastOutside');
%         freezeColors;
%          cbfreeze(colorbar);
        xt = [1:maxframes]*frameTime;
       
        subplot(numblocks*2,2,(blk-1)*2+2);     
%         imagesc(xt(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),trialnums,kappa_trials(:,round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)));
        imagesc(xt(round(.3/frameTime):round(4/frameTime)),trialnums,kappa_trials(:,round(.3/frameTime):round(4/frameTime)));
       
        caxis([-.01 0.01]);colormap(fireice);
        colorbar('location','EastOutside');
        title(['M:' obj{1}.mouseName ' S: ' obj{1}.sessionName ' Ttype: ' str ' Bk: ' block_tags{blk}  'Filtered Kappa'  ]);

        freezeColors;
         cbfreeze(colorbar);
   
    end

     saveas(gcf,[fpath,filesep,fnam],'tif');
    close(h2);
    
    
    %% plot fitted whisker
    if(plot_whiskerfits)
        w = waitbar(0,'Plotting fitted whisker'); 
        h3 = figure('Name','fitted whisker','visible','off');
        set(0,'CurrentFigure',h3);
        
        for(blk=1:numblocks)
    
            trialnums = block_trialnums{blk};
            for(i=1:1:length(trialnums))
                t = trialnums(i);            
% %                 fittedX = obj{t}.polyFitsROI{1}{1};
% %                 fittedY = obj{t}.polyFitsROI{1}{2};
% %                 fittedQ = obj{t}.polyFitsROI{1}{3};

                fittedX = obj{t}.polyFits{1}{1};
                fittedY = obj{t}.polyFits{1}{2};
                
                frames = [1: length(fittedX)];
                xt =  frames*frameTime;
                frameInds= find(xt >= restrictTime(1) & xt <= restrictTime(2));      
                cmap=jet(length(frameInds));
                colormap(cmap);
                nframes = length(frameInds);
                x = cell(1,nframes);
                y = cell(1,nframes);

                col=repmat(linspace(0,1,nframes)',1,3);
                col=repmat([1,.1,.1],nframes,1).*col;
%                 col=col(end:-1:1,:);
                barpos = obj{t}.bar_pos_trial;
                barpos(1,2) = point(1,2);
                for k=1:nframes
                    f = frameInds(k);               
                    px = fittedX(f,:);
                    py = fittedY(f,:);
%                     pq = fittedQ(f,:);
%                     q = linspace(pq(1),pq(2));
                    q=linspace(0,1);

                    x{k} = polyval(px,q);
                    y{k} = polyval(py,q);

                    plot(x{k},y{k},'color',col(k,:),'linewidth',1.5); axis ([0 520 0 400]); 
                    hold on;
                end


                p = (0:0.1:2*pi);
                r = 5;
                for(k=1:size(gopix,1))
                    plot(r*sin(p)+gopix(k,1),r*cos(p)+gopix(k,2),'linewidth',2,'color','blue'); 
                    hold on;
                end   
                    plot(r*sin(p)+barpos(1,1),r*cos(p)+barpos(1,2),'linewidth',6,'color','red'); 
                    plot(r*sin(p)+nogopix(1,1),r*cos(p)+nogopix(1,2),'linewidth',2,'color','black'); 

               filename = ['Mouse:' obj{i}.mouseName ' Session: ' obj{i}.sessionName ' Trialtype: ' str ' Block: ' block_tags{blk} obj{t}.trackerFileName];
               title(gca,filename);        
              set(gca,'YDir','reverse');
              hold off;
%               colorbar('location','EastOutside');
              fnam=['w' obj{t}.trackerFileName(30:33) '.tif'];
              saveas(gcf,[fpath,filesep,fnam],'tif');
              msg=sprintf('Plotting %d of %d',i,length(trialnums));
             waitbar(i/(length(trialnums)+1),w,msg);
        %       set(f,'visible','on');

            end
        end
        
     close(w);
    end
end

