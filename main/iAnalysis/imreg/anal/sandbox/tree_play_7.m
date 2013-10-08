% tests for DOUBLE decoder 
if (1)
	disp('meant for session_merged 167961 vol_04');

  roiId = 10282;
	X = s.caTSA.eventBasedDffTimeSeriesArray.getTimeSeriesById(roiId).value;
	X = s.caTSA.dffTimeSeriesArray.getTimeSeriesById(roiId).value;
	X = s.caTSA.caPeakTimeSeriesArray.getTimeSeriesById(roiId).value;

	yids = [20001 20011 20021 20031];
	Y = nan*zeros(length(yids), size(X,2));
	for i=1:length(yids)
		Y(i,:) = s.derivedDataTSA.getTimeSeriesById(yids(i)).value;
	end

	is_category_X = zeros(1,size(X,1));
	is_category_Y = zeros(1,size(Y,1));



	params_1.temporal_shifts = -4:0;
	params_1.nfold_cross_validation = 5;
	params_1.cross_validation_trial_vec = s.derivedDataTSA.trialIndices;
	params_1.z_score = [0 0];
	params_1.zero_nans = [0 2]; % strip NaN values in stimulus
	params_1.do_grouped = 1;
	params_1.do_individual= 1;

	% step 1:
	[full_ind_trees_1 cross_val_ind_trees_1 full_grouped_trees_1 ...
	cross_val_grouped_trees_1 rparams_1] ...
	= treebagger_call(X, Y, is_category_X, is_category_Y, params_1);

	% now predict secondary Y with prediction of Y
	baseTime = s.derivedDataTSA.time;
	baseTimeUnit = s.derivedDataTSA.timeUnit;
	touchTS = s.whiskerBarContactESA.esa{1}.deriveTimeSeries(baseTime,baseTimeUnit, [0 1]);
	touchTS.id = 40001;
	touchTS.idStr = 'All Touch';

	touchProTS = s.whiskerBarContactClassifiedESA.esa{1}.deriveTimeSeries(baseTime,baseTimeUnit, [0 1]);
	touchProTS.id = 40002;
	touchProTS.idStr = 'Pro Touch';

	touchRetTS = s.whiskerBarContactClassifiedESA.esa{2}.deriveTimeSeries(baseTime,baseTimeUnit, [0 1]);
	touchRetTS.id = 40003;
	touchRetTS.idStr = 'Ret Touch';

	Yp = treebagger_get_predicted(X,cross_val_ind_trees_1,rparams_1);
	X2 = Yp;

%	Y2 = [touchTS.value ; touchRetTS.value ; touchProTS.value];
	Y2 = [touchTS.value];

	is_category_X2 = zeros(1,size(X2,2));
	is_category_Y2 = ones(1,size(Y2,2));

	params_2.temporal_shifts = -4:0;
	params_2.nfold_cross_validation = 5;
	params_2.cross_validation_trial_vec = s.derivedDataTSA.trialIndices;
	params_2.z_score = [0 0];
	params_2.zero_nans = [0 2]; % strip NaN values in stimulus
	params_2.do_grouped = 1;
	params_2.do_individual= 1;

	% step 2:
	[full_ind_trees_2 cross_val_ind_trees_2 full_grouped_trees_2 ...
	cross_val_grouped_trees_2 rparams_2] ...
	= treebagger_call(X2, Y2, is_category_X2, is_category_Y2, params_2);

	
  % predict
	Y_pred_2 = treebagger_get_predicted(X2, cross_val_grouped_trees_2, rparams_2);
	for i=1:size(Y2,1)
		val = find(~isnan(Y2(i,:)) & ~isnan(Y_pred_2(i,:)));
		cv = corr(Y_pred_2(i,val)', Y2(i,val)')
	end

end

% session based
if (0)
  % setup touch TSs . . . 
	treeBaggerParams.roiIdList = [7003 7036 8022]; 

	treeBaggerParams.featureIdList2Step{1} = [20001 20011 20021 20031];
	treeBaggerParams.featureIdList2Step{2} = [21010 21011 21012];

	treeBaggerParams.runModes = [0 0 0 0 0 1 1];

	treeBaggerParams.typeVec2Step{1} = [0 0 0 0];
	treeBaggerParams.typeVec2Step{2} = [1 1 1];
	
	s.setupTreeBaggerPar('/data/an167951/treepartest',treeBaggerParams);

end

% tests for SINGLE decoder 
if (0)
	disp('meant for session_merged 167961 vol_01');

  roiId = 1048;
	X = s.caTSA.dffTimeSeriesArray.getTimeSeriesById(roiId).value;
	X = s.caTSA.eventBasedDffTimeSeriesArray.getTimeSeriesById(roiId).value;
	X = s.caTSA.caPeakTimeSeriesArray.getTimeSeriesById(roiId).value;

	yids = [10000];
	Y = nan*zeros(length(yids), size(X,2));
	for i=1:length(yids)
		Y(i,:) = s.derivedDataTSA.getTimeSeriesById(yids(i)).value;
	end

	is_category_X = zeros(1,size(X,1));
	is_category_Y = zeros(1,size(Y,1));

	params.temporal_shifts = -4:0;
	params.nfold_cross_validation = 5;
	params.cross_validation_trial_vec = s.derivedDataTSA.trialIndices;
	params.z_score = [0 0];
	params.zero_nans = [0 2]; % strip NaN values in stimulus
	params.do_grouped = 0;
	params.do_individual= 1;

	% bagger call
	[full_ind_trees cross_val_ind_trees full_grouped_trees ...
	cross_val_grouped_trees rparams] ...
	= treebagger_call(X, Y, is_category_X, is_category_Y, params);

  % predict
	Y_pred = treebagger_get_predicted(X, cross_val_ind_trees, rparams);
	val = find(~isnan(Y) & ~isnan(Y_pred));
	cv = corr(Y_pred(val)', Y(val)')
end



