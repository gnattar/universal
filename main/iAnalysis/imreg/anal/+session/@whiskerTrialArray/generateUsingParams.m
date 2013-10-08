%
% One-stop method that will generate whiskerTrialArray and run all computations.
%
% This method uses the params structure (See help for session.whiskerTrialArray)
%  to run the whole sequence of stuff.  Specifically, it runs, in order:
%
%  genererateWhiskerTrialArray
%  computeAngles
%  computeCurvatures
%  computeCurvatureChanges
%  updateBarInReachFromEphus
%  detectContacts
%  pushDataToWtArray
%  
% USAGE:
%
%  wta = session.whiskerTrialArray.generateUsingParams(params)
%
% ARGUMENTS:
%
%  params: structure described in help for session.whiskerTrialArray.
% 
% (C) S Peron Mar 2012
%
function wta = generateUsingParams (params)
  
	%% --- process

  if (exist(params.baseFileName, 'file'))
	  if (~isfield(params, 'forceRegenerate') || params.forceRegenerate ~= 1)
  	  disp(['generateUsingParams: ' params.baseFileName ' already exists.  Loading instead of generating.  To regenerate, delete it or set params.forceRegenerate to 1.']);
	    load (params.baseFileName);
		  wta = o;
	    return;
		end
  end

	wta = session.whiskerTrialArray.generateWhiskerTrialArray(params.whiskerFilePath, params.whiskerFileWC);

	wta.params = params;
	
	wta.computeAngles();
	wta.computeCurvatures();
	wta.computeCurvatureChanges();

	% bar voltage already pulled from ephus or not?
	if (isfield(params, 'barVoltageTS') && isobject(params.barVoltageTS))
	  wta.barVoltageTS = params.barVoltageTS;
	else
		eparams.fracInReach = 1;
	  if (isfield(params,'barInReachFraction'))
		  eparams.fracInReach = params.barInReachFraction;
		end
	  wta.updateBarInReachFromEphus (params.ephusPath, params.ephusWC, eparams);
  end

	% apply bar radius & center corrections prior to detect contacts
	if (isfield(params,'barCenterOffset'))
	  wta.barCenterTSA.valueMatrix(1,:) = wta.barCenterTSA.valueMatrix(1,:) + params.barCenterOffset(1);
	  wta.barCenterTSA.valueMatrix(2,:) = wta.barCenterTSA.valueMatrix(2,:) + params.barCenterOffset(2);
	end
	if (isfield(params,'barRadius'))
	  wta.barRadius = params.barRadius;
	end

  wta.computeDistanceToBar();
	if (isfield(params, 'detectContactsParams'))
    wta.detectContacts(params.detectContactsParams);
	else
    wta.detectContacts();
	end
  wta.pushDataToWtArray();

	% save to file
	wta.baseFileName = params.baseFileName;
	wta.saveToFile();
