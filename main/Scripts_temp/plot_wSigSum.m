function plot_wSigSum()   
datawave = {'med','prepole','peak'};
        colr(:,:,2) = [ 0 0 0 ;0 0 1; 1 0 0 ];
        colr(:,:,1) = [ .5 .5 .5 ;.5 .5 1; 1 .5 .5 ];
        for k = 1:length(datawave)
            
            selecteddata = strrep(datatoplot,'data',datawave(k));
            temp = getfield(wSigSummary{i},selecteddata{1});
            temp = temp{1};
            binnedxdata = temp{block}(:,1)';
            binnedydata = temp{block}(:,2)';
            binnedydata_sdev = temp{block}(:,3)';
            curr_meanbarpos = wSigSummary{i}.nogo_thetaenv_mean_barpos{1}{1};
             curr_meanbarpos = wSigSummary{i}.nogo_thetaenv_mean_barpos{1}{1};
            %            mean_bartheta = getfield(wSigSummary{i},strrep(datatoplot,'databinned','meanbar'));
            %            mean_bartheta  = cell2mat(mean_bartheta {1});
            axes(ah1);
            
            if(i<baseline_sessions+1)
                tcol = colr(:,:,1);
                errorbar(binnedxdata+count,binnedydata,binnedydata_sdev,'color',tcol(k,:),'Marker','o','MarkerSize',6,'MarkerFaceColor',tcol(k,:));hold on;
                axis([min(binnedxdata+count) max(binnedxdata+count) -30  max(binnedydata)-10]);
                hline(curr_meanbarpos,{'k--','linewidth',1.5});
                hline(baseline_bartheta ,{'k-','linewidth',1.5});
                
            else
                tcol = colr(:,:,2);
                errorbar(binnedxdata+count,binnedydata,binnedydata_sdev,'color',tcol(k,:),'Marker','o','MarkerSize',6,'MarkerFaceColor',tcol(k,:));hold on;
                axis([min(binnedxdata+count) max(binnedxdata+count) min(binnedydata)-10 max(binnedydata)+10 ]);
                %                 hline(biased_bartheta,'r--');
                hline(biased_bartheta,{'r-','linewidth',1.5});
                hline(curr_meanbarpos,{'r--','linewidth',1.5});
            end
            mindata = (mindata<min(binnedydata))*mindata + (mindata>min(binnedydata))*min(binnedydata);
            maxdata = (maxdata>max(binnedydata))*maxdata + (maxdata<max(binnedydata))*max(binnedydata);
            collateddata = [binnedxdata;binnedydata]';
            wSigSum_Sessions{i,j}.(selecteddata{1}) = {collateddata};
            
            legendstr(i) = {['session' num2str(i) ' ']};
            
            axes(ah2);
            if(i<baseline_sessions+1)
                tcol = colr(:,:,1);
                %        plot(xdata+count,(ydata-baseline_bartheta),'color',col(j,:),'linewidth',1.0);
                errorbar(binnedxdata+count,(binnedydata-baseline_bartheta),binnedydata_sdev,'color',tcol(k,:),'Marker','o','MarkerSize',6,'MarkerFaceColor',tcol(k,:));hold on;
            else
                tcol = colr(:,:,2);
                %        plot(xdata+count,(ydata-bartheta),'color',col(j,:),'linewidth',1.0);
                errorbar(binnedxdata+count,(binnedydata-biased_bartheta),binnedydata_sdev,'color',tcol(k,:),'Marker','o','MarkerSize',6,'MarkerFaceColor',tcol(k,:));hold on;
            end
            legendstr(i) = {['session' num2str(i) ' ']};
            hline(0,{'r-','linewidth',1});
        end
        
        count = count+binnedxdata(end)+10;
        
    end
    axes(ah1); axis([0 count mindata-5 maxdata+5]);grid on; ylabel('Medianpole, Prepole and Peak(binned thetaenv)'); xlabel('Trials');
    
    title('Binned Theta env Med Prepole Peak - K B R');
    
    saveas(gcf,['thetaenv_med_bl ' blocklist{j}] ,'jpg');
    saveas(gcf,['thetaenv_med_bl' blocklist{j}],'fig');
    
    axes(ah2);axis([0 count mindata-15 maxdata+2]);grid on; ylabel('Med, Prepole,Peak - mean bartheta (from expected bar position)'); xlabel('Trials');
    title('Mean subtracted Theta env Med Prepole Peak - K B R');
    saveas(gcf,['error_bl ' blocklist{j}] ,'jpg');
    saveas(gcf,['error_bl' blocklist{j}],'fig');
    hold off;
    %        plot_dist_sessions(commentstr,numsessions);
end
% title([commentstr ' Block ' blocklist{j} ]);



% plotting prcpastmeanbar and meanbarcross
mindata =0;
maxdata =0;
for j= 1:numblocks
    block =j;
    sc = get(0,'ScreenSize');
    figure('position', [1000, sc(4)/10-100, sc(3)*3/10, sc(4)*3/4], 'color','w'); %%raw theta
    %     title([commentstr 'Amplitude Block ' blocklist{j} 'Data ' 'Amp_med']);
    title([commentstr 'Percent past mean barpos ' ]);%blocklist{j} 'Data ' datatoplot]);
    hold on;
    count =0;
    prev=0;
    for i = 1:numsessions
        
        selecteddata = strrep(datatoplot,'data','prcpastmeanbar');
        temp = getfield(wSigSummary{i},selecteddata);
        temp = temp{1};
        
        binnedxdata = temp{block}(:,1)';
        binnedydata = temp{block}(:,2)';
        
        if(i<baseline_sessions+1)
            axis([min(binnedxdata+count) max(binnedxdata+count) -.1 .6]);
            plot(binnedxdata+count,binnedydata,'color',[.5 .5 .5],'Marker','o','MarkerSize',6,'MarkerFaceColor',[.5 .5 .5]);hold on;
            
        else
            axis([min(binnedxdata+count) max(binnedxdata+count) -.1 .6]);
            plot(binnedxdata+count,binnedydata,'color',[0 0 0 ],'Marker','o','MarkerSize',6,'MarkerFaceColor',[0 0 0 ]);hold on;
            
        end
        hline(0,{'k-','linewidth',1});
        hline(.5,{'r-','linewidth',1});
        legendstr(i) = {['session' num2str(i) ' ']};
        %        wSigSum_Sessions.thrmed_binned{i,j}= [binnedxdata;binnedydata]';
        collateddata = [binnedxdata;binnedydata]';
        maxdata = (maxdata>max(binnedydata))*maxdata + (maxdata<max(binnedydata))*max(binnedydata);
        wSigSum_Sessions{i,j}.(selecteddata) = {collateddata};
        
        count = count+binnedxdata(end)+10;
        
    end
    axis([0 count 0 maxdata+.02]);grid on; ylabel('Percent dwell past mean barpos'); xlabel('Trials');
    saveas(gcf,['prcpastbarpos_bl ' blocklist{j}] ,'jpg');
    saveas(gcf,['prcpastbarpos_bl' blocklist{j}],'fig');
end
% title([commentstr ' Block ' blocklist{j} ]);
hold off;


% plotting kappa
mindata =0;
maxdata =0;
for j= 1:numblocks
    block =j;
    sc = get(0,'ScreenSize');
    figure('position', [1000, sc(4)/10-100, sc(3)*3/10, sc(4)*3/4], 'color','w');
    title([commentstr 'TotalTouchKappa' ]); %' blocklist{j}]);
    
    hold on;
    count =0;
    prev=0;
    for i = 1:numsessions
  
         selecteddata = 'go_totalTouchKappa';
         temp = getfield(wSigSummary{i},selecteddata);
         temp = temp{1};
         temp = temp{1};
         
         ydata = temp(:,2);
         xdata= temp(:,1);
        
        if(i<baseline_sessions+1)
            axis([min(xdata+count) max(xdata+count) -10 40]);
            plot(xdata+count,ydata,'color',[.5 .5 .5],'linewidth',.2,'Marker','o','MarkerSize',6,'MarkerFaceColor',[.5 .5 .5]);
        else
            axis([min(xdata+count) max(xdata+count) -10 40]);

            plot(xdata+count,ydata,'color',[0 0 0 ],'linewidth',.2,'Marker','o','MarkerSize',6,'MarkerFaceColor',[0 0 0 ]);

        end
        
        legendstr(i) = {['session' num2str(i) ' ']};
        %        wSigSum_Sessions.thr_durbinned{i,j}= [binnedxdata;binnedydata]';
        collateddata = [xdata;ydata]';
        wSigSum_Sessions{i,j}.(selecteddata) = {collateddata};
        count = count+binnedxdata(end)+10;

    end
    axis([0 count -10 40]);grid on; ylabel('TotalTouchKappa'); xlabel('Trials');
    saveas(gcf,['totalTouchKappa_bl ' blocklist{j}] ,'jpg');
    saveas(gcf,['totalTouchKappa_bl' blocklist{j}],'fig');
    hold off;
    plot_dist_sessions(commentstr,numsessions);
end