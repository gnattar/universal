function sort_imtrialsbyBdata(d,solo_data,twindow,s)
cd (d);
list = dir('Image*.tif');
filenames =cell2mat(arrayfun(@(x) x.name(length(x.name)-6 :length(x.name)-4),list,'uniformoutput',false));
imtrials=str2num(filenames);
htrials = solo_data.hitTrialNums(ismember(solo_data.hitTrialNums,imtrials));
mtrials = solo_data.missTrialNums(ismember(solo_data.missTrialNums,imtrials));
crtrials = solo_data.correctRejectionTrialNums(ismember(solo_data.correctRejectionTrialNums,imtrials));
fatrials = solo_data.falseAlarmTrialNums(ismember(solo_data.falseAlarmTrialNums,imtrials));

%% htrials
temp_m_im = zeros(s(1),s(2),length(htrials));
parfor i = 1:length(htrials)
    n = find (imtrials == htrials(i));
    fname = list(n).name
    [im,header] = imread_multi_GR(fname, 'g');
    timeper =  (header.SI4.fastZEnable)*header.SI4.fastZPeriod +  (~header.SI4.fastZEnable)*header.SI4.scanFramePeriod;
    tpts = round(twindow / timeper);
    tinds = tpts(1) : tpts(2);
    tmmat = repmat(mean(im (:,:,tinds),3),1,1,length(tinds));
    temp_m_im(:,:,i) = mean(im (:,:,tinds)-uint16(tmmat),3);    
end

imwrite(uint16(temp_m_im(:,:,1)),colormap(gray), ['Bsort_htrials_Mean.tiff'])
for i = 2:size(temp_m_im,3)
    imwrite(uint16(temp_m_im(:,:,i)),colormap(gray), ['Bsort_htrials_Mean.tiff'], 'writemode', 'append')
end
'saved Bsort_htrials_Mean.tiff'
%% mtrials
temp_m_im = zeros(s(1),s(2),length(mtrials));
parfor i = 1:length(mtrials)
    n = find (imtrials == mtrials(i));
    fname = list(n).name
    [im,header] = imread_multi_GR(fname, 'g');
    timeper =  (header.SI4.fastZEnable)*header.SI4.fastZPeriod +  (~header.SI4.fastZEnable)*header.SI4.scanFramePeriod;
    tpts = round(twindow / timeper);
    tinds = tpts(1) : tpts(2);
    tmmat = repmat(mean(im (:,:,tinds),3),1,1,length(tinds));
    temp_m_im(:,:,i) = mean(im (:,:,tinds)-uint16(tmmat),3);  
end

imwrite(uint16(temp_m_im(:,:,1)),colormap(gray), ['Bsort_mtrials_Mean.tiff'])
for i = 2:size(temp_m_im,3)
    imwrite(uint16(temp_m_im(:,:,i)),colormap(gray), ['Bsort_mtrials_Mean.tiff'], 'writemode', 'append');
end
'saved Bsort_mtrials_Mean.tiff'
%% crtrials
temp_m_im = zeros(s(1),s(2),length(crtrials));
parfor i = 1:length(crtrials)
    n = find (imtrials == crtrials(i));
    fname = list(n).name;
    [im,header] = imread_multi_GR(fname, 'g');
    timeper =  (header.SI4.fastZEnable)*header.SI4.fastZPeriod +  (~header.SI4.fastZEnable)*header.SI4.scanFramePeriod;
    tpts = round(twindow / timeper);
    tinds = tpts(1) : tpts(2);
    tmmat = repmat(mean(im (:,:,tinds),3),1,1,length(tinds));
    temp_m_im(:,:,i) = mean(im (:,:,tinds)-uint16(tmmat),3);  
end

imwrite(uint16(temp_m_im(:,:,1)),colormap(gray), ['Bsort_crtrials_Mean.tiff'])
for i = 2:size(temp_m_im,3)
    imwrite(uint16(temp_m_im(:,:,i)),colormap(gray), ['Bsort_crtrials_Mean.tiff'], 'writemode', 'append')
end
'saved Bsort_crtrials_Mean.tiff'
%% fatrials
temp_m_im = zeros(s(1),s(2),length(fatrials));
parfor i = 1:length(fatrials)
    n = find (imtrials == fatrials(i));
    fname = list(n).name;
    [im,header] = imread_multi_GR(fname, 'g');
    timeper =  (header.SI4.fastZEnable)*header.SI4.fastZPeriod +  (~header.SI4.fastZEnable)*header.SI4.scanFramePeriod;
    tpts = round(twindow / timeper);
    tinds = tpts(1) : tpts(2);
    tmmat = repmat(mean(im (:,:,tinds),3),1,1,length(tinds));
    temp_m_im(:,:,i) = mean(im (:,:,tinds)-uint16(tmmat),3);  
end

imwrite(uint16(temp_m_im(:,:,1)),colormap(gray), ['Bsort_fatrials_Mean.tiff'])
for i = 2:size(temp_m_im,3)
    imwrite(uint16(temp_m_im(:,:,i)),colormap(gray), ['Bsort_fatrials_Mean.tiff'], 'writemode', 'append')
end
'saved Bsort_fatrials_Mean.tiff'