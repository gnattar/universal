function sort_imtrialsbyBdata(d,solo_data,twindow,s)
cd (d);
list = dir('Image*.tif');
filenames =cell2mat(arrayfun(@(x) x.name(length(x.name)-6 :length(x.name)-4),list,'uniformoutput',false));
imtrials=str2num(filenames);
htrials = solo_data.hitTrialNums(ismember(solo_data.hitTrialNums,imtrials));
mtrials = solo_data.missTrialNums(ismember(solo_data.missTrialNums,imtrials));
crtrials = solo_data.correctRejectionTrialNums(ismember(solo_data.correctRejectionTrialNums,imtrials));
fatrials = solo_data.falseAlarmTrialNums(ismember(solo_data.falseAlarmTrialNums,imtrials));

% htrials
if(length(htrials)>5)
    temp_m_im = zeros(s(1),s(2),length(htrials));
    parfor i = 1:length(htrials)
        n = find (imtrials == htrials(i));
        fname = list(n).name;
        [im,header] = imread_multi_GR(fname, 'g'); s
        if header.SI4.fastZEnable
            tpts = round(twindow / header.SI4.fastZPeriod);
        elseif (~header.SI4.fastZEnable)
            tpts = round(twindow / header.SI4.scanFramePeriod);
        end       
        tinds = tpts(1) : tpts(2);
        tmmat = repmat(mean(im (:,:,tinds),3),1,1,length(tinds));
        temp_m_im(:,:,i) = mean(im (:,:,tinds)-uint16(tmmat),3);    
    end

    imwrite(uint16(temp_m_im(:,:,1)),colormap(gray), ['Bsort_htrials_Mean.tiff'])
    for i = 2:size(temp_m_im,3)
        imwrite(uint16(temp_m_im(:,:,i)),colormap(gray), ['Bsort_htrials_Mean.tiff'], 'writemode', 'append')
    end
    subplot(2,2,1), imagesc(std(temp_m_im,[],3)); colormap(gray);title('Hit')
    'saved Bsort_htrials_Mean.tiff'
end

%% mtrials

if(length(mtrials)>5)
    temp_m_im = zeros(s(1),s(2),length(mtrials));
    timeper =0;
    parfor i = 1:length(mtrials)
        n = find (imtrials == mtrials(i));
        fname = list(n).name
        [im,header] = imread_multi_GR(fname, 'g');
        if header.SI4.fastZEnable
            tpts = round(twindow / header.SI4.fastZPeriod);
        elseif (~header.SI4.fastZEnable)
             tpts = round(twindow / header.SI4.scanFramePeriod);
        end

        tinds = tpts(1) : tpts(2);
        tmmat = repmat(mean(im (:,:,tinds),3),1,1,length(tinds));
        temp_m_im(:,:,i) = mean(im (:,:,tinds)-uint16(tmmat),3);  
    end

    imwrite(uint16(temp_m_im(:,:,1)),colormap(gray), ['Bsort_mtrials_Mean.tiff'])
    for i = 2:size(temp_m_im,3)
        imwrite(uint16(temp_m_im(:,:,i)),colormap(gray), ['Bsort_mtrials_Mean.tiff'], 'writemode', 'append');
    end
    subplot(2,2,2), imagesc(std(temp_m_im,[],3)); colormap(gray);title('Miss');
    'saved Bsort_mtrials_Mean.tiff'
end
%% crtrials
if(length(crtrials)>05)
    temp_m_im = zeros(s(1),s(2),length(crtrials));
    parfor i = 1:length(crtrials)
        n = find (imtrials == crtrials(i));
        fname = list(n).name;
        [im,header] = imread_multi_GR(fname, 'g');
        if header.SI4.fastZEnable
            tpts = round(twindow / header.SI4.fastZPeriod);
        elseif (~header.SI4.fastZEnable)
             tpts = round(twindow / header.SI4.scanFramePeriod);
        end

        tinds = tpts(1) : tpts(2);
        tmmat = repmat(mean(im (:,:,tinds),3),1,1,length(tinds));
        temp_m_im(:,:,i) = mean(im (:,:,tinds)-uint16(tmmat),3);  
    end

    imwrite(uint16(temp_m_im(:,:,1)),colormap(gray), ['Bsort_crtrials_Mean.tiff'])
    for i = 2:size(temp_m_im,3)
        imwrite(uint16(temp_m_im(:,:,i)),colormap(gray), ['Bsort_crtrials_Mean.tiff'], 'writemode', 'append')
    end
    subplot(2,2,3), imagesc(std(temp_m_im,[],3)); colormap(gray);title('CR')
    'saved Bsort_crtrials_Mean.tiff'
end
%% fatrials
if(length(fatrials)>05)
    temp_m_im = zeros(s(1),s(2),length(fatrials));
    for i = 1:length(fatrials)
        n = find (imtrials == fatrials(i));
        fname = list(n).name;
        [im,header] = imread_multi_GR(fname, 'g');
        if header.SI4.fastZEnable
            tpts = round(twindow / header.SI4.fastZPeriod);
        elseif (~header.SI4.fastZEnable)
             tpts = round(twindow / header.SI4.scanFramePeriod);
        end
        tinds = tpts(1) : tpts(2);
        tmmat = repmat(mean(im (:,:,tinds),3),1,1,length(tinds));
        temp_m_im(:,:,i) = mean(im (:,:,tinds)-uint16(tmmat),3);  
    end

    imwrite(uint16(temp_m_im(:,:,1)),colormap(gray), ['Bsort_fatrials_Mean.tiff'])
    for i = 2:size(temp_m_im,3)
        imwrite(uint16(temp_m_im(:,:,i)),colormap(gray), ['Bsort_fatrials_Mean.tiff'], 'writemode', 'append')
    end
    subplot(2,2,4), imagesc(std(temp_m_im,[],3)); colormap(gray);title('FA')
    'saved Bsort_fatrials_Mean.tiff'
end
        saveas(gcf,[pwd,filesep,'sort_by_trialtype'],'fig');
        suptitle('HMCF');
        set(gcf,'PaperUnits','inches');
        set(gcf,'PaperPosition',[1 1 12 12]);
        set(gcf, 'PaperSize', [12,12]);
        set(gcf,'PaperPositionMode','manual');
        saveas(gcf,[pwd,filesep,'sort_by_trialtype'],'jpg');