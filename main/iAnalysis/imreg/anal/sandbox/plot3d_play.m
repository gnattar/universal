if (length(strfind(pwd, '167951')) == 1)  
  wt = 'C3';
	maxZ = 600;
	barr_cen = [320 200];
	d_2to1 = [294 165];
elseif (length(strfind(pwd, '171923')) == 1)
  wt = 'C2';
	maxZ = 600;
	barr_cen = [230 270];
	d_2to1 = [93 -267];
end

%% --- data collection
if (1)
  ampCorr = [];
  spCorr = [];
  touchScore1 = [];
  touchScore2 = [];
  pTouchScore1 = [];
  pTouchScore2 = [];
  rTouchScore1 = [];
  rTouchScore2 = [];

	ri = 1;
 
  fl = dir('*vol*sess.mat');

  for v=1:length(fl)
		load(fl(v).name);

    ampCorr = [ampCorr s.cellFeatures.get('MeanWhiskerAmplitudeCorr')];
    spCorr = [spCorr s.cellFeatures.get('WhiskerSetpointCorr')];
    touchScore1 = [touchScore1 s.cellFeatures.get(['ContactsFor' wt 'AUC'])];
    touchScore2 = [touchScore2 s.cellFeatures.get(['ContactsFor' wt 'PProd'])];
    pTouchScore1 = [pTouchScore1 s.cellFeatures.get(['ProtractionContactsFor' wt 'AUC'])];
    pTouchScore2 = [pTouchScore2 s.cellFeatures.get(['ProtractionContactsFor' wt 'PProd'])];
    rTouchScore1 = [rTouchScore1 s.cellFeatures.get(['RetractionContactsFor' wt 'AUC'])];
    rTouchScore2 = [rTouchScore2 s.cellFeatures.get(['RetractionContactsFor' wt 'PProd'])];
    
    % x,y,z
		if (0)
			for f=1:3
				rA = s.caTSA.roiArray{f};
				z = (45*v) + 15*f;
				for r=1:rA.length
					rX(ri) = nanmean(s.caTSA.roiArray{f}.rois{r}.corners(1,:)); 
					rY(ri) = nanmean(s.caTSA.roiArray{f}.rois{r}.corners(2,:)); 
					rZ(ri) = z;
					ri = ri+1;
				end
			end
		end
		if (1) % collect from other data
		  rX = n_roi_centers(:,1);
		  rY = n_roi_centers(:,2);
			rZ = 0*rX;
			for r=1:size(roi_vol,1);
			  rv = roi_vol(r,:);
				if (rv(1) > 8) ; rv(1) = rv(1) - 8 ; end
			  rZ(r) = rv(1)*45 + (rv(2)*15);
		  end
		end
	end
end

mX = 100*floor(min(rX)/100)-200;
mY = 100*floor(min(rY)/100)-200;
axLims = [barr_cen(1)-500 barr_cen(1)+500 barr_cen(2)-500 barr_cen(2)+500 0 1000];
camPos = [-800 -800 1000];


%if (length(find(rX < 0)) < 5)
 % rX = rX - barr_cen(1);
 % rY = rY - barr_cen(2);
%end

%% --- points ...
if (0)
  z = 200;
  close all;
	figure('Position',[0 0 1200 800]);
	hold on;
	hc = {};


	% all cells
	if (1)
		hc{length(hc) + 1} = plot3(rX, rY, maxZ-rZ, 'k.', 'MarkerSize',1,'MarkerFaceColor', 'k');
	end

  % filter?
	if (1) % whisking cells
		thresh = 0.1;
		idx = find(ampCorr > thresh | spCorr > thresh);
		hc{length(hc) + 1} = plot3(rX(idx), rY(idx), maxZ-rZ(idx), 'g.', 'MarkerSize', 10, 'MarkerFaceColor','g');
	end

	if (1) % touch cells
		thresh = 0.575;
		thresh = 0.05;
		idx = find(touchScore2>= thresh);
		hc{length(hc)+1} = plot3(rX(idx), rY(idx), maxZ-rZ(idx), 'r.', 'MarkerSize', 10, 'MarkerFaceColor','r');
	end

	if (0) % touch cells
		thresh = 0.75;
		thresh = 0.075;
		idx = find(rTouchScore2 >= thresh);
		hc{length(hc)+1} = plot3(rX(idx), rY(idx), maxZ-rZ(idx), 'm.', 'MarkerSize', 10, 'MarkerFaceColor','m');
		idx = find(pTouchScore2 >= thresh);
		hc{length(hc)+1} = plot3(rX(idx), rY(idx), maxZ-rZ(idx), 'c.', 'MarkerSize', 10, 'MarkerFaceColor','c');
	end


	% rotate individual graphics objects
	dTheta = 5;
	cX = barr_cen(1);
	cY = barr_cen(2);
	cZ = maxZ - z;
	rotAx = [0 0 1];
	set(gca,'XTick',[]);
	set(gca,'YTick',[]);
	set(gca,'ZTick',[]);
	for theta=0:dTheta:360
%    set(gca,'Visible','off');

	  hold on;
		for hi=1:length(hc)
			rotate(hc{hi},rotAx,5,[cX cY cZ]);
		end

    % fix perspective
		axis (axLims)

		% camera
		set (gca,'CameraPosition', camPos);
		set (gca,'CameraTarget', 	[cX cY cZ]);


		pause(.1);
	end
end

%% --- stack
if (0)
	figure;
	hold on;
%	for i=50:100:550;

	% draw the individual surfaces ... no edges etc.

	% tangential
	z = 200;
  sim = im(:,:,z);
  [X,Y] = meshgrid(1:512,1:512);
  xi = 1:512 ; 
	yi = xi;
	hs{1} = surf(X(xi,yi),Y(xi,yi),sim(xi,yi)*0 + (size(im,3) - z),sim(xi,yi), ...
	  'EdgeColor','none','EdgeAlpha',1,'LineStyle','none') ; 
	hold on;

  % coronal along Y
  y = 256;
  y = 200;
  sim = im(y,:,:);
%  [X,Z] = meshgrid(1:size(sim,3),1:512);
  [X,Z] = meshgrid(1:512,1:size(sim,3));
  zi = 1:512 ; 
	xi = 1:size(sim,3);
	sim = reshape(sim, 512, size(sim,3))';
	sim = flipud(sim);
	hs{2} = surf(X(xi,zi),y + 0*X(xi,zi),Z(xi,zi),sim(xi,zi), ...
	  'EdgeColor','none','EdgeAlpha',1,'LineStyle','none') ; 

  % coronal along X
  x = 200;
  sim = im(:,x,:);
%  [X,Z] = meshgrid(1:size(sim,3),1:512);
  [Y,Z] = meshgrid(1:512,1:size(sim,3));
  zi = 1:512 ; 
	yi = 1:size(sim,3);
	sim = reshape(sim, 512, size(sim,3))';
	sim = flipud(sim);
	hs{3} = surf(x + 0*Y(yi,zi),Y(yi,zi),Z(yi,zi),sim(yi,zi), ...
	  'EdgeColor','none','EdgeAlpha',1,'LineStyle','none') ; 

  % colormap 
	colormap gray;
	set(gca,'CLim', [0 500]);

	% rotate individual graphics objects
	dTheta = 5;
	cX = 512/2;
	cY = 512/2;
	cZ = size(im,3) - z;
	rotAx = [0 0 1];
	set(gca,'XTick',[]);
	set(gca,'YTick',[]);
	set(gca,'ZTick',[]);
	for theta=0:dTheta:360
    set(gca,'Visible','off');
%		set(gca, 'CameraPosition', [camX camY cZ]);

    for hi=1:length(hs)
			rotate(hs{hi},rotAx,5,[cX cY cZ]);
		end

    % fix perspective
		axis ([-100 700 -100 700 0 800]);

		% camera
		set (gca,'CameraPosition', 	[-800 -800 1000]);
		set (gca,'CameraTarget', 	[cX cY cZ]);


		pause(.1);
	end
end

%% --- combo
if (1)
  close all;
	fig =figure('Position',[0 0 800 800]);
	hold on;
	hc = {};
	hs = {};
	if (1)
		maxZ = size(im,3);


		% draw the individual surfaces ... no edges etc.
		qth = .9995;

		% tangential
		z = 200;
		sim = im(:,:,z);
		msim = quantile(reshape(sim,[],1),qth);
		sim = 500*double(double(sim)/msim) ; sim(find(sim > msim)) = 500;
		[X,Y] = meshgrid(1:512,1:512);
		xi = 1:512 ; 
		yi = xi;
		hs{1} = surf(X(xi,yi),Y(xi,yi),sim(xi,yi)*0 + (size(im,3) - z),double(sim(xi,yi)), ...
			'EdgeColor','none','EdgeAlpha',1,'LineStyle','none') ; 
		hold on;
		if (1)
  		sim2 = im2(:,:,z);
		  msim2 = quantile(reshape(sim2,[],1),qth);
		  msim2 = quantile(reshape(sim2,[],1),.995);
		  sim2 = 500*double(sim2)/msim2 ; sim2(find(sim2 > msim2)) = 500;
	  	hs{length(hs)+1} = surf(d_2to1(1)+X(xi,yi),d_2to1(2)+Y(xi,yi),sim2(xi,yi)*0 + (size(im,3) - z),double(sim2(xi,yi)), ...
		  	'EdgeColor','none','EdgeAlpha',1,'LineStyle','none') ; 
		end


		% coronal along Y
		y = barr_cen(2);
		sim = im(y,:,:);
		msim = quantile(reshape(sim,[],1),qth);
		sim = 500*double(double(sim)/msim) ; sim(find(sim > msim)) = 500;
	%  [X,Z] = meshgrid(1:size(sim,3),1:512);
		[X,Z] = meshgrid(1:512,1:size(sim,3));
		zi = 1:512 ; 
		xi = 1:size(sim,3);
		sim = reshape(sim, 512, size(sim,3))';
		sim = flipud(sim);
		hs{length(hs)+1} = surf(X(xi,zi),y + 0*X(xi,zi),Z(xi,zi),double(sim(xi,zi)), ...
			'EdgeColor','none','EdgeAlpha',1,'LineStyle','none') ; 

		% coronal along X
		x = barr_cen(1);
		sim = im(:,x,:);
		msim = quantile(reshape(sim,[],1),qth);
		sim = 500*double(double(sim)/msim) ; sim(find(sim > msim)) = 500;
	%  [X,Z] = meshgrid(1:size(sim,3),1:512);
		[Y,Z] = meshgrid(1:512,1:size(sim,3));
		zi = 1:512 ; 
		yi = 1:size(sim,3);
		sim = reshape(sim, 512, size(sim,3))';
		sim = flipud(sim);
		hs{length(hs)+1} = surf(x + 0*Y(yi,zi),Y(yi,zi),Z(yi,zi),double(sim(yi,zi)), ...
			'EdgeColor','none','EdgeAlpha',1,'LineStyle','none') ; 

		% colormap 
		colormap gray;
		set(gca,'CLim', [0 500]);
  end

	% all cells
	if (1)
		hc{length(hc) + 1} = plot3(rX, rY, maxZ-rZ, 'b.', 'MarkerSize', 1);
	end

  % filter?
	if (1) % whisking cells
		thresh = 0.1;
		idx = find(ampCorr > thresh | spCorr > thresh);
		hc{length(hc) + 1} = plot3(rX(idx), rY(idx), maxZ-rZ(idx), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
	end

	if (1) % touch cells
		thresh = 0.05;
		idx = find(touchScore2 >= thresh);
		hc{length(hc)+1} = plot3(rX(idx), rY(idx), maxZ-rZ(idx), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
	end

	if (0) % touch cells
		thresh = 0.75;
		thresh = 0.075;
		idx = find(rTouchScore2 >= thresh);
		hc{length(hc)+1} = plot3(rX(idx), rY(idx), maxZ-rZ(idx), 'mo', 'MarkerSize', 10, 'MarkerFaceColor', 'm');
		idx = find(pTouchScore2 >= thresh);
		hc{length(hc)+1} = plot3(rX(idx), rY(idx), maxZ-rZ(idx), 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
	end


	% rotate individual graphics objects
	dTheta = 2;
	cX = barr_cen(1);
	cY = barr_cen(2);
	cZ = maxZ - z;
	rotAx = [0 0 1];
	set(gca,'XTick',[]);
	set(gca,'YTick',[]);
	set(gca,'ZTick',[]);

  aviobj = avifile('~/Desktop/spin3_cells.avi');

	for theta=0:dTheta:360
%    set(gca,'Visible','off');

	  hold on;
		for hi=1:length(hc)
			rotate(hc{hi},rotAx,dTheta,[cX cY cZ]);
		end

    for hi=1:length(hs)
			rotate(hs{hi},rotAx,dTheta,[cX cY cZ]);
		end

    % fix perspective
%		lims = [-50 650 -50 650 -50 650];
		axis (axLims);

		% camera
		set (gca,'CameraPosition', 	camPos);
		set (gca,'CameraTarget', 	[cX cY cZ]);



		F = getframe(fig);
		aviobj = addframe(aviobj,F);
		drawnow;
	end
	aviobj = close(aviobj);

end


%% --- combo 2 subplots
if (0)
  close all;
	fig = figure('Position',[0 0 1200 600]);
	ax1 = subplot('Position', [0 0 0.5 5/6]);
	ax2 = subplot('Position', [0.5 0 0.5 5/6]);
	hold on;
	hc = {};
	maxZ = size(im,3);


	% draw the individual surfaces ... no edges etc.

	% tangential
	subplot(ax1);
	z = 200;
  sim = im(:,:,z);
  [X,Y] = meshgrid(1:512,1:512);
  xi = 1:512 ; 
	yi = xi;
	hs{1} = surf(X(xi,yi),Y(xi,yi),sim(xi,yi)*0 + (size(im,3) - z),sim(xi,yi), ...
	  'EdgeColor','none','EdgeAlpha',1,'LineStyle','none') ; 
	hold on;

  % coronal along Y
  y = 256;
  y = 200;
  sim = im(y,:,:);
%  [X,Z] = meshgrid(1:size(sim,3),1:512);
  [X,Z] = meshgrid(1:512,1:size(sim,3));
  zi = 1:512 ; 
	xi = 1:size(sim,3);
	sim = reshape(sim, 512, size(sim,3))';
	sim = flipud(sim);
	hs{2} = surf(X(xi,zi),y + 0*X(xi,zi),Z(xi,zi),double(sim(xi,zi)), ...
	  'EdgeColor','none','EdgeAlpha',1,'LineStyle','none') ; 

  % coronal along X
  x = 200;
  sim = im(:,x,:);
%  [X,Z] = meshgrid(1:size(sim,3),1:512);
  [Y,Z] = meshgrid(1:512,1:size(sim,3));
  zi = 1:512 ; 
	yi = 1:size(sim,3);
	sim = reshape(sim, 512, size(sim,3))';
	sim = flipud(sim);
	hs{3} = surf(x + 0*Y(yi,zi),Y(yi,zi),Z(yi,zi),sim(yi,zi), ...
	  'EdgeColor','none','EdgeAlpha',1,'LineStyle','none') ; 

  % colormap 
	colormap gray;
	set(gca,'CLim', [0 500]);

	% all cells
	subplot(ax2);
	if (1)
%		hc{length(hc) + 1} = plot3(rX, rY, maxZ-rZ, 'y.');
	end

  % filter?
	if (1) % whisking cells
		thresh = 0.1;
		idx = find(ampCorr > thresh | spCorr > thresh);
		hc{length(hc) + 1} = plot3(rX(idx), rY(idx), maxZ-rZ(idx), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
	end

	if (0) % touch cells
		thresh = 0.075;
		idx = find(touchScore2 >= thresh);
		hc{length(hc)+1} = plot3(rX(idx), rY(idx), maxZ-rZ(idx), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
	end

	if (1) % touch cells
		thresh = 0.75;
		thresh = 0.075;
		idx = find(rTouchScore2 >= thresh);
		hc{length(hc)+1} = plot3(rX(idx), rY(idx), maxZ-rZ(idx), 'mo', 'MarkerSize', 10, 'MarkerFaceColor', 'm');
		idx = find(pTouchScore2 >= thresh);
		hc{length(hc)+1} = plot3(rX(idx), rY(idx), maxZ-rZ(idx), 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
	end


	% rotate individual graphics objects
	dTheta = 2;
	cX = barr_cen(1);
	cY = barr_cen(2);
	cZ = maxZ - z;
	rotAx = [0 0 1];
	set(ax1,'XTick',[],'ZTick',[],'YTick',[]);
	set(ax2,'XTick',[],'ZTick',[],'YTick',[]);
 
  aviobj = avifile('~/Desktop/spin2_cells.avi');

	for theta=0:dTheta:360
    set(ax1,'Visible','off');
%    set(ax2,'Visible','off');
%    set(gca,'Visible','off');

	  hold on;
		for hi=1:length(hc)
			rotate(hc{hi},rotAx,dTheta,[cX cY cZ]);
		end

    for hi=1:length(hs)
			rotate(hs{hi},rotAx,dTheta,[cX cY cZ]);
		end

    % fix perspective
		lims = [-100 700 -100 700 0 800];
		lims = [-50 650 -50 650 -50 650];
		subplot(ax1); axis (lims);
		subplot(ax2); axis (lims);

		% camera
		set (ax1,'CameraPosition', 	[-800 -800 1000],'CameraTarget', 	[cX cY cZ]);
		set (ax2,'CameraPosition', 	[-800 -800 1000],'CameraTarget', 	[cX cY cZ]);


		F = getframe(fig);
		aviobj = addframe(aviobj,F);
		pause(.1);
	end
	aviobj = close(aviobj);
end


