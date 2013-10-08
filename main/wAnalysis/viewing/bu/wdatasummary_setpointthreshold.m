
function[w_setpoint_trials,w_setpoint_early,w_setpoint_late,w_setpoint_trials_med, w_setpoint_trials_medbinned,w_setpoint_trials_width,w_setpoint_trials_dur,w_setpoint_trials_prewhisk, w_setpoint_trials_prewhiskbinned,pvalsetpoint...
    w_amp_trials,w_amp_early,w_amp_late,w_amp_trials_med,w_amp_trials_medbinned,w_amp_trials_width,pvalamp]...
    =  wdatasummary(obj,block_tags,block_trialnums,avg_trials,gopix,nogopix,restrictTime,p,plot_whiskerfits,str,timewindowtag)
%% new version : compare within block & with top 90% percentile of setpoint values
% w_setpoint_trials % all setpoint values from all trials  entire length
% w_setpoint_early % within the restricted time window from early trials
% w_setpoint_late % within the restricted time window from late trials
% w_setpoint_trials_med % mean of 90th percentile of setpoint values within window
%w_setpoint_trials_width std of the points avgd over

    numblocks = size(block_tags,2);
%% plot theta

    point = max(gopix);
    gopix(:,2) = point(1,2);
    nogopix(1,2) = point(1,2);

      
    frames_list=arrayfun(@(x) size(x{:}.time{1},2), obj,'uniformoutput',false);
    maxframes = max(cell2mat(frames_list));

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
    w_setpoint_early= cell(numblocks,1);
    w_setpoint_late= cell(numblocks,1);
    w_setpoint_trials = cell(numblocks,1);
    w_setpoint_trials_hist = cell(numblocks,1);
    
    
    for(blk=1:numblocks)
        trialnums = block_trialnums{blk};
         col=jet(length(trialnums));
        setpoint_trials= zeros(length(trialnums),maxframes);        
        setpoint_trials_dur= zeros(length(trialnums),1);
        setpoint_trials_med=zeros(length(trialnums),1);

        setpoint_trials_width=zeros(length(trialnums),1); %std
        setpoint_trials_prewhisk= zeros(length(trialnums),1);

        amp_trials=zeros(length(trialnums),maxframes);
        amp_trials_dur= zeros(length(trialnums),1);
        amp_trials_med=zeros(length(trialnums),1);

        amp_trials_width=zeros(length(trialnums),1); % std
 
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

% %                 clean_theta=obj{t}.theta{1,1};
% % 
% %                 sampleRate=1/frameTime;
% %                 BandPassCutOffsInHz = [6 60];  %%check filter parameters!!!
% %                 W1 = BandPassCutOffsInHz(1) / (sampleRate/2);
% %                 W2 = BandPassCutOffsInHz(2) / (sampleRate/2);
% %                 [b,a]=butter(2,[W1 W2]);
% %                 filteredSignal = filtfilt(b, a, clean_theta);
% % 
% %                 [b,a]=butter(2, 6/ (sampleRate/2),'low');
% %                 setpoint = filtfilt(b,a,clean_theta-filteredSignal);
% % 
% %                 hh=hilbert(filteredSignal);
% %                 amp=abs(hh);



                    setpoint = obj{t}.Setpoint{1,1};
                    amp     = obj{t}.Amplitude{1,1};





%%plot setpoint
%                 if((max(setpoint(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime))<30))&&(min(setpoint(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime))>-30)) )

                        temp = setpoint(round(restrictTime(1)/frameTime)-150:round(restrictTime(1)/frameTime)-50); %100points prewhisk
                        setpoint_trials_prewhisk(count,1) = mean(temp);

% % %                         subplot(numblocks*2,4,(blk-1)*4+1); plot(xt(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),setpoint(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),'color',col(i,:),'linewidth',1); axis ([restrictTime(1) restrictTime(2) -30 30]) ;
% % %                         set(gca,'YTick',-30:10:30);set(gca,'YGrid','on');
% % %                         hold on;
                        
                        
                        setpoint_trials(count,[1:frames])=setpoint;
                        amp_trials(count,[1:frames])=amp;
                        
 
                        temp = setpoint(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime));
                        time = xt(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime));
                        points=prctile(temp,[76,100]);
                        ind=find(points(1)<temp & temp<points(2));
                        setpointvals=temp(ind);
                        timevals = time(ind);
                        setpoint_trials_med(count,1)=mean(setpointvals); 
                        setpoint_trials_width(count,1) = sqrt(mean(setpointvals.^2)-setpoint_trials_med(count,1).^2);
                        setpoint_trials_dur(count,1)=max(timevals)-min(timevals);
  
                        
                        %%plot amp                        
% % %                         subplot(numblocks*2,4,(blk-1)*4+3); plot(xt(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),amp(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),'color',col(i,:),'linewidth',1); axis ([restrictTime(1) restrictTime(2) -5 25]) ;
% % %                         set(gca,'YTick',-5:10:50);set(gca,'YGrid','on');
% % %                         hold on;                                               
                        temp = amp(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime));
                          ampvals = temp(ind);
%                         ampvals = temp;
%                         amphist = hist(temp,ampbins);
%                         peak=find(amphist==max(amphist));
%                         amp_trials_med(count,1)=range(ampvals);
                          amp_trials_med(count,1)=median(ampvals);

                          amp_trials_width(count,1) = sqrt(mean(ampvals.^2)-amp_trials_med(count,1).^2);
%                         amp_trials_width(count,2) = min(ampvals);
%                         amp_trials_width(count,2) = max(ampvals);
                        count=count+1;
%                 else
%                      disp(['too huge theta deviations' obj{t}.trackerFileName num2str(trialnums(i))])    
%                 end
            end
        end

        hold off;
%         colorbar('location','EastOutside');
%         freezeColors;
%         cbfreeze(colorbar);
%%plot setpoint as image        
% % %          xt = [1:maxframes]*frameTime;
% % %         subplot(numblocks*2,3,(b-1)*3+2);imagesc(xt(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),trialnums,setpoint_trials(:,round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)));caxis([-30 30]);colormap(fireice);
% % %         colorbar('location','EastOutside');
% % %         freezeColors;
% % %          cbfreeze(colorbar);


        avg_trials = floor(length(trialnums)/3);
        if(count-1<=avg_trials)
             avg_trials = count-2;
             disp ([ 'there are only' num2str(count-1) ' good trials , reduced trialstoavg to ' num2str(count-2)]);
        end

        earlyinds= [50:50+avg_trials] ;             
        lateinds= [count-1-avg_trials : count-1] ;

        
        
        w_setpoint_trials(blk) = {setpoint_trials};  %%entire length
        

%%plot setpoint averages       
%         subplot(numblocks*2,4,(blk-1)*4+2);
       subplot(numblocks*2,2,(blk-1)*2+1);
       up = setpoint_trials_med(:,1)+setpoint_trials_width(:,1);
       low=setpoint_trials_med(:,1)-setpoint_trials_width(:,1);
         jbfill(trialnums',up',low',[0 .8 .8],[0 .8 .8],1,.5);hold on;
%         jbfill(trialnums,up,low,[0 .8 .8],[0 .8 .8],1,.5);hold on;
        plot(trialnums,setpoint_trials_med(:,1),'linewidth',1.5); hold on;
        windowSize=25;
%        smoothed=filter(ones(1,windowSize)/windowSize,1,setpoint_trials_med(:,1));
        data =setpoint_trials_med(:,1);
        binned = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
         binned=cat(1,binned{:});
        xbins = arrayfun( @(x) mean(x:min(x+windowSize-1,size(data,1))), 1:windowSize:size(data,1), 'UniformOutput', false);
        xbins=floor(cat(1,xbins{:}));         
       plot(trialnums(xbins),binned,'linewidth',1.5,'color','k','Marker','o');hold on;
       


         w_setpoint_trials_med(blk) = {horzcat(trialnums,setpoint_trials_med)}; %%median for restricted time window
         w_setpoint_trials_medbinned(blk) = {horzcat(trialnums(xbins),binned)}; %%median binned withi n restricted time window
         w_setpoint_trials_width(blk) = {setpoint_trials_width};
         
       
%         smoothed=filter(ones(1,windowSize)/windowSize,1,setpoint_trials_prewhisk(:,1));
        data = setpoint_trials_prewhisk(:,1);
        binned = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
        binned=cat(1,binned{:}); 

       plot(trialnums(xbins),binned,'color','r','linewidth',1,'Marker','o');       
        axis([min(trialnums) max(trialnums) -30 30]);
         title(['M:' obj{1}.mouseName ' S: ' obj{1}.sessionName ' Ttype: ' str ' Bk: ' block_tags{blk} 'Setpoint' ]);

         w_setpoint_trials_dur(blk)= {setpoint_trials_dur};
         w_setpoint_trials_prewhisk(blk)= {horzcat(trialnums,setpoint_trials_prewhisk)};
         w_setpoint_trials_prewhiskbinned(blk)= {horzcat(trialnums(xbins),binned)};
         
         
          w_setpoint_early(blk) ={setpoint_trials(earlyinds,round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime))};
          w_setpoint_late(blk) ={setpoint_trials(lateinds,round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime))};

%%plot amphist        

        subplot(numblocks*2,2,(blk-1)*2+2);

        plot(trialnums,amp_trials_med(:,1),'linewidth',1.5);hold on;
        windowSize=25;
      
%        smoothed=filter(ones(1,windowSize)/windowSize,1,amp_trials_med(:,1));
        data = amp_trials_med(:,1);
        binned = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
        binned=cat(1,binned{:});  

       plot(trialnums(xbins),binned,'linewidth',1.5,'color','k','Marker','o');
       axis([min(trialnums) max(trialnums) 0 30]);

                 
         w_amp_trials(blk) = {amp_trials};  %%entire length
         w_amp_trials_med(blk) = {horzcat(trialnums,amp_trials_med)}; %%median for restricted time window
          w_amp_trials_medbinned(blk) = {horzcat(trialnums(xbins),binned)}; 
         w_amp_trials_width(blk) = {amp_trials_width};
       
          w_amp_early(blk) ={amp_trials(earlyinds,round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime))};
         w_amp_late(blk) ={amp_trials(lateinds,round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime))};


          
          
%%plot setpoint first and last n trials
         avg_setpoint = mean(setpoint_trials(earlyinds,:),1); 
         xt=[1:size(setpoint_trials,2)]*frameTime;
         subplot(numblocks*2,2,(numblocks+blk-1)*2+1);plot(xt,setpoint_trials(earlyinds(1:2:end),:),'color',[.5 .5 .5],'linewidth',1); hold on;           
         plot(xt,setpoint_trials(lateinds(1:2:end),:),'color',[1 .5 .5],'linewidth',1); hold on;
         plot(xt,avg_setpoint,'linewidth',1.5,'color','k');hold on;
         avg_setpoint = mean(setpoint_trials(lateinds,:),1);
         plot(xt,avg_setpoint,'linewidth',1.5,'color','r');
         hold off;
         axis([.3,4,-30,30]);set(gca,'YGrid','on');
         set(gca,'YTick',-30:10:30);
         freezeColors;


         
  %%plot amp first and last n trials
          avg_amp = mean(amp_trials(earlyinds,:),1); 
         xt=[1:size(amp_trials,2)]*frameTime;
         subplot(numblocks*2,2,(numblocks+blk-1)*2+2);plot(xt,amp_trials(earlyinds(1:2:end),:),'color',[.5 .5 .5],'linewidth',1); hold on;           
         plot(xt,amp_trials(lateinds(1:2:end),:),'color',[1 .5 .5],'linewidth',1); hold on;   
         plot(xt,avg_amp,'linewidth',1.5,'color','k');hold on;
         avg_amp = mean(amp_trials(lateinds,:),1);
         plot(xt,avg_amp,'linewidth',1.5,'color','r');
         hold off;
         axis([.3,4,0,40]);set(gca,'YGrid','on');
         set(gca,'YTick',-30:10:30);
         freezeColors;
 
    end           
        saveas(gcf,[fpath,filesep,fnam],'tif');
        close(h1);
      
        
        
    for(blk=1:numblocks)    
        
 % setpoint test for sig      
         temp1= prctile(w_setpoint_early{blk},[81:100],2); temp1=temp1(:);
         temp2 = prctile(w_setpoint_late{blk},[81:100],2); temp2=temp2(:);

          [h,pvalsetpoint,ksstat]= kstest2(temp1,temp2,0.01,1); %(f2>f1)
%          [pvalsetpoint,h] = ranksum(temp1,temp2,'alpha',.01);
%          stats=mwwtest(temp1,temp2)
%         [pval, k, K] = circ_kuipertest(temp1*pi/180, temp2*pi/180, 1, 1);
        h1b=figure('Name','Set point histograms');  
        plot(spbins,hist(temp1,spbins)/sum(hist(temp1,spbins)),'color','k','linewidth',3); hold on;  plot(spbins,hist(temp2,spbins)/sum(hist(temp2,spbins)),'color','r','linewidth',3);
         axis([-30 30 0 .25]);set(gca,'XGrid','on');set(gca,'FontSize',10);set(gca,'YTick',[0:.05:.25]);
        if(h)
          title(['KS Test : h = ', num2str(h), ' p value ', num2str(pvalsetpoint), ' Separation ', num2str(ksstat)]); 
        else
          title(['KS Test : h = ', num2str(h), ' p value ', num2str(pvalsetpoint), ' Separation ', num2str(ksstat)]); 
        end       
%         legend(block_tags);
 legend( sprintf('first %d trials',avg_trials),sprintf('last %d trials',avg_trials));
        fnam=[str 'avg_setpoint_hist'];  
        saveas(gcf,[fpath,filesep,fnam],'tif');
        saveas(gcf,[fpath,filesep,fnam],'fig');
        close(h1b);
%% amp test for sig        
         temp1 = prctile(w_amp_early{blk},[81:100],2); temp1=temp1(:);
         temp2 = prctile(w_amp_late{blk},[81:100],2); temp2=temp2(:);

          [h,pvalamp,ksstat]= kstest2(temp1,temp2,0.01,-1);
%          [pvalamp,h] = ranksum(temp1,temp2,'alpha',.01);
%          stats=mwwtest(temp1,temp2)
%         [pval, k, K] = circ_kuipertest(temp1*pi/180, temp2*pi/180, 1, 1);
        h1c=figure('Name','Amplitude histograms');  
        plot(ampbins,hist(temp1,ampbins)/sum(hist(temp1,ampbins)),'color','k','linewidth',3); hold on;  plot(ampbins,hist(temp2,ampbins)/sum(hist(temp2,ampbins)),'color','r','linewidth',3);
         axis([1 30 0 .25]);set(gca,'XGrid','on');set(gca,'FontSize',10);set(gca,'YTick',[0:.025:.25]);
        if(h)
          title(['KS Test : h = ', num2str(h), ' p value ', num2str(pvalamp), ' Separation ', num2str(ksstat)]); 
        else
          title(['KS Test : h = ', num2str(h), ' p value ', num2str(pvalamp), ' Separation ', num2str(ksstat)]); 
        end       
%         legend(block_tags);
          legend( sprintf('first %d trials',avg_trials),sprintf('last %d trials',avg_trials));
        fnam=[str 'avg_amp_hist'];  
        saveas(gcf,[fpath,filesep,fnam],'tif');
        saveas(gcf,[fpath,filesep,fnam],'fig');
        close(h1c);
        
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

