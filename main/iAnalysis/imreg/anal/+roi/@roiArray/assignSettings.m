%
% This functions contains default values of the roiArray.settings structure
%
% USAGE:
%
%   This method is called *internally*, I just separated it into a file for
%   ease-of-reading.  Don't mess with this unless you know what you're
%   doing.
%
function settings = assignSettings(settings)
	% set all variables
	if (~isstruct(settings))
		settings.selectedColor = [1 1 1]; % color for selected ROI
	end

	%% --- plot settings
	% selected ROI color
	if (~isfield(settings, 'selectedColor')) ; settings.selectedColor = [1 1 1]; end 
	% color for text
	if (~isfield(settings, 'textColor')) ; settings.textColor = [1 1 1]; end
	% color for scalebar
	if (~isfield(settings, 'scaleBarColor')) ; settings.scaleBarColor = [0.5 0.5 0.5]; end
	% main figure position
	if (~isfield(settings, 'figRefPos')) ; settings.figRefPos = []; end
	% working image control positon
	if (~isfield(settings, 'workingImageControlFigPos')) ; settings.workingImageControlFigPos= []; end

	%% --- settings for tsai-wen semi-auto dector
	% expected radius of roi in pixzels
	if (~isfield(settings, 'semiAutoTW')) ; settings.semiAutoTW.expectedRadius = 10; end

	%% --- settings for gradient autodector
	if (~isfield(settings, 'semiAutoGrad'))  
		% range of acceptable radii in pixels
		settings.semiAutoGrad.radiusRange = [3 10]; 
		% edge sign: +1 means stop at increasing lum, -1 means decreasing
		settings.semiAutoGrad.edgeSign = -1;
		% change in position that is considered too large
		settings.semiAutoGrad.dPosMax = [];
		% how much to dilate by after whole thing is drawn
		settings.semiAutoGrad.postDilateBy = 0;
		% what fraction of lowest-luminance pixels to remove after all is done
		settings.semiAutoGrad.postFracRemove = 0;
	end

