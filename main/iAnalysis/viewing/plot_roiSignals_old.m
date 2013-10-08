function plot_roiSignals_old(obj,fov,rois,roislist,tag_trialtypes,trialtypes,sfx)
% plot signals arranged by rois : to check roi selection in fovs
plotsperrow = 5;
fovname = ['fov ' fov 'rois ' roislist]; 
frametime=obj.FrameTime;
rois_trials  = arrayfun(@(x) x.dff, obj,'uniformoutput',false);
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

if(tag_trialtypes ==1)
    temp = permute(temprois,[3,2,1]);
    newrois=zeros(size(temp,1),size(temp,2)+1,size(temp,3));
    newrois(:,1:size(temp,2),:) = temp;
    temp2=repmat(trialtypes,1,size(temp,3));
    temp2 = reshape(temp2,numtrials,1,numrois);
    temp2=temp2*(1/length(unique(trialtypes))) *cscale(1,2);
    temp2 = [temp2 temp2 temp2 temp2 temp2];
    newrois(:,size(temp,2)+1:size(temp,2)+5,:) = temp2;
else 
    newrois =permute(temprois,[3,2,1]);
end
h1=figure;
dt = ts(length(ts))-ts(length(ts)-1);
for i = 1:length(rois)
 subplot(ceil(length(rois)/plotsperrow),plotsperrow,i);
 imagesc([ts ts(length(ts))+dt*1:dt:ts(length(ts))+dt*5],[1:numtrials],newrois(:,:,rois(i)));caxis(cscale);colormap(jet);
    if(tag_trialtypes ==1)
         vline([1 1.5 2 2.5 ],'k-');
    else    
         vline([.5 ],'r-');
         vline([1 1.5 2 2.5],'k:');
    end 
end

     
% colorbar('location','EastOutside');
fnam=[fovname sfx '_roisIm.tif'];
set(gcf,'NextPlot','add');
axes;
h = title(fnam);
set(gca,'Visible','off');
set(h,'Visible','on'); 
saveas(gcf,[pwd,filesep,fnam],'tif');
close(h1);

%%
h2=figure; 

for i=1:length(rois)
     h=subplot(ceil(length(rois)/plotsperrow),plotsperrow,i);
     
     if(tag_trialtypes ==1)         
        types= unique(trialtypes);          
         spacing =cscale(2)+100;
        for k = 1:length(types)
            trials_types=(find(trialtypes==types(k)));  
             col = [0 0 1; 0 .5 1; 0 1 0;1 .6 0;1 0 0; .5 0 0  ];
%             col= jet(length(types));
            for j=1:length(trials_types)           
             plot(ts ,newrois(trials_types(j),1:length(ts),rois(i))-spacing*(k-1)','color',col(types(k),:),'linewidth',.5);           
             hold on;  
            end
            hold on;
        end
             axis([0 ts(length(ts)) (0-spacing*length(types)+100) 700]);set(gca,'YMinorTick','on','YTick', 0-spacing*length(types)+100:200:700);
        vline([ 1 1.5 2 2.5],'k-');
     else
        col=linspace(0,1,numtrials);
        for j=1:numtrials         
             plot(ts,newrois(j,:,rois(i))','color',[.7 0 0]*col(j),'linewidth',.5);
             axis([0 ts(length(ts)) -50 700]);set(gca,'YMinorTick','on','YTick', 0-50:200:700);
             hold on;
        end
        hold off;  
        vline([.5 ],'r-');
        vline([1 1.5 2 2.5],'k:');
     end
    

end

fnam=[fovname sfx '_roisTrace.tif'];
set(gcf,'NextPlot','add');
axes;
h = title(fnam);
set(gca,'Visible','off');
set(h,'Visible','on'); 
saveas(gcf,[pwd,filesep,fnam],'tif');
close(h2);
%% 
% if (strcmp( sfx ,'Csort'))
    h3=figure; 

    for i=1:length(rois)
         h=subplot(ceil(length(rois)/plotsperrow),plotsperrow,i);

         if(tag_trialtypes ==1) 

            types= unique(trialtypes);  
            temp_avg=zeros(length(types),length(ts));
%              col = [0 0 1; 1 .6 0;1 0 0; .5 0 0 ];
            col = [0 0 1; 0 .5 1; 0 1 0;1 .6 0;1 0 0; .5 0 0  ];
             spacing =cscale(2)-100;
            transparency=.35;
            for k = 1:length(types)
                trials_types=(find(trialtypes==types(k)));  
                    temp_data=newrois(trials_types,1:length(ts),rois(i));
% % %                     stdev  = std(temp_data');
% % %                     blanktrials=find(stdev<20);
% % %                     temp_data(blanktrials,:)=[];
                     temp_avg=mean(temp_data,1);                  
                     temp_sd=(temp_data.^2 + repmat(temp_avg.^2,size(temp_data,1),1) - 2*temp_data.*repmat(temp_avg,size(temp_data,1),1));
                     temp_sd=(mean(temp_sd,1)).^0.5;
                     temp_avg= temp_avg-spacing*(k-1);

%                      jbfill(ts,temp_avg+temp_sd,temp_avg-temp_sd,col(types(k),:),col(types(k),:),1,transparency); hold on;

                     plot(ts ,temp_avg,'color',col(types(k),:),'linewidth',1.5);           
                 hold on;  


            end
                 axis([0 ts(length(ts)) 0-spacing*length(types)+100 300]); set(gca,'YMinorTick','on','YTick', 0-spacing*length(types)+100:100:300);
                 vline([ 1 1.5 2 2.5],'k-');
         else


              transparency=.35;
                temp_data=newrois(:,1:length(ts),rois(i));
                temp_avg=mean(temp_data,1);                  
                temp_sd=(temp_data.^2 + repmat(temp_avg.^2,size(temp_data,1),1) - 2*temp_data.*repmat(temp_avg,size(temp_data,1),1));
                temp_sd=(mean(temp_sd,1)).^0.5;

%                 jbfill(ts,temp_avg+temp_sd,temp_avg-temp_sd,[.5 0 0 ],[.5 0 0 ],1,transparency); hold on;
                plot(ts ,temp_avg,'color',[.5 0 0 ],'linewidth',1.5); set(gca,'YMinorTick','on','YTick',0:100:300); 
    %              plot(ts,newrois(j,:,rois(i))','color',col(j,:),'linewidth',1);
                 axis([0 ts(length(ts)) -20 300]);set(gca,'YMinorTick','on','YTick', 0-20:100:300);

            hold off;       
            vline([.5 ],'r-');
            vline([1 1.5 2 2.5],'k:');

         end


    end

    fnam=[fovname sfx '_roisavgTrace.tif'];
    set(gcf,'NextPlot','add');
    axes;
    h = title(fnam);
    set(gca,'Visible','off');
    set(h,'Visible','on'); 
    saveas(gcf,[pwd,filesep,fnam],'tif');
% end
close(h3);
