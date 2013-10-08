%
% for merging sessions -- envetually make a static method in session
%
% S: your array of sessions ...
% volIdx: fov name scheme is fov_vvppp, where vv is volume # and ppp is
%         plane within the volume ; this is vv
%
function ns = session_merge(S, volIdx)
  %% --- base data path / input processing
	if (strcmp(computer, 'GLNXA64'))
    basePath = '/media/';
	elseif (strcmp(computer,'MACI64'))
		basePath = '/Volumes/';
	else
	  disp('Unrecognized computer.');
	  return;
	end
if (strcmp(S{1}.mouseId, 'an167951')) ; basePath = '/data/';end
  
	baseFileName = [basePath sprintf(['%sa%csession_merged%c%s_vol_%02d'], S{1}.mouseId, filesep, filesep, S{1}.mouseId, volIdx) '_sess.mat'];

  %% --- compile FOV data - that is, figure out which days this volume is even present on (!)
	sessVolPlaneId = nan*zeros(1000,5);
	svi = 1;
	for si=1:length(S)
	  for c=1:length(S{si}.caTSAArray.caTSA)
		  for f=1:length(S{si}.caTSAArray.caTSA{c}.roiArray)
        fovi = strfind(S{si}.caTSAArray.caTSA{c}.roiArray{f}.idStr, 'fov_');
				if (length(fovi) == 0)
          fovi = strfind(S{si}.caTSAArray.caTSA{c}.roiArray{f}.masterImageRelPath, 'fov_');
          if (length(fovi) == 0)
						disp(['roiArray idStr does not contain field of view (fov_vvppp) tag; is ' S{si}.caTSAArray.caTSA{c}.roiArray{f}.idStr '; ABORTING.']);
						return;
					else
						fovTag = S{si}.caTSAArray.caTSA{c}.roiArray{f}.masterImageRelPath(fovi+4:fovi+9);
						sessVolPlaneId(svi,:) = [si c f str2num(fovTag(1:2)) str2num(fovTag(3:5))];
						svi = svi+1;
					end
				else
					fovTag = S{si}.caTSAArray.caTSA{c}.roiArray{f}.idStr(fovi+4:end);
					sessVolPlaneId(svi,:) = [si c f str2num(fovTag(1:2)) str2num(fovTag(3:5))];
					svi = svi+1;
				end
			end
		end
	end
  sessVolPlaneId = sessVolPlaneId(find(~isnan(sessVolPlaneId(:,1))),:);


	%% --- make new session given volIdx

	% which sessions are to be considered?
	vpi = find(sessVolPlaneId(:,4) == volIdx);
	valSess = unique(sessVolPlaneId(vpi,1));

	% which among these has ALL the planes? put this one FIRST (valSess(1))
  allFOVTags = unique(sessVolPlaneId(vpi,5));
  svpi = sessVolPlaneId(vpi,:) ; 
  firstSess = [];
  for v=1:length(valSess)
    fovsInSess = unique(svpi(find(svpi(:,1) == valSess(v)),5));
    if (length(fovsInSess) == length(allFOVTags))
      firstSess = valSess(v);
      vsi = [v 1:(v-1) (v+1):length(valSess)];
      valSess = valSess(vsi);
      break;
    end
  end
  if (length(firstSess) == 0) 
    error('session_merge::No session contains ALL the planes, so no basis session, so fail!');
  end

  % go for it
	dtMs = session.timeSeries.convertTime(1,5,1); % separate by 1 day
	dTrial = 1000; % separate by this many trials -- session 2 will start at trial dTrial+1

	ns = session.session();

  ns.baseFileName = baseFileName;
	ns.mouseId = S{valSess(1)}.mouseId;
	ns.dateStr = 'compound';
	ns.behavProtocolName = S{valSess(1)}.behavProtocolName;
	ns.whiskerTag = S{valSess(1)}.whiskerTag;
	ns.trialType = S{valSess(1)}.trialType;
	ns.trialTypeStr = S{valSess(1)}.trialTypeStr;
	ns.trialTypeColor = S{valSess(1)}.trialTypeColor;

	i1 =1;
	for si=1:length(valSess)
	  % --- prelims
	  ssi = valSess(si);

		timeOffs = (si-1)*dtMs; % how much to offset start time by
		trialOffs = (si-1)*dTrial; % how much to offset trial # by
 
    % pull volume index within this session
		vsi = find(sessVolPlaneId(:,1) == ssi);
		inSessVolIdx = vsi(find(sessVolPlaneId(vsi,4) == volIdx));
		caArrIdx = sessVolPlaneId(inSessVolIdx(1),2);

		% which trials are in this particular volume?
		S{ssi}.useCaTSAArray(caArrIdx);
		disp(['session_merge::Processing ' S{ssi}.baseFileName]);

		%% --- some checks of the data
		dTSA = 0;
		disp('session_merge::derived data merging is OFF ; you should re-generate');
    if (~isobject(S{ssi}.derivedDataTSA)) ; dTSA = 0 ; end
		if (~isobject(S{ssi}.caTSA.caPeakTimeSeriesArray)) ; disp('caPeakTimeSeriesArray missing ; skipping');continue ; end
		if (~isobject(S{ssi}.caTSA.caPeakEventSeriesArray)) ; disp('caPeakEventSeriesArray missing ; skipping');continue ; end
		if (~isobject(S{ssi}.whiskerBarContactESA)) ; disp('whiskerBarContactESA missing ; skipping'); continue ; end
		if (~isobject(S{ssi}.behavESA)) ; disp('behavESA missing ; skipping'); continue ; end

		%% --- start assigning stuff ...
		trialsUsed = S{ssi}.caTSAArray.validCaTrialIds{caArrIdx};
		trialsDeleted = setdiff(S{ssi}.trialIds, trialsUsed);
		i2 = i1 + length(trialsUsed) - 1;

		% trial stuff
		ti = find(ismember(S{ssi}.trialIds, trialsUsed));
		for tt=i1:i2
			ttrial = S{ssi}.trial{ti(tt-i1+1)}.copy;
			ttrial.id = ttrial.id + trialOffs;
			ns.trial{tt} = ttrial;
		end
		ns.trialIds(i1:i2) = S{ssi}.trialIds(ti) + trialOffs;
		ns.trialStartTimes(i1:i2) = S{ssi}.trialStartTimes(ti) + timeOffs;
		
    % derivation messes up trials so fix it here
    if (~dTSA)
      S{ssi}.validTrialIds = intersect(S{ssi}.validBehavTrialIds, S{ssi}.validEphusTrialIds);
      S{ssi}.validTrialIds = intersect(S{ssi}.validTrialIds, S{ssi}.validCaTrialIds);
      S{ssi}.validTrialIds = intersect(S{ssi}.validTrialIds, S{ssi}.validWhiskerTrialIds);
    end
    
		ns.validTrialIds = union(ns.validTrialIds, intersect(trialsUsed, S{ssi}.validTrialIds)+trialOffs);
		ns.validWhiskerTrialIds = union(ns.validWhiskerTrialIds, intersect(trialsUsed, S{ssi}.validWhiskerTrialIds)+trialOffs);
		ns.validCaTrialIds = union(ns.validCaTrialIds, intersect(trialsUsed, S{ssi}.validCaTrialIds)+trialOffs);
		ns.validBehavTrialIds = union(ns.validBehavTrialIds, intersect(trialsUsed, S{ssi}.validBehavTrialIds)+trialOffs);
		ns.validEphusTrialIds = union(ns.validEphusTrialIds, intersect(trialsUsed, S{ssi}.validEphusTrialIds)+trialOffs);
		if (dTSA) ; ns.validDerivedTrialIds = union(ns.validDerivedTrialIds, intersect(trialsUsed, S{ssi}.validDerivedTrialIds)+trialOffs); end

	  % ESAs
		ns = processESA(S{ssi}, ns, si, 'behavESA' , trialsDeleted, trialOffs, timeOffs);
		ns = processESA(S{ssi}, ns, si, 'whiskerBarContactESA' , trialsDeleted, trialOffs, timeOffs);
		ns = processESA(S{ssi}, ns, si, 'whiskerBarContactClassifiedESA' , trialsDeleted, trialOffs, timeOffs);
		if (dTSA) ; ns = processESA(S{ssi}, ns, si, 'derivedDataESA' , trialsDeleted, trialOffs, timeOffs); end

    % ESs
		ns = processES(S{ssi}, ns, si, 'whiskerBarInReachES' , trialsDeleted, trialOffs, timeOffs);
	
		% TSAs
    ns = processTSA(S{ssi}, ns, si, 'ephusTSA' , trialsDeleted, trialOffs, timeOffs);
    ns = processTSA(S{ssi}, ns, si, 'whiskerCurvatureTSA' , trialsDeleted, trialOffs, timeOffs);
    ns = processTSA(S{ssi}, ns, si, 'whiskerCurvatureChangeTSA' , trialsDeleted, trialOffs, timeOffs);
    ns = processTSA(S{ssi}, ns, si, 'whiskerAngleTSA' , trialsDeleted, trialOffs, timeOffs);
    ns = processTSA(S{ssi}, ns, si, 'whiskerBarCenterXYTSA' , trialsDeleted, trialOffs, timeOffs);
		if (dTSA) ; ns = processTSA(S{ssi}, ns, si, 'derivedDataTSA' , trialsDeleted, trialOffs, timeOffs); end

		% caTSA ... special case
    ns = processCaTSA(S{ssi}, ns, si, trialsDeleted, trialOffs, timeOffs);

		% incrememnt
		i1 = i2+1;
	end

	% generate derived data
	ns.generateDerivedDataStructures();

%
% processes an ES
%
function ns = processES(os, ns, si, esName, trialsDeleted, trialOffs, timeOffs)
	tES = eval(['os.' esName '.copy();']);
	tES.deleteTrials(trialsDeleted);
  tES.eventTimes = tES.eventTimes + timeOffs;
	tES.eventTrials = tES.eventTrials + trialOffs;

	if (si == 1) 
		eval(['ns.' esName '= tES;']);
	else
		eval(['ns.' esName '.mergeWith(tES);']);
	end
  

%
% processes an ESA
%
function ns = processESA(os, ns, si, esaName, trialsDeleted, trialOffs, timeOffs)
	tESA = eval(['os.' esaName '.copy();']);
	tESA.deleteTrials(trialsDeleted);
	for e=1:length(tESA.esa)
	  tESA.esa{e}.eventTimes = tESA.esa{e}.eventTimes + timeOffs;
		tESA.esa{e}.eventTrials = tESA.esa{e}.eventTrials + trialOffs;
	end
	tESA.trialTimes = tESA.trialTimes + repmat([trialOffs timeOffs timeOffs], size(tESA.trialTimes,1), 1);

	if (si == 1) 
		eval(['ns.' esaName '= tESA;']);
	else
		eval(['ns.' esaName '.mergeWith(tESA);']);
  end
	
%
% processes caTSA
%
function ns = processCaTSA(os, ns, si, trialsDeleted, trialOffs, timeOffs)
 	tCaTSA = os.caTSA.copy();
  if (length(tCaTSA.caPeakEventSeriesArray.trialTimes) == 0) % should not but just in case
    tCaTSA.caPeakEventSeriesArray.trialTimes = os.behavESA.trialTimes;
  end
	tCaTSA.deleteTrials(trialsDeleted, 1);
	tCaTSA.time = tCaTSA.time + timeOffs;
	tCaTSA.trialIndices = tCaTSA.trialIndices + trialOffs;

  % caTSA is 'special' in that time and trial offsets don't propagate to caPeakEventSeriesArray
	%  so we do it here
	if (isobject(tCaTSA.caPeakEventSeriesArray))
		for i=1:length(tCaTSA)
		  es = tCaTSA.caPeakEventSeriesArray.esa{i};
			es.eventTimes = es.eventTimes + timeOffs;
			es.peakTimes = es.peakTimes + timeOffs;
			es.endTimes = es.endTimes + timeOffs;
			es.eventTrials = es.eventTrials + trialOffs;
		end
  end

  % new trialTimes
  tCaTSA.caPeakEventSeriesArray.trialTimes = tCaTSA.caPeakEventSeriesArray.trialTimes + ...
       repmat([trialOffs timeOffs timeOffs], size(tCaTSA.caPeakEventSeriesArray.trialTimes,1), 1);

  
	if (si == 1) 
		ns.caTSA = tCaTSA;
	else
		ns.caTSA.mergeWith(tCaTSA);
	end

%
% processes a TSA
%
function ns = processTSA(os, ns, si, tsaName, trialsDeleted, trialOffs, timeOffs)
	tTSA = eval(['os.' tsaName '.copy();']);
	tTSA.deleteTrials(trialsDeleted);
	tTSA.time = tTSA.time + timeOffs;
	tTSA.trialIndices = tTSA.trialIndices + trialOffs;
	if (si == 1) 
		eval(['ns.' tsaName '= tTSA;']);
	else
		eval(['ns.' tsaName '.mergeWith(tTSA);']);
	end
  
