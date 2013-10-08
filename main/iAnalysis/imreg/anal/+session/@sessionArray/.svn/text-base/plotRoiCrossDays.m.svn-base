% 
% SP Apr 2011
%
% plots a ROI's evolution across days.
%
%  USAGE:
%
%   sA.plotRoiCrossDays(params)
%
%  PARAMS:
%
%    params: a structure with following fields (or, you can just pass the roiID
%            that is, if isstruct(params) is true, then it will look for fields,
%            and if false, it will assume you are ONLY passing roiId).
%      roiId: # of roi to ploit
%      sessions: indices of sessions to plot ; by default all
%      showBorder: 1: show border (default 0)
%      showFill: 1: shows filled (default 0)
%      normMode: How to normalize image?  Mode 1 (default) - normalize to median of
%                of subimage and nSF.  2: normalize entire image to IQR range using
%                im_iqr_normalize.
%      nSF: scaling factor applied to sub image FOLLOWING normzliation (0.25 dflt)
%           image = image x nSF
%      showPlot: vector with 0/1 values, each element w/ 1 means a plot is made; 
%                [1 0 0 0] default:
%           (1): plot of ROI and nearby region over time
%           (2): summary histogram of pixel intensities of ROI
%           (3): center/edge, center/surround, spread over time
%           (4): center and edge normalized to first day as well as IQR spread change 
%      imageUsed: 1: activityFreeImage [default]
%                 2: rA.masterImage
%                 3: just keep rA.workingImage
%                 negative number: run activity-free image detector FOR THIS ROI with this
%                                  long activity-free epoch
%
function plotRoiCrossDays (obj, params)

  % --- argument process
	if (nargin < 2) ; help('session.sessionArray.plotRoiCrossDays'); disp('plotRoiCrossDays::must @ least give RoiID.') ; return ; end

  % defualts
	showBorder = 0;
	showFill = 0;
	nSF = 0.25;
	showPlot = [1 0 0 0];
	normMode = 1;
	sessions = 1:length(obj.sessions);
	imageUsed = 1;

	% paramns structure
	if (~isstruct(params)) ; roiId = params ; end
	if (isstruct(params)) roiId = params.roiId; end % must pass roiId in params
	if (isstruct(params) && isfield(params, 'showBorder')); showBorder = params.showBorder ; end
	if (isstruct(params) && isfield(params, 'showFill')); showFill = params.showFill ; end
	if (isstruct(params) && isfield(params, 'nSF')); nSF = params.nSF ; end
	if (isstruct(params) && isfield(params, 'sessions')); sessions = params.sessions ; end
	if (isstruct(params) && isfield(params, 'showPlot')); showPlot = params.showPlot ; end
	if (isstruct(params) && isfield(params, 'normMode')); normMode = params.normMode ; end
	if (isstruct(params) && isfield(params, 'imageUsed')); imageUsed = params.imageUsed ; end

	% --- row and column counters etc.
  N = length(sessions); % how many total
  nr = ceil(sqrt(N));
	nc = ceil(sqrt(N));
	c = 1;
	r = 1;

  % --- and the ploter ...
	if (showPlot(1))
		f1 = figure('Position', [ 100 100 nc*110 nr*110], 'Name', ['ROI ' num2str(roiId)], 'NumberTitle','off');
	end
	if (showPlot(2))
    f2= figure('Position', [ 200 200 nc*110 nr*110], 'Name', ['ROI ' num2str(roiId)], 'NumberTitle','off');
  end
	ecRatio = nan*(1:N);
	cmRatio = nan*(1:N);
	pixValIQR = nan*(1:N);
	borderVal = nan*(1:N);
	centerVal = nan*(1:N);
  for s=1:length(sessions)
	  si = sessions(s);
    rA = obj.sessions{si}.caTSA.roiArray;
    roi = rA.getRoiById(roiId);

		% is the ROI filled?
		isFilled = 0;
		if (length(obj.roiIsFilled) > 0)
		  ridx = find(obj.roiIds == roiId);
      isFilled = obj.roiIsFilled(si,ridx);
		end

		% pull stillest-frame image? [pull still across ALL rois!]
		if (imageUsed < 0)
		  nStillestFrames = -1*imageUsed;
    	stillIdx = obj.sessions{si}.caTSA.getEventFreeFrameIndices(nStillestFrames, roiId);

			if (length(stillIdx) >= nStillestFrames)
			  % use middle block
				sti = 1+ceil(length(stillIdx)/2)-ceil(nStillestFrames/2);
        sidx = stillIdx(sti:sti+nStillestFrames-1);

				% pull files
      	sim = obj.sessions{si}.caTSA.getRawImageFrames(sidx);	  

				% assign
				rA.workingImage = mean(sim,3);
			end
		elseif (imageUsed == 1) % activityFreeImage
		  % "checksum" (do we actually need to assign, which will kickoff time consuming stuff?)
			imSize = prod(size(rA.workingImage));
      rp = randperm(imSize);
			csIdx = rp(1:min(100,imSize));

      % generate 
      if (length(obj.sessions{si}.caTSA.activityFreeImage) == 0)
        obj.sessions{si}.caTSA.generateActivityFreeImage();
      end
      
			if (sum(rA.workingImage(csIdx) ~= obj.sessions{si}.caTSA.activityFreeImage(csIdx)) > 0)
				rA.workingImage = obj.sessions{si}.caTSA.activityFreeImage;
			end
		elseif (imageUsed == 2) % masterImage
		  % "checksum" (do we actually need to assign, which will kickoff time consuming stuff?)
			imSize = prod(size(rA.workingImage));
      rp = randperm(imSize);
			csIdx = rp(1:min(100,imSize));

			if (sum(rA.workingImage(csIdx) ~= rA.masterImage(csIdx)) > 0)
				rA.workingImage = rA.masterImage; % cleaner up
			end
		end

    % norm mode 2?
		if (normMode == 2)
		  rA.workingImage = im_iqr_normalize(rA.workingImage, nSF);
		end

		% --- figure with zoomed roi
		if (showPlot(1))
			if (sum(showPlot) > 1) ; figure(f1); end % do only if other figs are there
			cim = obj.sessions{si}.caTSA.roiArray.generateZoomedRoiImage(roiId, 0, 0, 10); % without excess stuff for range estimates
			im = rA.generateZoomedRoiImage(roiId, showBorder, showFill, 10);
			subplot('Position', [(c-(1/2))/(nc+1) (nr-r)/nr 1/(nc+2) 0.8/nr]);

			% normalize image with mode 1?
			if (normMode == 2)
				cim = cim - min(min(min(cim)));
				lim = reshape(cim,[],1);
				adjim = (double(cim)/median(lim))*double(nSF);
			else 
				adjim = cim;
			end

			% reintroduce ROI overlay
			idx = find(im(:,:,1) == roi.color(1) & ...
								 im(:,:,2) == roi.color(2) & ...
								 im(:,:,3) == roi.color(3));
			adjimT = adjim(:,:,1) ; adjimT(idx) = 0 ; adjim(:,:,1) = adjimT;
			adjimT = adjim(:,:,2) ; adjimT(idx) = 0.5 ; adjim(:,:,2) = adjimT;
			adjimT = adjim(:,:,3) ; adjimT(idx) = 1 ; adjim(:,:,3) = adjimT;

			% plot image
			imshow(adjim);
			axis square;
			title([obj.dateStr{si}]);

			% filled? underscore with red
			if (isFilled)
			  hold on;
				S = size(adjim);
				plot ([1 S(2)], [1 1], 'r-', 'LineWidth',2);
			end
		end

		% --- stats
		if (showPlot(2) | showPlot(3) | showPlot(4))

		  % get stats from roiArray.getRoiFillingStatistics
      [isFilled ecRatio(s) cmRatio(s) pixValIQR(s) borderVal(s) centerVal(s)] ... 
			  = rA.getRoiFillingStatistics(roiId);
      
      % --- histogram
			if (showPlot(2))
				rc = roi.copy();

				% normalize master image to 2*IQR (middle)
				mi = im_iqr_normalize(rA.masterImage,1);
				medmi = median(reshape(mi,[],1));

				% get pixels
				rc.fillToBorder(rA.workingImageXMat, rA.workingImageYMat);
				idx = rc.indices;
			  bidx = rc.borderIndices;
		    cidx = setdiff(idx,bidx);
		  	pixels = mi(idx);
    		cpixels = mi(cidx);
				pixels = reshape(pixels,[],1);
				cpixels = reshape(cpixels,[],1);
				tim = 0*mi;
				tim(cidx) = 1;
				tim = imerode(tim, strel('square',3));
				ecidx = find(tim == 1);
				ecpixels = mi(ecidx);
				ecpixels = reshape(ecpixels,[],1);

				% pixel histogram
				figure(f2);
				subplot('Position', [(c-(1/2))/(nc+1) (nr-r)/nr 1/(nc+2) 0.8/nr]);
				hist(ecpixels, .05:.1:9.95);
%				hist(pixels, .05:.1:9.95);
				axis([0 10 0 40]);
				title([obj.dateStr{si}]);
				hold on;

				% pixValIQR measure
				text(.1,10,['IQR: ' num2str(pixValIQR(s))]);

				% border:center ratio
				text(.1,20,['EC: ' num2str(ecRatio(s))]);

				% brigthness relative surround
				text(.1,30,['CS: ' num2str(cmRatio(s))]);
			end
    end

    % index increment
		c = c+1;
		if (c > nc) ; c = 1; r = r+1 ; end
	end

	% --- parameters not normalized over time
	if (showPlot(3))
	  figure;
		subplot(3,1,1);
	  plot(ecRatio, 'o-', 'Color', [1 0 0], 'MarkerFaceColor',[1 0 0]);
		hold on;
		plot([0 length(sessions)+1], 0.8*[1 1], 'k:');
		ylabel('edge:center ratio');
		axis([0 length(sessions)+1 0.5 1.5]);
		title(['ROI ' num2str(roiId)]);

		subplot(3,1,2);
	  plot(cmRatio, 'o-', 'Color', [0 0 1], 'MarkerFaceColor',[0 0 1]);
		hold on;
		ylabel('center:img-median ratio');
		axis([0 length(sessions)+1 0 4]);

		subplot(3,1,3);
	  plot(pixValIQR, 'o-', 'Color', [0 1 1], 'MarkerFaceColor',[0 1 1]);
		hold on;
		ylabel('IQR of normd pixel values');
		axis([0 length(sessions)+1 0 3]);
		for s=1:length(sessions)
			text(s,0.2, obj.dateStr{sessions(s)}(1:6) , 'Rotation', 90);
		end
	end

	% --- parameters normalized to first day over time ...
	if (showPlot(4))
    figure;
		subplot(3,1,1);
	  plot(borderVal/borderVal(1), 'o-', 'Color', [1 0.5 0], 'MarkerFaceColor',[1 0.5 0]);
		hold on;
		ylabel('edge/edge_d_a_y_1');
		axis([0 length(sessions)+1 0 3]);
		title(['ROI ' num2str(roiId) ' values over time']);
		subplot(3,1,2);
	  plot(centerVal/centerVal(1), 'o-', 'Color', [1 0 1], 'MarkerFaceColor',[1 0 1]);
		hold on;
		ylabel('center/center_d_a_y_1');
		axis([0 length(sessions)+1 0 3]);
		title(['ROI ' num2str(roiId)]);

		subplot(3,1,3);
	  plot(pixValIQR/pixValIQR(1), 'o-', 'Color', [0 1 1], 'MarkerFaceColor',[0 1 1]);
		hold on;
		ylabel('IQR/IQR_d_a_y_1');
		axis([0 length(sessions)+1 0 2]);
		for s=1:length(sessions)
			text(s,0.2, obj.dateStr{sessions(s)}(1:6) , 'Rotation', 90);
		end
  end
