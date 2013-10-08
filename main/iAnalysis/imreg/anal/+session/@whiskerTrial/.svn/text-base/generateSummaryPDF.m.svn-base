%
% Generates a PDF summarizing whisker .mat files.
%
% Will generate a summary PDF containing plotPositionTrajectory of all trials
%  in fileWildcard meeting scoreThresh score threshold in 
%  lastLinkPositionMatrixScore(2). Outputs to whiskingSummary.pdf in directory specified
%  by fileWildcard.
%
% USAGE:
%
%   session.whiskerTrial.generateSummaryPDF(fileWildcard, scoreThresh)
%
% ARGUMENTS:
%
%   fileWildcard: what to do directory on ; should be FULL path if not pwd
%   scoreThresh: lastLinkPositionMatrixScore(2) must be > this to be included 
%                dflt 0.025
%
% (C) SP Jun 2011
%
function generateSummaryPDF(fileWildcard, scoreThresh)
  %% --- prep work
  if (nargin < 1) ; fileWildcard = 'WDBP*mat'; end
	if (nargin < 2) ; scoreThresh = 0.025 ;end
  dPosThresh = 20; % we count changse in parabolic position in excess of this as BAD

  %% --- the juice
  fl = dir(fileWildcard);
	rootDir = fileparts(fileWildcard);
	if (length(rootDir) == 0) ; rootDir = pwd ; end
	if (length(rootDir) > 0) ; rootDir = [rootDir filesep]; end
	outputPath = [rootDir 'whiskingSummary.ps'];
	outputPathPdf = [rootDir 'whiskingSummary.pdf'];
	delete(outputPath);

  % loop
	badFiles = [];
	for f=1:length(fl)
	  load(fl(f).name);  
		wt.updatePaths(pwd);

		% test thresh ...
		if (wt.lastLinkPositionMatrixScore(2) > scoreThresh)
      textCol = [1 0 0 ];
      badFiles = [badFiles f];
    else
      textCol = [0 0 0 ];
    end
    
    try 
      % main call
      fh = wt.plotSummaryFigure([],0);
      A = axis(fh(2));
      vis = get(fh(2),'Visible');
      text(A(1) + 0.03*diff(A(1:2)), A(3) + 0.95*diff(A(3:4)), ...
        ['Score: ' num2str(wt.lastLinkPositionMatrixScore(2))], ...
        'FontWeight','bold', 'Color', textCol, ...
        'Visible', vis, 'Parent', fh(2));

      % compute dPos > thresh
      whiskerIds = wt.whiskerIds(find(wt.whiskerIds > 0));
      posMat = zeros(wt.numWhiskers, wt.numFrames);
      nBad = 0;
      nanCount = 0;
      for w=1:length(whiskerIds)
        for F=1:length(wt.frames)
        fi = wt.frames(F);
        fpmi = find(wt.positionMatrix(:,1) == fi);

          widx = find(wt.positionMatrix(fpmi,2) == whiskerIds(w));
          if (length(widx) == 1)
            fwpmi = fpmi(widx);
            posMat(w,F) = wt.positionMatrix(fwpmi,3);
          end
        end
        diffVec = diff(posMat(w,:));  
        nBad = nBad + length(find(diffVec > dPosThresh));
      end
      nanCount = length(find(isnan(wt.thetas)));
      text(A(1) + 0.03*diff(A(1:2)), A(3) + 0.85*diff(A(3:4)), ...
        ['dPos > ' num2str(dPosThresh) ' : ' num2str(nBad)], ...
        'FontWeight','bold', 'Color', textCol, ...
        'Visible', vis, 'Parent', fh(2));
      text(A(1) + 0.03*diff(A(1:2)), A(3) + 0.75*diff(A(3:4)), ...
        ['nan Count: ' num2str(nanCount)], 'FontWeight','bold', 'Color', textCol, ...
        'Visible', vis, 'Parent', fh(2) );

      if (nanCount/wt.numFrames > (0.025*wt.numWhiskers)) 
        badFiles = [badFiles f];
      end

      print(fh(1),'-dpsc2', '-append', outputPath);
      close(fh(1));
  	catch me
      badFiles = [badFiles f];
			disp(['generateSummaryPDF fail: ' fl(f).name ' message: ' me.identifier '::' me.message]);
    end
    
	end

  % final page -- badFiles
	nf = 1;
	for b=1:length(badFiles)
	  if (nf == 1)
			fh = figure('Position', [0 0 600 1000], 'Visible', 'off');
			ah = axes('Position', [0 0 1 1], 'Visible', vis);
			axis(ah,[0 600 0 1000]);
			text(150,970,['Bad File List (' num2str(length(badFiles)) '/' num2str(length(fl)) ')' ], ...
           'FontWeight','bold', 'Visible',vis,'Parent',ah);
			nf = 0;
			yc = 950;
		end
    
	  text(100,yc,strrep(fl(badFiles(b)).name,'_','-'), 'Parent', ah, 'Visible',vis);
    yc = yc - 20;
		if (yc < 0 || b == length(badFiles))
			print(fh, '-dpsc2', '-append', outputPath);
		  nf = 1;
      close (fh);
    end
	end

	% ps2pdf
	if (system('which ps2pdf') == 0)
    system(['ps2pdf ' outputPath ' ' outputPathPdf]);
	end


