%
% SP Jan 2011
%
% Generates ROI touch score bar plots using the touchIndex matrix for a given 
%  roi x whisker set.
%
% USAGE: 
%
%  s.plotRoiTouchScoreAcrossWhiskers(roiId, features, plotParams)
%  
%    roiId: in terms of s.caTSA.id ; which roi to look at (one)
%    whiskers: string name of whiskers to plot; cell array
%    plotParams: structure with the following fields:
%      axRef: figure to plot to ; make new if blank
%      valueRange: set bar range to this
%      showLabels: set to 0 to suppress printing of labels for bars; defautl 1
%
function plotRoiTouchScoreAcrossWhiskers(obj, roiId, whiskers, plotParams)
  % --- input chekz
	if (nargin < 2 || length(roiId) == 0) % roi
	  disp('plotRoiTouchScoreAcrossWhiskers::must provide roi to work with.');
		return;
	end

	if (nargin < 3 || length(whiskers) == 0) % whiskers -- defualt is all
	  whiskers = obj.whiskerTag;
	end

	if (nargin < 4) ; plotParams = []; end

  % --- Prepare data & make call to plotBarRF
	touchIndex = obj.cellFeatures.get('touchIndex');

  % pull whisker indices
	widx = [];
	wLabels = {};
	for w=1:length(whiskers)
    wi = find(strcmp(obj.whiskerTag,whiskers{w}));
		if (length(wi) > 0)
    	if (size(touchIndex,1) == 2*length(obj.whiskerTag))
			  widx = [widx (2*wi)-1 2*wi];
		  	wLabels{length(wLabels) + 1} = ['Pro ' whiskers{w}];
		  	wLabels{length(wLabels) + 1} = ['Ret ' whiskers{w}];
	    else
	  	  widx = [widx wi];
		  	wLabels{length(wLabels) + 1} = whiskers{w};
			end
		end
	end

	% pull from touchIndex
	r = find(obj.caTSA.ids == roiId);
	barValues = touchIndex(widx,r);
  session.session.plotBarRF(barValues, wLabels, plotParams);

