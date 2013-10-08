if (~exist('vim','var'))
  vim = load_image('an160508_2012_02_08_dz1_stack_0to611_pz250_start_15_001');
end

% can we average? what's that you say Obama?
if (0)
	close all;
	ax  =axes;
	for i=300:500
		imshow(mean(vim(:,:,i-4:i+4),3),[0 1000], 'Parent', ax, 'Border' ,'tight'); 
		pause;
	end
end

% assign a mask . . . (via roiArray)
start_z = 300;
end_z = 500;
start_xy = [138 228];
if (0)
  rA = roi.roiArray();
	tim = mean(vim(:,:,start_z-5:start_z+5),3);
  figure ; imshow(tim,[0 1000]);
  plot(start_xy(1),start_xy(2),'rx');
	rA.masterImage = tim;
  rA.startGui;
end

% now try to follow it thru the stack . . .
if ( 1) 
	load('/data/an160508/l5_play_roiArray.mat');
	rO = obj;

	rA = rO;
	nPixels = length(rO.rois{1}.indices);
	allRs = {};
	%for i=start_z+1:start_z+50
	for i=start_z+1:1:end_z
		nim = mean(vim(:,:,i-5:i+5),3);

		% 1) find best image match in next step based on LAST step
		rB = roi.roiArray();
		rB.masterImage = nim;
		rB.workingImage = nim;

		roi.roiArray.findMatchingRoisInNewImage(rA, rB);

		% 2) generate NEW mask --> a) dilate b) select top N pixels c) restrict to largest connected component
		rB.dilateRoiBorders(3,1);
		rB.fillToBorder(1);
		[irr sidx] = sort(rB.workingImage(rB.rois{1}.indices), 'descend');
		rB.rois{1}.indices = rB.rois{1}.indices(sidx(1:nPixels));

	  rB.removeAllButLargestConnectedComponent(1);
		rB.fitRoiBordersToIndices(1);
 

    % TO DO: how to detect when you are done and fill up the cell?? (look for bimodal luminance distro cutoff in dilated state (or even ultra-dilated state) -- should be fairly clear!)
		
		rA = rB;
		close all;
		tim = nim;
		allRs{i} = rB;

		disp(['done with ' num2str(i)]);
	end
end

% plot
if (1)
	close all;
	ax = axes;
	for i=start_z+1:1:end_z
	  oWi = allRs{i}.workingImage;
		nWi = oWi;
	  nWi(find(nWi > 700)) = 700;
		allRs{i}.workingImage = nWi;
	  allRs{i}.plotImage(0,1,0,[],ax);
		pause(.05);
		allRs{i}.workingImage = oWi;
	end
end

% TO DO: spin the cell!
% TO DO: multiple @ once?
