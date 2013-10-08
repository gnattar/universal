%
% Class to handle a session's worth of whisker data.
%
% USAGE:
%
%  Generally, you should invoke the static construction wrapper:
%
%  wta = session.whiskerTrialArray.generateWhiskerTrialArray(pwd,'WDBP*_*mat');
%
%  If you want to store the wta object somewhere specific (other than pwd), 
%   set the baseFileName property.
%
%  If you 
%
% CONSTRUCTOR:
%
%    wta = session.whiskerTrialArray (newWtArray, newBasePath, newBaseFileName)
%
%    newWtArray, newBasePath, newBaseFileName: see wtArray, basePath, and 
%       baseFileName properties below.
% 
% PROPERTIES:
%
%   Related to basic information about trial:
%
%     whiskerTags: string name of all whiskers that appear in session
%     whiskerPresent: matrix with a row per trial ; 1 if whisker is in that trial
%     numWhiskers: how many whiskers?
%     numTrials: how many trials
%     basePath: what is the base data path for files?  Changes propagate.  
%               DISTINCT from baseFileName, which is where the whiskerTrialArray
%               is saved to.  basePath is where the original data is -- the
%               whiskerTrial objects -- whereas baseFileName is where the new
%               whiskerTrialArray stuff is.
%     baseFileName: Where whiskerTrialArray is stored and its subordinate objects
%
%     fileIndices: for any TSA/ESA, if you find the index of a time point within
%                  obj.time, and then look at obj.fileIndices(x), that means that 
%                  the data originates from obj.wtArray{obj.fileIndices(x)}. 
%                  This ordering is sacrosanct and should NEVER be disrupted.
%
%     time: time vector
%     timeUnit: unit of time vector
%     trialIndices: vector of size time with trial # for each time point
%     trialTimes: for eventSeries trial # assignment
%
%   Data:
%
%     wtArray: cell array of individual whiskerTrial objects
%
%     whiskerTrackPolyIntersectXYTSA:  timeSeriesArray with track polynomial
%       intersection XYs (2 timeSeries/wh)
%     whiskerLengthTSA: timeSeriesArray storing whisker length
%     whiskerLengthAtTrackPolyIntersectTSA: TSA with distance from follicle 
%       to the face-hugging polynomial mask usually used as reference pos
%
%     whiskerPolysX: Matrix with all whisker-fit polynomials, where the 
%                    row is a trial and there are whiskerPolyDegree entries per
%                    whisker.  These are the X values.
%     whiskerPolysY: same as above, but for Y values
%
%     barCenterTSA: position of bar, in TSA form
%
%     whiskerAngleTSA: whisker angle at that time
%     whiskerCurvatureTSA: curvature for each whisker at each time point
%     whiskerCurvatureChangeTSA: curvature, normalized to the typical curvature
%       at that angle
%  
%	    whiskerPointNearestBarXYTSA: X/Y vector per whisker with x,y coordinates
%                                  of whisker point closest to bar center
%  		whiskerDistanceToBarTSA: Distance to bar for each whisker at each time
%
%     whiskerBarContactESA: event series with contacts
%     whiskerBarContactClassifiedESA: event series with pro/re labeled contacts
%     whiskerBarInReachTS: when bar was touchable, this is 1
%     whiskerBarInReachES: eventSeries representation of above
% 
%     barVoltageTS: stores output of bar voltage from ephus, if available.  This
%                   timeSeries does not have the same time vector as most of the rest.
%
%   Settings for the session:
%
%     whiskerPolyDegree: degree of whisker-fit polynomial
%     pix2um: multiply pixels by this to get microns
%     barRadius: radius of bar, in pixels
%     kappaPositionType: see session.whiskerTrial.computeKappas 
%     kappaPosition: position along whisker of kappa measurement ; see 
%       session.whiskerTrial.computeKappas
%     kappaParabolaHalfLength: if assigned a value, computeCurvatures will 
%        use the local parabolic estimate of this size (half-length, in pixels).
%        This is quite slow, but much less noisy.
%     thetaPositionType: see computeThetas ; at what point to measure theta?
%     thetaPosition: depends on thetaPositionType.
%
%  Other:
%
%     params: A structure that is used by (static) generateUsingParams to allow 
%             all-in-one execution.  If not running from this, it is IGNORED.
%
%             Fields (* means mandatory ; rest are optional):
%
%       *params.whiskerFilePath: Where are the whisker files?
%       *params.whiskerFileWC: wild card to use ; alternatively, whiskerFilePath
%                             can be cell array of FULL paths and this blank
%       params.barInReachFraction: At what fraction of its trajectory in/out
%                                  is the bar in reach? 1 default
%       params.barCenterOffset: How much to shift bar center by ; [x y]
%       params.barRadius: What should the bar radius be set to? 
%
%       *params.ephusPath: Pass this and it will use this to load bar voltage
%       *params.ephusWC: this is wildcard of ephus files with bar voltage
%       params.barVoltageTS: Alternative to ephusPath/WC ; pass the bar voltage
%         timeSeries directly via this.
%      
%       *params.baseFileName: where to save the resulting object to?
%
%       params.detectContactsParams: params argument to
%                                    session.whiskerTrialArray.detectContacts;
%                                    see that method for details
%
%  Internal stuff:
%
%     loadableVar: vars that use loadOnGet (see lib/loadonget*)
%     loadFlag: -1 don't load ; 0 not loaded but do load ; 1: loaded (loadonget support)
%     loading: 1 during load so that set methods don't get called
%
% (C) S Peron Mar 2012
%
classdef whiskerTrialArray < handle
	%% --- Properties
  properties 
	  whiskerTags;
		whiskerPresent; 
		numWhiskers;
		numTrials;
		basePath;
		baseFileName;

		fileIndices;
		time;
		timeUnit;
		trialIndices;
		trialTimes;

		wtArray;

		whiskerTrackPolyIntersectXYTSA;
		whiskerLengthTSA;
		whiskerLengthAtTrackPolyIntersectTSA;

		whiskerPolysX;
		whiskerPolysY;

		barCenterTSA;

		whiskerAngleTSA;
		whiskerCurvatureTSA;
		whiskerCurvatureChangeTSA; 
		  
	  whiskerPointNearestBarXYTSA;
		whiskerDistanceToBarTSA;

		whiskerBarContactESA; 
		whiskerBarContactClassifiedESA; 

		whiskerBarInReachTS;
		whiskerBarInReachES; 
		barVoltageTS; % 1) (use to recalculate whiskerBarInReachTS ...)

		whiskerPolyDegree;
		pix2um; % (not important now)
		barRadius;
		kappaPositionType;
		kappaPosition;
		kappaParabolaHalfLength;
		thetaPositionType;
		thetaPosition;

		params;

		loadableVar = {'wtArray', 'whiskerTrackPolyIntersectXYTSA', 'whiskerLengthTSA' , ...
		               'whiskerLengthAtTrackPolyIntersectTSA', 'whiskerPolysX', 'whiskerPolysY', ...
									 'whiskerPointNearestBarXYTSA', 'whiskerDistanceToBarTSA', ...
									 'barCenterTSA', 'whiskerAngleTSA', 'whiskerCurvatureTSA', 'whiskerCurvatureChangeTSA'};
%		loadFlag = [0 0 0 0 0 0 0 0 0 0 ];
		loadFlag = [0 0 0 0 0 0 0 0 0 0 0 0];

		loading; % so that set methods can be skipped ...
  end

  % Properties not saved to file
	% properties (Transient = true)
	% end

	%% --- Public methods
	methods (Access = public)

    %
		% Constructor
		%
		function obj = whiskerTrialArray (newWtArray, newBasePath, newBaseFileName)
      % Constructor for whiskerTrialArray
		 
		  obj.loading = 0;

		  % input check
			if (nargin < 3 && nargin > 0)
			  help('session.whiskerTrialArray');
			  error('session.whiskerTrialArray.whiskerTrialArray::constructor requires 2 variables; call static generateWhiskerTrialArray instead.');
      elseif (nargin > 0) % don't return just blank object -- use passed stuff

				% assign passed
				obj.wtArray = newWtArray;
				obj.basePath = newBasePath;
				obj.baseFileName = newBaseFileName;

				% some basic variable assignment
				obj.numTrials = length(obj.wtArray);
				whiskerTags = {};
				for t=1:length(obj.wtArray)
					for w=1:length(obj.wtArray{t}.whiskerTag)
						whiskerTags{length(whiskerTags)+1} = obj.wtArray{t}.whiskerTag{w};
					end
				end
				obj.whiskerTags = unique(whiskerTags);
				obj.numWhiskers = length(obj.whiskerTags);

				% now populate whiskerPresent
				obj.populateWhiskerPresentMatrix();
			end
		end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% UTILS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		% 
		% Populates whiskerPresent matrix
		% 
		function obj = populateWhiskerPresentMatrix(obj)
		  obj.whiskerPresent = zeros(obj.numTrials, obj.numWhiskers);
			for t=1:obj.numTrials
			  for w=1:length(obj.whiskerTags)
				  if (sum(strcmp(obj.whiskerTags{w}, obj.wtArray{t}.whiskerTag)) == 1)
					  obj.whiskerPresent(t,w) = 1;
					end
				end
			end
		end

		%
		% Deletes a single trial
		%
		function obj = deleteTrial(obj, trialId)
		  % the hard stuff 
			ti = find(obj.trialIndices == trialId);
      if (length(ti) == 0) ; disp('session.whiskerTrialArray.deleteTrial::no match found.'); return ; end

			keepIndices = setdiff(1:length(obj.trialIndices),ti);
			fi = obj.fileIndices(ti(1));
      keepIdx = setdiff(1:obj.numTrials, fi);

			obj.whiskerPresent = obj.whiskerPresent(keepIdx,:);
			obj.wtArray = obj.wtArray(keepIdx);
			obj.numTrials = obj.numTrials - 1;

      % fileIndices must respect 1 2 3 4 ... and match wtArray
			keptIndices = obj.fileIndices(keepIndices);
			newFileIndices = 0*keptIndices;
			uki = unique(keptIndices);
      for i=1:length(uki)
			  idx = find(keptIndices == uki(i));
				newFileIndices(idx) = i;
			end
			obj.fileIndices = newFileIndices;

      if (length(obj.whiskerPolysX) > 1)
				obj.whiskerPolysX = obj.whiskerPolysX(:,keepIndices);
				obj.whiskerPolysY = obj.whiskerPolysY(:,keepIndices);
			end

      if (isobject(obj.whiskerBarInReachTS)) 
				obj.whiskerBarInReachTS.time = obj.whiskerBarInReachTS.time(keepIndices);
				obj.whiskerBarInReachTS.value = obj.whiskerBarInReachTS.value(keepIndices);
			end
	
      if (isobject(obj.barVoltageTS)) 
				obj.barVoltageTS.time = obj.barVoltageTS.time(keepIndices);
				obj.barVoltageTS.value = obj.barVoltageTS.value(keepIndices);
			end
				
      % "easy" stuff -- call delete methods of ESA, TSA, ES
			if (isobject(obj.whiskerTrackPolyIntersectXYTSA)) ; obj.whiskerTrackPolyIntersectXYTSA.deleteTrials(trialId); end
			if (isobject(obj.whiskerLengthTSA)) ; obj.whiskerLengthTSA.deleteTrials(trialId); end
			if (isobject(obj.whiskerLengthAtTrackPolyIntersectTSA)) ;obj.whiskerLengthAtTrackPolyIntersectTSA.deleteTrials(trialId); end
			if (isobject(obj.barCenterTSA)) ;obj.barCenterTSA.deleteTrials(trialId); end
			if (isobject(obj.whiskerAngleTSA)) ;obj.whiskerAngleTSA.deleteTrials(trialId); end
			if (isobject(obj.whiskerCurvatureTSA)) ;obj.whiskerCurvatureTSA.deleteTrials(trialId); end
			if (isobject(obj.whiskerCurvatureChangeTSA)) ;obj.whiskerCurvatureChangeTSA.deleteTrials(trialId); end
			if (isobject(obj.whiskerPointNearestBarXYTSA)) ;obj.whiskerPointNearestBarXYTSA.deleteTrials(trialId); end
			if (isobject(obj.whiskerDistanceToBarTSA)) ;obj.whiskerDistanceToBarTSA.deleteTrials(trialId); end

			if (isobject(obj.whiskerBarContactESA)) ; obj.whiskerBarContactESA.deleteTrials(trialId); end
			if (isobject(obj.whiskerBarContactClassifiedESA)) ; obj.whiskerBarContactClassifiedESA.deleteTrials(trialId); end

			if (isobject(obj.whiskerBarInReachES)) ; obj.whiskerBarInReachES.deleteTrials(trialId); end


      % time and trialIndices updated at very end with load flag ON 
			%  so that set method is not dumb
			obj.loading = 1;
      obj.time = obj.time(keepIndices);
      obj.trialIndices = obj.trialIndices(keepIndices);
			obj.loading = 0;
		end
    
		%
		% Updates data paths for all whiskerTrial objects
		%
		function obj = updatePaths(obj, newDataPath)
		  for t=1:obj.numTrials
			  obj.wtArray{t}.updatePaths(newDataPath);
			end
		end

		% pushes data into wtArray
		obj = pushDataToWtArray(obj)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DATA GENERATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		% compiles 'derived' data from individual trials - should be called early
		obj = compileArrayDataFromTrials(obj)

		% computes angles for entire session repopulating TSA
		obj = computeAngles(obj)

		% computes curvaure (kappa) for all whiskers, trials, regenerating TSA
		obj = computeCurvatures(obj)
   
	  % computes curvature relative baseline (delta-kappa)
	  obj = computeCurvatureChanges(obj)
    
		% uses ephus pole_voltage to update barInReach* parameters
    obj = updateBarInReachFromEphus(obj,ephusFilePath, ephusFileWC, params) 

    % computes distance to bar as well as the position of the most bar-proximal whisker point
    obj = computeDistanceToBar (obj, params)

		% performs contact detection
		obj = detectContacts (obj, params)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MISC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % generates a summary pdf
    generateSummaryPDF(obj, pdfPath)

		% gives you a minimal copy
    function lightObj = lightCopy(obj)
      lightObj = loadonget_lightcopy(obj);
    end

		function obj = saveToFile(obj, baseFileName)
		  if (nargin == 1) ; baseFileName = obj.baseFileName ; end
      obj = loadonget_savetofile(obj, baseFileName);
		end

    %
		% you should not use save explicitly, but implicitly ...
		%
		function obj = saveobj(a)
			obj = a;
		end

    %
		% save the loadOnGet stuff
		%
		function saveLoadOnGet(obj, varName)
		  for t=1:obj.numTrials
			  obj.wtArray{t}.quickSave = 1;
			end
		  loadonget_saveloadonget(obj, varName);
		end

    % 
		% loads a file-stored variable
		% 
		function value = loadOnGet(obj, varName)
			value =	loadonget_loadonget(obj, varName);
		end
	end
  
	%% --- set/get methods
	methods
%	  function b = saveobj(a) % called on save
%		  for t=1:a.numTrials
%			  a.wtArray{t}.quickSave = 1;
%			end
%			b = a;
%		end

	  function set.basePath(obj, value)
		  obj.basePath = value;
			for t=1:length(obj.wtArray)
			  obj.wtArray{t}.updatePaths(value);
			end
		end

		% baseFileName -- relativbe root data path
    function obj = set.baseFileName(obj, newBaseFileName)
		  obj.baseFileName = init_root_data_path(newBaseFileName);
    end

    % returns the baseFileName -- WITH global path !
    function value = get.baseFileName(obj)
      value = assign_root_data_path(obj.baseFileName);
    end


    function obj = set.fileIndices(obj, newFileIndices)
		  if (size(newFileIndices,2) == 1) ; newFileIndices = newFileIndices'; end
			ufi = unique(newFileIndices);
			if (length(ufi) >= 1)
  			if (length(find(diff(ufi) > 1)) > 0 || min(ufi) > 1) 
	  		  error('Cannot have file indices that are not exactly in order 1 2 3 ...');
				end
			end
			obj.fileIndices = newFileIndices;
		end

    % propagates time to appropriate sub-items
		function obj = set.time(obj, newTime)
		  if (size(newTime,2) == 1) ; newTime = newTime'; end

		  if (~obj.loading)
			 
			  if (length(obj.time) > 0 && length(obj.time) ~= length(newTime))
				  disp('whiskerTrialArray.set.time::you must pass a vector that is EXACTLY same length as original.');
					return;
				end

			  if (isobject(obj.whiskerTrackPolyIntersectXYTSA)); obj.whiskerTrackPolyIntersectXYTSA.time = newTime; end
			  if (isobject(obj.whiskerLengthTSA)); obj.whiskerLengthTSA.time = newTime; end
			  if (isobject(obj.whiskerLengthAtTrackPolyIntersectTSA)); obj.whiskerLengthAtTrackPolyIntersectTSA.time = newTime; end
			  if (isobject(obj.barCenterTSA)); obj.barCenterTSA.time = newTime; end
			  if (isobject(obj.whiskerAngleTSA)); obj.whiskerAngleTSA.time = newTime; end
			  if (isobject(obj.whiskerCurvatureTSA)); obj.whiskerCurvatureTSA.time = newTime; end
			  if (isobject(obj.whiskerCurvatureChangeTSA)); obj.whiskerCurvatureChangeTSA.time = newTime; end
			  if (isobject(obj.whiskerPointNearestBarXYTSA)); obj.whiskerPointNearestBarXYTSA.time = newTime; end
			  if (isobject(obj.whiskerDistanceToBarTSA)); obj.whiskerDistanceToBarTSA.time = newTime; end
			  if (isobject(obj.whiskerBarInReachTS)); obj.whiskerBarInReachTS.time = newTime; end
			  if (isobject(obj.barVoltageTS)); obj.barVoltageTS.time = newTime; end

				% eventSeries -- assumes that both old and new time are sequential (!)
				if (length(obj.time) > 0) % interchange iff this is a full vector
					if (isobject(obj.whiskerBarInReachES))
						oti = find(ismember(obj.time, obj.whiskerBarInReachES.eventTimes));
						obj.whiskerBarInReachES.eventTimes = newTime(oti);
					end
					if (isobject(obj.whiskerBarContactESA))
						for e=1:length(obj.whiskerBarContactESA)
							oti = find(ismember(obj.time, obj.whiskerBarContactESA.esa{e}.eventTimes));
							obj.whiskerBarContactESA.esa{e}.eventTimes = newTime(oti);
						end
					end
					if (isobject(obj.whiskerBarContactClassifiedESA))
						for e=1:length(obj.whiskerBarContactClassifiedESA)
							oti = find(ismember(obj.time, obj.whiskerBarContactClassifiedESA.esa{e}.eventTimes));
							obj.whiskerBarContactClassifiedESA.esa{e}.eventTimes = newTime(oti);
						end
					end
				end
			end

			% do at end because eventSeries depends on original
			obj.time = newTime;
		end

    % propagates trialIndices to appropriate sub-items
		function obj = set.trialIndices(obj, newTrialIndices)
		  if (size(newTrialIndices,2) == 1) ; newTrialIndices = newTrialIndices'; end
		  if (~obj.loading)
			 
			  if (length(obj.trialIndices) > 0 && length(obj.trialIndices) ~= length(newTrialIndices))
				  disp('whiskerTrialArray.set.trialIndices::you must pass a vector that is EXACTLY same length as original.');
					return;
				end

			  if (isobject(obj.whiskerTrackPolyIntersectXYTSA)); obj.whiskerTrackPolyIntersectXYTSA.trialIndices = newTrialIndices; end
			  if (isobject(obj.whiskerLengthTSA)); obj.whiskerLengthTSA.trialIndices = newTrialIndices; end
			  if (isobject(obj.whiskerLengthAtTrackPolyIntersectTSA)); obj.whiskerLengthAtTrackPolyIntersectTSA.trialIndices = newTrialIndices; end
			  if (isobject(obj.barCenterTSA)); obj.barCenterTSA.trialIndices = newTrialIndices; end
			  if (isobject(obj.whiskerAngleTSA)); obj.whiskerAngleTSA.trialIndices = newTrialIndices; end
			  if (isobject(obj.whiskerCurvatureTSA)); obj.whiskerCurvatureTSA.trialIndices = newTrialIndices; end
			  if (isobject(obj.whiskerCurvatureChangeTSA)); obj.whiskerCurvatureChangeTSA.trialIndices = newTrialIndices; end
			  if (isobject(obj.whiskerPointNearestBarXYTSA)); obj.whiskerPointNearestBarXYTSA.trialIndices = newTrialIndices; end
			  if (isobject(obj.whiskerDistanceToBarTSA)); obj.whiskerDistanceToBarTSA.trialIndices = newTrialIndices; end

				% eventSeries -- assumes that both old and new trialIndices are sequential (!)
				if (length(obj.trialIndices) > 0) % do iff we already have assigned prior
          % we will need a mapping ...
					uti = unique(obj.trialIndices);
					oti = 0*uti;
					for t=1:length(uti)
					  firsti = min(find(ismember(obj.trialIndices, uti(t))));
					  oti(t) = firsti;
					end

					if (isobject(obj.whiskerBarInReachES))
						for t=1:length(obj.whiskerBarInReachES.eventTrials)
						  utii = find(uti == obj.whiskerBarInReachES.eventTrials(t));
  						obj.whiskerBarInReachES.eventTrials(t) = newTrialIndices(oti(utii));
						end
					end
					if (isobject(obj.whiskerBarContactESA))
						for e=1:length(obj.whiskerBarContactESA)
							for t=1:length(obj.whiskerBarContactESA.esa{e}.eventTrials)
								utii = find(uti == obj.whiskerBarContactESA.esa{e}.eventTrials(t));
							  obj.whiskerBarContactESA.esa{e}.eventTrials(t) = newTrialIndices(oti(utii));
							end
						end
          end
          
          
					if (isobject(obj.whiskerBarContactClassifiedESA))
						for e=1:length(obj.whiskerBarContactClassifiedESA)
              nnei = find(~isnan(obj.whiskerBarContactClassifiedESA.esa{e}.eventTrials));
              obj.whiskerBarContactClassifiedESA.esa{e}.eventTrials = obj.whiskerBarContactClassifiedESA.esa{e}.eventTrials(nnei);
              obj.whiskerBarContactClassifiedESA.esa{e}.eventTimes = obj.whiskerBarContactClassifiedESA.esa{e}.eventTimes(nnei);
              if (length(obj.whiskerBarContactClassifiedESA.esa{e}.eventTimesRelTrialStart) > 0)
                obj.whiskerBarContactClassifiedESA.esa{e}.eventTimesRelTrialStart = obj.whiskerBarContactClassifiedESA.esa{e}.eventTimesRelTrialStart(nnei);
              end
							for t=1:length(obj.whiskerBarContactClassifiedESA.esa{e}.eventTrials)
								utii = find(uti == obj.whiskerBarContactClassifiedESA.esa{e}.eventTrials(t));
							  obj.whiskerBarContactClassifiedESA.esa{e}.eventTrials(t) = newTrialIndices(oti(utii));
							end
						end
					end
				end

			end
			% do this at the END -- we need the originals for eventSeries stuff above
			obj.trialIndices = newTrialIndices;
		end


    % propagates timeUnit to appropriate sub-items
		function obj = set.timeUnit(obj, newTimeUnit)
		  if (~obj.loading)
			  disp('whiskerTrialArray.set.timeUnit::warning - this method does NOT convert underlying time vectors to new time unit.');
				disp('  It is meant to be used in context of switching BOTH time vector AND timeUnit.');

        % timeSeries
			  if (isobject(obj.whiskerTrackPolyIntersectXYTSA)); obj.whiskerTrackPolyIntersectXYTSA.timeUnit = newTimeUnit; end
			  if (isobject(obj.whiskerLengthTSA)); obj.whiskerLengthTSA.timeUnit = newTimeUnit; end
			  if (isobject(obj.whiskerLengthAtTrackPolyIntersectTSA)); obj.whiskerLengthAtTrackPolyIntersectTSA.timeUnit = newTimeUnit; end
			  if (isobject(obj.barCenterTSA)); obj.barCenterTSA.timeUnit = newTimeUnit; end
			  if (isobject(obj.whiskerAngleTSA)); obj.whiskerAngleTSA.timeUnit = newTimeUnit; end
			  if (isobject(obj.whiskerCurvatureTSA)); obj.whiskerCurvatureTSA.timeUnit = newTimeUnit; end
			  if (isobject(obj.whiskerCurvatureChangeTSA)); obj.whiskerCurvatureChangeTSA.timeUnit = newTimeUnit; end
			  if (isobject(obj.whiskerPointNearestBarXYTSA)); obj.whiskerPointNearestBarXYTSA.timeUnit = newTimeUnit; end
			  if (isobject(obj.whiskerDistanceToBarTSA)); obj.whiskerDistanceToBarTSA.timeUnit = newTimeUnit; end
			  if (isobject(obj.whiskerBarInReachTS)); obj.whiskerBarInReachTS.timeUnit = newTimeUnit; end
			  if (isobject(obj.barVoltageTS)); obj.barVoltageTS.timeUnit = newTimeUnit; end

				% eventSeries
			  if (isobject(obj.whiskerBarInReachES)); obj.whiskerBarInReachES.timeUnit = newTimeUnit; end
			  if (isobject(obj.whiskerBarContactESA))
				  for e=1:length(obj.whiskerBarContactESA)
					  obj.whiskerBarContactESA.esa{e}.timeUnit = newTimeUnit;
					end
				end
			  if (isobject(obj.whiskerBarContactClassifiedESA))
				  for e=1:length(obj.whiskerBarContactClassifiedESA)
					  obj.whiskerBarContactClassifiedESA.esa{e}.timeUnit = newTimeUnit;
					end
				end
			end
			obj.timeUnit = newTimeUnit;
		end

    % propagates trialTimes to eventSeries
		function obj = set.trialTimes(obj, newTrialTimes)
		  if (~obj.loading)
				if (isobject(obj.whiskerBarInReachES)) ; obj.whiskerBarInReachES.updateEventSeriesFromTrialTimes(newTrialTimes) ; end
				if (isobject(obj.whiskerBarContactESA)) ; obj.whiskerBarContactESA.trialTimes = newTrialTimes; end
				if (isobject(obj.whiskerBarContactClassifiedESA)) ; obj.whiskerBarContactClassifiedESA.trialTimes = newTrialTimes; end
			end
			obj.trialTimes = newTrialTimes;
		end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LOADONGET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function value = get.wtArray(obj)
		  if (~iscell(obj.wtArray)) % not cell ? try to load it 
		    value = loadOnGet(obj, 'wtArray');
				obj.wtArray = value;
			else
				idx = find(strcmp(obj.loadableVar ,'wtArray'));
				obj.loadFlag(idx) = 1;
			end
			value = obj.wtArray;
		end	

		function value = get.whiskerTrackPolyIntersectXYTSA(obj)
		  if (~isobject(obj.whiskerTrackPolyIntersectXYTSA)) % not object? try to load it 
		    value = loadOnGet(obj, 'whiskerTrackPolyIntersectXYTSA');
				obj.whiskerTrackPolyIntersectXYTSA = value;
			else
				idx = find(strcmp(obj.loadableVar ,'whiskerTrackPolyIntersectXYTSA'));
				obj.loadFlag(idx) = 1;
			end
			value = obj.whiskerTrackPolyIntersectXYTSA;
		end	

		function value = get.whiskerLengthTSA(obj)
		  if (~isobject(obj.whiskerLengthTSA)) % not object? try to load it 
		    value = loadOnGet(obj, 'whiskerLengthTSA');
				obj.whiskerLengthTSA = value;
			else
				idx = find(strcmp(obj.loadableVar ,'whiskerLengthTSA'));
				obj.loadFlag(idx) = 1;
			end
			value = obj.whiskerLengthTSA;
		end	

		function value = get.whiskerLengthAtTrackPolyIntersectTSA(obj)
		  if (~isobject(obj.whiskerLengthAtTrackPolyIntersectTSA)) % not object? try to load it 
		    value = loadOnGet(obj, 'whiskerLengthAtTrackPolyIntersectTSA');
				obj.whiskerLengthAtTrackPolyIntersectTSA = value;
			else
				idx = find(strcmp(obj.loadableVar ,'whiskerLengthAtTrackPolyIntersectTSA'));
				obj.loadFlag(idx) = 1;
			end
			value = obj.whiskerLengthAtTrackPolyIntersectTSA;
		end	

		function value = get.whiskerPolysX(obj)
		  if (isempty(obj.whiskerPolysX)) % empty? try to load it 
		    value = loadOnGet(obj, 'whiskerPolysX');
				obj.whiskerPolysX = value;
			else
				idx = find(strcmp(obj.loadableVar ,'whiskerPolysX'));
				obj.loadFlag(idx) = 1;
			end
			value = obj.whiskerPolysX;
		end	

		function value = get.whiskerPolysY(obj)
		  if (isempty(obj.whiskerPolysY)) % empty? try to load it 
		    value = loadOnGet(obj, 'whiskerPolysY');
				obj.whiskerPolysY = value;
			else
				idx = find(strcmp(obj.loadableVar ,'whiskerPolysY'));
				obj.loadFlag(idx) = 1;
			end
			value = obj.whiskerPolysY;
		end	

		function value = get.barCenterTSA(obj)
		  if (~isobject(obj.barCenterTSA)) % not object? try to load it 
		    value = loadOnGet(obj, 'barCenterTSA');
				obj.barCenterTSA = value;
			else
				idx = find(strcmp(obj.loadableVar ,'barCenterTSA'));
				obj.loadFlag(idx) = 1;
			end
			value = obj.barCenterTSA;
		end	

		function value = get.whiskerAngleTSA(obj)
		  if (~isobject(obj.whiskerAngleTSA)) % not object? try to load it 
		    value = loadOnGet(obj, 'whiskerAngleTSA');
				obj.whiskerAngleTSA = value;
			else
				idx = find(strcmp(obj.loadableVar ,'whiskerAngleTSA'));
				obj.loadFlag(idx) = 1;
			end
			value = obj.whiskerAngleTSA;
		end	

		function value = get.whiskerPointNearestBarXYTSA(obj)
		  if (~isobject(obj.whiskerPointNearestBarXYTSA)) % not object? try to load it 
		    value = loadOnGet(obj, 'whiskerPointNearestBarXYTSA');
				obj.whiskerPointNearestBarXYTSA = value;
			else
				idx = find(strcmp(obj.loadableVar ,'whiskerPointNearestBarXYTSA'));
				obj.loadFlag(idx) = 1;
			end
			value = obj.whiskerPointNearestBarXYTSA;
		end	


		function value = get.whiskerDistanceToBarTSA(obj)
		  if (~isobject(obj.whiskerDistanceToBarTSA)) % not object? try to load it 
		    value = loadOnGet(obj, 'whiskerDistanceToBarTSA');
				obj.whiskerDistanceToBarTSA = value;
			else
				idx = find(strcmp(obj.loadableVar ,'whiskerDistanceToBarTSA'));
				obj.loadFlag(idx) = 1;
			end
			value = obj.whiskerDistanceToBarTSA;
		end	

		function value = get.whiskerCurvatureTSA(obj)
		  if (~isobject(obj.whiskerCurvatureTSA)) % not object? try to load it 
		    value = loadOnGet(obj, 'whiskerCurvatureTSA');
				obj.whiskerCurvatureTSA = value;
			else
				idx = find(strcmp(obj.loadableVar ,'whiskerCurvatureTSA'));
				obj.loadFlag(idx) = 1;
			end
			value = obj.whiskerCurvatureTSA;
		end	

		function value = get.whiskerCurvatureChangeTSA(obj)
		  if (~isobject(obj.whiskerCurvatureChangeTSA)) % not object? try to load it 
		    value = loadOnGet(obj, 'whiskerCurvatureChangeTSA');
				obj.whiskerCurvatureChangeTSA = value;
			else
				idx = find(strcmp(obj.loadableVar ,'whiskerCurvatureChangeTSA'));
				obj.loadFlag(idx) = 1;
			end
			value = obj.whiskerCurvatureChangeTSA;
		end	
	end

	%% --- Static methods
	methods (Static = true)
    % generates a whiskerTrialArray given a data directory (or specific file list)
	  wta = generateWhiskerTrialArray (whiskerFilePath, whiskerFileWC)

    % all-in-one method that wraps generateWhiskerTrialArray and calls all computations
	  wta = generateUsingParams (params)

		% this is called on load
	  function obj = loadobj(a) 
		  a.loading = 1;
		  a = loadonget_loadobj(a);
		  obj = a;
			obj.loading = 0;
		end
  end
end


