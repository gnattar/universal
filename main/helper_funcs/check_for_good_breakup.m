% % function [cim,fim,mim] = check_for_good_breakup(d,refname,frames)
% % cd (d);
% % [ref, header] = imread_multi_GR(refname, 'g');
% % files = dir('*.tif');
% % num= size(files,1);
% % cim = zeros(num,1);
% % fim = [];
% % mim = zeros(size(ref,1),size(ref,2),num);
% % for i=1:num
% %     
% %     name = files(i).name;
% %     fim(i) =  str2num(name(length(name)-6:length(name)-4));
% %     [im, header] = imread_multi_GR(name, 'g');
% %     im2 = mean(im(:,:,frames),3);
% %     rim = mean(ref(:,:,frames),3);
% %     cim(i) = corr2(im2,rim);
% %     mim(:,:,i) = im2;
% % end
% % 
% % 
% %     imwrite(uint16(mim(:,:,1)),colormap(gray), ['Mean_im.tiff']);
% %     for i = 2:num
% %         imwrite(uint16(mim(:,:,i)),colormap(gray), ['Mean_im.tiff'], 'writemode', 'append');
% %     end
% %     'saved mean.tiff'

    %%%%%%%%
    
    function [cim,fim] = check_for_good_breakup(d,refname,frames)
cd (d);
[ref, header] = imread_multi_GR(refname, 'g');
files = dir('*.tif');
num= size(files,1);
cim = zeros(num,1);
fim = [];
for i=1:num
    [ num2str(i) ' of ' num2str(num)]
    name = files(i).name;
    fim(i) =  str2num(name(length(name)-6:length(name)-4));
    [im, header] = imread_multi_GR(name, 'g');
    im2 = mean(im(:,:,frames),3);
    rim = mean(ref(:,:,frames),3);
    cim(i) = corr2(im2,rim);
    if(i==1)
         imwrite(uint16(im2),colormap(gray), ['Mean_im.tiff']);
    elseif(i>1)
        imwrite(uint16(im2),colormap(gray), ['Mean_im.tiff'], 'writemode', 'append');
    end
    im=[];im2=[];
end

    'saved mean.tiff'
