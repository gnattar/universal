function [r,id]=test_corr(obj)
numcells = size(obj,2);
r = zeros((numcells*(numcells+1)/2)-numcells,9,2);
id = zeros((numcells*(numcells+1)/2)-numcells,2);
count =1;
for i =1:numcells
    for j= i+1:numcells
        id(count,1) = obj{i}.dend;
        id(count,2) = obj{j}.dend;
        temp1=obj{i}.rawdata(obj{i}.lightstim==0,:);
        temp2 =obj{j}.rawdata(obj{j}.lightstim==0,:);
        temp1(isnan(temp1)) =0;
        temp2(isnan(temp2))=0;
        r(count,1,1) = corr2(temp1,temp2);
        r(count,2,1) = obj{i}.dend;
        r(count,3,1) = obj{j}.dend;
% %         r(count,2,1) = obj{i}.eventrate_NL(1,1);
% %         r(count,3,1) = obj{j}.eventrate_NL(1,1);
%         r(count,4,1) = nanmean(obj{i}.intarea(obj{i}.eventsdetected&~obj{i}.lightstim));
%         r(count,5,1) = nanmean(obj{j}.intarea(obj{j}.eventsdetected&~obj{i}.lightstim));
%         r(count,6,1) = nanmean(obj{i}.peakamp(obj{i}.eventsdetected&~obj{i}.lightstim));
%         r(count,7,1) = nanmean(obj{j}.peakamp(obj{j}.eventsdetected&~obj{i}.lightstim));        
%         r(count,8,1) = nanmean(obj{i}.fwhm(obj{i}.eventsdetected&~obj{i}.lightstim));
%         r(count,9,1) = nanmean(obj{j}.fwhm(obj{j}.eventsdetected&~obj{i}.lightstim));   
%         
        
        temp1=obj{i}.rawdata(obj{i}.lightstim==1,:);
        temp2 =obj{j}.rawdata(obj{j}.lightstim==1,:);
        temp1(isnan(temp1)) =0;
        temp2(isnan(temp2))=0;
        r(count,1,2) = corr2(temp1,temp2);
        r(count,2,2) = obj{i}.eventrate_L(1,1);
        r(count,3,2) = obj{j}.eventrate_L(1,1);
        r(count,4,2) = nanmean(obj{i}.intarea(obj{i}.eventsdetected&obj{i}.lightstim));
        r(count,5,2) = nanmean(obj{j}.intarea(obj{j}.eventsdetected&obj{i}.lightstim));
        r(count,6,2) = nanmean(obj{i}.peakamp(obj{i}.eventsdetected&obj{i}.lightstim));
        r(count,7,2) = nanmean(obj{j}.peakamp(obj{j}.eventsdetected&obj{i}.lightstim));        
        r(count,8,2) = nanmean(obj{i}.fwhm(obj{i}.eventsdetected&obj{i}.lightstim));
        r(count,9,2) = nanmean(obj{j}.fwhm(obj{j}.eventsdetected&obj{i}.lightstim));   
        count = count +1;
    end
end