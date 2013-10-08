%
% SP May 2011
%
% Creates an image, activityFreeImage, by finding the middle-most (in session)
%  contiguous frame block where NO cells fire.
%
% USAGE:
%
%   caTSA.generateActivityFreeImage (nActivityFreeFrames, roiIds)
%
% PARAMS:
%
%   nActivityFreeFrames: how many frames do you want without activity?
%                        default is 10.
%   roiIds: which rois to consider (i.e., which rois must have no activity) -
%           default is to use ALL rois, which is generally the way to go as the
%           image will be different for each roi if you don't use this.
%
function	obj = generateActivityFreeImage(obj, nActivityFreeFrames, roiIds)
  % --- params
  if (nargin < 2) ; nActivityFreeFrames = 10; end
	if (nargin < 3) ; roiIds = []; end
	nFallbackFrames = max(5,ceil(nActivityFreeFrames/2)); % # frames to try to get in fallback

	% --- sanity cheks
	if (~isobject(obj.caPeakEventSeriesArray)) ; disp('generateActivityFreeImage::must first detect events.'); return ; end

	% --- rock out
	stillIdx = obj.getEventFreeFrameIndices(nActivityFreeFrames);
	if (length(stillIdx) < nActivityFreeFrames)
		nActivityFreeFrames = nFallbackFrames;
		stillIdx = obj.getEventFreeFrameIndices(nActivityFreeFrames);
	end

	if (length(stillIdx) >= nActivityFreeFrames)
		% use middle block
		sti = 1+ceil(length(stillIdx)/2)-ceil(nActivityFreeFrames/2);
		sidx = stillIdx(sti:sti+nActivityFreeFrames-1);

	  for f=1:obj.numFOVs
			% pull files
			sim = obj.getRawImageFrames(sidx,f);	  

			% assign
			obj.activityFreeImage{f} = nanmean(sim,3);
		end
	else
	  disp ('generateActivityFreeImage::could not find a contiguous block of the size you requested.  Either use a smaller value or not all ROIs.');
	end


