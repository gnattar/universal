function im_avg= makeavgzstack(im,nframes)
%[im, header] = imread_multi_GR('anm178478_2012_09_06_15_main_186.tif', 'g')
temp = uint16(zeros(size(im,1),size(im,2),size(im,3)/nframes));
% temp = zeros(size(im,1),size(im,2),nframes);
im_avg=uint16(zeros(size(im,1),size(im,2),size(im,3)/nframes));
count=0;
% for i = 1:size(im,3)/nframes
    for i = 1:nframes
     temp = im(:,:,count+1:count+size(im,3)/nframes);
     im_avg =im_avg+ temp;
     count=count+size(im,3)/nframes;
% % %    temp = im(:,:,count+1:count+nframes);
% % %    im_avg(:,:,i) = mean(temp,3);
% % %     count=count+nframes;
end
im_avg(:,:,:)=im_avg(:,:,:)./nframes;
imwrite(uint16(im_avg(:,:,1)),colormap(gray), 'zstack_397.tiff')
for i = 2:size(im,3)/nframes
imwrite(uint16(im_avg(:,:,i)),colormap(gray), 'zstack_397.tiff', 'writemode', 'append')
end