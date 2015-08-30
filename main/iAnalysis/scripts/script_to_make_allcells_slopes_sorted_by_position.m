% script_to_make_allcells_slopes_sorted_by_position

%run the dfollowing after loading each pooled_contactCaTrials_locdep file
%adjusting for n as cumcellcount
S=zeros(118,7);
n=0;
for i = n+1:n+size(pooled_contactCaTrials_locdep,2)
    d =[1:size(pooled_contactCaTrials_locdep,2)];
    temp=cell2mat(cellfun(@(x) x.fitmean.NLslopes(:,1,1), pooled_contactCaTrials_locdep,'uni',0))';
     S(n+d,[1:6]) = temp(:,:)
end

%once all cells are collected or load Slopes.mat
S(find(S==0))=nan;

[Smin,Sminpos] = nanmin(S');
Smin=Smin';Sminpos=Sminpos';
tempmin = repmat(Smin,1,6);

Ssub=S-tempmin;
[Smax,Smaxpos] = nanmax(Ssub');
 Smax=Smax';Smaxpos=Smaxpos';
tempmax=repmat(Smax,1,6);

Snorm=Ssub./tempmax;
[y,i]=sort(Smaxpos);
Snorm_sorted = Snorm(i,:);

figure;imagesc(Snorm_sorted)
suptitle('Norm Slopes all cells sorted by position Control Data')