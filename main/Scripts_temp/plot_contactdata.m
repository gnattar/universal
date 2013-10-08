function [roidata] = plot_contactdata(contact_CaTrials,roiNos)
numtrials=size(contact_CaTrials,2);
barpos = cell2mat(arrayfun(@(x) x.barpos, contact_CaTrials([1:numtrials]),'uniformoutput',false))';
pos=unique(barpos);
for i = 1:numtrials
    data = contact_CaTrials(i).dff;
    dFFArray = data(roiNos,:);
    roi_eventtrials(:,i) =  eventsdetected(dFFArray);
    barposind(i)=find(pos==barpos(i));
end
numrois=length(roiNos);
inds = [floor(.5/contact_CaTrials(1,1).FrameTime) : ceil(1.5/contact_CaTrials(1,1).FrameTime)];
dFF = arrayfun(@(x) x.dff(roiNos,inds)', contact_CaTrials([1:numtrials]),'uniformoutput',false);
dFF=reshape(cell2mat(dFF),length(inds),numrois,numtrials);
dFF_mean = squeeze(max(dFF))';


dKappa = arrayfun(@(x) x.deltaKappa{1}, contact_CaTrials([1:numtrials]),'uniformoutput',false); 
numptns = size(dKappa{1},2);
inds=[floor(0.5/.002):ceil(1.5/.002)];
dKappa_mean=reshape(cell2mat(dKappa),numtrials,numptns);
dKappa_mean = mean(dKappa_mean(:,inds),2);


theta = arrayfun(@(x) x.theta{1}, contact_CaTrials([1:numtrials]),'uniformoutput',false); 
numptns = size(theta{1},2);
inds=[floor(0.5/.002):ceil(1.5/.002)];
theta_med=reshape(cell2mat(theta),numtrials,numptns);
theta_med = median(theta_med(:,inds),2);

contacts =arrayfun(@(x) x.contacts{1}, contact_CaTrials([1:numtrials]),'uniformoutput',false);
    figure;
col = jet(length(pos));

markers = {'s','o','h','d','p','h'};
for j = 1: numrois
    trials = roi_eventtrials(j,:);
    trialsoi = find(trials); 
    numtrials = size(trialsoi,2);
    ha(j) = subaxis(numrois,1,j, 'sv', 0.05);
   scatter(dKappa_mean( trialsoi),dFF_mean( trialsoi,j),100,col(barposind(trialsoi),:),'sq','filled');
   axis([0 .08 -10 max(dFF_mean( trialsoi,j))+30] ); 
    title(['dFFmax vs. dKappa_mean Rois ' num2str(roiNos(j)) ' Blue - Ant, Red- Post' ]);
   colorbar;
    
end

figure;
for j = 1: numrois
    trials = roi_eventtrials(j,:);
    trialsoi = find(trials); 
    numtrials = size(trialsoi,2);
    ha(j) = subaxis(numrois,1,j, 'sv', 0.05);
   scatter(theta_med( trialsoi),dFF_mean( trialsoi,j),100,col(barposind(trialsoi),:),'sq','filled');
%    axis([0 30 -10 max(dFF_mean( trialsoi,j))+30] ); 
    title(['dFFmax vs. theta_med Rois ' num2str(roiNos(j)) ' Blue - Ant, Red- Post' ]);
%    colorbar;
    
end

figure;

   
 function [eventrois] = eventsdetected(dFFArray)
    eventrois = zeros(size(dFFArray,1),1);
    stdev=std(dFFArray');
    eventrois(find(stdev>25))=1;
    potential=find(25>stdev>15);
    eventrois(potential)=1;
     for i = 1:length(potential)
         signal=dFFArray(potential(i),:);
         f0=repmat(mean(signal(1:15)),size(signal,2),1);
         f1=f0;
         f1(21:60)=150;
         f1(61:end)=50;
         if(sum((signal'-f1).^2) < sum((signal'-f0).^2))
            eventrois(potential(i))=1;
         else 
             eventrois(potential(i))=0;
         end
            
     end

