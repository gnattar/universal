
function[w_setpoint_trials,w_setpoint_early,w_setpoint_late,w_setpoint_trials_med,w_setpoint_trials_width,w_setpoint_trials_hist,pvalsetpoint...
    w_amp_trials,w_amp_early,w_amp_late,w_amp_trials_med,w_amp_trials_width,w_amp_trials_hist,pvalamp]...
    =  wdatasummary(obj,block_tags,block_trialnums,avg_trials,gopix,nogopix,restrictTime,p,plot_whiskerfits,str,timewindowtag)
%% new version : compare within block
% w_setpoint_trials % all setpoint values from all trials  entire length
% w_setpoint_early % within the restricted time window from early trials
% w_setpoint_late % within the restricted time window from late trials
% w_setpoint_trials_med % median of setpoint values within window
% w_setpoint_trials_width % FWHM of the setpoint hist
% w_setpoint_trials_hist % hist of the values within window

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
    if~(exist([fpath timewindowtag],'dir'))
       mkdir (fpath,timewindowtag) ;
    end
    
    fpath = [p '/plots/' timewindowtag '/'];
    if~(exist([fpath str],'dir'))
       mkdir (fpath,str) ;
    end
%    fpath = [p '/plots/' str];
       fpath = [p '/plots/' timewindowtag '/' str];
   
    fnam=[str 'ftheta.tif'];
    h1=figure('Name','Set point plot'); 
    set(0,'CurrentFigure',h1);
    spbins = [-40:1:40];
    ampbins =[-5:.25:50];
    w_setpoint_early= cell(numblocks,1);
    w_setpoint_late= cell(numblocks,1);
    w_setpoint_trials = cell(numblocks,1);
    w_setpoint_trials_hist = cell(numblocks,1);
    for(blk=1:numblocks)
        trialnums = block_trialnums{blk};
         col=jet(length(trialnums));
        setpoint_trials= zeros(length(trialnums),maxframes);        
        setpoint_trials_hist= zeros(length(trialnums),length(spbins));
        setpoint_trials_med=zeros(length(trialnums),1);
        setpoint_trials_width=zeros(length(trialnums),4); %[fwhm lower, fwhm upper, min, max]
      
        amp_trials=zeros(length(trialnums),maxframes);
        amp_trials_hist= zeros(length(trialnums),length(spbins));
        amp_trials_med=zeros(length(trialnums),1);
        amp_trials_width=zeros(length(trialnums),4); %[fwhm lower, fwhm upper, min, max]
 
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

                clean_theta=obj{t}.theta{1,1};

% % %                 windowSize = 160; %% for low pass filtered set-point
% % %                 setpoint= filter(ones(1,windowSize)/windowSize,1,temp);

                sampleRate=1/frameTime;
                BandPassCutOffsInHz = [6 60];  %%check filter parameters!!!
                W1 = BandPassCutOffsInHz(1) / (sampleRate/2);
                W2 = BandPassCutOffsInHz(2) / (sampleRate/2);
                [b,a]=butter(2,[W1 W2]);
                filteredSignal = filtfilt(b, a, clean_theta);

                [b,a]=butter(2, 6/ (sampleRate/2),'low');
                setpoint = filtfilt(b,a,clean_theta-filteredSignal);

                hh=hilbert(filteredSignal);
                amp=abs(hh);

%%plot setpoint
%                 if((max(setpoint(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime))<30))&&(min(setpoint(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime))>-30)) )
                  
                        subplot(numblocks*2,4,(blk-1)*4+1); plot(xt(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),setpoint(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),'color',col(i,:),'linewidth',1); axis ([restrictTime(1) restrictTime(2) -30 30]) ;
                        set(gca,'YTick',-30:10:30);set(gca,'YGrid','on');
                        hold on;
                        setpoint_trials(count,[1:frames])=setpoint;
                        temp = hist(setpoint(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),spbins);
                        temp=temp/sum(temp);
                        if(temp(1)>0)
                            temp(1)=0;
                        elseif(temp(length(temp))>0)
                            temp(length(temp))=0;
                        end
                        setpoint_trials_hist(count,[1:length(spbins)])=temp; 
                        med=max(temp);
                        deg=find(temp==med);
                        setpoint_trials_med(count) = spbins(round(mean(deg)));
                        width = fwhm(spbins,temp);
                        deg=[ min(setpoint(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime))) max(setpoint(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)))];
                        setpoint_trials_width(count,:) = [setpoint_trials_med(count)-width/2 setpoint_trials_med(count)+width/2 deg];
                       
%%plot amp                        
                        subplot(numblocks*2,4,(blk-1)*4+3); plot(xt(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),amp(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),'color',col(i,:),'linewidth',1); axis ([restrictTime(1) restrictTime(2) -5 25]) ;
                        set(gca,'YTick',-5:10:50);set(gca,'YGrid','on');
                        hold on;
                        amp_trials(count,[1:frames])=amp;
                        temp = hist(amp(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),ampbins);
                        temp=temp/sum(temp);
                        if(temp(1)>0)
                            temp(1)=0;
                        elseif(temp(length(temp))>0)
                            temp(length(temp))=0;
                        end
                        amp_trials_hist(count,[1:length(ampbins)])=temp; 
                        med=max(temp);
                        deg=find(temp==med);
                        amp_trials_med(count) = ampbins(round(mean(deg)));
                        width = fwhm(ampbins,temp);
                        deg=[ min(amp(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime))) max(amp(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)))];
                        amp_trials_width(count,:) = [setpoint_trials_med(count)-width/2 setpoint_trials_med(count)+width/2 deg];
                                               
                        
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

        if(count-1<=avg_trials)
             avg_trials = count-2;
             disp ([ 'there are only' num2str(count-1) ' good trials , reduced trialstoavg to ' num2str(count-2)]);
         end

                earlyinds= [1:avg_trials] ;             
                lateinds= [count-1-avg_trials : count-1] ;


%%plot setpointhist        
        subplot(numblocks*2,4,(blk-1)*4+2);imagesc(spbins,trialnums,setpoint_trials_hist);caxis([0 1]);colormap(hot); 
        hold on;  plot(setpoint_trials_med,trialnums,'color',[1 1 1],'linewidth',.5); 
%         colorbar('location','EastOutside');
         title(['M:' obj{1}.mouseName ' S: ' obj{1}.sessionName ' Ttype: ' str ' Bk: ' block_tags{blk} 'Setpoint' ]);
%          freezeColors;
%          cbfreeze(colorbar);
%         axis([-30 30 trialnums(1) trialnums(length(trialnums))])

         
          w_setpoint_early(blk) ={setpoint_trials(earlyinds,round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime))};
          w_setpoint_late(blk) ={setpoint_trials(lateinds,round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime))};

                   
%%plot amphist        
        subplot(numblocks*2,4,(blk-1)*4+4);imagesc(ampbins,trialnums,amp_trials_hist);caxis([0 max(max(amp_trials_hist))]);colormap(hot); 
        hold on;  plot(amp_trials_med,trialnums,'color',[1 1 1],'linewidth',.5); 
%         colorbar('location','EastOutside');
%          title(['M:' obj{1}.mouseName ' S: ' obj{1}.sessionName ' Ttype: ' str ' Bk: ' block_tags{b} 'Setpoint' ]);
%          freezeColors;
%          cbfreeze(colorbar);
        axis([-1 30 trialnums(1) trialnums(length(trialnums))]);
          w_amp_early(blk) ={amp_trials(earlyinds,round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime))};
          w_amp_late(blk) ={amp_trials(lateinds,round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime))};

          
%%plot setpoint first and last n trials
         avg_setpoint = mean(setpoint_trials(earlyinds,:),1); 
         xt=[1:size(setpoint_trials,2)]*frameTime;
         subplot(numblocks*2,4,(numblocks+blk-1)*4+1);plot(xt,setpoint_trials(earlyinds,:),'color',[.5 .5 .5],'linewidth',1); hold on;           
         plot(xt,setpoint_trials(lateinds,:),'color',[1 .5 .5],'linewidth',1); hold on;
         plot(xt,avg_setpoint,'linewidth',1.5,'color','k');hold on;
         avg_setpoint = mean(setpoint_trials(lateinds,:),1);
         plot(xt,avg_setpoint,'linewidth',1.5,'color','r');
         hold off;
         axis([.3,4,-30,30]);set(gca,'YGrid','on');
         set(gca,'YTick',-30:10:30);
         freezeColors;

%%plot setpointhist first and last n trials         
         avg_setpointhist= mean(setpoint_trials_hist(earlyinds,:),1);
         temp_avg_setpointhist(:,blk) = avg_setpointhist;
         subplot(numblocks*2,4,(numblocks+blk-1)*4+2);plot(spbins,setpoint_trials_hist(earlyinds,:),'color',[.5 .5 .5],'linewidth',1); hold on;
         plot(spbins,setpoint_trials_hist(lateinds,:),'color',[1 .5 .5],'linewidth',1); hold on;
         plot(spbins,avg_setpointhist,'linewidth',2,'color','k');hold on;
         avg_setpointhist= mean(setpoint_trials_hist(lateinds,:),1);
         plot(spbins,avg_setpointhist,'linewidth',2,'color','r');
         hold off;
         axis([-40 40 0 max(max(setpoint_trials_hist(lateinds,:)))]);
         set(gca,'XTick',-40:10:40);set(gca,'XGrid','on');
         freezeColors;
         
  %%plot amp first and last n trials
          avg_amp = mean(amp_trials(earlyinds,:),1); 
         xt=[1:size(amp_trials,2)]*frameTime;
         subplot(numblocks*2,4,(numblocks+blk-1)*4+3);plot(xt,amp_trials(earlyinds,:),'color',[.5 .5 .5],'linewidth',1); hold on;           
         plot(xt,amp_trials(lateinds,:),'color',[1 .5 .5],'linewidth',1); hold on;   
         plot(xt,avg_amp,'linewidth',1.5,'color','k');hold on;
         avg_amp = mean(amp_trials(lateinds,:),1);
         plot(xt,avg_amp,'linewidth',1.5,'color','r');
         hold off;
         axis([.3,4,0,40]);set(gca,'YGrid','on');
         set(gca,'YTick',-30:10:30);
         freezeColors;

%%plot amphist first and last n trials         
         avg_amphist= mean(amp_trials_hist(earlyinds,:),1);
         temp_avg_amphist(:,blk) = avg_amphist;
         subplot(numblocks*2,4,(numblocks+blk-1)*4+4);plot(ampbins,amp_trials_hist(earlyinds,:),'color',[.5 .5 .5],'linewidth',1); hold on;
         plot(ampbins,amp_trials_hist(lateinds,:),'color',[1 .5 .5],'linewidth',1); hold on;
         plot(ampbins,avg_amphist,'linewidth',2,'color','k'); hold on;
         avg_amphist= mean(amp_trials_hist(lateinds,:),1);
         plot(ampbins,avg_amphist,'linewidth',2,'color','r');
         hold off;
         axis([0 40 0 max(max(amp_trials_hist(lateinds,:)))]);
         set(gca,'XTick',0:10:40);set(gca,'XGrid','on');
         freezeColors;      
         
      
         w_setpoint_trials(blk) = {setpoint_trials};  %%entire length
         w_setpoint_trials_med(blk) = {setpoint_trials_med}; %%median for restricted time window
         w_setpoint_trials_width(blk) = {setpoint_trials_width};
         w_setpoint_trials_hist(blk)= {setpoint_trials_hist};

         w_amp_trials(blk) = {amp_trials};  %%entire length
         w_amp_trials_med(blk) = {amp_trials_med}; %%median for restricted time window
         w_amp_trials_width(blk) = {amp_trials_width};
         w_amp_trials_hist(blk)= {amp_trials_hist};

         
         
    end           
        saveas(gcf,[fpath,filesep,fnam],'tif');
        close(h1);
      
        
        
    for(blk=1:numblocks)    
        
 % setpoint test for sig      
         temp1 = w_setpoint_early{blk};temp1 = reshape(temp1,size(temp1,1)*size(temp1,2),1);
         temp2 = w_setpoint_late{blk};temp2 = reshape(temp2,size(temp2,1)*size(temp2,2),1);

%          [h,pval]= kstest2(temp1,temp2,0.01);
         [pvalsetpoint,h] = ranksum(temp1,temp2,'alpha',.01);
%          stats=mwwtest(temp1,temp2)
%         [pval, k, K] = circ_kuipertest(temp1*pi/180, temp2*pi/180, 1, 1);
        h1b=figure('Name','Set point histograms');  
        plot(spbins,hist(temp1,spbins)/sum(hist(temp1,spbins)),'color',[0 .6 .5],'linewidth',6); hold on;  plot(spbins,hist(temp2,spbins)/sum(hist(temp2,spbins)),'color',[1 .6 0],'linewidth',6);
        axis([-30 30 0 .2]);set(gca,'XGrid','on');set(gca,'FontSize',30);set(gca,'YTick',[0:.05:.2]);
        if(h)
          title(['Significantly different Wilcoxon Ranksum Test : h = ', num2str(h), ' p value ', num2str(pvalsetpoint)]); 
        else
          title(['Not significantly different Wilcoxon Ranksum Test : h = ', num2str(h), ' p value ', num2str(pvalsetpoint)]); 
        end       
%         legend(block_tags);
 legend( sprintf('first %d trials',avg_trials),sprintf('last %d trials',avg_trials));
        fnam=[str 'avg_setpoint_hist'];  
        saveas(gcf,[fpath,filesep,fnam],'tif');
        saveas(gcf,[fpath,filesep,fnam],'fig');
        close(h1b);
%% amp test for sig        
         temp1 = w_amp_early{blk};temp1 = reshape(temp1,size(temp1,1)*size(temp1,2),1);
         temp2 = w_amp_late{blk};temp2 = reshape(temp2,size(temp2,1)*size(temp2,2),1);

%          [h,pval]= kstest2(temp1,temp2,0.01);
         [pvalamp,h] = ranksum(temp1,temp2,'alpha',.01);
%          stats=mwwtest(temp1,temp2)
%         [pval, k, K] = circ_kuipertest(temp1*pi/180, temp2*pi/180, 1, 1);
        h1c=figure('Name','Amplitude histograms');  
        plot(ampbins,hist(temp1,ampbins)/sum(hist(temp1,ampbins)),'color',[0 .6 .5],'linewidth',6); hold on;  plot(ampbins,hist(temp2,ampbins)/sum(hist(temp2,ampbins)),'color',[1 .6 0],'linewidth',6);
        axis([1 30 0 .1]);set(gca,'XGrid','on');set(gca,'FontSize',30);set(gca,'YTick',[0:.025:.1]);
        if(h)
          title(['Significantly different Wilcoxon Ranksum Test : h = ', num2str(h), ' p value ', num2str(pvalamp)]); 
        else
          title(['Not significantly different Wilcoxon Ranksum Test : h = ', num2str(h), ' p value ', num2str(pvalamp)]); 
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
            for(i=1:10:length(trialnums))
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

              filename = ['Mouse:' obj.mouseName ' Session: ' obj.sessionName ' Trialtype: ' str ' Block: ' block_tags{blk} obj{t}.trackerFileName];
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

