%
% SP Jun 2011
%
% Collects a variety of touch index matrices.
%
% USAGE:
%
%   s.getTouchIndexMat(params)
%
% PARAMS: structure params with fields:
%
function getTouchIndexMat(obj, params)

  % generic
	params.whiskerTags = {'c1','c2','c3'};
	params.useExclusiveWhiskers = 1;

  % --- loop thru methods
	methods = {'P_prod', 'SNR', 'MI', 'MI_norm', 'AUC_Ca'};
	i = 1;
	for m=1:length(methods)
%	i = 9;
%	for m=5
	  disp(['getTouchIndexMat::method now being done is ' methods{m} ', nondirectional.']);
    params.method = methods{m};
		params.directional = 0;
%		obj.computeRoiTouchIndex(params, 'caTSA.eventBasedDffTimeSeriesArray');
		obj.computeRoiTouchIndex(params, 'caTSA.caPeakTimeSeriesArray');
%		obj.computeRoiTouchIndex(params, 'caTSA.dffTimeSeriesArray');
		obj.touchIndexMatId{i} = [methods{m} ' nondirectional'];
		for si=1:length(obj.sessions) ; obj.touchIndexMats{i}{si} = obj.sessions{si}.touchIndex; end
		i = i+1;

	  disp(['getTouchIndexMat::method now being done is ' methods{m} ', directional.']);
		params.directional = 1;
%		obj.computeRoiTouchIndex(params, 'caTSA.eventBasedDffTimeSeriesArray');
		obj.computeRoiTouchIndex(params, 'caTSA.caPeakTimeSeriesArray');
%		obj.computeRoiTouchIndex(params, 'caTSA.dffTimeSeriesArray');
		obj.touchIndexMatId{i} = [methods{m} ' directional'];
		for si=1:length(obj.sessions) ; obj.touchIndexMats{i}{si} = obj.sessions{si}.touchIndex; end
		i = i+1;
  end


