%
% Gradient (diff) based roi-detector.  Inspired by Tsai-Wen Chen.  Works by 
%  computing the luminance diff along lines at various angles emenating from 
%  center, then using various parameters to decide where to designate a 
%  border.  Note that this method ONLY returns a border.
%
% USAGE:
%
%  [borderXY borderIndices roiIndices] = 
%      cellDetGradient(obj, im, center, params)
%
% PARAMS:
%
%   Note that for all but im and center, you can pass [] and it will use 
%     use default.
%
%   obj: roiArray object, passed so we have access to its nonstatic methods
%   im: image in which to detect
%   center: [x y] coordinates over which to look
%   
%   params: structure for optional variables with following fields:
%  
%    radRange: [m M] where m is minimal and M is maximal border distance from
%              center.  This is not *strictly* enforced, but deviations are 
%              re-interpolated and excessive deviation (>50%) results in no
%              returned data. [3 10] default.
%    dPosMax: maximal change in position (in pixels) for the border between two
%             adjacent pixels.  5 default.
%         [breakup at these points, take largest left set, 
%            but rotate]
%    edgeSign: if -1 (default) looks for largest decrease in luminance; 1 
%              looks for largest increase (first case is for finding filled 
%              morphologies, second for finding unfilled when joined with
%              post-hoc dilation
%    postDilateBy: How many pixels to dilate the ROI by after finishing?  
%                  Default is 3 if edgeSign 1; 0 if edgeSign -1.  If it is < 1, 
%                  it will do fraction of mean edge radius.
%    postFracRemove: What fraction of lowest-luminance member pixels to remove
%                    following roi construction?  Basically, if edgeSign is 1
%                    you will find the hollow part of a cell.  You will then
%                    need to dilate to get border, and finally remove middle.
%                    Default is 0, but .5 if edgeSign is 1.  Note that this is
%                    the FRACTION of points removed.
%
% RETURNS:
%
%   borderXY: 2-by-n matrix with x and y border coordinates
%   borderIndices: index of border points within im
%   roiIndices: indexing of ROI points within im
%
function [borderXY borderIndices roiIndices] = cellDetGradient(obj, im, center, params)
  %% --- presets
  borderXY = [];
	borderIndices = [];
	roiIndices = [];
	thetas = linspace(0,2*pi,90);
  
  %% --- passed parameters 
	if (nargin < 3) ; error('cellDetGradient::must pass obj, im, and center at least.'); end
	x = center(1);
	y = center(2);

	radRange = [3 10]; 
	dPosMax = 5; 
	edgeSign = -1;
	postDilateBy = 0;
	postFracRemove = 0;
	if (nargin >= 4 && isstruct(params))
	  fn = fieldnames(params);
		for f=1:length(fn)
		  if (length(eval(['params.' fn{f} ';'])) > 0)
  		  eval([fn{f} ' = params.' fn{f} ';']);
			end
		end
	end
	if (~exist('postDilateBy','var') && edgeSign == 1) ; postDilateBy = 3; end
	if (~exist('postFracRemove','var') && edgeSign == 1) ; postFracRemove = .5; end


	%% --- detection

	% now generate angular profile of luminance
	fullRad = round(2*radRange(2));
	nSamples = 2*fullRad; % oversample by factor of ~2 samp/pixel

	linProfile=zeros(nSamples,length(thetas));
	for i=1:length(thetas)
		f=improfile(im,[x,x+fullRad*cos(thetas(i))],[y,y+fullRad*sin(thetas(i))],nSamples,'bilinear')';    
		linProfile(:,i)=f;
	end

  % get the diff matrix ...
	dlp = diff(linProfile);

	% minima/maxima along diff -- that is our initial guess
	if (edgeSign == 1)
    [irr edgeIdx] = max(dlp);
	else
    [irr edgeIdx] = min(dlp);
	end
    
  % now smooth this to eliminate further outliers - start at 0, 1/5, 2/5,
  % 3/5, 4/5 of span, the average these 5 -- in case ends were screwy.
  mEdgeIdx = zeros(5,length(thetas));
  idx = 1:length(thetas);
  mEdgeIdx(1,:) = medfilt1(edgeIdx(idx), round(length(thetas)/10));
  for i=2:5
    sp = round(length(idx)/5);
    idx = [idx(sp+1:end) idx(1:sp)]; % shift indexing
    mEdgeIdx(i,idx) = medfilt1(edgeIdx(idx), round(length(thetas)/10));
  end
  sEdgeIdx = median(mEdgeIdx);

  % eliminate outliers via applying strict size range from settings, interpolating missing
	%  again with sliding window
	inval = find(sEdgeIdx/2 < radRange(1) | sEdgeIdx/2 > radRange(2));
	if (length(inval) > 0.5*length(sEdgeIdx))
	  disp('roiGenSemiautoGradient::more than half of points exceed your radius tolerance; not detecting.');
		return;
	end
	if (length(inval) > 0) ; sEdgeIdx = interpMissing (inval, thetas, sEdgeIdx); end

  % eliminate outliers in form of big jumps in sEdgeIdx by smooth
  dPosMax = dPosMax*2; % conver to 2 pixels
	inval = find(abs(diff(sEdgeIdx)) > dPosMax);
  if (dPosMax > 0 && length(inval) > 1)
    sEdgeIdx = smooth(sEdgeIdx, length(thetas/5))';
  end

	%% --- setup indices and border indices
  
  % convert edgeIdx to x, y and actual radius 
  fEdgeRad = round(sEdgeIdx)/2;
  X = x + fEdgeRad.*cos(thetas);
  Y = y + fEdgeRad.*sin(thetas);
	borderXY = [X ; Y]; % temporary ...

  % now fill in border -- i.e., return indices 
  % so you can fillToBorder ...
	if (size(obj.workingImageYMat,1) == 0  || size(obj.workingImageXMat,1) == 0)
		obj.workingImageYMat = repmat(1:obj.imageBounds(1), obj.imageBounds(2),1)';
		obj.workingImageXMat = repmat(1:obj.imageBounds(2), obj.imageBounds(1),1);
	end

	% build tmp new roi, generating corners from border 
	tRoi = roi.roi(-1, borderXY, [], [1 0 0.5], obj.imageBounds, []);
	tRoi.fillToBorder(obj.workingImageXMat, obj.workingImageYMat);
	borderXY = tRoi.computeBoundingPoly();

	%% --- run post-steps and assign final output
  
	% dilate
	if (postDilateBy > 0 & postDilateBy >= 1)
    tRoi.dilateRoiIndices(postDilateBy, obj.workingImageXMat, obj.workingImageYMat);
	elseif (postDilateBy > 0) % fractional
	  postDilateBy = ceil(postDilateBy*mean(fEdgeRad));
    tRoi.dilateRoiIndices(postDilateBy, obj.workingImageXMat, obj.workingImageYMat);
	end

	% remove center
	if (postFracRemove > 0)
	  lumVals = obj.workingImage(tRoi.indices);
		[irr sIdx] = sort(lumVals, 'ascend');
    nR = round(postFracRemove*length(tRoi.indices));
		tRoi.indices = tRoi.indices(sIdx(nR:end));
	end

  % final output
	borderXY = tRoi.computeBoundingPoly();
	tRoi.assignBorderIndices();
	borderIndices = tRoi.borderIndices;
	roiIndices = round(tRoi.indices);

  %% --- debug 
  if (0)
  %figure ; imshow(linProfile,[0 max(max(linProfile))]); colormap jet;
  figure ; imshow(dlp, [min(min(dlp)) max(max(dlp))]) ; colormap jet;
  hold on ; plot(1:length(thetas),edgeIdx, 'kx-');
    hold on ; plot(1:length(thetas),sEdgeIdx, 'rx-');
  end

%
% interpolates missing and returns median after emlpoying several start 
%  positions since theta is continuous.
%
function sEdgeIdx  = interpMissing(inval, thetas, sEdgeIdx)
	val = setdiff(1:length(thetas),inval);
  mEdgeIdx = zeros(5,length(thetas));
  mEdgeIdx(1,inval) = interp1(val,sEdgeIdx(val), inval, 'linear', 'extrap');
	mEdgeIdx(:,val) = repmat(sEdgeIdx(val),5,1);
  idx = 1:length(thetas);
  for i=2:5
    sp = round(length(idx)/5);
    idx = [idx(sp+1:end) idx(1:sp)]; % shift indexing
    mEdgeIdx(i,inval) = interp1(idx(val),sEdgeIdx(val), idx(inval), 'linear', 'extrap');
  end
  sEdgeIdx = median(mEdgeIdx);
