%
% SP May 2011
%
% Given a set of frame indices, will use fileList and fileFrameIdx to retrieve
%  specified frames and make image stack.
%
% USAGE:
% 
%   im = caTSA.getRawImageFrames(frames, fov)
%
% PARAMS:
%
%   frames: indices of desired frames in terms of caTSA, where first frame is 1
%           and so on
%   fov: idx of FOV to use (if multiple roiArray objects) ; can be a vector in 
%        which case im is a cell array
%
% RETURNS:
%   im: returned image(s) -- either single image or cell array of image objects
%       1/FOV
%
function im = getRawImageFrames(obj, frames, fov)
  % --- input parse
	if (nargin < 3 || length(fov) == 0)
	  fov = 1:obj.numFOVs;
	end

	% --- fov loop
	if (length(fov) == 1)
    im = processSingleFOV(obj, frames, fov(1));
	else
	  for f=1:length(fov)
		  im{f} = processSingleFOV(obj, frames, fov(f));
		end
	end
 
function im = processSingleFOV(obj, frames, fovIdx)
  % --- preparatory
	% preallocate
	im = nan*zeros(size(obj.roiArray{fovIdx}.masterImage,1), ...
	               size(obj.roiArray{fovIdx}.masterImage,2), ...
								 length(frames));

	% files 
	uFileIdx = unique(obj.fileFrameIdx{fovIdx}(1,frames));
  uFileIdx = uFileIdx(find(~isnan(uFileIdx)));

  % --- main frame loop -- minimize file reads, so loop thru files
	for fi=1:length(uFileIdx)
	  disp(['getRawImageFrames::processing ' obj.fileList{fovIdx}{uFileIdx(fi)}]);
	  tim = load_image(obj.fileList{fovIdx}{uFileIdx(fi)});
	  fframes = intersect(frames,find(obj.fileFrameIdx{fovIdx}(1,:) == uFileIdx(fi)));

		% grab pertinent frames
		for f=1:length(fframes)
		  retIdx = find(frames == fframes(f));
			srcIdx = obj.fileFrameIdx{fovIdx}(2,fframes(f)) ;
      im(:,:,retIdx) = tim(:,:,srcIdx);
		end
	end
