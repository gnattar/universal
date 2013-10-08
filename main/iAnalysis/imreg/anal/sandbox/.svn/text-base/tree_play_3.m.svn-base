%
% analyziing
%

if (0) % encoder ... grouped
	figure ; 
	plot(s.caTSA.caPeakTimeSeriesArray.valueMatrix(outstruct_arr{1}.save_vars.cell_idx,:));
	hold on;
	Y = treebagger_get_predicted(s.derivedDataTSA.valueMatrix(outstruct_arr{1}.save_vars.feat_idx,:), ...
										 outstruct_arr{1}.full_grouped_trees, outstruct_arr{1}.treebagger_call_params);
	plot(Y,'r-');
	corr(s.caTSA.caPeakTimeSeriesArray.valueMatrix(outstruct_arr{1}.save_vars.cell_idx,:)',Y') 
	Y = treebagger_get_predicted(s.derivedDataTSA.valueMatrix(outstruct_arr{1}.save_vars.feat_idx,:), ...
										 outstruct_arr{1}.cross_val_grouped_trees, outstruct_arr{1}.treebagger_call_params);
	plot(Y,'g-');
	corr(s.caTSA.caPeakTimeSeriesArray.valueMatrix(outstruct_arr{1}.save_vars.cell_idx,:)',Y') 
end

if (0) % encoder ... individual
	figure ; 
	plot(s.caTSA.caPeakTimeSeriesArray.valueMatrix(outstruct_arr{1}.save_vars.cell_idx,:));
	hold on;
	for f=1:length(outstruct_arr{1}.save_vars.feat_idx)
		Y = treebagger_get_predicted(s.derivedDataTSA.valueMatrix(outstruct_arr{1}.save_vars.feat_idx(f),:), ...
											 outstruct_arr{1}.full_ind_trees(f), outstruct_arr{1}.treebagger_call_params);
%		plot(Y,'r-');
		cg = corr(s.caTSA.caPeakTimeSeriesArray.valueMatrix(outstruct_arr{1}.save_vars.cell_idx,:)',Y') ;
		Y = treebagger_get_predicted(s.derivedDataTSA.valueMatrix(outstruct_arr{1}.save_vars.feat_idx(f),:), ...
											 outstruct_arr{1}.cross_val_ind_trees(f,1,:), outstruct_arr{1}.treebagger_call_params);
%		plot(Y,'g-');
		ccv = corr(s.caTSA.caPeakTimeSeriesArray.valueMatrix(outstruct_arr{1}.save_vars.cell_idx,:)',Y') ;

		disp([outstruct_arr{1}.save_vars.feat_name_list{f} ': ' num2str(cg) ' ' num2str(ccv)]);
	end
end

if (1) % decoder`
	figure ; 
	Yo = s.derivedDataTSA.valueMatrix(outstruct_arr{1}.save_vars.feat_idx,:);
	plot(Yo);
	hold on;
	Y = treebagger_get_predicted(s.caTSA.caPeakTimeSeriesArray.valueMatrix(outstruct_arr{1}.save_vars.cell_idx,:), ...
										 outstruct_arr{1}.full_grouped_trees, outstruct_arr{1}.treebagger_call_params);
	plot(Y,'r-');
  val = intersect(find(~isnan(Yo)), find(~isnan(Y)));
	cg = corr(Yo(val)', Y(val)');
	Y = treebagger_get_predicted(s.caTSA.caPeakTimeSeriesArray.valueMatrix(outstruct_arr{1}.save_vars.cell_idx,:), ...
										 outstruct_arr{1}.cross_val_grouped_trees, outstruct_arr{1}.treebagger_call_params);
	plot(Y,'g-');
  val = intersect(find(~isnan(Yo)), find(~isnan(Y)));
	ccv = corr(Yo(val)', Y(val)');
	disp([outstruct_arr{1}.save_vars.feat_name_list ': ' num2str(cg) ' ' num2str(ccv)]);
end

if (0) % decoder` indiv
	figure ; 
	Yo = s.derivedDataTSA.valueMatrix(outstruct_arr{1}.save_vars.feat_idx,:);
	plot(Yo);
	hold on;

	for c=1:length(outstruct_arr{1}.save_vars.cell_idx)
	  ci = outstruct_arr{1}.save_vars.cell_idx(c);
		Y = treebagger_get_predicted(s.caTSA.caPeakTimeSeriesArray.valueMatrix(ci,:), ...
											 outstruct_arr{1}.full_ind_trees(c), outstruct_arr{1}.treebagger_call_params);
%		plot(Y,'r-');
		val = intersect(find(~isnan(Yo)), find(~isnan(Y)));
		cg = corr(Yo(val)', Y(val)');
		Y = treebagger_get_predicted(s.caTSA.caPeakTimeSeriesArray.valueMatrix(ci,:), ...
											 outstruct_arr{1}.cross_val_ind_trees(c,:,:), outstruct_arr{1}.treebagger_call_params);
%		plot(Y,'g-');
		val = intersect(find(~isnan(Yo)), find(~isnan(Y)));
		ccv = corr(Yo(val)', Y(val)');
		disp([outstruct_arr{1}.save_vars.feat_name_list ' cell ' num2str(s.caTSA.ids(ci)) ' : ' num2str(cg) ' ' num2str(ccv)]);
	end
end

