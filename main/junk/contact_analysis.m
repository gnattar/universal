function [roidata] = plot_contactdata(roiNos)
global contact_CaTrials
% figure;
for i = 1:size(contact_CaTrials,2)
    data = contact_CaTrials{1,i}.dFF;
    dFFArray = data(roiNos,:);
    roi_eventtrials(:,i) =  eventsdetected(dFFArray);
end

for j = 1: length(roiNos)
   dKappa = cellfun(@(x) x.deltaKappa{1}, contact_CaTrials,'uniformoutput',false);  
  for k = 1: size(contact_CaTrials,2)
    
  end
end

   ha(1) = subaxis(5,1,1, 'sv', 0.05);

   
 function [p] = eventsdetected(dFFArray)
    eventrois = zeros(size(dFFArray,1),1);
    stdev=std(dFFArray);
    potential=find(stdev>15);
     for i = 1:length(potential)
         signal=dFFArray(potential(i),:);
         f0=repmat(mean(signal(1:15)),size(signal,2),1);
         f1=f0;
         f1(16:end)=150;
         if(sum((signal-f1).^2) < sum((signal-f0).^2))
            eventrois(potential(i))=1;
         end
            
     end

