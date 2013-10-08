% Script for plotting a volume cube with sections demarcated

figure ; 
imshow(reshape(mean(im(100:120,:,:),1),512,611)',[0 1000]);
hold on ;
z0 = 50;
dz = 15;
cols = jet(11);
cols = cols([1 4 7 10 2 5 8 11 3 6 9],:);
for z=1:33
  ci = floor((z-1)/3) + 1;
  zoffs = (z-1)*dz + z0;
  plot([0 512], [zoffs zoffs+dz], 'Color', cols(ci,:));
end  

figure ; imshow(reshape(mean(im(:,100:120,:),2),512,611)',[0 1000]);
hold on ;
z0 = 50;
dz = 15;
cols = jet(11);
cols = cols([1 4 7 10 2 5 8 11 3 6 9],:);
for z=1:33
  ci = floor((z-1)/3) + 1;
  zoffs = (z-1)*dz + z0;
  plot([0 512], [zoffs zoffs+dz], 'Color', cols(ci,:));
end

figure ; imshow(im(:,:,50), [0 1000]);
