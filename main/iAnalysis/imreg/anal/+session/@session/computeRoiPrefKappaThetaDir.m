%
% SP Jun 2011
%
% Computes ROI preference for kappa, theta, and direction while controling for
%  other 2 variables.
%
% USAGE:
%
%   retParams = s.computeRoiPrefKappaThetaDir(params)
%
% PARAMS: 
%
%  retParams: structure with fields
%    kappaAUC: AUC and confidence intervals for various kappa vs. dff ROC measurements
%    thetaAUC: AUC and CIs for various theta ROC measurements
%    posAUC: AUC and CIs for various position (go/nogo 4 now) ROC measurements
%    dirAUC: AUC and CIs for pro/ret ROC measurements
%    data: stT, reT, ... all the raw data
%
%  params: structure w/ fields
%    kParams: kappa params that are used by getPeriWhiskerContactRF.
%    tParams: theta params that are used by getPeriWhiskerContactRF.
%    useExclusive: force switch on t/kParams exclusivity flag if passed
%
function retParams = computeRoiPrefKappaThetaDir (obj, params)
  % --- input process

	% non-negotiable
	kParams = params.kParams;
	tParams = params.tParams;

	% optional
	if (isfield(params, 'useExclusive'))
	  tParams.useExclusive = params.useExclusive;
	  kParams.useExclusive = params.useExclusive;
	end

	% --- pull events & get indices of appropriate trials ...

	% get list of trials @ each position [assume hit/miss FA/CR are 2 positions]
	goIdx = find( ismember(obj.trialTypeStr, {'Hit','Miss'}));
	nogoIdx = find( ismember(obj.trialTypeStr, {'CR','FA'}));
	goTrials = obj.trialIds(find(sum(obj.trialTypeMat(goIdx,:))));
	nogoTrials = obj.trialIds(find(sum(obj.trialTypeMat(nogoIdx,:))));

  % get the stim-resp for theta, kappa and for direction
  [stK reK parK] = obj.getPeriWhiskerContactRF(kParams);
	stK = abs(stK) ; % dont want signed kappa
  [stT reT parT] = obj.getPeriWhiskerContactRF(tParams);
	proKParams = kParams;
	proKParams.wcESA = 'whiskerBarContactClassifiedESA';
	proKParams.wcESId = strrep(proKParams.wcESId, 'Contacts', 'Protraction contacts');
  [stKP reKP parKP] = obj.getPeriWhiskerContactRF(proKParams);
	stKP = abs(stKP) ; % dont want signed kappa
	proTParams = tParams;
	proTParams.wcESA = 'whiskerBarContactClassifiedESA';
	proTParams.wcESId = strrep(proTParams.wcESId, 'Contacts', 'Protraction contacts');
  [stTP reTP parTP] = obj.getPeriWhiskerContactRF(proTParams);
	retKParams = kParams;
	retKParams.wcESA = 'whiskerBarContactClassifiedESA';
	retKParams.wcESId = strrep(retKParams.wcESId, 'Contacts', 'Retraction contacts');
  [stKR reKR parKR] = obj.getPeriWhiskerContactRF(retKParams);
	stKR = abs(stKR) ; % dont want signed kappa
	retTParams = tParams;
	retTParams.wcESA = 'whiskerBarContactClassifiedESA';
	retTParams.wcESId = strrep(retTParams.wcESId, 'Contacts', 'Retraction contacts');
  [stTR reTR parTR] = obj.getPeriWhiskerContactRF(retTParams);

  % --- reg & bin-AUC for dF/F binned by theta (pos), control for force , dir, both
  retParams.thetaAUC = computeAUCTheta(stT, reT, parT, stK, stTP, reTP, parTP, stKP, stTR, reTR, parTR, stKR, goTrials, nogoTrials);

  % --- bin-AUC for dF/F v. kappa, controlling for theta (pos) , dir , both
	retParams.kappaAUC = computeAUCKappa(stK, stT, reK, parK, stKP, stTP, reKP, parKP, stKR, stTR, reKR, parKR, goTrials, nogoTrials);
  
  % --- reg & bin-AUC for dF/F binned by (pos), control for force , dir, both
  retParams.posAUC = computeAUCPosition(stT, reT, parT, stK, stTP, reTP, parTP, stKP, stTR, reTR, parTR, stKR, goTrials, nogoTrials);

	% --- reg & bin-AUC for dF/F binned by direction, control for force, theta , both
  retParams.dirAUC = computeAUCDirection(stT, reT, parT, stK, stTP, reTP, parTP, stKP, stTR, reTR, parTR, stKR, goTrials, nogoTrials);

	% --- plot things if requested

	% --- compile data
	data.stT = stT;
	data.stK = stK;
	data.re = reT;
	data.paramsT = parT;
	data.paramsK = parK;

	data.stTR = stTR;
	data.stKR = stKR;
	data.reR = reTR;
	data.paramsTR = parTR;
	data.paramsKR = parKR;

	data.stTP = stTP;
	data.stKP = stKP;
	data.reP = reTP;
	data.paramsTP = parTP;
	data.paramsKP = parKP;

	retParams.data = data;




%
% This will determine how much discrimination power remains for direction 
%  once theta, kappa, or both are controlled for.
%
function dirAUC = computeAUCDirection(stT, reT, parT, stK, stTP, reTP, parTP, stKP, stTR, reTR, parTR, stKR, goTrials, nogoTrials);
  % for calls to discrim_of_classes_normd_for_stim
  dparams.ks_thresh = 0.2;
  dparams.rs_thresh = 0.2;
   
	rGoIdx = find(ismember(parTR.eTrials, goTrials));
	rNogoIdx = find(ismember(parTR.eTrials, nogoTrials));
	pGoIdx = find(ismember(parTP.eTrials, goTrials));
	pNogoIdx = find(ismember(parTP.eTrials, nogoTrials));

  % --- 0) BASE AUC with no controls
  [AUCBase AUCBaseCI] = roc_area_from_distro_boot(reTR, reTP, 50);

  % --- 1) Control for kappa
  [AUCKappaNorm AUCKappaNormCI irr1 irr2 KNRidx KNPidx] = ...
     discrim_of_classes_normd_for_stim(reTR, stKR, reTP, stKP, 'dmat_shrink', dparams);

  % --- 2) Control for theta
  [AUCThetaNorm AUCThetaNormCI irr1 irr2 TNRidx TNPidx] = ...
     discrim_of_classes_normd_for_stim(reTR, stTR, reTP, stTP, 'dmat_shrink', dparams);

  % --- 3) Control for kappa & theta
	KappThetNormRetIdx = intersect(TNRidx, KNRidx);
	KappThetNormProIdx = intersect(TNPidx, KNPidx);
  [AUCKappaThetaNorm AUCKappaThetaNormCI] = roc_area_from_distro_boot(reTR(KappThetNormRetIdx), reTP(KappThetNormProIdx), 50);

	% --- 4) Control for position
  [AUCGo AUCGoCI] = roc_area_from_distro_boot(reTR(rGoIdx), reTP(pGoIdx), 50);
  [AUCNogo AUCNogoCI] = roc_area_from_distro_boot(reTR(rNogoIdx), reTP(pNogoIdx), 50);

	% --- 5) Control for position & kappa
  [AUCGoKappaNorm AUCGoKappaNormCI] = ...
     discrim_of_classes_normd_for_stim(reTR, stKR, reTP, stKP, 'dmat_shrink', dparams);
  [AUCNogoKappaNorm AUCNogoKappaNormCI] = ...
     discrim_of_classes_normd_for_stim(reTR, stKR, reTP, stKP, 'dmat_shrink', dparams);

	dirAUC.AUCBase = AUCBase; dirAUC.AUCBaseCI = AUCBaseCI;
	dirAUC.AUCKappaNorm = AUCKappaNorm; dirAUC.AUCKappaNormCI = AUCKappaNormCI;
	dirAUC.AUCThetaNorm = AUCThetaNorm; dirAUC.AUCThetaNormCI = AUCThetaNormCI;
	dirAUC.AUCKappaThetaNorm = AUCKappaThetaNorm; dirAUC.AUCKappaThetaNormCI = AUCKappaThetaNormCI;
	dirAUC.AUCGo = AUCGo; dirAUC.AUCGoCI = AUCGoCI;
	dirAUC.AUCNogo = AUCNogo; dirAUC.AUCNogoCI = AUCNogoCI;
	dirAUC.AUCGoKappaNorm = AUCGoKappaNorm; dirAUC.AUCGoKappaNormCI = AUCGoKappaNormCI;
	dirAUC.AUCNogoKappaNorm = AUCNogoKappaNorm; dirAUC.AUCNogoKappaNormCI = AUCNogoKappaNormCI;

	% display
	if (1) 
		disp(['dir baseline: ' num2str(AUCBase) ' CI: ' num2str(AUCBaseCI)]);
		disp(['  KappaNorm: ' num2str(AUCKappaNorm) ' CI: ' num2str(AUCKappaNormCI)]);
		disp(['  ThetaNorm: ' num2str(AUCThetaNorm) ' CI: ' num2str(AUCThetaNormCI)]);
		disp(['  KappaThetaNorm: ' num2str(AUCKappaThetaNorm) ' CI: ' num2str(AUCKappaThetaNormCI)]);
		disp(['  GO: ' num2str(AUCGo) ' CI: ' num2str(AUCGoCI)]);
		disp(['  NOGO: ' num2str(AUCNogo) ' CI: ' num2str(AUCNogoCI)]);
		disp(['  KNorm-GO: ' num2str(AUCGoKappaNorm) ' CI: ' num2str(AUCGoKappaNormCI)]);
		disp(['  KNorm-NOGO: ' num2str(AUCNogoKappaNorm) ' CI: ' num2str(AUCNogoKappaNormCI)]);
  end

%
% This will determine how much discrimination power remains for kappa once 
%  pole position ("theta"), whisking direction, or both are controlled for
%
%  Since we are dealing with many bins instead of a natural partitioning as
%  for the other variables, take the MAX AUC if possible ...
%
function kappaAUC = computeAUCKappa(stK, stT, reK, parK, stKP, stTP, reKP, parKP, stKR, stTR, reKR, parKR, goTrials, nogoTrials)
  
  % --- 0) BASE AUC with no controls
  [AUCBase AUCBaseCI poop AUCMaxBase AUCMaxBaseCI] = discrim_by_multibin_stim_boot(stK, reK, 4,50);

	% --- 1) control for position only.  This is simple.  All you do is 
	%     compute AUC at both positions and you are done.
	goIdx = find(ismember(parK.eTrials, goTrials));
	nogoIdx = find(ismember(parK.eTrials, nogoTrials));
  [AUCGo AUCGoCI poop AUCMaxGo AUCMaxGoCI] = discrim_by_multibin_stim_boot(stK(goIdx), reK(goIdx), 4,50);
  [AUCNogo AUCNogoCI poop AUCMaxNogo AUCMaxNogoCI] = discrim_by_multibin_stim_boot(stK(nogoIdx), reK(nogoIdx), 4,50);

	% --- 2) control for direction of contact only.  Again, just compute AUC for 
	%        both sets.
  [AUCRet AUCRetCI poop AUCMaxRet AUCMaxRetCI] = discrim_by_multibin_stim_boot(stKR, reKR, 4,50);
  [AUCPro AUCProCI poop AUCMaxPro AUCMaxProCI] = discrim_by_multibin_stim_boot(stKP, reKP, 4,50);

	% --- 3) control for both direction  & position (i.e., 4 combinations - 2 positions x 2 directions)
	rGoIdx = find(ismember(parKR.eTrials, goTrials));
	rNogoIdx = find(ismember(parKR.eTrials, nogoTrials));
  [AUCRetGo AUCRetGoCI poop AUCMaxRetGo AUCMaxRetGoCI] = discrim_by_multibin_stim_boot(stKR(rGoIdx), reKR(rGoIdx), 4,50);
  [AUCRetNogo AUCRetNogoCI poop AUCMaxRetNogo AUCMaxRetNogoCI] = discrim_by_multibin_stim_boot(stKR(rNogoIdx), reKR(rNogoIdx), 4,50);

	pGoIdx = find(ismember(parKP.eTrials, goTrials));
	pNogoIdx = find(ismember(parKP.eTrials, nogoTrials));
  [AUCProGo AUCProGoCI poop AUCMaxProGo AUCMaxProGoCI] = discrim_by_multibin_stim_boot(stKP(pGoIdx), reKP(pGoIdx), 4,50);
  [AUCProNogo AUCProNogoCI poop AUCMaxProNogo AUCMaxProNogoCI] = discrim_by_multibin_stim_boot(stKP(pNogoIdx), reKP(pNogoIdx), 4,50);

	% --- 4) control for THETA only
  [AUCThetaNorm AUCThetaNormCI poop AUCMaxThetaNorm AUCMaxThetaNormCI] = discrim_by_bin_stim_normd_for_other_stim_boot(stK,stT, reK, 4, 50);

	% --- 5) control for THETA & direction
  [AUCProThetaNorm AUCProThetaNormCI poop AUCMaxProThetaNorm AUCMaxProThetaNormCI] = discrim_by_bin_stim_normd_for_other_stim_boot(stKP,stTP, reKP, 4, 50);
  [AUCRetThetaNorm AUCRetThetaNormCI poop AUCMaxRetThetaNorm AUCMaxRetThetaNormCI] = discrim_by_bin_stim_normd_for_other_stim_boot(stKR,stTR, reKR, 4, 50);  



	% --- compile results for return . . .
	kappaAUC.AUCBase = AUCBase; kappaAUC.AUCBaseCI = AUCBaseCI;
	kappaAUC.AUCGo = AUCGo; kappaAUC.AUCGoCI = AUCGoCI;
	kappaAUC.AUCNogo = AUCNogo; kappaAUC.AUCNogoCI = AUCNogoCI;
	kappaAUC.AUCPro = AUCPro; kappaAUC.AUCProCI = AUCProCI;
	kappaAUC.AUCRet = AUCRet; kappaAUC.AUCRetCI = AUCRetCI;
	kappaAUC.AUCProGo = AUCProGo; kappaAUC.AUCProGoCI = AUCProGoCI;
	kappaAUC.AUCProNogo = AUCProNogo; kappaAUC.AUCProNogoCI = AUCProNogoCI;
	kappaAUC.AUCRetGo = AUCRetGo; kappaAUC.AUCRetGoCI = AUCRetGoCI;
	kappaAUC.AUCRetNogo = AUCRetNogo; kappaAUC.AUCRetNogoCI = AUCRetNogoCI;
	kappaAUC.AUCThetaNorm = AUCThetaNorm; kappaAUC.AUCThetaNormCI = AUCThetaNormCI;
	kappaAUC.AUCProThetaNorm = AUCProThetaNorm; kappaAUC.AUCProThetaNormCI = AUCProThetaNormCI;
	kappaAUC.AUCRetThetaNorm = AUCRetThetaNorm; kappaAUC.AUCRetThetaNormCI = AUCRetThetaNormCI;

	kappaAUC.AUCMaxBase = AUCMaxBase; kappaAUC.AUCMaxBaseCI = AUCMaxBaseCI;
	kappaAUC.AUCMaxGo = AUCMaxGo; kappaAUC.AUCMaxGoCI = AUCMaxGoCI;
	kappaAUC.AUCMaxNogo = AUCMaxNogo; kappaAUC.AUCMaxNogoCI = AUCMaxNogoCI;
	kappaAUC.AUCMaxPro = AUCMaxPro; kappaAUC.AUCMaxProCI = AUCMaxProCI;
	kappaAUC.AUCMaxRet = AUCMaxRet; kappaAUC.AUCMaxRetCI = AUCMaxRetCI;
	kappaAUC.AUCMaxProGo = AUCMaxProGo; kappaAUC.AUCMaxProGoCI = AUCMaxProGoCI;
	kappaAUC.AUCMaxProNogo = AUCMaxProNogo; kappaAUC.AUCMaxProNogoCI = AUCMaxProNogoCI;
	kappaAUC.AUCMaxRetGo = AUCMaxRetGo; kappaAUC.AUCMaxRetGoCI = AUCMaxRetGoCI;
	kappaAUC.AUCMaxRetNogo = AUCMaxRetNogo; kappaAUC.AUCMaxRetNogoCI = AUCMaxRetNogoCI;
	kappaAUC.AUCMaxThetaNorm = AUCMaxThetaNorm; kappaAUC.AUCMaxThetaNormCI = AUCMaxThetaNormCI;
	kappaAUC.AUCMaxProThetaNorm = AUCMaxProThetaNorm; kappaAUC.AUCMaxProThetaNormCI = AUCMaxProThetaNormCI;
	kappaAUC.AUCMaxRetThetaNorm = AUCMaxRetThetaNorm; kappaAUC.AUCMaxRetThetaNormCI = AUCMaxRetThetaNormCI;


	% display
	if (1) 
		disp(['kappa baseline: ' num2str(AUCBase) ' CI: ' num2str(AUCBaseCI)]);
		disp(['  GO: ' num2str(AUCGo) ' CI: ' num2str(AUCGoCI)]);
		disp(['  NOGO: ' num2str(AUCNogo) ' CI: ' num2str(AUCNogoCI)]);
		disp(['  Pro: ' num2str(AUCPro) ' CI: ' num2str(AUCProCI)]);
		disp(['  Ret: ' num2str(AUCRet) ' CI: ' num2str(AUCRetCI)]);
		disp(['  Pro-GO: ' num2str(AUCProGo) ' CI: ' num2str(AUCProGoCI)]);
		disp(['  Pro-NOGO: ' num2str(AUCProNogo) ' CI: ' num2str(AUCProNogoCI)]);
		disp(['  Ret-GO: ' num2str(AUCRetGo) ' CI: ' num2str(AUCRetGoCI)]);
		disp(['  Ret-NOGO: ' num2str(AUCRetNogo) ' CI: ' num2str(AUCRetNogoCI)]);
		disp(['  ThetaNorm: ' num2str(AUCThetaNorm) ' CI: ' num2str(AUCThetaNormCI)]);
		disp(['  Pro-ThetaNorm: ' num2str(AUCProThetaNorm) ' CI: ' num2str(AUCProThetaNormCI)]);
		disp(['  Ret-ThetaNorm: ' num2str(AUCRetThetaNorm) ' CI: ' num2str(AUCRetThetaNormCI)]);
		disp(['kappa Max baseline: ' num2str(AUCMaxBase) ' CI: ' num2str(AUCMaxBaseCI)]);
		disp(['  Max GO: ' num2str(AUCMaxGo) ' CI: ' num2str(AUCMaxGoCI)]);
		disp(['  Max NOGO: ' num2str(AUCMaxNogo) ' CI: ' num2str(AUCMaxNogoCI)]);
		disp(['  Max Pro: ' num2str(AUCMaxPro) ' CI: ' num2str(AUCMaxProCI)]);
		disp(['  Max Ret: ' num2str(AUCMaxRet) ' CI: ' num2str(AUCMaxRetCI)]);
		disp(['  Max Pro-GO: ' num2str(AUCMaxProGo) ' CI: ' num2str(AUCMaxProGoCI)]);
		disp(['  Max Pro-NOGO: ' num2str(AUCMaxProNogo) ' CI: ' num2str(AUCMaxProNogoCI)]);
		disp(['  Max Ret-GO: ' num2str(AUCMaxRetGo) ' CI: ' num2str(AUCMaxRetGoCI)]);
		disp(['  Max Ret-NOGO: ' num2str(AUCMaxRetNogo) ' CI: ' num2str(AUCMaxRetNogoCI)]);
		disp(['  Max ThetaNorm: ' num2str(AUCMaxThetaNorm) ' CI: ' num2str(AUCMaxThetaNormCI)]);
		disp(['  Max Pro-ThetaNorm: ' num2str(AUCMaxProThetaNorm) ' CI: ' num2str(AUCMaxProThetaNormCI)]);
		disp(['  Max Ret-ThetaNorm: ' num2str(AUCMaxRetThetaNorm) ' CI: ' num2str(AUCMaxRetThetaNormCI)]);
  end


%
% This will determine how much discrimination power remains for theta 
%  once kappa, direction, or both are normalized for
%
function thetaAUC = computeAUCTheta(stT, reT, parT, stK, stTP, reTP, parTP, stKP, stTR, reTR, parTR, stKR, goTrials, nogoTrials)
  % for calls to discrim_of_classes_normd_for_stim
  dparams.ks_thresh = 0.2;
  dparams.rs_thresh = 0.2;
   
  % --- 0) BASE AUC with no controls
  [AUCBase AUCBaseCI poop AUCMaxBase AUCMaxBaseCI] = discrim_by_multibin_stim_boot(stT, reT, 4,50);

	% --- 1) control for kappa only using KS test
  [AUCKappaNorm AUCKappaNormCI poop AUCMaxKappaNorm AUCMaxKappaNormCI] = discrim_by_bin_stim_normd_for_other_stim_boot(stT,stK, reT, 4, 50);

	% --- 2) control for direction of contact only.  Fairly simple --> use pro/ret subsets
	%        on go/nogo trials (progo vs pronogo ; retgo vs retnogo)
  [AUCRet AUCRetCI poop AUCMaxRet AUCMaxRetCI] = discrim_by_multibin_stim_boot(stTR, reTR, 4,50);
  [AUCPro AUCProCI poop AUCMaxPro AUCMaxProCI] = discrim_by_multibin_stim_boot(stTP, reTP, 4,50);

	% --- 3) control for both direction  & kappa -- as in 2, but now thru 
	%        discrim_of_classes_normd_for_stim
  [AUCProKappaNorm AUCProKappaNormCI poop AUCMaxProKappaNorm AUCMaxProKappaNormCI] = discrim_by_bin_stim_normd_for_other_stim_boot(stTP,stKP, reTP, 4, 50);
  [AUCRetKappaNorm AUCRetKappaNormCI poop AUCMaxRetKappaNorm AUCMaxRetKappaNormCI] = discrim_by_bin_stim_normd_for_other_stim_boot(stTR,stKR, reTR, 4, 50);  


	thetaAUC.AUCBase = AUCBase; thetaAUC.AUCBaseCI = AUCBaseCI;
	thetaAUC.AUCKappaNorm = AUCKappaNorm; thetaAUC.AUCKappaNormCI = AUCKappaNormCI;
	thetaAUC.AUCRet = AUCRet; thetaAUC.AUCRetCI = AUCRetCI;
	thetaAUC.AUCPro = AUCPro; thetaAUC.AUCProCI = AUCProCI;
	thetaAUC.AUCRetKappaNorm = AUCRetKappaNorm; thetaAUC.AUCRetKappaNormCI = AUCRetKappaNormCI;
	thetaAUC.AUCProKappaNorm = AUCProKappaNorm; thetaAUC.AUCProKappaNormCI = AUCProKappaNormCI;

	thetaAUC.AUCMaxBase = AUCMaxBase; thetaAUC.AUCMaxBaseCI = AUCMaxBaseCI;
	thetaAUC.AUCMaxKappaNorm = AUCMaxKappaNorm; thetaAUC.AUCMaxKappaNormCI = AUCMaxKappaNormCI;
	thetaAUC.AUCMaxRet = AUCMaxRet; thetaAUC.AUCMaxRetCI = AUCMaxRetCI;
	thetaAUC.AUCMaxPro = AUCMaxPro; thetaAUC.AUCMaxProCI = AUCMaxProCI;
	thetaAUC.AUCMaxRetKappaNorm = AUCMaxRetKappaNorm; thetaAUC.AUCMaxRetKappaNormCI = AUCMaxRetKappaNormCI;
	thetaAUC.AUCMaxProKappaNorm = AUCMaxProKappaNorm; thetaAUC.AUCMaxProKappaNormCI = AUCMaxProKappaNormCI;

	% display
	if (1) 
		disp(['theta baseline: ' num2str(AUCBase) ' CI: ' num2str(AUCBaseCI)]);
		disp(['  kappa-normd: ' num2str(AUCKappaNorm) ' CI: ' num2str(AUCKappaNormCI)]);
		disp(['  Ret: ' num2str(AUCRet) ' CI: ' num2str(AUCRetCI)]);
		disp(['  Pro: ' num2str(AUCPro) ' CI: ' num2str(AUCProCI)]);
		disp(['  Ret k-norm: ' num2str(AUCRetKappaNorm) ' CI: ' num2str(AUCRetKappaNormCI)]);
		disp(['  Pro k-norm: ' num2str(AUCProKappaNorm) ' CI: ' num2str(AUCProKappaNormCI)]);
		disp(['theta max baseline: ' num2str(AUCMaxBase) ' CI: ' num2str(AUCMaxBaseCI)]);
		disp(['  max kappa-normd: ' num2str(AUCMaxKappaNorm) ' CI: ' num2str(AUCMaxKappaNormCI)]);
		disp(['  max Ret: ' num2str(AUCMaxRet) ' CI: ' num2str(AUCMaxRetCI)]);
		disp(['  max Pro: ' num2str(AUCMaxPro) ' CI: ' num2str(AUCMaxProCI)]);
		disp(['  max Ret k-norm: ' num2str(AUCMaxRetKappaNorm) ' CI: ' num2str(AUCMaxRetKappaNormCI)]);
		disp(['  max Pro k-norm: ' num2str(AUCMaxProKappaNorm) ' CI: ' num2str(AUCMaxProKappaNormCI)]);
  end


%
% This will determine how much discrimination power remains for position
%  once kappa, direction, or both are normalized for
%
function posAUC = computeAUCPosition(stT, reT, parT, stK, stTP, reTP, parTP, stKP, stTR, reTR, parTR, stKR, goTrials, nogoTrials)
  % for calls to discrim_of_classes_normd_for_stim
  dparams.ks_thresh = 0.2;
  dparams.rs_thresh = 0.2;
   
  % --- 0) BASE AUC with no controls
	goIdx = find(ismember(parT.eTrials,goTrials));
	nogoIdx = find(ismember(parT.eTrials,nogoTrials));
  [AUCBase AUCBaseCI] = roc_area_from_distro_boot(reT(goIdx), reT(nogoIdx), 50);

	% --- 1) control for kappa only using KS test
  [AUCKappaNorm AUCKappaNormCI] = ...
     discrim_of_classes_normd_for_stim(reT(goIdx), stK(goIdx), reT(nogoIdx), stK(nogoIdx), 'dmat_shrink', dparams);

	% --- 2) control for direction of contact only.  Fairly simple --> use pro/ret subsets
	%        on go/nogo trials (progo vs pronogo ; retgo vs retnogo)
	rGoIdx = find(ismember(parTR.eTrials, goTrials));
	rNogoIdx = find(ismember(parTR.eTrials, nogoTrials));
  [AUCRet AUCRetCI] = roc_area_from_distro_boot(reTR(rGoIdx), reTR(rNogoIdx), 50);

	pGoIdx = find(ismember(parTP.eTrials, goTrials));
	pNogoIdx = find(ismember(parTP.eTrials, nogoTrials));
  [AUCPro AUCProCI] = roc_area_from_distro_boot(reTP(pGoIdx), reTP(pNogoIdx), 50);

	% --- 3) control for both direction  & kappa -- as in 2, but now thru 
	%        discrim_of_classes_normd_for_stim
  [AUCRetKappaNorm AUCRetKappaNormCI] = ...
     discrim_of_classes_normd_for_stim(reTR(rGoIdx), stKR(rGoIdx), reTR(rNogoIdx), stKR(rNogoIdx), 'dmat_shrink', dparams);
  [AUCProKappaNorm AUCProKappaNormCI] = ...
     discrim_of_classes_normd_for_stim(reTP(pGoIdx), stKP(pGoIdx), reTP(pNogoIdx), stKP(pNogoIdx), 'dmat_shrink', dparams);


	% --- compile results for return . . .
	posAUC.AUCBase = AUCBase; posAUC.AUCBaseCI = AUCBaseCI;
	posAUC.AUCKappaNorm = AUCKappaNorm; posAUC.AUCKappaNormCI = AUCKappaNormCI;
	posAUC.AUCRet = AUCRet; posAUC.AUCRetCI = AUCRetCI;
	posAUC.AUCPro = AUCPro; posAUC.AUCProCI = AUCProCI;
	posAUC.AUCRetKappaNorm = AUCRetKappaNorm; posAUC.AUCRetKappaNormCI = AUCRetKappaNormCI;
	posAUC.AUCProKappaNorm = AUCProKappaNorm; posAUC.AUCProKappaNormCI = AUCProKappaNormCI;

	% display
	if (1) 
		disp(['position baseline: ' num2str(AUCBase) ' CI: ' num2str(AUCBaseCI)]);
		disp(['  kappa-normd: ' num2str(AUCKappaNorm) ' CI: ' num2str(AUCKappaNormCI)]);
		disp(['  Ret: ' num2str(AUCRet) ' CI: ' num2str(AUCRetCI)]);
		disp(['  Pro: ' num2str(AUCPro) ' CI: ' num2str(AUCProCI)]);
		disp(['  Ret k-norm: ' num2str(AUCRetKappaNorm) ' CI: ' num2str(AUCRetKappaNormCI)]);
		disp(['  Pro k-norm: ' num2str(AUCProKappaNorm) ' CI: ' num2str(AUCProKappaNormCI)]);
  end
