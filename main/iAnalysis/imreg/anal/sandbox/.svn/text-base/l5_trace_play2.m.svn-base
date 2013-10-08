%
%
% start_z = 368 ; end_z = 619 ;
% tim = mean(vim(:,:,start_z-5:start_z+5),3);
% figure ; imshow(tim,[0 1000]);
% rA = roi.roiArray();
% rA.masterImage = tim;
% rA.startGui;
%
% select it . . . 
%
% l5_trace_play2(vim, rA, start_z, end_z)
%
function l5_trace_play2(rO, rId, vim)
% now try to follow it thru the stack . . .

  % Prep work
	rA = rO;
	rIdx = find(rO.roiIds == rId);
	nPixels = length(rO.rois{rIdx}.indices);
	allRs = {};

  % map to volume
  [col row] = get_xy_from_idx(rO.rois{rIdx}.indices, size(rO.refStackMap.X));
	X = 0*length(col);
	Y = 0*length(col);
	Z = 0*length(col);
	for i=1:length(col)
  	X(i) = rO.refStackMap.X(row(i),col(i));
  	Y(i) = rO.refStackMap.Y(row(i),col(i));
  	Z(i) = rO.refStackMap.Z(row(i),col(i));
	end
	X = round(X);
	Y = round(Y);
	Z = round(Z);

  % load volume
%	vim = load(assign_root_data_path(rO.refStackRelPath));
  end_z = size(vim,3);

  % base image yo
	start_z = round(mean(Z));
	tRoi = roi.roi(1, [], get_idx_from_xy(X,Y, size(rO.refStackMap.X)), [1 1 0], size(rO.refStackMap), []);
	tRoi.imageBounds = size(rO.refStackMap.X);
	tRoi.indices = get_idx_from_xy(X,Y, size(rO.refStackMap.X));
	tRoi.corners =tRoi.computeBoundingPoly(); 
	tRoi.assignBorderIndices();

	rA = roi.roiArray();
	rA.masterImage = vim(:,:,start_z);
	rA.workingImage = vim(:,:,start_z);
	rA.addRoi(tRoi);
	%rA.startGui();
%	return

% gradient autodet settings
gparams.radRange =  [3 10];
gparams.edgeSign = -1;
gparams.postDilateBy = 0;
gparams.dPosMax = 2;
gparams.postFracRemove = 0;

if (0) % START UP TOP GO DOWN
	%for i=start_z+1:start_z+50
	corrvals = zeros(1,end_z);
	fin_z = end_z;
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

%% at this point , see if gradient autodet will work . . .
    centerPoint(1) = mean(rB.rois{1}.corners(1,:));
    centerPoint(2) = mean(rB.rois{1}.corners(2,:));
	[gBorderXY gBorderIndices gRoiIndices] = roi.roiArray.cellDetGradient(rB, ...
	    rB.workingImage,[centerPoint(1) centerPoint(2)], gparams);

    
    % TO DO: how to detect when you are done and fill up the cell?? (look for bimodal luminance distro cutoff in dilated state (or even ultra-dilated state) -- should be fairly clear!)
		
		rA = rB;
		close all;
		tim = nim;
		allRs{i} = rB;

    corrvals(i) = length(gRoiIndices);
% criteria - at least 10 in a row
corrvec = 0*corrvals;
corrvec(find(corrvals > 0)) = 1;
if (sum(corrvec(max(1,i-11):max(1,i-1))) >= 10)
%  if (corrvals(i) == 0)
	  disp(['SOMA CENTER AT ' num2str(i)]);
		fin_z = i;
		break;
%	end
end
% criteria now over 100

		disp(['done with ' num2str(i)]);
	end
else % START AT THE BOTTOM WORK UP
  end_z = 300;
	fin_z = end_z;
	close all;

	ax = axes;
	nPixels = [];
	for i=start_z:-1:end_z
    try 
			nim = mean(vim(:,:,i-5:i+5),3);

			% 1) find best image match in next step based on LAST step
			rB = roi.roiArray();
			rB.masterImage = nim;
			rB.workingImage = nim;

      fm_params(1).value = [];
			fm_params(2).value = [];
			fm_params(3).value = [];
      fm_params(4).value = 3/512;
			fm_params(5).value = [];
%			corrvals(i) = roi.roiArray.findMatchingRoisInNewImage(rA, rB);
			corrvals(i) = roi.roiArray.findMatchingRoisInNewImage(rA, rB, fm_params);

			% 2) generate NEW mask --> 
			%   1. Try to use cellDetGradient of various size OR 
			centerPoint(1) = mean(rB.rois{1}.corners(1,:));
			centerPoint(2) = mean(rB.rois{1}.corners(2,:));
centerPoint0(1) = mean(rA.rois{1}.corners(1,:));
centerPoint0(2) = mean(rA.rois{1}.corners(2,:));
disp(' ');
disp('=================================================================');
disp(['xo: ' num2str(centerPoint0(1)) ' y0: ' num2str(centerPoint0(2))]);
disp(['x: ' num2str(centerPoint(1)) ' y: ' num2str(centerPoint(2))]);
			[gBorderXY gBorderIndices gRoiIndices] = roi.roiArray.cellDetGradient(rB, ...
					rB.workingImage,[centerPoint(1) centerPoint(2)], gparams);
			if (length(gRoiIndices) == 0) % you can take it down TWICE
				gparams.radRange = gparams.radRange - 1;
				if (gparams.radRange(1) == 0) ; gparams.radRange(1) = 1 ; end
				if (gparams.radRange(2) == 1) ; gparams.radRange(2) = 2; end
				[gBorderXY gBorderIndices gRoiIndices] = roi.roiArray.cellDetGradient(rB, ...
					rB.workingImage,[centerPoint(1) centerPoint(2)], gparams);

				if (length(gRoiIndices) == 0) % you can take it down TWICE
					gparams.radRange = gparams.radRange - 1;
					if (gparams.radRange(1) == 0) ; gparams.radRange(1) = 1 ; end
					if (gparams.radRange(2) == 1) ; gparams.radRange(2) = 2; end
					[gBorderXY gBorderIndices gRoiIndices] = roi.roiArray.cellDetGradient(rB, ...
						rB.workingImage,[centerPoint(1) centerPoint(2)], gparams);
				end
			end

centerPoint0(1) = mean(rB.rois{1}.corners(1,:));
centerPoint0(2) = mean(rB.rois{1}.corners(2,:));
disp(['x2: ' num2str(centerPoint0(1)) ' y0: ' num2str(centerPoint0(2))]);


			if (length(nPixels) == 0) ; nPixels = length(rB.rois{1}.indices); end
			if (length(gRoiIndices) == 0) %
			% still nothing?
			%   2. a) dilate b) select top N pixels c) restrict to largest connected component
disp('nada');        
				rB.dilateRoiBorders(1,1);
				rB.fillToBorder(1);
				[irr sidx] = sort(rB.workingImage(rB.rois{1}.indices), 'descend');
				rB.rois{1}.indices = rB.rois{1}.indices(sidx(1:min(nPixels,length(rB.rois{1}.indices))));

				rB.removeAllButLargestConnectedComponent(1);
				rB.fitRoiBordersToIndices(1);
			else % you got something in the cellDetGradient calls above ?
				rB.rois{1}.corners = gBorderXY;
				rB.rois{1}.borderIndices = gBorderIndices;
				rB.rois{1}.indices = gRoiIndices;
			end
centerPoint0(1) = mean(rB.rois{1}.corners(1,:));
centerPoint0(2) = mean(rB.rois{1}.corners(2,:));
disp(['x3: ' num2str(centerPoint0(1)) ' y0: ' num2str(centerPoint0(2))]);

			% No growth!
			if (length(rB.rois{1}.indices) > nPixels)
				rB.dilateRoiBorders(1,1);
				rB.fillToBorder(1);
				[irr sidx] = sort(rB.workingImage(rB.rois{1}.indices), 'descend');
				rB.rois{1}.indices = rB.rois{1}.indices(sidx(1:min(nPixels,length(rB.rois{1}.indices))));
				rB.removeAllButLargestConnectedComponent(1);
				rB.fitRoiBordersToIndices(1);
			end
			nPixels = max(10,length(rB.rois{1}.indices));
centerPoint0(1) = mean(rB.rois{1}.corners(1,:));
centerPoint0(2) = mean(rB.rois{1}.corners(2,:));
disp(['x4: ' num2str(centerPoint0(1)) ' y0: ' num2str(centerPoint0(2))]);
			
			% TO DO: how to detect when you are done and fill up the cell?? (look for bimodal luminance distro cutoff in dilated state (or even ultra-dilated state) -- should be fairly clear!)
			
			rA = rB;
			tim = nim;
			allRs{i} = rB;
	% criteria now over 100
oWi = allRs{i}.workingImage;
nWi = oWi;
nWi(find(nWi > 700)) = 700;
allRs{i}.workingImage = nWi;
allRs{i}.plotImage(0,1,0,[],ax);
text(30,30, num2str(i), 'Color', [1 1 0]);
drawnow;
allRs{i}.workingImage = oWi;

			disp(['done with ' num2str(i)]);
		catch ME
		  disp(ME.getReport);
		  break; 
		end
	end

end

fin_z = i+1;
length(allRs)
% build the soma so it is nice . . .

% plot
	close all;
%	figure ; plot(corrvals);
aviobj = avifile(['~/Desktop/' num2str(rId) 'trace.avi']);
fig=figure;
	ax = axes;
	for i=start_z:-1:fin_z
	  oWi = allRs{i}.workingImage;
		nWi = oWi;
	  nWi(find(nWi > 700)) = 700;
		allRs{i}.workingImage = nWi;
	  allRs{i}.plotImage(0,1,0,[],ax);
		text(30,30, num2str(i), 'Color', [1 1 0]);
		drawnow;
		F = getframe(fig);
		aviobj = addframe(aviobj,F);
		allRs{i}.workingImage = oWi;
	end
aviobj = close(aviobj);


% TO DO: spin the cell!
% TO DO: trace UPWARDS
% TO DO: multiple @ once?

% eventual workflow:
% 1) select apical ROIs in an imaged plane
% 2) correlate that plane to the volume stack [volume PATH as roiArray field ; roiArray method registerToStack which does either workingImage or masterImage]
% 3) trace the apical ROIs to their somas and record the soma position [roiArray method traceApicalDendriteThruStack; roiArray field to store full cell?]
% 4) for other planes, determine where the apical dendrite is and label accordingly.
