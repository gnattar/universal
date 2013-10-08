%
% SP Dec 2010
%
% This defines a class for dealing with an array of session objects.
%
%  USAGE: 
%
%    session.sessionArray(sessions)
%
%    sessions: cell array of session.session objects
%
%  CLASS PROPERTIES:
%
%    sessions: a cell array with all the (light) session objects.  Note that 
%              though these can be manipulated, sessionArray's save methods 
%              DO NOT save these individually, so if you update these, be sure to
%              call the pertinent sessions{x}.saveToFile methods.
%    mouseId: The mouse this array is for
%    dateStr: cell array corresponding to sessions with the date of each (time 
%             included  in case of multiple sessions/day)
%
%    whiskerTag: cell array of whisker names
%    whiskerPresent: (s,w) will be 1 if whiskerTag(w) was present in sessions(s)
%                    and 0 if not.
%
%    performanceStats: (s,1): % correct ; (s,2): d' for sessions{s}
%    whiskingSummary: data obtained from getWhiskingSummaryData for each day
%
%    roiIds: vector with all roi Ids encountered across sessions ; ASCENDING SORT
%    roiPresent: (s,r) will be 1 if roiIds(r) is in sessions{s}
%    roiIsFilled: after running detectFilledRois, 1 means filled, 0 not, nan
%                 absent
%
classdef sessionArray< handle
  % Properties
  properties 
		% session objects ; cell array
		sessions; 

    % identifiers
		mouseId;  
		dateStr; % cell array of length sessions ; functions as unique ID since even 
		         % when you had multiple sessions/day, this is the exact start time
						 % from the solo data

    % derived data
    whiskerTag; % names of the whiskers 
		whiskerPresent; % length(sessions) x length(whiskerTag) ; 1 if whisker present , 0 if not

    roiIds; % list of rois
		roiPresent; % roiPresent(s,r): 1 means on sessions{s}, roiIds(r) is present.

		roiIsFilled; % same size as roiPresent; roiIsFilled(s,r)=1 means on sessions{s}, 
             		 % roiId(r) is filled
		roiPrefContactVar; % from getRoiWhiskerContactVariable ; cell array, 1 per ROI
		roiKappaThetaDirPref; % from getRoiPrefKappaThetaDir {r}{s}{w}
		
		touchIndexMats; % cell array of touch index matrices {i}{s} where i is touchIndexMatId
		touchIndexMatId; % corresponds to touchIndexMats, contains which variable each mat has

		whiskerAndDirPref; % stores whisker and directional preference AUCs *with* CIs 
		                   % {s} contains results from computeWhiskerAndDirecitonalPref for session

		performanceStats; % session x 2 ; % correct & dprime from all days
    whiskingSummary; % from getWhiskingSummary

  end

  properties(Transient = true) % not saved to file -- for internal stuff
		guiData; % stores all the gui-related stuff
		saveFlag; % to notify user of misuse of save
		currentTreeScoreTag; % stores what is stored in individual sessions' treeScores to prevent redundant reload
  end

	% Methods -- public
  methods (Access = public)
	  %
	  % Constructor -- as basic as they get(!)
		%
    function obj = sessionArray(newSessions)
		  obj.sessions = newSessions;

			obj.saveFlag = 0;
		end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% UTILITY  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		% Allows you to propagate a command thru all session objects
		obj = evalForAll(obj, command)

		% computes cell filling across days taking into account shifts over time
		obj = detectFilledRois (obj, params)

		% compiles touch index mat
		obj = getTouchIndexMat(obj, params)

		% tells you frac of good whisker trials rel ca
		function showFracGoodWhiskerTrials(obj)
		  for si=1:length(obj.sessions) 
			  s=obj.sessions{si};
				disp([s.dateStr ' ' num2str(length(intersect(s.validCaTrialIds,s.validWhiskerTrialIds))/length(s.validCaTrialIds))]);
			end
		end

		% returns cells that meet criteria for being in a particular tree class
		roiIds = getRoisInFeatureClass (obj, params)

    %%%%%%%%%%%%%% SINGLE SESSION METHOD WRAPPERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% wrapper for computeRoiTouchIndex
		function obj = computeRoiTouchIndex(obj, params, tsId)
		  if (nargin < 3) ; tsId = 'caTSA.dffTimeSeriesArray' ; end
			for s=1:length(obj.sessions) 
			  disp(['Processing ' obj.dateStr{s}]);
				params.caDffTSA = eval(['obj.sessions{s}.' tsId ';']);
			  obj.sessions{s}.computeRoiTouchIndex(params);
			end
		end

		% wrapper for computeDiscrim
		function obj = computeDiscrim(obj, params, tsId)
		  if (nargin < 3) ; tsId = 'caTSA.caPeakTimeSeriesArray' ; end
			for s=1:length(obj.sessions) 
			  disp(['Processing ' obj.dateStr{s}]);
				params.responseTSA = eval(['obj.sessions{s}.' tsId ';']);
			  obj.sessions{s}.computeDiscrim(params);
			end
		end

		% wrapper for getTreeScores
		function obj = getTreeScores(obj, tbRootDir, inputTag, treeTag, scoreMethod)
		  if (nargin < 5) ; scoreMethod = '';end
      if (nargin == 1) ; obj.sessions{1}.listTreeFeatures ; return ; end

		  if (length(tbRootDir) == 0) ; tbRootDir = strrep(fileparts(obj.sessions{1}.baseFileName), 'session2', 'tree'); end
		  treeTagS = treeTag; if (isnumeric(treeTag)) ; treeTagS = num2str(treeTag); end
      newTreeScoreTag = [tbRootDir inputTag treeTagS scoreMethod];
			if (~strcmp(obj.currentTreeScoreTag, newTreeScoreTag))
			  for si=1:length(obj.sessions) 
			    disp(['Processing ' obj.dateStr{si}]);
				  fPath=  [tbRootDir  filesep obj.mouseId  '_' datestr(obj.dateStr{si}, 'yyyy_mm_dd') '_sess'];
				  eval(['obj.sessions{si}.getTreeScores(fPath, inputTag, treeTag, scoreMethod);']);
				end
        obj.currentTreeScoreTag = newTreeScoreTag;
			end
		end


		% wrapper for generateWhiskerContactTriggerImages
		function obj = generateWhiskerContactTriggeredImages(obj,  baselineTimeWindow, responseTimeWindow, saveToRoiFile)
			for s=1:length(obj.sessions) 
			  disp(['Processing ' obj.dateStr{s}]);
			  obj.sessions{s}.generateWhiskerContactTriggeredImages( baselineTimeWindow, responseTimeWindow, saveToRoiFile);
			end
		end
  

		% wrapper for getWhiskingSummaryData
		function obj = getWhiskingSummaryData(obj)
			for s=1:length(obj.sessions) 
			  disp(['Processing ' obj.dateStr{s}]);
				obj.whiskingSummary{s} = obj.sessions{s}.getWhiskingSummaryData();
			end
		end

		% wrapper for computeWhiskerAndDirectionPreference
		function obj = getWhiskerAndDirectionPreference(obj)
		  params.whiskerTags = {'c1','c2','c3'};
			params.useExclusiveWhiskers = 1;
			for s=1:length(obj.sessions) 
			  disp(['Processing ' obj.dateStr{s}]);
%rparams = obj.sessions{s}.computeWhiskerAndDirectionPreference(params);
%obj.whiskerAndDirPref{s}.dirAUC = rparams.dirAUC;
				obj.whiskerAndDirPref{s} = obj.sessions{s}.computeWhiskerAndDirectionPreference(params);
			end
		end

		% wrapper for computeRoiWhiskerContactVariableImportance
		function obj = getRoiWhiskerContactVariable(obj, roiIds)
		  for r=1:length(roiIds)
			  ri = find(obj.roiIds == roiIds(r));
        params.roiId = roiIds(r);
				params.useExclusive = 1;
				params.directional = 0;
				params.paramsTested = [1 1 0];
				params.whiskerTags = {'c1','c2','c3'};
				for s=1:length(obj.sessions) 
					disp(['Processing ' obj.dateStr{s}]);
					obj.roiPrefContactVar{ri}{s} = obj.sessions{s}.computeRoiWhiskerContactVariableImportance(params);
				end
			end
		end

		% wrapper for computeRoiPrefKappaThetaDir
		function obj = getRoiPrefKappaThetaDir(obj, roiIds)
		  wTags = {'c1','c2','c3'};
		  
      % setup kParams, tParams
			% common:
			params.useExclusive = 1;
			params.trialEventNumber = [];
			params.wcESA = 'whiskerBarContactESA';
			params.stimTimeWindow = [-0.1 0.5];
			params.respTimeWindow = [0 2];
			params.respMode = 'max';
			params.respTSA = 'caTSA.caPeakTimeSeriesArray';

			kParams = params;
			tParams = params;

			kParams.stimTSA = 'whiskerCurvatureChangeTSA';
			kParams.stimMode = 'summaxabs';

			tParams.stimTSA = 'whiskerAngleTSA';
			tParams.stimMode = 'first';
			tParams.trialEventNumber = 1;

		  for r=1:length(roiIds)
			  ri = find(obj.roiIds == roiIds(r));
				tParams.roiId = roiIds(r);
				kParams.roiId = roiIds(r);
				for s=1:length(obj.sessions) 
					disp(['Processing ' obj.dateStr{s}]);
  				for w=1:length(wTags)
					  wi = find(strcmp(wTags{w}, obj.whiskerTag));
			      tParams.stimTSId = ['Angle for ' wTags{w}];
			      kParams.stimTSId = ['Curvature change for ' wTags{w}];
			      tParams.wcESId = ['Contacts for ' wTags{w}];
			      kParams.wcESId = ['Contacts for ' wTags{w}];
						prparams.kParams = kParams;
						prparams.tParams = tParams;
						if (obj.whiskerPresent(s,wi))
  	  				obj.roiKappaThetaDirPref{ri}{s}{w} = obj.sessions{s}.computeRoiPrefKappaThetaDir(prparams);
						else
  	  				obj.roiKappaThetaDirPref{ri}{s}{w} = {};
						end
					end
				end
			end
		end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		% plots performance
		plotPerformance (obj)

		% plots whisking strategy across days
		plotWhiskingSummary (obj, params)

		% plots fill accross days ...
		plotCellFilling (obj)

		% plots event-triggered average for a TSA across days
    [avgFig barFig rawFig] = plotEventTriggeredAverageCrossDays(obj, params)

		% plots ROI across days
    plotRoiCrossDays (obj, params)

		% plots touch index across days
    plotRoiTouchIndex(obj, params)
    
		% plots health status of the rOI across days
		plotRoiHealthCrossDays (obj, params)

		% plots discrimination index across days
		plotDiscrim(obj, params)

		% plots kappa RF cross days
		plotKappaRFCrossDays(obj, params)

		% plots peri-vent RF cross days
		plotPeriEventRFCrossDays(obj, params)

		% plots timeSeries as image across days
		plotTimeSeriesAsImageCrossDays (obj, params)

		% plots timeSeries as line across days
		plotTimeSeriesAsLineCrossDays (obj, params)

		% plots whisker contact triggered images cross days
		plotContactTriggeredImagesCrossDays(obj, params)

    % wrapper for matrix plotting
		plotRoiMatrixCrossDays(obj, params)
 
    % plots color rois across days as session.plotColorRois
    plotColorRoisCrossDays(obj, params)

		% plots pref contact vriable across days
		plotPrefContactVarCrossDays(obj, params)

		% plots kappa v. dir v. theta pref cross days
		plotKappaVThetaVDirPrefCrossDays(obj, params)

		% plots prefered whisker cross days
		plotPrefWhiskerCrossDays(obj, params)

		% plots directional preference cross days
		plotDirectionalityIndexCrossDays(obj, params)

		% plots tree score cross days
		plotTreeScoreCrossDays(obj, params)

		% plots cross correlation across days for a set of timeseries
		plotCrosscorrCrossDays (obj, params)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INTERNAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		obj = addSessions(obj, sessions)

		obj = removeSessions(obj, removeId)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SAVE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		saveToFile(obj, fileName)

    %
		% you should not use this!
		%
		function obj = saveobj(a)
		  if (length(a.saveFlag) == 0)
				disp('save::you should call saveToFile to save, not save!!');
		  elseif (~ a.saveFlag)
				disp('save::you should call saveToFile to save, not save!!');
			end
			obj = a;
		end
	end

	methods (Static) % static methods 
		% Generates a sessionArray object from a collection of session.mat files
		sA = generateSessionArray(sessionFilePath, sessionFileWC)
  end
 
  % Methods -- set/get/basic variable manipulation stuff
	methods 
	  % 
    % On modification of the sessions array, you must
		%  1) sort by date and populated dateStr
		%  2) get mouseId ; do consitency check
		%  3) redo whiskerTag, whiskerPresent
		%  4) redo roiIds, roiPresent
		% 
	  function obj = set.sessions(obj, newSessions)
		  % 1) sort by data
			datenums = 0*(1:length(newSessions));
			for s=1:length(newSessions)
			  datenums(s) = datenum(newSessions{s}.dateStr);
			end
      [irr idx] = sort(datenums);

			% 2) constructed sorted date and populate mouse Id
			for s=1:length(newSessions)
				obj.dateStr{s} = newSessions{idx(s)}.dateStr;
				newSessions{idx(s)}.mouseId = lower(newSessions{idx(s)}.mouseId);
				obj.sessions{s} = newSessions{idx(s)};
				if (s > 1 & ~strcmp(obj.mouseId, newSessions{idx(s)}.mouseId))
				  disp('sessionArray.set.sessions::detected multiple mouse Ids!');
				else
					obj.mouseId = newSessions{idx(s)}.mouseId;
				end
			end

			% 3) whiskerTag
			allTags = {};
			for s=1:length(newSessions)
			  for t=1:length(newSessions{s}.whiskerTag)
				  if (length(find(strcmp(allTags,newSessions{s}.whiskerTag{t}))) == 0)
				    allTags{length(allTags)+1}  = newSessions{s}.whiskerTag{t};
					end
				end
			end
			obj.whiskerTag = sort(allTags);

      % 3b) whiskerPresent
      obj.whiskerPresent = zeros(length(newSessions), length(obj.whiskerTag));
			for s=1:length(newSessions)
			  for t=1:length(obj.whiskerTag)
				  if (length(find(strcmp(obj.whiskerTag{t},newSessions{s}.whiskerTag))) == 1)
				    obj.whiskerPresent(s,t) = 1;
					end
				end
			end

			% 4) roiId
			if (isobject(newSessions{1}.caTSA))
				allRois = [];
				for s=1:length(newSessions)
          for f=1:length(newSessions{s}.caTSA.roiArray)
            allRois = union(allRois, newSessions{s}.caTSA.roiArray{f}.roiIds);
          end
				end
				obj.roiIds = sort(allRois);

				% 4b) roiIdPresent
				obj.roiPresent = zeros(length(newSessions), length(obj.roiIds));
				for s=1:length(newSessions)
          sessRoiIds = [];
          for f=1:length(newSessions{s}.caTSA.roiArray)
            sessRoiIds = union(sessRoiIds, newSessions{s}.caTSA.roiArray{f}.roiIds);
          end
					obj.roiPresent(s,:) = ismember(obj.roiIds, sessRoiIds);
				end
			end
			
		end
	  % -- ID ; nothing for now
	  %function obj = set.id (obj, newId)
		%  obj.id = newId;
		%end
	  %function value = get.id (obj)
		%  value = obj.id;
		%end
  end


end
