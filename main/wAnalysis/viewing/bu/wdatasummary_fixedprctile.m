
function[w_thetaenv]...
    =  wdatasummary(sessionInfo,obj,block_tags,block_trialnums,avg_trials,gopix,nogopix,restrictTime,p,plot_whiskerfits,str,timewindowtag)
%% new version : compare within block & with top 90% percentile of setpoint values
% w_setpoint_trials % all setpoint values from all trials  entire length
% w_setpoint_early % within the restricted time window from early trials
% w_setpoint_late % within the restricted time window from late trials
% w_setpoint_trials_med % mean of 90th percentile of setpoint values within window
% w_setpoint_trials_width std of the points avgd over

    w_thetaenv = struct('trials',[],'time',[],'dist',[],'bins',[],'med',[],'medbinned',[],'meanbarcros',[],'peakbinned',[],'prepole',[],'prepolebinned',[],'pval',[]);
    numblocks = size(block_tags,2);
    
%% get mean bar theta cut off
     x = sessionInfo.gopos;
     y  = sessionInfo.go_bartheta;
     p=polyfit(x,y,1);
     mean_bartheta = polyval(p,median(sessionInfo.goPosition_mean));
    
%% plot theta
    point = max(gopix);
    gopix(:,2) = point(1,2);
    nogopix(1,2) = point(1,2);

      
    frames_list=arrayfun(@(x) size(x{:}.time{1},2), obj,'uniformoutput',false);
    maxframes = max(cell2mat(frames_list));
   numpoleframes = (restrictTime(2)-restrictTime(1))*500;

    if~(exist([p '/plots/'],'dir'))
       mkdir (p,'plots') ;
    end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
    
    fpath = [p '/plots/'];
    if ~(exist([fpath timewindowtag],'dir'))
       mkdir (fpath,timewindowtag) ;
    end
    
    fpath = [p '/plots/' timewindowtag '/'];
    if ~(exist([fpath str],'dir'))
       mkdir (fpath,str) ;
    end

       fpath = [p '/plots/' timewindowtag '/' str];
   
    fnam=[str 'thetaEnv.tif'];
    h1=figure('Name','Set point plot'); 
    set(0,'CurrentFigure',h1);
    suptitle(['M:' obj{1}.mouseName ' S:' obj{1}.sessionName ' B: ' str ]);

    
    for(blk=1:numblocks)
        trialnums = block_trialnums{blk};
         col=jet(length(trialnums));  
        thetaenv_bins = -50:1:50;
        nbins=length(thetaenv_bins);
        thetaenv_dist = nan(length(trialnums),nbins);
        thetaenv_trials = nan(length(trialnums)+1,numpoleframes);

        thetaenv_med = nan(length(trialnums),1);
        thetaenv_peak = nan(length(trialnums),1);
        thetaenv_prepole = nan(length(trialnums),1);    
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
                   
                    thetaenv_dist(i,:) = hist(thetaenv_pole,thetaenv_bins)./length(thetaenv_pole);
                    thetaenv_med(i,1) = median(thetaenv_pole);
                    thetaenv_med(i,2) =  std(thetaenv_pole);

                    thetaenv_peak(i,1) = prctile(thetaenv_pole,85); %% change it to prctile later
                 
                    temp = thetaenv(prepoleinds);
                    thetaenv_prepole(i,1) = mean(temp);

            end
        end

        hold off;
        avg_trials = floor(length(trialnums)/3);
        if(i-1<=avg_trials)
             avg_trials = i-2;
             disp ([ 'there are only' num2str(i-1) ' good trials , reduced trialstoavg to ' num2str(i-2)]);
        end

        earlyinds= [50:50+avg_trials] ;             
        lateinds= [i-1-avg_trials : i-1] ;

        

%%plot thetaenv _med,peak,prepole  

       subplot(numblocks*2,3,(blk-1)*2+1);
       up = thetaenv_med(:,1)+thetaenv_med(:,2);
       low=thetaenv_med(:,1)-thetaenv_med(:,2);
       jbfill(trialnums',up',low',[.8 .8 .8],[.8 .8 .8],1,.5);hold on;
        plot(trialnums,thetaenv_med(:,1),'linewidth',1); hold on;
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
        errorbar(trialnums(xbins),binned,binned_sdev,'linewidth',1.5,'color','k','Marker','o');hold on;
        grid on; 
        s = regstats(binned,trialnums(xbins),'linear','tstat');
        pval(1)  = s.tstat.pval(2); % test for non-zero slope of med
        s = regstats(binned_sdev,trialnums(xbins),'linear','tstat');
        pval(2) = s.tstat.pval(2);

         w_thetaenv.med{blk} = {horzcat(trialnums,thetaenv_med(:,1),thetaenv_med(:,2))}; %%median for restricted time window
         w_thetaenv.medbinned{blk} = {horzcat(trialnums(xbins),binned,binned_sdev)}; %%median binned withi n restricted time window

         
        data = thetaenv_prepole(:,1);
        binned = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
        binned=cat(1,binned{:}); 
       plot(trialnums(xbins),binned,'color','b','linewidth',1,'Marker','o');  grid on;      
        s = regstats(binned,trialnums(xbins),'linear','tstat');
        pval(3)  = s.tstat.pval(2); % test for non-zero slope of prepole


         w_thetaenv.prepole{blk}= {horzcat(trialnums,thetaenv_prepole)};
         w_thetaenv.prepolebinned{blk}= {horzcat(trialnums(xbins),binned)};
         
          data = thetaenv_peak(:,1);
        binned = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
        binned=cat(1,binned{:}); 
       plot(trialnums(xbins),binned,'color','r','linewidth',1,'Marker','o');  grid on;       
         axis([min(trialnums) max(trialnums) -30 30]);
         s = regstats(binned,trialnums(xbins),'linear','tstat');
        pval(4)  = s.tstat.pval(2); % test for non-zero slope of prepol
         text(.5,.02,'Thetaenv Med stdev,  Prepole ,Peak,(K.B.R) ','VerticalAlignment','bottom','HorizontalAlignment','center');
         %['Theta envelope pval ' num2str(pvalsetpoint)
           w_thetaenv.peak{blk}= {horzcat(trialnums,thetaenv_peak)};
         w_thetaenv.peakbinned{blk}= {horzcat(trialnums(xbins),binned)};    
         w_thetaenv.pval {blk}={pval};
         
         w_thetaenv.trials{blk} = {thetaenv_trials};
         w_thetaenv.time {blk}= {thetaenv_time};
         w_thetaenv.dist {blk}= {thetaenv_dist};
         w_thetaenv.bins {blk}= {thetaenv_bins};
         
%%plot dist   

        subplot(numblocks*2,3,(blk-1)*2+2);
        set(gcf,'DefaultAxesColorOrder',copper(size(thetaenv_dist,1)));  
         plot(thetaenv_bins',thetaenv_dist','linewidth',0.25);hold on; grid on; 
         
          set(gcf,'DefaultAxesColorOrder',jet(size(thetaenv_peak,1)));
         line([thetaenv_peak'; thetaenv_peak'], [ones(1,length(thetaenv_peak))*.9; ones(1,length(thetaenv_peak))*.95],'linewidth',1);         
        line([thetaenv_med(:,1)'; thetaenv_med(:,1)'], [ones(1,length(thetaenv_med(:,1)))*.8; ones(1,length(thetaenv_med(:,1)))*.85],'linewidth',1);
        axis ([-50 50 0 1]);grid on;
        text(.5,.02,'Thetaenv_dist ','VerticalAlignment','bottom','HorizontalAlignment','center');

        subplot(numblocks*2,3,(blk-1)*2+3);
        temp= [thetaenv_med(:,1) thetaenv_peak(:,1) ];
        set(gcf,'DefaultAxesColorOrder',copper(size(temp,1)));  
        plot(temp','linewidth',1); axis ([0 3 -50 50]);
        
         
    
     %%plot thetaenv first and last n trials
          
         xt = thetaenv_time;
         subplot(numblocks*2,3,(blk-1)*2+4);plot(xt,thetaenv_trials(earlyinds(1:2:end),:),'color',[.5 .5 .5],'linewidth',1); hold on; 
         avg_thetaenv = nanmean(thetaenv_trials(earlyinds,:));plot(xt,avg_thetaenv,'linewidth',1.5,'color','k');hold off;
         axis([restrictTime(1),restrictTime(2),-30,30]);set(gca,'YGrid','on');
         set(gca,'YTick',-30:10:30);
         subplot(numblocks*2,3,(blk-1)*2+5); plot(xt,thetaenv_trials(lateinds(1:2:end),:),'color',[1 .5 .5],'linewidth',1); hold on;   
         avg_thetaenv = nanmean(thetaenv_trials(lateinds,:),1); plot(xt,avg_thetaenv,'linewidth',1.5,'color','r'); grid on;   hold off;
         axis([restrictTime(1),restrictTime(2),-30,30]);set(gca,'YGrid','on');
         set(gca,'YTick',-30:10:30);
         freezeColors;    
 
    end           
        saveas(gcf,[fpath,filesep,fnam],'tif');
        close(h1);
      
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
           line([thetaenv_peak(strtrl:endtrl,1)'; thetaenv_peak(strtrl:endtrl,1)'], [ones(1,endtrl-strtrl+1)*.8; ones(1,endtrl-strtrl+1)*.95],'linewidth',1.5);         

           count = count +1;
        end
        fnam = [ str 'Thetaenv_Dist'];
        saveas(gcf,[fpath,filesep,fnam],'tif');
        close(h1b);
     
        if strcmp(str,'nogo')
            figure;
            for p = 1:size(thetaenv_dist,1)
              plot(thetaenv_bins(1,:),thetaenv_dist(p,:),'linewidth',1.5); grid on;hold on;line([thetaenv_peak(p,1)'; thetaenv_peak(p,1)'], [ones(1,1)*.05; ones(1,1)*.15],'linewidth',1.5);hold off; title(['Dist of trial' num2str(p) str timewindowtag]);saveas (gcf,[fpath,filesep,'Dist' num2str(p)],'tif');
            end
        end
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

