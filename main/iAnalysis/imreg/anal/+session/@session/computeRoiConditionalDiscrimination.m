%
% SP Jun 2011
%
% This will explore what aspect of the stimulus a ROI cares about.  
%  It will look at directional preference, normalized for force etc., and
%  sequence/combo preference.  
%  [ADD PREFERED WHISKER]
%
% USAGE:
%
%   s.computeRoiConditionalDiscrimination(params)
%
% PARAMS: members of the strucure params:
%
%   roiId: numeric Id of roi to do 
%   whiskerTags: which whiskers to test on ; blank -> all
%   paramsTested: vector with 1/0, 1 meaning test:
%                 (1) directiona preference
%                 (2) directional preference, exclusive contacts
%                 (3) combo contact preference
%                 (4) sequence contact preference
%  
%   respTSA: what is response? defualt is "caTSA.dffTimeSeriesArray"
%
%  The following should be based on what computeRoiWhiskerContactVariableImportance
%    tells you:
% 
%   stimTSA: textual representation of which stimulus TSA to use ; default is
%            "whiskerCurvatureChangeTSA"
%   stimMode: 'max', 'maxabs', '...
%   trialEventNumber: 1, 'max', or [] for all
%   
%
function computeRoiConditionalDiscrimination(obj, params)
  % --- inputs
  if (nargin == 2 && ~isstruct (params))
	  roiId = params;
	elseif (nargin == 2)
		roiId = params.roiId; % required so
	else
	  help('session.session.computeRoiConditionalDiscrimination');
		return;
	end

	whiskerTags = obj.whiskerTag;
	paramsTested = [1 1 0 0];
	respTSA = 'caTSA.dffTimeSeriesArray';
	stimTSA = 'whiskerCurvatureChangeTSA';
	stimMode = 'sumabs';
	trialEventNumber = [];

	if (isfield(params, 'whiskerTags')) ; whiskerTags = params.whiskerTags; end
	if (isfield(params, 'paramsTested')) ; paramsTested = params.paramsTested; end
	if (isfield(params, 'respTSA')) ; respTSA = params.respTSA; end
	if (isfield(params, 'stimTSA')) ; stimTSA = params.stimTSA; end
	if (isfield(params, 'stimMode')) ; stimMode = params.stimMode; end
	if (isfield(params, 'trialEventNumber')) ; trialEventNumber = params.trialEventNumber; end
	
	if (~iscell(whiskerTags)) ; whiskerTags = {whiskerTags} ; end
  
  % --- directional preference, non-exclusive
	if (paramsTested(1))
	  for w=1:length(whiskerTags)
  	  getDirectionalScore(obj, roiId, whiskerTags{w}, 0, stimTSA, respTSA, stimMode, trialEventNumber);
		end
	end

  % --- directional preference, exclusive
	if (paramsTested(2))
	  for w=1:length(whiskerTags)
  	  getDirectionalScore(obj, roiId, whiskerTags{w}, 1, stimTSA, respTSA, stimMode, trialEventNumber);
		end
	end

%
% computes directional preference
%
function dirScore = getDirectionalScore(obj, roiId, whiskerTag, useExclusive, stimTSA, respTSA, stimMode, trialEventNumber)
  % whisker idx
	wi = find(strcmp(obj.whiskerTag,whiskerTag));
  if (length(wi) > 0)
		% get points for both directions
		[stimRet respRet] = getRF(obj, roiId,  useExclusive, 'whiskerBarContactClassifiedESA', ...
		   ['Retraction contacts for ' whiskerTag], stimMode, stimTSA, wi, respTSA, trialEventNumber);
		[stimPro respPro] = getRF(obj, roiId,  useExclusive, 'whiskerBarContactClassifiedESA', ...
		   ['Protraction contacts for ' whiskerTag] , stimMode, stimTSA, wi, respTSA, trialEventNumber);

%  [bin_aucs bin_rs_pvals bin_var_ks_pvals bin_var_rs_pvals bin_bounds] = ...
%    discrim_of_classes_binned_stim(respRet, abs(stimRet), respPro, abs(stimPro),5);

    dparams.ks_thresh = 0.2;
		dparams.rs_thresh = 0.2;
    [resp_auc resp_auc_ci resp_auc_distro resp_rs_pval A_idx B_idx var_ks_pval var_rs_pval var_rs_auc] = ...
      discrim_of_classes_normd_for_stim(respRet, abs(stimRet), respPro, abs(stimPro), 'dmat_shrink', dparams);
disp([whiskerTag ' AUC: ' num2str(resp_auc) ' AUC CI: ' num2str(resp_auc_ci) ' p rank: ' num2str(resp_rs_pval)]);

  end
%  figure ; plot(abs(stimRet), respRet, 'bx') ; hold on ; plot(abs(stimPro), respPro,'rx'); 


%
% computes a single receptive field
%
function [st re] = getRF(obj, roiId,  useExclusive, wESA, wESId, stimMode, stimTSA, stimTSId, respTSA, trialEventNumber)
  params.roiId = roiId;
  params.wcESA = wESA;
	params.wcESId = wESId;
  params.stimMode = stimMode;
	params.stimTSA = stimTSA;
	params.stimTSId = stimTSId;
	params.respTSA = respTSA;

  params.respTSA = respTSA;
	params.useExclusive = useExclusive;
	params.trialEventNumber = trialEventNumber;
	
	[st re] = obj.getPeriWhiskerContactRF(params);

