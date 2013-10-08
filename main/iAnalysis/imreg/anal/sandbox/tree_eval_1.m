load decoder_feat_Whisker_setpoint_roi_individual_all_trees

Y = zeros(197,14752);
for i=1:197 ; disp(num2str(i)) ; Y(i,:) = treebagger_get_predicted(outstruct_arr{1}.treebagger_par_execute_params.X(i,:), outstruct_arr{1}.cross_val_ind_trees(i,:,:), outstruct_arr{1}.treebagger_call_params); end

c2vec = s.derivedDataTSA.getTimeSeriesByIdStr('Whisker setpoint');

for i=1:197
  val = find(~isnan(c2vec.value) & ~isnan(Y(i,:)));
  cv = corr(c2vec.value(val)', Y(i,val)');
	disp(['ROI : ' num2str(i) ' corr: ' num2str(cv)]);
end



