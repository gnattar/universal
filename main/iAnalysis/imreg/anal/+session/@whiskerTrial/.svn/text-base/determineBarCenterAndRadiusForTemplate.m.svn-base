% 
% SP Nov 2010
%
% This is a method that will establish, within the template rectangle, the
%  bar's center and radius.  These parameters in turn must be stored when 
%  saving the template so that - after finding best relative match to template -
%  it is possible to extract bar border therefrom.
%
% USAGE:
%
%  [barCenter barRadius barTemplateCorrelation] = 
%     wt.determineBarCenterAndRadiusForTemplate(radiusRange, barTemplateIm, suppressOutput)
%
% radiusRange: the range of radii to test
% barTemplateIm: image to test on
%
% barCenter: [x y]
% barRadius: single #
% suppressOutput: set to 1 to block imshow
% 
function [barCenter barRadius] = determineBarCenterAndRadiusForTemplate(radiusRange, barTemplateIm, suppressOutput)

  if (nargin < 3) ; suppressOutput = 0; end

  % tested radii/setup params
	radii = radiusRange(1):0.25:radiusRange(2);
	matrixSize = ([2 2]*radiusRange(2))+1; 

	% test them all using customdisk
	maxVal = max(max(barTemplateIm));
	minVal = min(min(barTemplateIm));
	corrScore = 0*(1:length(radii));
	for r=1:length(radii)
	  % setup a center-surround disk to test w/
	  testDisk = customdisk(matrixSize, [1 1]*radii(r), ceil(matrixSize/2), 0);
    center = find(testDisk == 1);
		surround = find(testDisk == 0);
		testDisk(surround) = maxVal;
		testDisk(center) = minVal;

    % score each one 
		nim = normxcorr2(testDisk, barTemplateIm);
		corrScore(r) = max(max(nim));
	end

	% find best one and use it to get radius, center
	[bestVal bestIdx] = max(corrScore);
	barRadius = radii(bestIdx);
	testDisk = customdisk(matrixSize, [1 1]*barRadius, ceil(matrixSize/2), 0);
	center = find(testDisk == 1);
	surround = find(testDisk == 0);
	testDisk(surround) = maxVal;
	testDisk(center) = minVal;
	nim = normxcorr2(testDisk, barTemplateIm);
	peakVal = max(max(nim)); 
  peakIdx = find(nim == peakVal);
  [ypeak, xpeak] = ind2sub(size(nim),peakIdx);
	barCenter(1) = xpeak-((size(nim,2) - size(barTemplateIm,2))/2); % x center
	barCenter(2) = ypeak-((size(nim,1) - size(barTemplateIm,1))/2); % y center

  % display for user
	if (~suppressOutput)
		figure;
		imshow(barTemplateIm); hold on ; plot (barCenter(1), barCenter(2), 'rx');
		rectangle('Position', [barCenter(1)-barRadius barCenter(2)-barRadius 2*barRadius 2*barRadius], 'Curvature', [1 1], 'EdgeColor', [0 0 1], 'LineWidth', 2);
		title('Baseline bar fit');
  end
