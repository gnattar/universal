cd /data/an166555/2012_04_23/scanimage/fov_01002/fluo_batch_out/


imwc = 'Image_Registration_4*main_20*tif';
fl = dir(imwc);
fidx = [];
inReach = [10 25];
for f=1:length(fl)
  info = imfinfo(fl(f).name);

  fidx = [fidx 1:length(info)];
end

im = load_image(imwc);

aviobj = avifile ('/home/speron/Desktop/L4_movie_an166555.avi');
f =figure;
ax = axes;
for i=1:size(im,3)-10
  imshow(mean(im(:,:,i:i+10),3),[0 500], 'Parent', ax, 'Border', 'tight');
  if (fidx(i) >= inReach(1) & fidx(i) <= inReach(2))
	  hold on;
		rectangle ('Position', [20 20 20 20], 'FaceColor' , [1 1 1]);
	end
	F = getFrame(f);
	aviobj = addframe(aviobj,F);
	pause(.05);
	cla;
end
aviobj = close(aviobj);

