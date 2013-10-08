%
% SP Oct 2010
%
% Method for linking a series of whisker files -- uses parallel computing toolbox.
%
% EVERYTHING assumes that your animal's nose is pointing to the left, and that the
%   animal's face is at the top of the screen, with whiskers pointing down.  If
%   this assumption is NOT met, you need to write a method to alter your image 
%   and whisker position vectors appropriately.  This should be easy if you 
%   know linear algebraz.
%
% Logging is done in linkMultiple.log within the directory of the files, and
%  a pdf is generated for each .whiskers file to allow quick inspection of
%  the resulting whisker trajectories via plotSummaryFigure.
%
% USAGE:
%
%  linkMultiple (rootDirectory, fileListOrWildcard, numWhiskers, positionDirection, 
%                minWhiskerLength, maxFollicleY, useBadFrameTimes,
%                polynomialMaxFollicleY, polynomialDistanceFromFace)
%
%    rootDirectory: root path where all .whiskers and .mp4 files are
%    fileListOrWildcard: if a cell array, then treated as list of files WITHIN
%                        rootDirectory (i.e., strings should NOT include root
%                        path).  If a single string, used as a wildcard for
%                        generating file list.  If blank, equivalent to *.
%                        Obviously, .whiskers is appended to this and both the
%                        .whiskers and .mp4 files must be present.  You can also
%                        pass the output structure from a matlab dir call.
%    numWhiskers: how many whiskers to expect?
%    positionDirection: 1 means whiskers labeled left-to-right increasing #;
%                       -1 is opposite.  This is important because the initial
%                       (or last, if initial fails) frame is used as the basis
%                       for subsequent linking
%    minWhiskerLength: minimal length of whiskers in pixels - measure the
%                      distance from pad to pole, and subtract 10%.
%    maxFollicleY: sometimes the pole will split a whisker in two, or hairs
%                  on the face will get flagged as whiskers.  Set this to
%                  a point between whisker pad and pole, about 25% of the 
%                  way from the pad.  This will reject garbage.
%    useBadFrameTimes: if 1, it will use weird frame timings -- see the
%                      useBadFRames() method.  Otherwise, frameTimes are
%                      assumed to be uniformly distributed and are, therefore,
%                      simply 1:length(whiskerData)
%    polynomialMaxFollicleY: maximal Y value for whisker follicle to include
%                            the whisker in polynomial fitting for the
%                            updatePolynomialIntersectXY() call.  This   
%                            polynomial is used to convert whisker position
%                            into 1-d.
%    polynomialDistanceFromFace: distance range from face (follicle) along 
%                                along whisker used for poly fit
%
%
%    
function linkMultiple (rootDirectory, fileListOrWildcard, numWhiskers,  ...
     positionDirection, minWhiskerLength, maxFollicleY, useBadFrameTimes, ...
		 polynomialMaxFollicleY, polynomialDistanceFromFace)
	
	% 1) compile file list based on passed parameters
	if (iscell(fileListOrWildcard))
		wildCard = 'user specified';
	  for f=1:length(fileListOrWildcard)
		  fileList(f).name = fileListOrWildcard{f};
		end
	elseif (isstruct(fileListOrWildcard))
		wildCard = 'user specified';
	  fileList = fileListOrWildcard;
	else
	  if (length(fileListOrWildcard) == 0) 
		  fileListOrWildcard = '*';
		end
		wildCard = strrep(fileListOrWildcard,'.whiskers',''); % strip any .whiskers since this is done automagically
		fileList = dir([rootDirectory filesep wildCard '.whiskers']);
	end

	% 2) setup logs
  logFile = [rootDirectory filesep 'linkMultiple.log'];
	log2file(logFile, ['===============================================================================']);
	log2file(logFile, ['Starting processing in ' rootDirectory ' with wild card ' wildCard]);
	log2file(logFile, ['===============================================================================']);

  summaryFile = [rootDirectory filesep 'summary.log'];
	summaryCompleteScores = -1*ones(1,length(fileList));
	summaryPotentialProblemScores = 2*ones(1,length(fileList));

	% 3) master loop
	success = zeros(1,length(fileList));
	parfor f=1:length(fileList)
	  try % enclose the whole thing in a try block
			% filenames
			whiskersFile = [rootDirectory filesep fileList(f).name];
			mp4File = strrep(whiskersFile, '.whiskers', '.mp4');
			outputMatFile = strrep(whiskersFile, '.whiskers', '.mat');
			outputPDFFile = strrep(whiskersFile, '.whiskers', '.pdf');

			% the meat
			subidx = find(fileList(f).name == '_');
			trialId = str2num(fileList(f).name(subidx(length(subidx)-1)+1:subidx(length(subidx))-1));
			wt = session.whiskerTrial(trialId, whiskersFile , mp4File, polynomialMaxFollicleY, polynomialDistanceFromFace, minWhiskerLength);

			% sometimes there is a failure on load, in which case wt will be a number
      wt.enableWhiskerData();
			if (isstruct(wt.whiskerData))
				% general settings 
				wt.badFrameCriteria = [1 1 1];
				wt.numWhiskers = numWhiskers;
				wt.positionDirection = positionDirection;
				wt.minWhiskerLength = minWhiskerLength;
				wt.maxFollicleY = maxFollicleY;

				% frame tiems
				if (useBadFrameTimes)
					wt.useBadFrameTimes();
				end

				% message settings
				wt.waitBar = 0;
				wt.messageLevel = 2;

				% link, save, log
				score = wt.link();
				wt.matFilePath = outputMatFile;
				psave(outputMatFile, wt);
				log2file(logFile, ['FINISHED: ' fileList(f).name ' fraction all-present frames: ' num2str(score(1)) ' fraction putative misassignments: ' num2str(score(2))]);
				success(f) = 1;
				summaryCompleteScores(f) = score(1);
				summaryPotentialProblemScores(f) = score(2);

				wt.computeWhiskerParams();
			  log2file(logFile, ['finished contacts: ' fileList(f).name]);
				psave(outputMatFile, wt);
			end
		catch me
      log2file(logFile, ['GENERAL LINK FAIL: ' fileList(f).name ' message: ' me.identifier '::' me.message]);
		end
	end

	% 4) oh matlab, how I hate your stupid parallel toolbox -- generate summary figures
  for f=1:length(fileList)
	  if (success(f))
			whiskersFile = [rootDirectory filesep fileList(f).name];
			outputPDFFile = strrep(whiskersFile, '.whiskers', '.pdf');
			outputMatFile = strrep(whiskersFile, '.whiskers', '.mat');
			load(outputMatFile);

			% summary figure
			try
				fh = figure;
				wt.plotSummaryFigure(fh);
				print('-dpdf', outputPDFFile);
				delete(fh);
			catch me
				log2file(logFile, ['SUMMARY FIGURE FAIL: ' fileList(f).name ' message: ' me.identifier '::' me.message]);
			end
		end
	end

	% 5) Generate summary
	log2file(summaryFile, ['==============================================================================='], 1, 1);
	log2file(summaryFile, ['==============================================================================='], 1, 1);
	log2file(summaryFile, ['Summary for ' rootDirectory ' with wild card ' wildCard],1,0);
	log2file(summaryFile, ['sorted with largest fraction potential problem frames first.  2 = big problem.'],1,1);
	log2file(summaryFile, ['==============================================================================='], 1, 1);
	log2file(summaryFile, ['==============================================================================='], 1, 1);
	[scores sortedIdx] = sort(summaryPotentialProblemScores, 'descend');
	for s=1:length(sortedIdx)
	  i = sortedIdx(s);
		log2file(summaryFile, [fileList(i).name ' frac. potential problem: ' num2str(summaryPotentialProblemScores(i)) ' frac. all present: ' num2str(summaryCompleteScores(i))], 1, 1);
	end



% because matlab parallel toolbox is retarted
function psave(fname,wt)
  save(fname, 'wt')


