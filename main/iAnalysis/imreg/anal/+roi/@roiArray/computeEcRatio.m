%
% SP May 2011
%
%  Computes Edge:Center ratio for ROI.
%
% USAGE:
%
%  [ecRatio borderVal centerVal] = rA.computeEcRatio( roiId, im)
%
% PARAMS:
%
%  ecRatio: edge:center ratio
%  borderVal: value @ border
%  centerVal: value @ center
%
%  roiId: roi you want to do with
%  im: Image on which to work ; default is obj.workingImage (if blank)
%
function [ecRatio borderVal centerVal] = computeEcRatio(obj, roiId, im)
	debug =0;
	ecRatio = nan;
	borderVal = nan;
	centerVal = nan;

  % some params
  cenSize = [2 1]; % center is -cenSize:cenSize, (1) for hor and (2) for ver dimension
	lpSF = 2; % how much to scale line length by when doing COM -> edge profiles
	angles = 0:15:345; % @ which angles to compute profile
  
  % --- process inputs
	if (nargin < 2)
	  help('roi.roiArray.computeEcRatio');
	  disp('Must specify roiId @ least');
	end

	if (nargin < 3 || length(im) == 0)
	  im = obj.workingImage;
	end

	% --- prelims

	% pull roi
	roi = obj.getRoiById(roiId);

	% for easy access
	imBounds = obj.imageBounds;
  idx = roi.indices;
	bidx = roi.borderIndices;

	if (length(bidx) == 0 | length(idx) == 0); return; end

	% --- work

  % get COM
	X = ceil(idx/imBounds(1));
	Y = idx-(imBounds(1)*floor(idx/imBounds(1)));
	ocom = round([mean(X) mean(Y)]);

	% points around center
	[cX cY] = meshgrid(ocom(1)-cenSize(1):ocom(1)+cenSize(1), ocom(2)-cenSize(2):ocom(2)+cenSize(2));
	val = find(cX > 0 & cY > 0 & cX <= imBounds(2) & cY < imBounds(1));
	iC = cY(val) + imBounds(1)*(cX(val)-1);

	% new center of mass
	[minVal minIdx] = min(im(iC));
	cenIdx = iC(minIdx);
	com = [ceil(cenIdx/imBounds(1)) cenIdx-(imBounds(1)*floor(cenIdx/imBounds(1)))];
	if(ismember(cenIdx, bidx)) ; com = ocom; end
	centerVal = median(im(iC));

  % line profiles around COM for border
	bX = ceil(bidx/imBounds(1));
	bY = bidx-(imBounds(1)*floor(bidx/imBounds(1)));

  % get "angle" (we want to sample uniformly, so not too concerned here ergo atan2)
	theta = 180+atan2(bX-com(1),bY-com(2))*(180/pi);
	aidx = nan*angles;
	for a=1:length(angles)
	  [irr idx] = min(abs(theta-angles(a)));
		if (length(idx) > 0)
			aidx(a) = idx(1);
		end
	end
	valang = find(~isnan(aidx));
	aidx = aidx(valang);
	angles = angles(valang);

	% compute end poitns of all lines from center ...
	ebX = lpSF*(bX(aidx) - com(1)) + com(1);
	ebY = lpSF*(bY(aidx) - com(2)) + com(2);
  Lp = 0*angles;

	% compile center->edge profile at all angles into matrix
	for a=1:length(angles)
	  lprofile{a} = improfile(im,[com(1) ebX(a)],[com(2) ebY(a)]);
		Lp(a) = length(lprofile{a});
	end
	MLp = max(Lp);
	lProfiles = nan*ones(MLp,length(angles));
	for a=1:length(angles)
	  lProfiles(1:Lp(a),a) = lprofile{a};
	end

	% get interpolated profiles (i.e., same length, which makes defining fractional
	%  distances easy since 1 applies to all)
	iProfiles = nan*ones(MLp,length(angles));
	longestProfile = 1:MLp;
	for a=1:length(angles)
	  lProfiles(1:Lp(a),a) = lprofile{a};
	  % interpolate profile
		px = 1+((0:Lp(a)-1))*(MLp/(Lp(a)-1));
		iProfile = interp1(px, lprofile{a}, longestProfile);

		% compile  INTERPOLATED profiles
	  iProfiles(:,a) = iProfile;
	end

  % compute point of max change for profiles -- this is border (smooth it)
	eIdx = ceil(MLp/lpSF); % where border was DRAWN
	ei1 = max(1,floor(0.5*eIdx));
	ei2 = min(MLp, floor(1.5*eIdx));
  [irr dMaxIdx] = max(abs(diff(iProfiles(ei1:ei2,:))));
	dMaxIdx = dMaxIdx + ei1;
	smoothDMaxIdx = round(smooth(1:length(dMaxIdx), dMaxIdx, 3));

  % --- final values

	% center value
  cIdx = 1:max(floor(MLp/lpSF)*0.5,1);
	centerVals = reshape(iProfiles(cIdx,:),[],1);
	centerVal= nanmean(centerVals);

	% edge -- take from smoothed dmax, and only if within certain region
	val = find(smoothDMaxIdx >= ei1 & smoothDMaxIdx <= ei2);
	borderVals = nan*(1:length(angles));
	for v=1:length(val)
	  inD = max(1,smoothDMaxIdx(val(v))-3); % take measurement as max along border
		borderVals(val(v)) = nanmean(iProfiles(inD:smoothDMaxIdx(val(v)),val(v)));
	end
  borderVal = nanmean(borderVals);

  val = find(~isnan(borderVals));
	ecRatio = quantile(borderVals(val)/centerVal,.75);
  
  % --- debugging
  if (debug)
		subplot('Position', [0.05 0.7 0.9 0.25]);
		cla; hold on ;

		for a=1:length(angles)
			plot(lprofile{a},'b-');
		end
		subplot('Position', [0.35 0.05 0.6 0.6]);
		cla;
		imshow(iProfiles', [min(min(iProfiles)) max(max(iProfiles))] , 'Parent', gca, 'Border','tight');
		%imshow(lProfiles', [min(min(lProfiles)) max(max(lProfiles))] , 'Parent', gca, 'Border','tight');
		hold on;
		plot(dMaxIdx,1:length(angles),'wx-');
		plot(smoothDMaxIdx,1:length(angles),'mx-');
		colormap jet;

		subplot('Position', [0.05 0.3 0.25 0.25]);
		zim = obj.generateZoomedRoiImage(roiId, 0, 0, 10);
		imshow(zim);
		title(['E: ' num2str(borderVal) ' C: ' num2str(centerVal) ' ECr: ' num2str(ecRatio)]);

		subplot('Position', [0.05 0.05 0.25 0.25]);
		zim = obj.generateZoomedRoiImage(roiId, 1, 0, 10);
		imshow(zim);
		title(num2str(roiId));
		pause

%pause;
%di = abs(diff(iProfiles))';
%imshow(di, [min(min(di)) max(max(di))] , 'Parent', gca, 'Border','tight');
%colormap jet;
%pause
%	plot(meanProfile,'r-');
%pause


		if (0)
			figure;
			imshow(im, [0 max(max(im))]);
			hold on;
			plot(com(1), com(2),'rx');
			plot(ocom(1), ocom(2),'ro');
			plot (bX(aidx), bY(aidx), 'mx');
			plot (ebX, ebY, 'gx');
			plot(bX, bY,'y-');
			pause
		end
	end

