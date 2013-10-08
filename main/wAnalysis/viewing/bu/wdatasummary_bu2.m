
function[w_thetaenv]...
    =  wdatasummary(obj,block_tags,block_trialnums,avg_trials,gopix,nogopix,restrictTime,p,plot_whiskerfits,str,timewindowtag)
%% new version : compare within block & with top 90% percentile of setpoint values
% w_setpoint_trials % all setpoint values from all trials  entire length
% w_setpoint_early % within the restricted time window from early trials
% w_setpoint_late % within the restricted time window from late trials
% w_setpoint_trials_med % mean of 90th percentile of setpoint values within window
%w_setpoint_trials_width std of the points avgd over

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
    h=figure('Name','Set point plot'); 
    set(0,'CurrentFigure',h);
    w_thetaenv_dist = cell(numblocks,1);
    w_thetaenv_trials = cell(numblocks,1);
    
    for(blk=1:numblocks)
        trialnums = block_trialnums{blk};
        col=jet(length(trialnums));
        bins = -30:1:10;
        nbins=length(bins);
% %         thetaenv_dist = zeros(length(trialnums),nbins);     
% %         thetaenv_trials= zeros(length(trialnums),numpoleframes);              
% %         thetaenv_med=zeros(length(trialnums),1);
% %         thetaenv_width=zeros(length(trialnums),1); %std
% %         thetaenv_prepole= zeros(length(trialnums),1);
% %         thetaenv_dur= zeros(length(trialnums),1);
        
        count =1;
        for(i=1:1:length(trialnums))
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
% % %                 temp = amp(valinds);
% % %                 points=prctile(temp,[80,100]);
% % %                 valinds=find(points(1)<temp & temp<points(2));
                
                temp = thetaenv(poleinds); 
                thetaenv_trials{count} = temp;
                thetaenv_time{count} = xt(poleinds);

                temp = thetaenv(valinds); 
                thetaenv_dist(count,:) = hist(temp,nbins);
                
                temp = thetaenv(prepoleinds); %100points prepole
                thetaenv_prepole(count,1) = mean(temp);
                
                temp = thetaenv(valinds); %pole
                thetaenv_med(count,1) = median(temp);                
                thetaenv_width(count,1) = std(temp); %sqrt(mean(temp.^2)-mean(temp).^2);
                thetaenv_skew(count,1) = skewness(temp);
                thetaenv_kurt(count,1) = kurtosis(temp);
                thetaenv_dur(count,1)=max(xt(valinds))-min(xt(valinds));    
                    
                    
                    count=count+1;
            end
        end

        
        avg_trials = floor(length(trialnums)/3);
        if(count-1<=avg_trials)
             avg_trials = count-2;
             disp ([ 'there are only' num2str(count-1) ' good trials , reduced trialstoavg to ' num2str(count-2)]);
        end

        earlyinds= [50:50+avg_trials] ;             
        lateinds= [count-1-avg_trials : count-1] ;

        
        
        w_thetaenv_trials(blk) = {thetaenv_trials};  %%entire length
        

%%plot thetaenv mean and std       

       subplot(numblocks*2,2,(blk-1)*4+1,'Parent',h);
       up = thetaenv_med(:,1)+thetaenv_width(:,1);
       low=thetaenv_med(:,1)-thetaenv_width(:,1);
       jbfill(trialnums',up',low',[.8 .8 .8],[.8 .8 .8],1,.5);hold on;

        plot(trialnums,thetaenv_med(:,1),'linewidth',1); hold on;
        windowSize=25;
        grid on;

        data =thetaenv_med(:,1);
        binned_med = arrayfun( @(x) median(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
        binned_med=cat(1,binned_med{:});
        data =thetaenv_width(:,1);
        binned_width = arrayfun( @(x) median(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
        binned_width=cat(1,binned_width{:});
        xbins = arrayfun( @(x) mean(x:min(x+windowSize-1,size(data,1))), 1:windowSize:size(data,1), 'UniformOutput', false);
        xbins=floor(cat(1,xbins{:}));         
        errorbar(trialnums(xbins),binned_med,binned_width,'linewidth',1.5,'color','k','Marker','o');hold on;
        grid on; axis([min(trialnums),max(trialnums), -30, 30]);
        s = regstats(binned_med,trialnums(xbins),'linear','tstat');
        pval  = s.tstat.pval(2); % test for non-zero slope of setpoint
        title(['M:' obj{1}.mouseName ' S: ' obj{1}.sessionName ' Ttype: ' str 'Thetaenv pval ' num2str(pval) ]);
    
%       theta_env prepole   
        data = thetaenv_prepole(:,1);
        binned_med = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
        binned_med=cat(1,binned_med{:}); 

%        plot(trialnums(xbins),binned_med,'color','r','linewidth',1,'Marker','o');  grid on;      
%         axis([min(trialnums) max(trialnums) -30 30]);
         w_thetaenv_dur(blk)= {thetaenv_dur};
         w_thetaenv_prepole(blk)= {horzcat(trialnums,thetaenv_prepole)};
         w_thetaenv_prepolebinned(blk)= {horzcat(trialnums(xbins),binned_med)};
         w_thetaenv_pval(blk) = pval;

        % plotthetaenv_ skewness and kurtosis
          
        subplot(numblocks*2,2,(blk-1)*4+2,'Parent',h);
% %         imagesc([1:length(trialnums)],bins,thetaenv_dist');
% %         caxis([0 100]);colormap(jet);

       up =thetaenv_skew(:,1);
       low=thetaenv_skew(:,1);
       jbfill(trialnums',up',low',[.05 .0 .8],[.05 .0 .8],1,.5);hold on;
 %         plot(trialnums,thetaenv_skew(:,1),'linewidth',1,'color','b');hold on;      
       up = thetaenv_kurt(:,1);
       low=thetaenv_kurt(:,1);
       jbfill(trialnums',up',low',[.2 .5 .0],[.2 .5 .0],1,.5);hold on;
%        plot(trialnums,thetaenv_kurt(:,1),'linewidth',1,'color','g');

        windowSize=25;
        grid on;

        data =thetaenv_skew(:,1);
        binned_skew = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
        binned_skew=cat(1,binned_skew{:});
        data =thetaenv_kurt(:,1);
        binned_kurt = arrayfun( @(x) mean(data(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data,1), 'UniformOutput', false);
        binned_kurt=cat(1,binned_kurt{:});
        xbins = arrayfun( @(x) mean(x:min(x+windowSize-1,size(data,1))), 1:windowSize:size(data,1), 'UniformOutput', false);
        xbins=floor(cat(1,xbins{:}));         
        plot(trialnums(xbins),binned_skew,'color',[.2 .0 .5],'Marker','o','MarkerFaceColor',[.2 .0 .5]);hold on;
        plot(trialnums(xbins),binned_kurt,'color',[.2 .5 .0],'Marker','o','MarkerFaceColor',[.2 .5 .0]);
        axis([min(trialnums),max(trialnums), -10, 30]);
        s = regstats(binned_skew,trialnums(xbins),'linear','tstat');
        pval  = s.tstat.pval(2); % test for non-zero slope of setpoint
        title(['M:' obj{1}.mouseName ' S: ' obj{1}.sessionName ' Ttype: ' str 'Thetaenv pval ' num2str(pval) ]);


        
         w_thetaenv_med(blk) = {horzcat(trialnums,thetaenv_med)}; %%median for restricted time window
         w_thetaenv_binned(blk) = {horzcat(trialnums(xbins),binned_skew,binned_kurt)}; %%median binned withi n restricted time window
         w_thetaenv_width(blk) = {thetaenv_width};      
         w_thetaenv_skew(blk) = {thetaenv_skew};
         w_thetaenv_kurt(blk) = {thetaenv_kurt};
        
       
%%plot thetaenv first and last n trials
         subplot(numblocks*2,2,(blk-1)*4+3,'Parent',h);
         avg_thetaenv =nan(length(earlyinds),(restrictTime(2)-restrictTime(1))*500);
         avg_time = zeros(1,(restrictTime(2)-restrictTime(1))*500);
         avg_time = restrictTime(1)+.002:.002:restrictTime(2);avg_time=round(avg_time.*1000)./1000;
%          avg_count = zeros(1,(restrictTime(2)-restrictTime(1))*500);
         for j = 1: length(earlyinds)
             i=earlyinds(j);
             current_thetaenv = thetaenv_trials{i};
             xt = thetaenv_time{i};xt = round(xt.*1000)./1000;
             [lia,matchedinds]= ismember(xt,avg_time);
             avg_thetaenv(j,matchedinds>0) =   current_thetaenv;
%              avg_thetaenv(matchedinds>0) =  avg_thetaenv(matchedinds>0)+ current_thetaenv;
%              avg_count(matchedinds>0) =  avg_count(matchedinds>0)+ 1;
             plot(xt,current_thetaenv,'color',[.5 .5 .5],'linewidth',.5); hold on;           
         end
           avg_thetaenv =nanmedian(avg_thetaenv,1);
%          avg_thetaenv = avg_thetaenv./ avg_count;
         plot(avg_time,avg_thetaenv,'linewidth',1.5,'color','k'); grid on; hold on;
         hold off;
         axis([restrictTime(1),restrictTime(2),-30,30]);set(gca,'YGrid','on');
         set(gca,'YTick',-30:10:30);
         freezeColors;    
         
         avg_thetaenv = nan(length(lateinds),(restrictTime(2)-restrictTime(1))*500);
         subplot(numblocks*2,2,(blk-1)*4+4 ,'Parent',h);
         for j = 1:length(lateinds)
             i=lateinds(j);
              current_thetaenv = thetaenv_trials{i};
            xt = thetaenv_time{i};xt = round(xt.*1000)./1000;
            [lia,matchedinds]= ismember(xt,avg_time);
            avg_thetaenv(j,matchedinds>0) =  current_thetaenv;
%              avg_thetaenv(matchedinds>0) =  avg_thetaenv(matchedinds>0)+ current_thetaenv;
             plot(xt,current_thetaenv,'color',[1 .5 .5],'linewidth',.5); hold on;                    
         end
         

         avg_thetaenv =nanmedian(avg_thetaenv,1);
         plot(avg_time,avg_thetaenv,'linewidth',1.5,'color','r'); grid on; 
         hold off;
         axis([restrictTime(1),restrictTime(2),-30,30]);set(gca,'YGrid','on');
         set(gca,'YTick',-30:10:30);
         freezeColors;    
    end           
        saveas(gcf,[fpath,filesep,fnam],'tif');
        close(h);
        
        
        
        w_thetaenv.trials = w_thetaenv_trials;         
        w_thetaenv.med= w_thetaenv_med;
       w_thetaenv.width= w_thetaenv_width;
       w_thetaenv.prepole= w_thetaenv_prepole;
        w_thetaenv.dur = w_thetaenv_dur;
         w_thetaenv.binned = w_thetaenv_binned;
        w_thetaenv.dist = w_thetaenv_dist;
        w_thetaenv.prepolebinned = w_thetaenv_prepolebinned;
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

