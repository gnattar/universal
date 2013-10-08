%% decoder single file
if (0)

	% and correlations
	cell_idx = outstruct_arr{1}.save_vars.cell_idx;
	roi_id = outstruct_arr{1}.save_vars.cell_id_list;

	cv = 0*roi_id;
	for i=1:length(cell_idx)

    Y_pred = treebagger_get_predicted(outstruct_arr{1}.treebagger_par_execute_params.X(i,:), outstruct_arr{1}.cross_val_ind_trees(i,:,:), outstruct_arr{1}.treebagger_call_params);
    
		val = find(~isnan(Y_pred) & ~isnan(outstruct_arr{1}.treebagger_par_execute_params.Y));

	  cv(i) = corr(Y_pred(val)', outstruct_arr{1}.treebagger_par_execute_params.Y(val)');
		disp([outstruct_arr{1}.save_vars.feat_name_list ' roi ' num2str(roi_id(i)) ' corr: ' num2str(cv(i))]);
	end

	% plot 
	feat = 0*cv;
	feat(cell_idx) = cv;
	s.plotColorRois(feat)
end

%% decoder multiple files
if (1)
	fl = dir('decoder*mat');
	cv = [];
	cell_idx = [];
	roi_id = [];

  % get correlations
	for f=1:length(fl)
		load(fl(f).name);
	  %% NOTE -- you should do a two-step here!! 
    Y_pred = treebagger_get_predicted(outstruct_arr{1}.treebagger_par_execute_params.X(1,:), ...
		  outstruct_arr{1}.cross_val_ind_trees(1,:,:), outstruct_arr{1}.treebagger_call_params);
 
		val = find(~isnan(Y_pred) & ~isnan(outstruct_arr{1}.treebagger_par_execute_params.Y));

	  cv(f) = corr(Y_pred(val)', outstruct_arr{1}.treebagger_par_execute_params.Y(val)');

		cell_idx(f) = outstruct_arr{1}.save_vars.cell_idx;
		roi_id(f) = outstruct_arr{1}.save_vars.cell_id_list;

		disp([outstruct_arr{1}.save_vars.feat_name_list ' roi ' num2str(roi_id(f)) ' corr: ' num2str(cv(f))]);
	end

	% plot it
	feat = 0*cv;
	feat(cell_idx) = cv;
	s.plotColorRois(feat);
end


%% double decoder:
if (0)
	fl = dir('double_decoder*Contacts*mat');
	cv = [];
	cell_idx = [];
	roi_id = [];

  % get correlations
	for f=1:length(fl)
		load(fl(f).name);
	  %% NOTE -- you should do a two-step here!! 
		Y2_pred = treebagger_get_predicted(outstruct_arr{1}.Yp, ...
					outstruct_arr{1}.cross_val_grouped_trees, outstruct_arr{1}.treebagger_call_params);
		val = find(~isnan(Y2_pred) & ~isnan(outstruct_arr{1}.treebagger_par_execute_params.Y2));

		cv(f) = corr(Y2_pred(val)', outstruct_arr{1}.treebagger_par_execute_params.Y2(val)');

		cell_idx(f) = outstruct_arr{1}.save_vars.cell_idx;
		roi_id(f) = outstruct_arr{1}.save_vars.cell_id_list;

		disp([fl(f).name ' ' num2str(cv(f))]);
	end

	% plot it
	feat = 0*cv;
	feat(cell_idx) = cv;
	s.plotColorRois(feat);
end
