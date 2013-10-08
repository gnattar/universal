function [im1,im2,im3] = splitfile(im)
im1= im(:,:,[41*1:41*20]);
im2= im(:,:,[41*21:41*40]);
im3= im(:,:,[41*41:41*60]);
imwrite_multi(im1,'anm178478_2012_09_06_15_main_186a.tiff');
imwrite_multi(im2,'anm178478_2012_09_06_15_main_186b.tiff');
imwrite_multi(im3,'anm178478_2012_09_06_15_main_186c.tiff');




function imwrite_multi(im,fname)

imwrite(uint16(im(:,:,1)),colormap(gray), fname)
for i = 2:size(im,3)
imwrite(uint16(im(:,:,i)),colormap(gray), fname, 'writemode', 'append')
end
