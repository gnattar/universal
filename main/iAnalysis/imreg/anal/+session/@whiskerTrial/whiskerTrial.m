%
% SP Aug 2010
%
% This defines a class for dealing with a single whisker movie.  The reason for
%  this being the unit is that analysis -- specifically linking and theta/
%  curvature analysis -- use this as the unit.
%
% Most of the methods in this class are false starts.  If at any point you want
%  to play with improving this, please talk to me and I can show you how this
%  stuff works.  There are a lot of things in here to make experimentation 
%  easier, and a lot of things have already been proven to fail . . .
%
% IMPORTANT: this ALL assumes that your face is at the TOP of the image and that
%  the animal's anterior-posterior axis is such that the anterior end is to the
%  left of the screen and the posterior is to the right, while the medial side
%  is towards the top (i.e., whisker follicle/face is TOP and whisker tips are
%  at BOTTOM).  If you have data in another orientation, PREROTATE/FLIP your
%  .whiskers after you read it in.  Do the same to the movies if you wish to 
%  view things.
%
% CONSTRUCTOR USAGE 1:
% 
%  wt = session.whiskerTrial(trialId, dotWhiskersPath, whiskersMoviePath
%		                        newPolynomialFitMaxFollicleY, newPolynomialDistanceFromFace)
%
%  REQUIRED:
%
%    trialId: the ID of the trial you are creating; numeric
%    dotWhiskersPath: the .whiskers file's FULL path
%    whiskersMovieFile: the .mp4 file's FULL path
%
%  OPTIONAL (leave as [] if you want to pass one but not the other)
%    
%    newPolynomialFitMaxFollicleY: (100 default) maximal Y to be included in whisker
%                          polynomial fit; see updatePolynomialIntersectXY.
%    newPolynomialDistanceFromFace: ([20 30] default) range of distances from
%                                   face along whisker that is included in poly
%                                   calculation 
%    
%
% CONSTRUCTOR USAGE 2: (for easy browsing)
% 
%  wt = session.whiskerTrial(basePath)
%
%  REQUIRED:
%
%    basePath: .mp4 and .whiskers are appended to this to get whiskers and base
%              name ; trial # is set to -1.  If no path is provided, pwd is used.
%
%  OPTIONAL (leave as [] if you want to pass one but not the other)
%    
%    newPolynomialFitMaxFollicleY: (100 default) maximal Y to be included in whisker
%                          polynomial fit; see updatePolynomialIntersectXY.
%    newPolynomialDistanceFromFace: ([20 30] default) range of distances from
%                                   face along whisker that is included in poly
%                                   calculation 
%    
%
classdef whiskerTrial< handle
  % Properties
  properties 
	  % basic
    trialId; % trial #
		whiskerIds; % whisker numbers [numeric]
		whiskerColors = [1 0 0; 0 1 0 ; 0 0 1 ; 1 1 0 ; 1 0 1 ; 0 1 1];

    % set to 1 if you want to save without any other steps
		quickSave = 0;
  
    % set to 1 to enable waitbars in long loops
		waitBar;

		% 1: basic messages 2: detailed messagesa
		messageLevel; 

		% parameters for processing
    numWhiskers; 
		maxFollicleY; % maximal Y value for follicle -- bar often separates whiskers,
		              %  and then the reported follicle value is very high; this is
									%  an easy way to detect and filter out these segments
		minWhiskerLength; % in pixels

		% a matrix where every 1:numWhiskers has a row and every frame has a column
		%  if the value is 0, whisker of id (row) is not present in frame (column)
		framesPresent;

		% parameters for dilation for assignIdFromOverlap (of dilated whiskers)
		dilationSize; % size of dilation square in pixels (length of side)
		dilationMaxPixels; % how many pixels - starting from follicle base - to use
		dilationIgnoreRejects; % 1: only use whisker segments with id > 0 ; 0: all
		dilationForceRedo; % Normally, dilation only happens once; if you change 
		                   %  parameters, this will be ignored unles this is set to 1
		overlapNFramesUsed; % How many frames to consider overlap?
		overlapNonlatestWeight; % when doing overlap, only use 1/this of poitns from 
		                        %  frames that are NOT the latest\
		overlapWeighByDistance; % If 1, score of candidate whisker combination will
		                        %  be weighted (divided by) the net follicle displacement
														%  that the particular combination introduces from 
														%  previous frame
		overlapWeightLengthChange; % Will incorporate CHANGE in length as another divisor 
		                           % (i.e., large change in length = penalty)
		overlapEnforceSpatialOrder; % Will assign a score of 0 to follicle combos that
		                            %  do not obey follcilePositionDirection.
		correctionTemporalDirection; % 1: go in increasing frame # (with time) ; 
		                          % -1: go in decreasing frame order ('against' time)
															% applies to assignIdFromOveralp and correct...()
															%  and detectBadFrames

    % parameters for 1-d representation of whisker position 
    positionDirection; % 1: left to right ; -1: right to left -- direction
	                     % in which #s are assigned to whiskers (left to right
											 % means position value must be INCREASING)
		positionMatrixMode; % 1: use follicle base positino
		                    % 2: use X-itnersect of the polynomial fitted to whisker trajectory
		                    % 3: use path length ALONG the above-described polynomial
		interAdjacentWhiskerDistanceMatrix; % in terms of position ; one row/frame, with
		                                    % each row consisting of the following columns:
		                                    %  [mean median min max] 
																				% Values are measured for whiskers that are
																				% both long enough AND > maxfolly
		positionDeltaMax; % maximal allowd displacement for position
		polynomialDistanceFromFace; % 2 element vector specifying range of distances, 
		                          %  in pixels, from face that are used to fit 
															%  positional polynomial (2nd degree for now)
		polynomialFitMaxFollicleY; % whiskers having follicle base Y greater than this are not used for the polynomial fit
		polynomial; % parameters for the polynomial -- 2nd deg [MUST BE 2nd degree!] -- format polyval compatible
		polynomialOffset; % offset applied to polynomial when it is computed

		% parameters for assignIdFromPosition 
		positionSortBy; % 1: length -- pick/ numWhiskers longers
		                        % 2: position -- from left to right, numWhiskers [id > 0]
		                        % 3: position -- from right to left, numWhiskers [id > 0]
		useFaceContour; % if set to 1, updateFolicleXY will compute a contour of
		                % face position based on shortest whiskers and use 
										%  proximity to this point to calculate follicle position
										% instead of minimal Y as is default.


 
		% parameters for correctLargeFoolicleDisplacement
    nFramesAroundSuddenPositionDisplacementsCorrected; % self explanatory(!)

    % files
    dotWhiskersPath; % the .whiskers file generated by Nate Dogg's tracker
    whiskerMoviePath;  % the movie file -- mp4
		whiskerDataFilePath; % path where whiskerData structure is stored (for speed/size)
    matFilePath; % where it is all saved to in the end
		basePathName; % the basic name of file obtained via fileparts

		% raw data
		whiskerData; % whiskerData(f).whisker(w).x: x coordinates of whisker w in frame f
		             %                          .y: y coordinates of whisker w in frame f
		             %                          .dilatedIndices: indices in image of when dilated
								 %               .whiskerLength(w): length of whisker in units of pixels.
		             %               .whiskerId(w): ID of whisker ; 0 = reject
								 %               .originalSegId(w): ID of segment in .measurements/.whiskers files
								 % Note that whiskerData is ONLY updated on save or on call of 
								 %    updateWhiskerdata.
		whiskerDataUpdated; % if 1, whiskerData will be saved on save call
		positionMatrix; % matrix with follicle positions -- FOR ALL FRAMES, not just obj.frames
		              % column 1: frame # ; column 2: whisker Id ; column 3: position
									% column 3 should only change when you change positionMaatrixMode
									% column 1 should *never* change and column 2 should be changed often as
									%   whisker ID is moved around
		lengthVector; % corresponds to positionMatrix, but stores whisker length.  
		lastLinkPositionMatrixScore; % return from scorePositionMatrix() for last link
		                             % 1: fraction of frames with ALL whiskers
																 % 2: fraction of frames that are missing a whisker but
																 %    have a non-tagged whisker meeting base criteria

		faceCOM; % center of mass of the face, KIND OF -- not a true COM

    % movie related / frame tracking
		frames; % frame indices.  Note that many methods are written in a way that 
		        %  respects this indexing.  So say that you have 3000 frames, but you
						%  want to test on 300:500 since the algo takes a long time.  If you
						%  set obj.frames to the desired range, EVERYTHING will operate on this
						%  subset.  Generally, frames should be 1:obj.numFrames, but
						%  if you are experimenting OR if a method is to be restricted to a 
						%  specific frame subset (e.g., badFrames), transiently assign obj.frames
						%  accordingly.  
		frameTimes; % frame time -- usually rel. start trial
		frameTimeUnit; % time unit of frames -- 1 usually [session.timeSeries.timeUnitId]
		numFrames; % # of frames -- wt.frames can be restricted if you want to operate
		           % on a smaller subset, but this variable ALWAYS is the numebr of actual
							 % frames in whiskerData (i.e., wt.numFrames >= length(wt.frames))

		% for bad frames -- i.e., the ones needign correction
		badFrames; % indices of frames deemed bad
		badFrameCriteria; % 2 element vector, 0 or 1 @ each position (1 to enable criteria):
	                    %  (1): large jumps in follicle x position displacement
											%  (2): missing one of nWhiskers
											%  (3): order violation (positionDirection applies)
    badFrameDPositionThresh; % threshold in distance for bad frame

  
	  % bar stuff
		barCenter; % for each frame ; 2xn matrix.  
		distanceToBarCenter; % for each whisker, distance to bar center (nframes,nwhisker)
		barRadius; % radius -- for now fixed, but leaving open possibility of different per frame
		barTemplateCorrelation; % what is the bar template correlation score @ this frame
		barFractionTrajectoryInReach; % 0: out of reach 1: fully in reach ; if 0 < this < 1, then 
		                              % some FRACTIONAL position is considered the point at which 
																	% the bar is touchable - fraction of center OR radius
		useFractionCorrectedPosition; % default 0; in this case, bar position is always used
		                              % according to match.  If 1, barCenter is held 
																	% at the initial in reach position for all positions
																	% after the first in-reach timepoint.  This is because it
																	% is assumed the pole is slanted and hence, relative whiskers
																	% what is important is this position and not the pole top
																	% which is what barCenter usually gives.
		barInReach; % boolean - 1 if in reach, 0 otherwise
		barInReachParameterUsed;  % 1,2: column of barCenter ; 3: barTemplateCorrelation 4: poleVoltageTrace
		barDominantPosition; % 1: in reach ; 0: out of reach [DEFAULT].  trackBar looks position or
		                     %  template-image correlation histogram and looks at the histogram's
												 %  two peaks ; the dominant position is the most-frequent (modal)
												 %  peak; the other position is the 2nd most frequent.  So if, as 
												 %  is in my case, your bar is generally NOT in range, set to 0
		barVoltageTrace; % populated sometimes post-hoc

		% kappa & theta related
		whiskerPolyDegree; % degree of whisker polynomial ; typically 5
		whiskerPolysX; % matrix where (f,(w-1)*whiskerPolyDegree+1:w*whiskerPolyDegree+1) is the
		               % polynomial from polyfit for whisker of whiskerId w (one of numWhiskers)
									 % during frame f - for the X component of whisker position
		whiskerPolysY; % matrix where (f,(w-1)*whiskerPolyDegree+1:w*whiskerPolyDegree+1) is the
		               % polynomial from polyfit for whisker of whiskerId w (one of numWhiskers)
									 % during frame f - for the Y component of whisker position
		lengthAtPolyXYIntersect; % Matrix of size (numFrames,numWhiskers), where each entry
		                         % is the length integrated along length that 
		kappas; % Matrix of (numFrames, numWhiskers) size storing your kappas
		thetas; % Matrix of (numFrames, numWhiskers) size storing your thetas
		kappaPositionType; % tells computeKappas what position to use ; see computeKappas
		kappaPosition; % tells computeKappas what position to use ; see computeKappas
		kappaParabolaHalfLength; % tells computeKappas secondary parabola size -- see computeKappas
		thetaPositionType; % tells computeThetas what position to use ; see computeThetas
		thetaPosition; % tells computeThetas what position to use ; see computeThetas
		deltaKappas; % Matrix of (numFrames,numWhiskers) size storing deltaKappas

		% whisker contact related
		whiskerContacts; % (numFrames, numWhiskers) matrix, where each entry signifies
		                 % the number of the whisker contact that occurs at that frame;
										 % 0 implies no contact.

	  % directional whisker contact related
		correctedBarCenter; % (numframes, 2) where 1 is x and 2 is y; position of bar
		                    %  with fraction bar in reach correction
		polynomialIntersectX; % (numFrames, numWhiskers) which stores X position of that
		                      % whisker's polynomial intersection
	  polynomialIntersectY; % y point as above
		whiskerPointNearestBarX; % Point along whisker that is closest to bar (X); (f,w)
		whiskerPointNearestBarY; % Y point

		% generated data -- what is eventually used by session structure
		whiskerCurvatureTSA; % timeSeriesArray object for curvature for numWhiskers whiskers
		whiskerAngleTSA; % timeSeriesArray with angular deflection
		whiskerBarContactESA; % eventSeriesArray with times of contacts (start, end)
		whiskerTag; % cell array same size as numWhiskers -- tells you identity of each whisker (D1, gamma, etc)

		% internal
		loading; % set to 1 during load to avoid annoying set calls
  end

	% Properties *NOT* saved to file -- internal variables basically
	properties (Transient = true)
	  whiskerMovieFrames; % from mmread 
		currentFrame; % index of frame currently being worked/looked at

		% for GUIS
		guiData; % this is a STRUCTURE whose members are data pertinent to 
		         % specific guis:
		         %   guiData.frameBrowser
		         %   guiData.batchSetup
		         %   guiData.barTemplateSelector
		         %   guiData.commandWindow
	end

	% Methods -- public
  methods (Access = public)
	  %
	  % Constructor
		%
    function obj = whiskerTrial(newTrialId, newDotWhiskersPath, newWhiskerMoviePath, ...
		                            newPolynomialFitMaxFollicleY, newPolynomialDistanceFromFace, newMinWhiskerLength)
			obj.loading = 0;

			% --- input handling
		  if (nargin < 1 ) % help message if 'light' version - for lightCopy etc.
			  help('session.whiskerTrial');
        disp('session.whiskerTrial::instantiating light version without support files etc.');
			else % # or File path settings
			  if (isnumeric(newTrialId))
					obj.trialId = newTrialId;
				else
				  obj.trialId = -1;
					[ffa ffb ] = fileparts(newTrialId);
					if (length(fileparts(newTrialId)) == 0)
					  newTrialId = [pwd filesep newTrialId];
					end
					obj.dotWhiskersPath = [newTrialId '.whiskers'];
					obj.whiskerMoviePath = [newTrialId '.mp4'];
					obj.matFilePath = [newTrialId '.mat'];
					obj.whiskerDataFilePath = [newTrialId '.wc'];
					[ffa ffb ] = fileparts(obj.dotWhiskersPath);
					obj.basePathName = ffb;
				end
			end

      % movie and whisker files specified
			if (nargin >= 3) 
				obj.dotWhiskersPath = newDotWhiskersPath;
				obj.whiskerMoviePath = newWhiskerMoviePath;
				obj.matFilePath = strrep(obj.dotWhiskersPath, '.whiskers','.mat');
				obj.whiskerDataFilePath = strrep(obj.dotWhiskersPath, '.whiskers','.wc');
				[ffa ffb ] = fileparts(obj.dotWhiskersPath);
				obj.basePathName = ffb;
			end

			% no polynomial stuff
			skipPoly = 0; % by default, DO polynomial fitting
			if (nargin == 3) % ... but if user d/n specify they may just want a quick look
			  skipPoly = 1;
			end

			% Face fitting parameters that may or may not have been passed
			if (nargin < 4)
			  newPolynomialFitMaxFollicleY = 100;
			elseif (length(newPolynomialFitMaxFollicleY) == 0)
			  newPolynomialFitMaxFollicleY = 100;
			end
			if (nargin < 5)
				newPolynomialDistanceFromFace = [20 30];
			elseif (length(newPolynomialDistanceFromFace ) < 2) 
				newPolynomialDistanceFromFace = [20 30];
			end
			if (nargin < 6)
				newMinWhiskerLength = 100;
			elseif (length(newMinWhiskerLength) ==0 ) 
				newMinWhiskerLength = 100;
			end

			% --- Setup
      % no frames @ start
			obj.numFrames = 0;

			% no whiskerData update
		  obj.whiskerDataUpdated=0; 

      % timing vector
			obj.frameTimeUnit = 1; % ms
			obj.frameTimes = [];

			% bad frame stuff
      obj.badFrames = [];
			obj.badFrameCriteria = [1 1 1]; % by default go for all criteria
			obj.badFrameDPositionThresh = 0;

			% follicle & face tracking
			obj.faceCOM = []; % no COM for now ...
			obj.useFaceContour = 1;
   
      % distance stuff (either follicle position or polynomial)
			obj.positionMatrix = [];
			obj.lengthVector = [];
			obj.positionDeltaMax = 40;  % MAXIMAL ALLOWED by certain methods -- not always applicable
			obj.positionDirection = -1;
			obj.positionMatrixMode = 3; % polynomial pah length
			obj.polynomialDistanceFromFace = newPolynomialDistanceFromFace;
			obj.polynomialFitMaxFollicleY = newPolynomialFitMaxFollicleY;
		  obj.polynomial = []; 
		  obj.polynomialOffset = []; 
   
			% default: disable wait bars, excessive messages
			obj.waitBar = 0;
			obj.messageLevel = 1;

			% defaults - general
			obj.numWhiskers = 4;
			obj.minWhiskerLength = newMinWhiskerLength; % pixels
			obj.maxFollicleY = 100;
			obj.framesPresent = [];

      % defaults - assignIdFromOverlap/generateDilatedIndices
			obj.dilationSize = 21; 
			obj.dilationMaxPixels = 70;
			obj.dilationIgnoreRejects = 1;
			obj.dilationForceRedo = 0; 
			obj.overlapNFramesUsed = 10; 
			obj.overlapNonlatestWeight = 1; % disable it
			obj.overlapWeighByDistance = 1;
			obj.overlapEnforceSpatialOrder = 1;
			obj.overlapWeightLengthChange = 1;

      % temporal direction
			obj.correctionTemporalDirection = 1; 

			% defauts - assignIdFromPosition
			obj.positionSortBy = 1;

			% bar properties
			obj.barDominantPosition = 0; % default is that it is more often out of reach than not
		  obj.barFractionTrajectoryInReach = 1; % default: must be @ end of trajectory to be in reach
			obj.barInReachParameterUsed = 0; % default to tell it you have NOT init'd yet
			obj.useFractionCorrectedPosition = 0; % do not by default alter position 

			% defaults - correctLargePositionDisplacements
			obj.nFramesAroundSuddenPositionDisplacementsCorrected = 10;

			% defaults for kappa, theta calculations
		  obj.whiskerPolyDegree = 5;
			obj.kappaPositionType = 4;
			obj.kappaPosition = 60;
			obj.kappaParabolaHalfLength = []; % in pixels ; 40 if you want it
			obj.thetaPositionType = 1;
			obj.thetaPosition = 0;

      % File stuff sepcified?
			if (nargin >= 3) 
				% call loadDotWhiskersFile -- sometimes this FAILS on corrupted files
				try
					obj.loadDotWhiskersFile();
				catch 
					disp(['whiskerTrial.loadDotWhiskersFile::failed to load ' obj.basePathName]);
					obj.whiskerData = -1;
					return;
				end

				% Setup face polynomial
				if (~skipPoly)
					obj.updatePolynomialIntersectXY();
				end
			end

			% STILL no position matrix?
			if (length(obj.positionMatrix) == 0)
			  obj.updatePositionMatrix();
			end
		end


    %
		% Creates light copy for positionMatrix manipulations -- basically everything
		%  except whiskerData
		%
		function lco = lightCopy(obj)
		  % --- create light clone
      lco = session.whiskerTrial(obj.trialId);
			if (obj.messageLevel >= 2)  
			  disp('session.whiskerTrial.lightCopy::light copy currently works with subset of methdos in link(). You may need to add');
				disp('                                additional attribute copying if you wish to work with other methods.'); 
			end
  
	    % --- assign parameters
      % naming
			lco.basePathName = obj.basePathName;
			lco.dotWhiskersPath = obj.dotWhiskersPath;
			lco.whiskerMoviePath = obj.whiskerMoviePath;
			lco.matFilePath = obj.matFilePath;
			lco.whiskerDataFilePath = obj.whiskerDataFilePath;

      % ids, colors etc.
			lco.whiskerIds = obj.whiskerIds;
			lco.whiskerColors = obj.whiskerColors;

			% frames
			lco.frames = obj.frames;
			lco.numFrames = obj.numFrames;

      % timing vector
			lco.frameTimeUnit = obj.frameTimeUnit;
			lco.frameTimes = obj.frameTimes;

			% bad frame stuff
      lco.badFrames = obj.badFrames ;
			lco.badFrameCriteria = obj.badFrameCriteria;
			lco.badFrameDPositionThresh = obj.badFrameDPositionThresh;

			% follicle & face tracking
			lco.faceCOM = obj.faceCOM; 
			lco.useFaceContour = obj.useFaceContour;
   
      % distance stuff (either follicle position or polynomial)
			lco.positionMatrix = obj.positionMatrix;
		  lco.interAdjacentWhiskerDistanceMatrix = obj.interAdjacentWhiskerDistanceMatrix;
			lco.lengthVector = obj.lengthVector;
			lco.positionDirection = obj.positionDirection;
			lco.positionMatrixMode = obj.positionMatrixMode; 
			lco.polynomialDistanceFromFace = obj.polynomialDistanceFromFace;
			lco.polynomialFitMaxFollicleY = obj.polynomialFitMaxFollicleY;
		  lco.polynomial = obj.polynomial;
		  lco.polynomialOffset = obj.polynomialOffset;
   
			% default: disable wait bars, excessive messages
			lco.waitBar = obj.waitBar;
			lco.messageLevel = obj.messageLevel;

			% defaults - general
			lco.numWhiskers = obj.numWhiskers;
			lco.minWhiskerLength = obj.minWhiskerLength ;
			lco.maxFollicleY = obj.maxFollicleY;
			lco.framesPresent = obj.framesPresent;

      % temporal direction
			lco.correctionTemporalDirection = obj.correctionTemporalDirection;

			% kappa, theta calculations
		  lco.whiskerPolyDegree = obj.whiskerPolyDegree;
			lco.kappaPositionType = obj.kappaPositionType;
			lco.kappaPosition = obj.kappaPosition;
			lco.kappaParabolaHalfLength = obj.kappaParabolaHalfLength; % in pixels
			lco.thetaPositionType = obj.thetaPositionType;
			lco.thetaPosition = obj.thetaPosition;

			lco.thetas = obj.thetas;
			lco.kappas = obj.kappas;
			lco.deltaKappas = obj.deltaKappas;

			% contact stuff
			lco.whiskerContacts = obj.whiskerContacts;

			lco.correctedBarCenter = obj.correctedBarCenter;
			lco.polynomialIntersectX = obj.polynomialIntersectX;
			lco.polynomialIntersectY = obj.polynomialIntersectY;
			lco.whiskerPointNearestBarX = obj.whiskerPointNearestBarX;
			lco.whiskerPointNearestBarY = obj.whiskerPointNearestBarY;


			% this is because lengtH(obj.whiskerData) is often required
			lco.whiskerData = 1:length(obj.whiskerData);
		end
	end

  % Methods -- Basic methods ...
	methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%% UTILITY METHODS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		% Updates ALL paths, replacing origStr with newStr across all paths
		function updatePaths(obj, origStr, newStr)
		  % if only one string passed, assume origStr is all but basedir name of whiskerDataFilePath
      if (nargin < 2) ; origStr = pwd ; end
      if (nargin < 3) ; newStr = origStr ; origStr = ''; end
		  if (length(origStr) == 0) ; origStr = fileparts(obj.whiskerDataFilePath);  end

		  obj.dotWhiskersPath = strrep(obj.dotWhiskersPath, origStr, newStr);
		  obj.whiskerMoviePath= strrep(obj.whiskerMoviePath, origStr, newStr);
		  obj.whiskerDataFilePath= strrep(obj.whiskerDataFilePath, origStr, newStr);
		  obj.matFilePath= strrep(obj.matFilePath, origStr, newStr);
		end

		% Loads .whiskers file ; called at end of constructor
	  loadDotWhiskersFile(obj)

		% Loads .measurements file and uses it to assign IDs
	  loadDotMeasurementsFile(obj, measurementsFilePath)

    % updates whiskerData.whiskerId 
    updateWhiskerData(obj)

		% enables whisker data by loading it from file
		enableWhiskerData(obj)

		% Loads particular frames *IF NOT LOADED ALREADY* into whiskerMovieFrames
		loadMovieFrames(obj, frames)

		% Uses "bad" frame times, defined in path of whiskerTrial.m in badFrameTimes.mat,
		%  where the variable frameTimes is used for whisker.frameTimes.
		function useBadFrameTimes(obj)
		  prePath = fileparts(which('session.whiskerTrial'));
			tmp = load([prePath filesep 'badFrameTimes.mat']);
			obj.frameTimes = tmp.frameTimes;
			modeDt = mode(diff(obj.frameTimes));
			nAdded = length(obj.frames)-length(obj.frameTimes);
			if (nAdded > 0)
			  for f=1:nAdded
				  obj.frameTimes(length(obj.frameTimes)+1) = obj.frameTimes(length(obj.frameTimes)) + modeDt;
				end
			elseif (nAdded < 0) % too MANY
			  obj.frameTimes = obj.frameTimes(1:end+nAdded);
			end
			if(size(obj.frameTimes,1) > 1) ; obj.frameTimes = obj.frameTimes'; end

			% take off 100 ms since we do this OURSELVES!! this needs to be CNSISTENT
			obj.frameTimes = obj.frameTimes-100;
		end


		% Determines which frames are bad
		detectBadFrames(obj, windowSize)

		% This will blank dilated indices for all whiskers, trials, forcing redo on
		%  next assignDIlatedIndices call ; useful for overlap resets and also 
		%  shoudl be done before saving as this adds some serious heft to files.
		function obj = clearDilatedIndices(obj)
		  if (length(obj.whiskerData) > 0)
				for f=1:obj.numFrames
					for w=1:length(obj.whiskerData(f).whisker)
						obj.whiskerData(f).whisker(w).dilatedIndices = [];
					end
				end
			end
		end

		% This will apply maxFollicleY threshold to all whiskers id > 0 
		applyMaxFollicleY (obj)

		% This will eliminate whiskers that are not long enuff
		applyLengthThreshold(obj, preventDeZero)

		% This will return mean length of whisker with ID whiskerId
		meanLen = getMeanLength(obj, whiskerId)

		% Returns most recent overlap frame derived from framesPresent for two Ids; 
		olf = getMostRecentOverlapFrame (obj, id1, id2, f)

		% Gives consensus position from last time missingId overlapped with the presentIds
    consensusPosition = getConsensusPositionForMissingFromPresent (obj, missingId, presentIds, f)

		% This will return a *range* of positions in which a particular whisker is likely
		%  to reside based on the position of the present whisker(s).
		positionRange = getPositionRangeForMissingFromPresent (obj, missingIds, presentIds, f)

		% Will only do whiskers in most recent frame with some overlap
		positionRange = getPositionRangeForMissingFromMostRecentlyPresent(obj, missingIds, presentIds, f)

    % Returns position range and expected position for each missingIds whisker using interpolation
    [expectedPosition positionRange] = getPositionRangeForMissingFromInterp (obj, missingIds, presentIds, f)

    % Returns position range, expected position for missingIds whiskers using interpolation of all whisker motion
    [expectedPosition positionRange] = getPositionRangeForMissingFromNetMotionInterp (obj, missingIds, presentIds, f)

    % As with getPositionRangeForMissingFromNetMotionInterp, but improved
    [expectedPosition positionRange] = getPositionRangeForMissingFromNetMotionInterp2 (obj, missingIds, presentIds, f, SFdEP)

		% This will combine whiskers where the root name is shared, root being the start of the name
		status = consolidateDoubleWhiskers(obj, cleanup)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% BAR HANDLERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		% tracks the bar using template
		trackBar(obj, barTemplatePath)

		% computes barInReach
		computeBarInReach(obj)

		% returns bar in reach based on barFractionTrajectoryInReach
		[barInReach barCenterAtFirstContact] = getFractionCorrectedBarInReach(obj)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%% POSITION HANDLERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
		% updates positionMatrix (no params means generate de novo)
		updatePositionMatrix(obj, F)

		% updates whiskerData(:).whisker(:).follicleXY
		updateFollicleXY(obj)

		% Fits whisker trajectory to a polynomial (2d) that is then used for positioning 
		%  whiskers (updates whiskerData(:).whisker(:).polynomialIntersectXY and
		%  polynomialIntersectXY
		updatePolynomialIntersectXY(obj)

		% updates interwhisker distance matrix
		updateInterWhiskerDistanceMatrix (obj)

    % Returns all positionDirection-obeying candidate whisker sets at frame f
    [originalIdVec originalPMIdxVec newIdMat] = getAllOrderPreservingCandidates(obj, f)

		% Will predict position of whisker at desired frames.  Uses matlab's interp1 function.
		posVec = predictPositionFromInterp(obj, whiskerId, knownFrames, predictedFrames, method, frameHorizon)

		% This will return the change(s) in position for the specified whisker(s).
		dp = getDeltaPosition (obj, f, whiskerIds, frameHorizon)

		% This will return the change(s) in length for the specified whisker(s).
		dl = getDeltaLength(obj, f, whiskerIds, frameHorizon)

		% Returns most recent length of whisker(s) whiskerId before or ON f
		wl = getLastWhiskerLength(obj, whiskerId, f)

		% Returns most recent position of whisker(s) whiskerId before or ON f
		wp = getLastWhiskerPosition(obj, whiskerId, f)

		% Returns position of whisker(s) whiskerId at frame f
		wp = getWhiskerPosition(obj, whiskerId, f)

		% Returns length of whisker(s) whiskerId at frame f
		wl = getWhiskerLength(obj, whiskerId, f)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%% LINKING METHODS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % master linker -- should be state-of-the art command sequence; returns score
		score = link(obj)

		% This will assign ID based on being one of the numWhiskers longest whiskers,
		%  and then going from left to right off of top-most point.
		assignIdFromPosition(obj)

		% Chunker
		assignIdByConservativeDisplacementChunking(obj)

		% Adaptive linker that is quick and uses position
		assignIdFromWhiskerPositionProximity(obj)

		% Computes the score of particular whisker combo relative last frame -- ONLY
		score = getLengthPositionCompositeScore(obj, newIdVec, originalIdVec, missingIds, f, posBounds, expectedPos)

		% Scores the positionMatrix on various criteria
		scores = scorePositionMatrix(obj)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%% METHODS FOR CHUNK HANDLINNG %%%%%%%%%%%%%%%%%%%%%%
		
		% Deletes all whisker segments with ID delId by setting their ID to zero and 
		%  then nan'ing them in position matrix.
    deleteAllWithId (obj, delId)
 
		% Swaps the ids of two whiskers - i.e., chunk swap
		swapIds(obj, Id1, Id2)

		% Assigns ALL whiskers with a given ID a new id -- AKA chunk join!
		assignNewId(obj, oldId, newId, stopOverlap)

		% Breakup segment into 2
		breakupIdSegment (obj, f, oldId, newId)

		% Breakup into distinct chunks ohrdering flips
		breakupOrderingReversals(obj)

		% Breakup id contiguity if there is an abnormal jump in position
		breakupLargePositionJumps(obj, veryLargeJumps)

		% This will break 1:numWhiskers where unsual position changes occur
    breakupUnusualPositionJumpsForPrincipals(obj)

		% Breakup id contiguity if there is an abnormal jump in length
		breakupLargeLengthJumps(obj)

		% Updates obj.whiskerIds by looking at positionMatrix
		refreshWhiskerIds (obj)

		% Builds framesPresent matrix 	 ; optionally, update it @ a single frame
		updateFramesPresent(obj,f)

		% This will remove whiskers that are not 1:numWhiskers in frames where all
		%  desired whiskers ARE present.  Note that entire chunks are removed.
		removeExtraWhiskers(obj,frames, cleanup)

		% This will clean up whisker IDs preventing dupes at a given frame
		removeWhiskerIdDuplicates(obj, f, removeZeroDupes)

		% Returns the ordering in terms of whiskerIds for frame f
		ordering = getWhiskerOrdering(obj, f, whiskerIds)

		% This will force the proper ordering for 1:numWhiskers based on positionDirection
		%  for frame f.
		forceOrderingAtFrame (obj, f, mode)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%% KAPPA,THETA,CONTACT METHODS %%%%%%%%%%%%%%%%%%%%%%%%%%

		% This will run all of the below
		computeWhiskerParams(obj, skipBarTrack)

		% This will populate whiskerPolys
		computeWhiskerPolys (obj)

		% computes distance to bar CENTER
		computeDistanceToBar(obj)

		% populates kappas evaluated at a specific position
		computeKappas(obj, positionType, position, parabolaHalfLength)

		% computes baseline then delta kappa
		computeDeltaKappasWrapper(obj)

		% populates thetas evaluated at a specific position
		computeThetas(obj, positionType, position)

		% detects contacts using bar presense & kappa
		detectContactsWrapper (obj)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%% BATCH PROCESSING METHODS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		% This will run computeWhiskerParams AND link
		process(obj)

		% This will run process based on a batchConfig .mat file
		processFromBatchConfigFile(obj, batchConfigFilePath)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% GUIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		% gui to browse frames
		guiFrameBrowser(obj, subFunction, subFunctionParams)

		% gui to select bar template
		guiBarTemplateSelector(obj, subFunction, subFunctionParams)

		% for setting up batch stuff
		guiBatchSetup(obj, subFunction, subFunctionParams)

		% with main commands
    guiCommandWindow(obj, subFunction, subFunctionParams)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%% PLOTTING METHODS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		% Plots the frame(s) with whiskers superimposed
		plotFrame(obj, frameIdx, axHandle, plotOpts)

    % plots whisker trajectories
    plotPositionTrajectory(obj, whiskerIds, axHandle, plotBadFrames)

		% plots whisker position v length
    plotLengthVPosition(obj, whiskerIds)

    % plots kappas
    plotKappas(obj, whiskerIds, axHandle, showContacts)

    % plots kappa change
    plotDeltaKappas(obj, whiskerIds, axHandle, showContacts)

    % plots kappas vs. barDistanceToCenter
    plotKappaVBarDistance(obj, whiskerIds, frames, axHandle, showContacts)

    % plots thetas
    plotThetas(obj, whiskerIds, axHandle)

		% plots a summary figure
		handles = plotSummaryFigure(obj, figHandle, hide)

		% plots whisker trajectory *in 2d*
    plotNetWhiskerTrajectory(obj, whiskerIds, frames)

		% plots whisker trajectory *in 2d*, coloring based on frequency of crossing
    plotWhiskerHeatmap(obj, whiskerIds, frames)

		% This will assign whisker colors randomly beyond the first 5
		assignRandomColors(obj)
	end

	% Static methods
	methods (Static = true)
		% this is called on load
	  function obj = loadobj(a) 
		  a.loading = 1;
		  obj = a;
	    obj.whiskerMovieFrames = []; % will force reload since not cell

			if (length(obj.useFractionCorrectedPosition) == 0)
			  obj.useFractionCorrectedPosition = 0;
			end

			obj.loading = 0;
		end

		% for batch linking
		linkMultiple (rootDirectory, fileListOrWildcard, numWhiskers, positionDirection, minWhiskerLength, ...
		              maxFollicleY, useBadFrameTimes, polynomialMaxFollicleY, polynomialDistanceFromFace)

		% A fucntion for generating possbile whisker positino permuttaions
    comboMat = getAllWhiskerCombinations(availableWhiskerIds, numDesiredWhiskers, minNumWhiskers)

    % This finds bar then computes its size & center given an image with a ROUND bar in it
    [barCenter barRadius] = determineBarCenterAndRadiusForTemplate(radiusRange, barTemplateIm, suppressOutput)
 
    % This will generate the .mat files for par_Execute to run -- object-independent thus static
    generateParFiles(whiskerSourcePathWc, parDirectoryPath)

		% For parallel processing -- called by par_execute
		executeParFile(subfunc, params)

    % actual logic for delta kappa computation
    deltaKappas = computeDeltaKappas(kappas, thetas, barInReach, postProcess)
	
		% soon-to replace real deal
		whiskerContacts = detectContacts(kappas, dtobar, barInReach, params)

		% will output plotPositionTrajectory for all guys meeting criteria to a giant postscript
    generateSummaryPDF(fileWildcard, scoreThresh)

		% static method that does actual kappa computation
    kappas = computeKappasS (numFrames, numWhiskers, positionType, position, ...
                         lengthAtPolyXYIntersect, lengthMatrix, whiskerPolyDegree, ...
												 whiskerPolysX, whiskerPolysY, parabolaHalfLength, wt)
	
		% static method that does actual theta computation
    thetas = computeThetasS (numFrames, numWhiskers, positionType, position, ...
                         lengthAtPolyXYIntersect, lengthMatrix, whiskerPolyDegree, ...
												 whiskerPolysX, whiskerPolysY)

		% static method that cleans up contacts
    whiskerContacts = detectContactsCleanupS (whiskerContacts, kappas, fillSkipSize, minTouchDuration)
	end

  % Methods -- set/get/basic variable manipulation stuff
	methods 
		% called on save
		function b = saveobj(a)
		   if (a.quickSave ~= 1) 
				 % update whisker data
				 a.updateWhiskerData();
				 % save whiskerData to separate file
				 if (a.whiskerDataUpdated)
					 whiskerData = a.whiskerData;
					 save(a.whiskerDataFilePath, 'whiskerData', '-mat');
					 a.whiskerDataUpdated = 0;
				 end
				 a.whiskerData = [];

				 % clear dilated indices
				 a.clearDilatedIndices();
       end

       % and output
			 b = a;
		end

	  % polynomialDistanceFromFace -- set polynomial [] to force redo
    function set.polynomialDistanceFromFace (obj, value)
		  if (~obj.loading)
				if (length(value) ~= 2) % 2 elements?
					disp('whiskerTrial.set.polynomialDistanceFromFace::Must be 2 element vector.');
				elseif (length(obj.polynomialDistanceFromFace) ~= 2) % is older 2 elements or blank?
					obj.polynomialDistanceFromFace = value;
					obj.polynomial = [];
				elseif (sum(obj.polynomialDistanceFromFace == value) < 2) % is value different?
					obj.polynomialDistanceFromFace = value;
					obj.polynomial = [];
				end
			else
				obj.polynomialDistanceFromFace = value;
			end
		end

		% positionMatrixMode -- automatically call updatePositionMatrix()
		function set.positionMatrixMode(obj, value)
		  if (~obj.loading)
				if (length(obj.positionMatrixMode) == 0)
					obj.positionMatrixMode = value;
				else
					opm = obj.positionMatrixMode;
					if (opm ~= value)
						obj.positionMatrixMode = value;
						obj.updatePositionMatrix();
					end
				end
			else
				obj.positionMatrixMode = value;
			end		  
		end

		% thetaPosition 
		function set.thetaPosition(obj, value)
		  if (~obj.loading)
				okt = obj.thetaPosition;
				if (length(okt) == 0)
					obj.thetaPosition = value;
				elseif (okt ~= value)
					obj.thetaPosition = value;
					obj.thetas = [];
					obj.distanceToBarCenter = [];
					obj.whiskerAngleTSA = [];
					obj.whiskerContacts = [];
					obj.whiskerBarContactESA = [];
				end
			else
				obj.thetaPosition = value;
			end
		end

		% thetaPositionType
		function set.thetaPositionType(obj, value)
		  if (~obj.loading)
				oktt = obj.thetaPositionType;
				if (length(oktt) == 0)
					obj.thetaPositionType = value;
				elseif (oktt ~= value)
					obj.thetaPositionType = value;
					obj.thetas = [];
					obj.whiskerAngleTSA = [];
					obj.distanceToBarCenter = [];
					obj.whiskerContacts = [];
					obj.whiskerBarContactESA = [];
				end
			else
				obj.thetaPositionType = value;
			end
		end

		% kappaPosition
		function set.kappaPosition(obj, value)
		  if (~obj.loading)
				okp = obj.kappaPosition;
				if (length(okp) == 0) 
					obj.kappaPosition = value;
				elseif (okp ~= value)
					obj.kappaPosition = value;
					obj.kappas = [];
					obj.deltaKappas = [];
					obj.whiskerCurvatureTSA = [];
					obj.whiskerContacts = [];
					obj.whiskerBarContactESA = [];
				end
			else
				obj.kappaPosition = value;
			end
		end

		% kappaPositionType
		function set.kappaPositionType(obj, value)
		  if (~obj.loading)
				okpt = obj.kappaPositionType;
				if (length(okpt) == 0)
					obj.kappaPositionType= value;
				elseif (okpt ~= value)
					obj.kappaPositionType = value;
					obj.kappas = [];
					obj.deltaKappas = [];
					obj.whiskerCurvatureTSA = [];
					obj.whiskerContacts = [];
					obj.whiskerBarContactESA = [];
				end
			else
			  obj.kappaPositionType = value;
			end
		end

    % matFilePath get -- if blank, use dotWhiskersPath
		function value = get.matFilePath (obj)
		  if (length(obj.matFilePath) == 0)
				obj.matFilePath = strrep(obj.dotWhiskersPath, '.whiskers','.mat');
			end
			value = assign_root_data_path(obj.matFilePath);
		end

    % whiskerMoviePath
		function value = get.whiskerMoviePath (obj)
			value = assign_root_data_path(obj.whiskerMoviePath);
		end

    % dotWhiskersPath
		function value = get.dotWhiskersPath (obj)
			value = assign_root_data_path(obj.dotWhiskersPath);
		end

    % whiskerDataFilePath 
		function value = get.whiskerDataFilePath(obj)
			value = assign_root_data_path(obj.whiskerDataFilePath);
		end

	  % -- ID ; nothing for now
%	  function obj = set.id (obj, newId)
%		  obj.id = newId;
%		end
%	  function value = get.whiskerMovieFrames(obj, idx)
%		  % is frame index requested loaded?
%		  value = obj.whiskerMovieFrames;
%		end
  end

end
