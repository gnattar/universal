figure('Position', [0 0 800 400]);
ax1 = subplot('Position',[0 0 .5 1]); 
ax2= subplot('Position',[.5 0 .5 1]);

for i=100:200;
  
  imshow(im(:,:,i),[0 2000], 'Parent', ax1, 'Border','tight'); 
%	hold on;
%	 plot([0 512 ; 0 512 ; 0 512 ; 0 512 ; 0 512],[100 100 ; 200 200 ; 300 300 ; 400 400 ; 500 500])
	extern_freezeColors; 
	vec = reshape(im(:,:,i),[],1);
	imshow(segmented(:,:,i),[min(vec(find(vec > 0))) max(vec)], 'Parent', ax2, 'Border','tight');
%	hold on;
%	 plot([0 512 ; 0 512 ; 0 512 ; 0 512 ; 0 512],[100 100 ; 200 200 ; 300 300 ; 400 400 ; 500 500])
	colormap jet; 
	pause ;
end

