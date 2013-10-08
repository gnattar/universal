
function[w_setpoint_trials,w_setpoint_trials_med, w_setpoint_trials_medbinned,w_setpoint_trials_width,w_setpoint_trials_dur,w_setpoint_trials_prewhisk, w_setpoint_trials_prepolebinned,pvalsetpoint...
    w_amp_trials,w_thetaenv_trials,w_thetaenv_dist,w_amp_trials_med,w_amp_trials_medbinned,w_amp_trials_width,pvalamp]...
    =  wdatasummary(obj,block_tags,block_trialnums,avg_trials,gopix,nogopix,restrictTime,p,plot_whiskerfits,str,timewindowtag)
%% new version : compare within block & with top 90% percentile of setpoint values
% w_setpoint_trials % all setpoint values from all trials  entire length
% w_setpoint_early % within the restricted time window from early trials
% w_setpoint_late % within the restricted time window from late trials
% w_setpoint_trials_med % mean of 90th percentile of setpoint values within window
%w_setpoint_trials_width std of the points avgd over

w_setpoint = struct('trials',[],'med',[],'width',[],'binned',[],'prepole',[],'prepolebinned',[],'pval',[],'dist',[]);
w_amp = struct('trials',[],'med',[],'width',[],'binned',[],'prepole',[],'prepolebinned',[],'pval',[],'dist',[]);
w_thetaenv = struct('trials',[],'med',[],'width',[],'binned',[],'prepole',[],'prepolebinned',[],'pval',[],'dist',[],'dur',[]);


    numblocks = size(block_tags,2);
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
   
    fnam=[str 'ftheta.tif'];
    h1=figure('Name','Set point plot'); 
    set(0,'CurrentFigure',h1);
    spbins = [-40:2:40];
    ampbins =[-5:2:50];

    w_setpoint_trials = cell(numblocks,1);
    w_setpoint_trials_hist = cell(numblocks,1);
    w_thetaenv_dist = cell(numblocks,1);
    w_thetaenv_trials = cell(numblocks,1);
    
    for(blk=1:numblocks)
        trialnums = block_trialnums{blk};
        col=jet(length(trialnums));
        setpoint_trials= zeros(length(trialnums),numpoleframes);              
        setpoint_trials_med=zeros(length(trialnums),1);
        setpoint_trials_width=zeros(length(trialnums),1); %std
        setpoint_trials_prepole= zeros(length(trialnums),1);

        amp_trials=zeros(length(trialnums),numpoleframes);
        amp_trials_dur= zeros(length(trialnums),1);
        amp_trials_med=zeros(length(trialnums),1);
        amp_trials_width=zeros(length(trialnums),1); % std
       
        thetaenv_trials= zeros(length(trialnums),numpoleframes);              
        thetaenv_trials_med=zeros(length(trialnums),1);
        thetaenv_trials_width=zeros(length(trialnums),1); %std
        thetaenv_trials_prepole= zeros(length(trialnums),1);
        thetaenv_trials_dur= zeros(length(trialnums),1);
        
        bins = -30:1:10;
        nbins=length(bins);
        thetaenv_dist = zeros(length(trialnums),nbins);
        thetaenv_trials = zeros(length(trialnums),numpoleframes);
 
        count =1;
        for(i=1:1:length(trialnums))
            t = trialnums(i);
            frames = length(obj{t}.theta{1,1});
            if(frames<1500)
                disp(['delete trial' obj{t}.trackerFileName num2str(trialnums(i))])     
                frameTime = obj{t}.framePeriodInSec;
            else
                frameTime = obj{t}.framePeriodInSec;
                xt = [1:frames]*frameTime;

                    setpoint = obj{t}.Setpoint{1,1};
                    amp     = obj{t}.Amplitude{1,1};
                    theta = obj{t}.theta{1,1};
                    thetaenv = envelope(theta,'linear');                


                     temp = thetaenv(round(restrictTime(1)/frameTime)+1:round(restrictTime(2)/frameTime)); 
                     thetaenv_trials(count,:) = temp;
                     thetaenv_dist(count,:) = hist(temp,nbins);
                      

                    temp = setpoint(round(restrictTime(1)/frameTime)-150+1:round(restrictTime(1)/frameTime)-50); %100points prepole
                    setpoint_trials_prepole(count,1) = mean(temp);
                    temp = amp(round(restrictTime(1)/frameTime)+1:round(restrictTime(2)/frameTime));
                    time = xt(round(restrictTime(1)/frameTime)+1:round(restrictTime(2)/frameTime));
                    points=prctile(temp,[90,100]);
                    ind=find(points(1)<temp & temp<points(2));
                    amp_trials(count,:)=temp;
                    

                     ampvals = temp(ind);
                     amp_trials_med(count,1)=mean(ampvals);
                     amp_trials_width(count,1) = sqrt(mean(ampvals.^2)-amp_trials_med(count,1).^2);
                     temp = setpoint(round(restrictTime(1)/frameTime)+1:round(restrictTime(2)/frameTime));    
                     setpoint_trials(count,:)=temp;

                    setpointvals=temp(ind);
                    timevals = time(ind);
                    setpoint_trials_med(count,1)=mean(setpointvals); 
                    setpoint_trials_width(count,1) = sqrt(mean(setpointvals.^2)-setpoint_trials_med(count,1).^2);
                    setpoint_trials_dur(count,1)=max(timevals)-min(timevals);                 
                    
                    
                    thetaenv_trials_med(count,1)=mean(setpointvals); 
                    thetaenv_trials_width(count,1) = sqrt(mean(setpointvals.^2)-setpoint_trials_med(count,1).^2);
                    thetaenv_trials_dur(count,1)=max(timevals)-min(timevals);    
                    
                    count=count+1;
            end
        end

        hold off;
        avg_trials = floor(length(trialnums)/3);
        if(count-1<=avg_trials)
             avg_trials = count-2;
             disp ([ 'there are only' num2str(count-1) ' good trials , reduced trialstoavg to ' num2str(count-2)]);
        end

        earlyinds= [50:50+avg_trials] ;             
        lateinds= [count-1-avg_trials : count-1] ;

        
        
        w_setpoint_trials(blk) = {setpoint_trials};  %%entire length
        

%%plot setpoint averages       

       subplot(numblocks*2,3,(blk-1)*3+1);
       up = setpoint_trials_med(:,1)+setpoint_trials_width(:,1);
       low=setpoint_trials_med(:,1)-setpoint_trials_width(:,1);
       jbfill(trialnums',up',low',[.8 .8 .8],[.8 .8 .8],1,.5);hold on;

        plot(trialnums,setpoint_trials_med(:,1),'linewidth',1); hold on;
        windowSize=25;
        grid on;

        data =setpoint_trials_med(:,1);
        binned = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
        binned=cat(1,binned{:});
        data =setpoint_trials_width(:,1);
        binned_sdev = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
        binned_sdev=cat(1,binned_sdev{:});
        xbins = arrayfun( @(x) mean(x:min(x+windowSize-1,size(data,1))), 1:windowSize:size(data,1), 'UniformOutput', false);
        xbins=floor(cat(1,xbins{:}));         
        errorbar(trialnums(xbins),binned,binned_sdev,'linewidth',1.5,'color','k','Marker','o');hold on;
        grid on; 
        s = regstats(binned,trialnums(xbins),'linear','tstat');
        pvalsetpoint  = s.tstat.pval(2); % test for non-zero slope of setpoint
        title(['M:' obj{1}.mouseName ' S: ' obj{1}.sessionName ' Ttype: ' str 'Setpoint pval ' num2str(pvalsetpoint) ]);

         w_setpoint_trials_med(blk) = {horzcat(trialnums,setpoint_trials_med)}; %%median for restricted time window
         w_setpoint_trials_medbinned(blk) = {horzcat(trialnums(xbins),binned)}; %%median binned withi n restricted time window
         w_setpoint_trials_width(blk) = {setpoint_trials_width};
         
        data = setpoint_trials_prepole(:,1);
        binned = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
        binned=cat(1,binned{:}); 

       plot(trialnums(xbins),binned,'color','r','linewidth',1,'Marker','o');  grid on;      
        axis([min(trialnums) max(trialnums) -30 30]);
         w_setpoint_trials_dur(blk)= {setpoint_trials_dur};
         w_setpoint_trials_prepole(blk)= {horzcat(trialnums,setpoint_trials_prepole)};
         w_setpoint_trials_prepolebinned(blk)= {horzcat(trialnums(xbins),binned)};
         

%%plot amp      

        subplot(numblocks*2,3,(blk-1)*3+2);
        up = amp_trials_med(:,1)+amp_trials_width(:,1);
        low=amp_trials_med(:,1)-amp_trials_width(:,1);
         jbfill(trialnums',up',low',[.8 .8 .8],[.8 .8 .8],1,.5);hold on;
        plot(trialnums,amp_trials_med(:,1),'linewidth',1.5);hold on; grid on; title('Whisking Amplitude');
         
        windowSize=25;

        data = amp_trials_med(:,1);
        binned = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
        binned=cat(1,binned{:});  
        data =amp_trials_width(:,1);
        binned_sdev = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
        binned_sdev=cat(1,binned_sdev{:});
%        plot(trialnums(xbins),binned,'linewidth',1.5,'color','k','Marker','o'); grid on;
        errorbar(trialnums(xbins),binned,binned_sdev,'linewidth',1.5,'color','k','Marker','o'); grid on;
       axis([min(trialnums) max(trialnums) 0 30]);
         s = regstats(binned,trialnums(xbins),'linear','tstat');
         pvalamp  = s.tstat.pval(2); % test for non-zero slope of amp
        title(['Whisking Amplitude pval ' num2str(pvalamp) ]);       
        
         w_amp_trials(blk) = {amp_trials};  %%entire length
         w_amp_trials_med(blk) = {horzcat(trialnums,amp_trials_med)}; %%median for restricted time window
          w_amp_trials_medbinned(blk) = {horzcat(trialnums(xbins),binned)}; 
         w_amp_trials_width(blk) = {amp_trials_width};


          % plotthetaenv_dist over trials
          
        subplot(numblocks*2,3,(blk-1)*3+3);
        imagesc([1:length(trialnums)],bins,thetaenv_dist');
         caxis([0 600]);colormap(jet);


          
%%plot setpoint first and last n trials
         avg_setpoint = mean(setpoint_trials(earlyinds,:),1); 

         xt = [restrictTime(1)+frameTime:frameTime:restrictTime(2)];
         subplot(numblocks*2,3,(numblocks+blk-1)*3+1);plot(xt,setpoint_trials(earlyinds(1:2:end),:),'color',[.5 .5 .5],'linewidth',1); hold on;           
         plot(xt,setpoint_trials(lateinds(1:2:end),:),'color',[1 .5 .5],'linewidth',1); hold on;
         plot(xt,avg_setpoint,'linewidth',1.5,'color','k');hold on; grid on;
         avg_setpoint = mean(setpoint_trials(lateinds,:),1);
         plot(xt,avg_setpoint,'linewidth',1.5,'color','r'); grid on;
         hold off;
         axis([restrictTime(1),restrictTime(2),-30,30]);set(gca,'YGrid','on');
         set(gca,'YTick',-30:10:30);
         freezeColors;


         
  %%plot amp first and last n trials
          avg_amp = mean(amp_trials(earlyinds,:),1); 
         xt = [restrictTime(1)+frameTime:frameTime:restrictTime(2)];
         subplot(numblocks*2,3,(numblocks+blk-1)*3+2);plot(xt,amp_trials(earlyinds(1:2:end),:),'color',[.5 .5 .5],'linewidth',1); hold on;           
         plot(xt,amp_trials(lateinds(1:2:end),:),'color',[1 .5 .5],'linewidth',1); hold on;   
         plot(xt,avg_amp,'linewidth',1.5,'color','k');hold on;
         avg_amp = mean(amp_trials(lateinds,:),1);
         plot(xt,avg_amp,'linewidth',1.5,'color','r'); grid on;
         hold off;
         axis([restrictTime(1),restrictTime(2),0,40]);set(gca,'YGrid','on');
         set(gca,'YTick',-30:10:30);
         freezeColors;
         
         
     %%plot thetaenv first and last n trials
          avg_thetaenv = mean(thetaenv_trials(earlyinds,:),1); 
         xt = [restrictTime(1)+frameTime:frameTime:restrictTime(2)];
         subplot(numblocks*2,3,(numblocks+blk-1)*3+3);plot(xt,thetaenv_trials(earlyinds(1:2:end),:),'color',[.5 .5 .5],'linewidth',1); hold on;           
         plot(xt,thetaenv_trials(lateinds(1:2:end),:),'color',[1 .5 .5],'linewidth',1); hold on;   
         plot(xt,avg_thetaenv,'linewidth',1.5,'color','k');hold on;
         avg_thetaenv = mean(thetaenv_trials(lateinds,:),1);
         plot(xt,avg_thetaenv,'linewidth',1.5,'color','r'); grid on;
         hold off;
         axis([restrictTime(1),restrictTime(2),-30,30]);set(gca,'YGrid','on');
         set(gca,'YTick',-30:10:30);
         freezeColors;    
 
    end           
        saveas(gcf,[fpath,filesep,fnam],'tif');
        close(h1);
        
        
        
        w_thetaenv.trials = thetaenv_trials;         
        w_thetaenv.med= thetaenv_trials_med;
        w_thetaenv.= thetaenv_trials_med;
       w_thetaenv.width= thetaenv_trials_width;
       w_thetaenv.prepole= thetaenv_trials_prepole;
       w_thetaenv.prepolebinned= thetaenv_trials_prepolebinned;
        w_thetaenv.dur = thetaenv_trials_dur;
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
      
 
        
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
            subplot(numblocks*2,2,(blk-1)*2+1);
             
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

