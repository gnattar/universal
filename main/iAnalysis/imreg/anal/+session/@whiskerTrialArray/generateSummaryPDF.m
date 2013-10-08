%
% Generates a summary that allows you to quickly evaluate linking.
%
% USAGE:
%
%   wta.generateSummaryPDF(pdfPath)
%
% ARGUMENTS:
%
%  pdfPath: where your PDF should go
%
% (C) 2012 S Peron
%
function generateSummaryPDF(obj, pdfPath)

  %% input checks
  if (nargin < 2)
	  error('Must specify PDF output path');
	end

	%% first the summary of the settings ...

	%% trial loop . . . 
	nAbove = zeros(1,obj.numTrials);
	for t=1:obj.numTrials
		wt = obj.wtArray{t};

    % whisker-specific variables
		for w=1:wt.numWhiskers
		  wi = find(wt.positionMatrix(:,2) == w);

			% dPos > 20 count
			dPos = diff(wt.positionMatrix(wi,3));
			nAbove(t) = nAbove(t) + length(find(dPos > 20));
		end
		disp([num2str(t) ': ' num2str(nAbove(t))]);

		%% plot it 
	end

