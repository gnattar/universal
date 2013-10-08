function  plotdetails(obj,block_tags,block_trialnums,avg_trials,gopix,nogopix,restrictTime,p,plot_whiskerfits,str)
% [wAmpm,wAmpsd]
    numblocks = size(block_tags,2);
%% plot theta
%     wAmpm = zeros(numblocks,1);
%     wAmpsd = zeros(numblocks,1);
    point = max(gopix);
    gopix(:,2) = point(1,2);
    nogopix(1,2) = point(1,2);

      
    frames_list=arrayfun(@(x) size(x{:}.time{1},2), obj,'uniformoutput',false);
    maxframes = max(cell2mat(frames_list));

    if~(exist([p '/plots/'],'dir'))
       mkdir (p,'plots') ;
    end
    fpath = [p '/plots/'];
    if~(exist([fpath str],'dir'))
       mkdir (fpath,str) ;
    end
   fpath = [p '/plots/' str];
        
    fnam=[str 'ftheta.tif'];
    h1=figure('Name','Set point plot'); 
    set(0,'CurrentFigure',h1);
    spbins = [-40:2:40];
    setpoint_restricted = cell(2,1);
   
    for(b=1:numblocks)
        trialnums = block_trialnums{b};
        col=jet(length(trialnums));
        setpoint_trials= zeros(length(trialnums),maxframes);        
        setpoint_trials_hist= zeros(length(trialnums),length(spbins));
%         setpoint_restricted(b) =  zeros(length(trialnums),round(restrictTime(2)/frameTime)-round(restrictTime(1)/frameTime));

        count =1;
        for(i=1:1:length(trialnums))
            t = trialnums(i);
            frames = length(obj{t}.theta{1,1});
            if(frames<250)
                disp(['delete trial' obj{t}.trackerFileName num2str(trialnums(i))])              
            else
                frameTime = obj{t}.framePeriodInSec;
                xt = [1:frames]*frameTime;

                temp=obj{t}.theta{1,1};
    % %             wAmpm = wAmpm+ mean(temp(0.4/.002 : 0.5/.002));
    % %             wAmpsd = wAmpsd +(mean(temp(0.4/.002 : 0.5/.002))^2);
                windowSize = 160; %% for low pass filtered set-point
                setpoint= filter(ones(1,windowSize)/windowSize,1,temp);
        %         if~(max(setpoint(1:.05/.002)>20))
        %             if~(min(setpoint(1:.05/.002)<-20))            
                        subplot(numblocks*2,3,(b-1)*6+1); plot(xt(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),setpoint(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),'color',col(i,:),'linewidth',2); axis ([restrictTime(1) restrictTime(2) -25 25]) ;

                        hold on;
                        setpoint_trials(count,[1:frames])=setpoint;
                        temp = hist(setpoint(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),spbins);
                        temp=temp/sum(temp);
                        setpoint_trials_hist(count,[1:length(spbins)])=temp;
                       
                        count=count+1;
        %             end
        %         end
            end
        end
   
% %         wAmpm = wAmpm/length(trialnums);
% %         wAmpsd = wAmpsd/length(trialnums);
% %         wAmpsd = (wAmpsd - wAmpm^2)^0.5;
        hold off;
        colorbar('location','EastOutside');
        freezeColors;
        cbfreeze(colorbar);
         xt = [1:maxframes]*frameTime;
        setpoint_restricted(b) ={setpoint_trials(:,round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime))};
        subplot(numblocks*2,3,(b-1)*6+2);imagesc(xt(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),trialnums,setpoint_trials(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)));caxis([-25 25]);colormap(fireice);
        colorbar('location','EastOutside');
        freezeColors;
         cbfreeze(colorbar);
        subplot(numblocks*2,3,(b-1)*6+3);imagesc(spbins,trialnums,setpoint_trials_hist);caxis([0 max(max(setpoint_trials_hist))]);colormap(hot); 
         colorbar('location','EastOutside');
         title(['M:' obj{1}.mouseName ' S: ' obj{1}.sessionName ' Ttype: ' str ' Bk: ' block_tags{b} 'Setpoint' ]);
         freezeColors;
         cbfreeze(colorbar);

         if(count-1<=avg_trials)
             avg_trials = count -10;
             disp ([ 'there are only' num2str(count-1) ' good trials , reduced trialstoavg to ' num2str(count-10)]);
         end
         avg_setpoint = mean(setpoint_trials(count-1-avg_trials : count-1,:),1);
         set(0,'DefaultAxesColorOrder',hot(count)); 
         subplot(numblocks*2,3,(b-1)*6+4);plot(xt,setpoint_trials(count-1-avg_trials : count-1,:),'linewidth',1); hold on;

         plot(xt,avg_setpoint,'linewidth',1,'color','k');hold off;
         axis([.2,4,-25,25]);
         freezeColors;
    
                       
         avg_setpointhist= mean(setpoint_trials_hist(count-1-avg_trials : count-1,:),1);
         temp_avg_setpointhist(:,b) = avg_setpointhist;
         subplot(numblocks*2,3,(b-1)*6+6);plot(spbins,setpoint_trials_hist(count-1-avg_trials : count-1,:),'linewidth',1); hold on;
         plot(spbins,avg_setpointhist,'linewidth',2,'color','k');hold off;
         axis([-40 40 -.1 max(max(setpoint_trials_hist))]);

         freezeColors;
     
    end    
       
        saveas(gcf,[fpath,filesep,fnam],'tif');
        close(h1);
        
   
         temp1 = setpoint_restricted{1};temp1 = reshape(temp1,size(temp1,1)*size(temp1,2),1);
         temp2 = setpoint_restricted{2};temp2 = reshape(temp2,size(temp2,1)*size(temp2,2),1);

         [h,p]= kstest2(temp1,temp2);
%         [pval, k, K] = circ_kuipertest(temp1*pi/180, temp2*pi/180, 1, 1);
        h1b=figure('Name','Set point histograms');  
%         set(0,'DefaultAxesColorOrder',hsv); 
        plot(spbins,hist(temp1,spbins)/max(hist(temp1,spbins)),'b'); hold on;  plot(spbins,hist(temp2,spbins)/max(hist(temp2,spbins)),'g');
%         plot(spbins,temp_avg_setpointhist,'linewidth',2);
        axis([-40 40 0 1]);
        if(h)
          title(['Significantly different KS Test : h = ', num2str(h), ' p value ', num2str(p)]); 
        else
          title(['Not significantly different KS Test : h = ', num2str(h), ' p value ', num2str(p)]); 
        end
        
        legend(block_tags);
        fnam=[str 'avg_setpoint_hist'];  
        saveas(gcf,[fpath,filesep,fnam],'tif');
        close(h1);
    
    %% plot kappa
 
    fnam=[str 'fkappa.tif'];
    h2=figure('Name','Kappa');
     set(0,'CurrentFigure',h2);
     
    for(b=1:numblocks)
    
        trialnums = block_trialnums{b};
        kappa_trials= zeros(length(trialnums),maxframes);
        col=jet(length(trialnums));
        count =1;
        for(i=1:length(trialnums))
            t = trialnums(i);
            frames = length(obj{t}.kappa{1,1});
            if(frames<2500)
                disp(['delete trial' obj{t}.trackerFileName num2str(trialnums(i))])
                
            else
            frameTime = obj{t}.framePeriodInSec;
            xt = [1:frames]*frameTime;
            temp=obj{t}.kappa{1,1};
            baseline = mean(temp(1:round(0.3/frameTime)));
            temp=temp-baseline;
            windowSize = 10;
            filtkappa= filter(ones(1,windowSize)/windowSize,1,temp);  
            subplot(numblocks*2,2,(b-1)*2+1);
            %plot(obj{t}.kappa{1,1},'color',col(i,:))
            plot(xt(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),filtkappa(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),'color',col(i,:),'linewidth',2); axis ([restrictTime(1) restrictTime(2) -.01 0.01]) ;
%             title(['Mouse:' obj.mouseName ' Session: ' obj.sessionName ' Trialtype: ' str ' Block: ' block_tags{b} 'Filtered Kappa' ]);
            hold on;
            kappa_trials(count,[1:frames])=filtkappa;
            count=count+1;
            end
        end
        hold off;

        colorbar('location','EastOutside');
        freezeColors;
         cbfreeze(colorbar);
        xt = [1:maxframes]*frameTime;
       
        subplot(numblocks*2,2,(b-1)*2+2);imagesc(xt(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),trialnums,kappa_trials(:,round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)));caxis([-.01 0.01]);colormap(fireice);
        colorbar('location','EastOutside');
        title(['M:' obj{1}.mouseName ' S: ' obj{1}.sessionName ' Ttype: ' str ' Bk: ' block_tags{b}  'Filtered Kappa'  ]);

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
        
        for(b=1:numblocks)
    
            trialnums = block_trialnums{b};
            for(i=1:5:length(trialnums))
                t = trialnums(i);            
                fittedX = obj{t}.polyFitsROI{1}{1};
                fittedY = obj{t}.polyFitsROI{1}{2};
                fittedQ = obj{t}.polyFitsROI{1}{3};
                frames = [1: length(fittedX)];
                xt =  frames*frameTime;
                frameInds= find(xt >= restrictTime(1) & xt <= restrictTime(2));      
                cmap=jet(length(frameInds));
                colormap(cmap);
                nframes = length(frameInds);
                x = cell(1,nframes);
                y = cell(1,nframes);

                col=jet(nframes); 
                barpos = obj{t}.bar_pos_trial;
                barpos(1,2) = point(1,2);
                for k=1:nframes
                    f = frameInds(k);               
                    px = fittedX(f,:);
                    py = fittedY(f,:);
                    pq = fittedQ(f,:);

                    q = linspace(pq(1),pq(2));

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
                    plot(r*sin(p)+nogopix(1,1),r*cos(p)+nogopix(1,2),'linewidth',5,'color','black'); 

              filename = ['Mouse:' obj.mouseName ' Session: ' obj.sessionName ' Trialtype: ' str ' Block: ' block_tags{b} obj{t}.trackerFileName];
              title(gca,filename);        
              set(gca,'YDir','reverse');
              hold off;
              colorbar('location','EastOutside');
              fnam=['w' filename(30:33) '.tif'];
              saveas(gcf,[fpath,filesep,fnam],'tif');
              msg=sprintf('Plotting %d of %d',i,length(trialnums));
             waitbar(i/(length(trialnums)+1),w,msg);
        %       set(f,'visible','on');

            end
        end
        
     close(w);
    end
end

