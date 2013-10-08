
function[w_thetaenv]...
    =  wdatasummary(obj,block_tags,block_trialnums,avg_trials,gopix,nogopix,restrictTime,p,plot_whiskerfits,str,timewindowtag)
%% new version : compare within block & with top 90% percentile of setpoint values
% w_setpoint_trials % all setpoint values from all trials  entire length
% w_setpoint_early % within the restricted time window from early trials
% w_setpoint_late % within the restricted time window from late trials
% w_setpoint_trials_med % mean of 90th percentile of setpoint values within window
%w_setpoint_trials_width std of the points avgd over

w_thetaenv = struct('trials',[],'binned',[],'pval',[],'binned_dist',[]);


    numblocks = size(block_tags,2);
    windowSize=25;
%% theta

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
%    fpath = [p '/plots/' str];
       fpath = [p '/plots/' timewindowtag '/' str];
   
    fnam=[str obj{1}.mouseName ' S' obj{1}.sessionName 'wdata.tif'];
    h=figure('Name','Thetaenv plot'); 
    set(0,'CurrentFigure',h);
    suptitle(['M:' obj{1}.mouseName ' S:' obj{1}.sessionName ' B: ' str ]);
    w_thetaenv_dist = cell(numblocks,1);
    w_thetaenv_trials = cell(numblocks,1);
    
    for(blk=1:numblocks)
        trialnums = block_trialnums{blk};
        col=jet(length(trialnums));
        bins = -30:1:10;
        nbins=length(bins);

        
         avg_binned =nan(windowSize,(restrictTime(2)-restrictTime(1))*500);
         avg_time = zeros(1,(restrictTime(2)-restrictTime(1))*500);
         avg_time = restrictTime(1)+.002:.002:restrictTime(2);avg_time=round(avg_time.*1000)./1000;
        
        count =0;
        binned_ind =1;
        xbinscount =0;
        
        if( mod(length(trialnums),windowSize) ==1)
            lasttrial = length(trialnums)-1;
        else
            lasttrial = length(trialnums);
        end
        for(i=1:1:lasttrial)
            t = trialnums(i);
            frames = length(obj{t}.theta{1,1});
            if(frames<1500)
                disp(['delete trial' obj{t}.trackerFileName num2str(trialnums(i))])     
                frameTime = obj{t}.framePeriodInSec;
            else
                frameTime = obj{t}.framePeriodInSec;
                xt = obj{t}.time{1};

                theta = obj{t}.theta{1,1};
                setpoint = obj{t}.Setpoint{1,1};
                amp = obj{t}.Amplitude{1,1};
                
                poleinds =  find( (restrictTime(1)< xt) & (xt<=restrictTime(2)) );
                prepoleinds = find( (xt>restrictTime(1)-.2) & (xt<=restrictTime(1)));
                thetaenv = envelope(theta,'linear'); 
                
                valinds = poleinds;
                thetaenv_trials{i} =thetaenv(valinds);
                thetaenv_time{i} = xt(valinds);
                

                if(count+1>windowSize)|| (i==length(trialnums))
                   
                   binned_trials(binned_ind,:) = nanmedian(avg_thetaenv,1);
                   xbins(binned_ind,1)= floor(xbinscount/count);
                   xbinscount = 0;
                    avg_thetaenv = nan(windowSize,(restrictTime(2)-restrictTime(1))*500);
                    count =0*(count+1>windowSize)+(i==length(trialnums))*count;
                    binned_ind = binned_ind+1;
                end
                     count=count+1;
                     current_thetaenv = thetaenv_trials{i};
                     current_xt = thetaenv_time{i}; current_xt = round( current_xt.*1000)./1000;
                    [lia,matchedinds]= ismember( current_xt,avg_time);
                     avg_thetaenv(count,matchedinds>0) =   current_thetaenv;    
                     xbinscount = xbinscount+trialnums(i);
                    
                    
            end
        end
        binned_trialsxt = avg_time;
        windowSize=25;
         subplot(numblocks*3,2,(blk-1)*4+(5),'Parent',h);       
         set(0,'DefaultAxesColorOrder',copper(size(binned_trials,1)));        
         plot(binned_trialsxt,binned_trials, 'linewidth',1); axis( [ restrictTime(1) restrictTime(2) -20 20]);
         xlabel('Time (s)');
         ylabel ('Theta_env avg_25trials');
        data = binned_trials(:,:);
        [dist,x] =hist(data',-20:1:20);
        binned_dist = [dist x];
        
          subplot(numblocks*3,2,(blk-1)*4+(6),'Parent',h);
        plot(binned_dist(:,end),binned_dist(:,1:end-1), 'linewidth',1); 
        set(gca,'XTick',[-20:5:20]);
        xlabel('Theta_env');
         ylabel ('Num');
          legend('Location',  'EastOutside' )       
        
        binned_med = nanmedian(data,2);
        prc=prctile(binned_trials',95);
        mat=(data>repmat(prc',1,size(data,2)));
         binned_thrmed=data;
          binned_thrmed(~mat) = nan;
          
        binned_thrmed = nanmean(binned_thrmed ,2);
        binned_trialsxt = repmat(binned_trialsxt,size(data,1),1);
        binned_trialsxt (~mat) = nan;
        binned_thrdur= nanmax(binned_trialsxt,[],2)-nanmin(binned_trialsxt,[],2);
        binned_kurt = kurtosis(data,0,2);
        

        avg_trials = floor(length(trialnums)/3);
        if(i-1<=avg_trials)
             avg_trials = i-2;
             disp ([ 'there are only' num2str(i-1) ' good trials , reduced trialstoavg to ' num2str(i-2)]);
        end

        earlyinds= [51:51+avg_trials] ;             
        lateinds= [i-1-avg_trials : i-1] ;

        
        
        w_thetaenv_trials(blk) = {thetaenv_trials};  %% only poleinds
        

%%plot thetaenv mean and std       

       subplot(numblocks*3,2,(blk-1)*4+1,'Parent',h);
     
%         errorbar(xbins,binned_med,binned_std,'linewidth',1.5,'color','k','Marker','o');hold on;
        plot(xbins,binned_med,'linewidth',1.5,'color','k','Marker','o','MarkerFaceColor','k');hold on;
        plot(xbins,binned_thrmed,'linewidth',1.5,'color','r','Marker','o','MarkerFaceColor','r');
        xlabel('Trials');
        ylabel ('Theta_env');
%         legend('med','med_thr');
        grid on; axis([min(trialnums),max(trialnums), -30, 30]);
        s = regstats(binned_med,xbins,'linear','tstat');  
        pval(1)  = s.tstat.pval(2); % test for non-zero slope of median
        s = regstats(binned_thrmed,xbins,'linear','tstat');  
        pval(2)  = s.tstat.pval(2); % test for non-zero slope of median        
        
        title(['Thetaenv Med_pval ' num2str(pval(1)),'thrmed_pval' num2str(pval(2)) ]);

        % plotthetaenv_ skewness and kurtosis
          
        subplot(numblocks*3,2,(blk-1)*4+2,'Parent',h);
          [ax,h1,h2] = plotyy(xbins,binned_thrdur,xbins,binned_kurt);
         set(get(ax(1),'ylabel'),'String','Thr_dur');
          set(ax(1),'YTick',[0:.5:2] );
          axes(ax(1));axis([min(trialnums),max(trialnums), 0, 2]);%,
         set(h1,'color',[.0 .0 .8],'Marker','o','MarkerFaceColor',[.0 .0 .8]);
         set(h2,'color',[.2 .5 .0],'Marker','o','MarkerFaceColor',[.2 .5 .0]);
         hold on;
         set(get(ax(2),'ylabel'),'String','kurt');
          set(ax(2),'YTick',[0:2:16] );
%         plot(xbins,binned_thrdur,'color',[.0 .0 .8],'Marker','o','MarkerFaceColor',[.0 .0 .8]);hold on;
%          plot(xbins,binned_kurt,'color',[.2 .5 .0],'Marker','o','MarkerFaceColor',[.2 .5 .0]);

         axes(ax(2));axis([min(trialnums),max(trialnums), 0, 16]);
        xlabel('Trials');
       
        
%         legend('thr_dur');
        s = regstats(binned_thrdur,xbins,'linear','tstat');
        pval(3)  = s.tstat.pval(2); % test for non-zero slope of skew
        
        s = regstats(binned_kurt,xbins,'linear','tstat');
        pval(4)  = s.tstat.pval(2); % test for non-zero slope of skew
        title(['Thetaenv thrdur pval ' num2str(pval(3)) 'kurt pval ' num2str(pval(4)) ]);



        
        
         w_thetaenv_binned(blk) = {horzcat(xbins,binned_med,binned_thrmed,binned_thrdur,binned_kurt)}; %%median binned withi n restricted time window
            w_thetaenv_binned_dist(blk) = {binned_dist};
         w_thetaenv_pval(blk) = {pval(1,:)};
       
%%plot thetaenv first and last n trials
         subplot(numblocks*3,2,(blk-1)*4+3,'Parent',h);
         avg_thetaenv =nan(length(earlyinds),(restrictTime(2)-restrictTime(1))*500);
         avg_time = zeros(1,(restrictTime(2)-restrictTime(1))*500);
         avg_time = restrictTime(1)+.002:.002:restrictTime(2);avg_time=round(avg_time.*1000)./1000;
         for j = 1: length(earlyinds)
             i=earlyinds(j);
             current_thetaenv = thetaenv_trials{i};
             xt = thetaenv_time{i};xt = round(xt.*1000)./1000;
             [lia,matchedinds]= ismember(xt,avg_time);
             avg_thetaenv(j,matchedinds>0) =   current_thetaenv;

             plot(xt,current_thetaenv,'color',[.5 .5 .5],'linewidth',.5); hold on;           
         end
           avg_thetaenv =nanmedian(avg_thetaenv,1);

         plot(avg_time,avg_thetaenv,'linewidth',1.5,'color','k'); grid on; hold on;
         hold off;
         axis([restrictTime(1),restrictTime(2),-30,30]);set(gca,'YGrid','on');
         set(gca,'YTick',-30:10:30);
         freezeColors;    
         xlabel('Time');
         ylabel ('Theta_env First-third trials');
         
         
         avg_thetaenv = nan(length(lateinds),(restrictTime(2)-restrictTime(1))*500);
         subplot(numblocks*3,2,(blk-1)*4+4 ,'Parent',h);
         for j = 1:length(lateinds)
             i=lateinds(j);
              current_thetaenv = thetaenv_trials{i};
            xt = thetaenv_time{i};xt = round(xt.*1000)./1000;
            [lia,matchedinds]= ismember(xt,avg_time);
            avg_thetaenv(j,matchedinds>0) =  current_thetaenv;
             plot(xt,current_thetaenv,'color',[1 .5 .5],'linewidth',.5); hold on;                    
         end
         

         avg_thetaenv =nanmedian(avg_thetaenv,1);
         plot(avg_time,avg_thetaenv,'linewidth',1.5,'color','r'); grid on; 
         hold off;
         axis([restrictTime(1),restrictTime(2),-30,30]);set(gca,'YGrid','on');
         set(gca,'YTick',-30:10:30);
         freezeColors;    
         xlabel('Time');
         ylabel ('Theta_env Last-third trials');
    end           
        saveas(gcf,[fpath,filesep,fnam],'tif');
        close(h);
        
        
        
        w_thetaenv.trials = w_thetaenv_trials;         

        w_thetaenv.binned_dist= w_thetaenv_binned_dist;

         w_thetaenv.binned = w_thetaenv_binned;

        w_thetaenv.pval =w_thetaenv_pval;
   if(plot_whiskerfits) 
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
            subplot(numblocks*3,2,(blk-1)*2+1);
             
             plot(xt(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),filtkappa(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),'color',col(i,:),'linewidth',1.5); axis ([restrictTime(1) restrictTime(2) -.01 0.01]) ;
            hold on;
            kappa_trials(count,[1:frames])=filtkappa;
            count=count+1;
            end 
        end
        hold off;


        xt = [1:maxframes]*frameTime;
       
        subplot(numblocks*2,2,(blk-1)*2+2);     
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
   
        w = waitbar(0,'Plotting fitted whisker'); 
        h3 = figure('Name','fitted whisker','visible','off');
        set(0,'CurrentFigure',h3);
        
        for(blk=1:numblocks)
    
            trialnums = block_trialnums{blk};
            for(i=1:1:length(trialnums))
                t = trialnums(i);            


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

                barpos = obj{t}.bar_pos_trial;
                barpos(1,2) = point(1,2);
                for k=1:nframes
                    f = frameInds(k);               
                    px = fittedX(f,:);
                    py = fittedY(f,:);

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

              fnam=['w' obj{t}.trackerFileName(30:33) '.tif'];
              saveas(gcf,[fpath,filesep,fnam],'tif');
              msg=sprintf('Plotting %d of %d',i,length(trialnums));
             waitbar(i/(length(trialnums)+1),w,msg);


            end
        end
        
     close(w);
    end
end

