%
nids = [201 121 485 263 28 57 30 411 413 415];
fids = 61:64;

% decoder (predict env variable from neuronal activity)
if (1)
  X = s.caTSA.caPeakTimeSeriesArray.valueMatrix;
  Y = s.derivedDataTSA.valueMatrix;

  params.temporal_shifts = -0;
	params.verbose = 1;
	params.do_individual = 1;
  params.cross_validation_trial_vec = s.caTSA.trialIndices;

	[full_ind_trees cross_val_ind_trees full_grouped_trees cross_val_grouped_trees params] = treebagger_call(X(nids,:),Y(fids,:),[],params);
  [Xx Yy] = treebagger_prep_matrices(X(nids,:),Y(fids,:), params);
end

if (1)
  % prep cross-val matrices
	all_indices = 1:size(X,2);
	test_indices = cell(1,params.nfold_cross_validation);
	for i=1:params.nfold_cross_validation
		test_indices{i} = find(params.cv_test_label == i);
	  [Xv_test{i} Yv_test{i}] = treebagger_prep_matrices(X(nids, test_indices{i}), Y(fids, test_indices{i}), params);
	end

  disp('======================================================================================')
	disp(['temporal shifts: ' num2str(params.temporal_shifts)]);
  n_shifts = max(1,length(params.temporal_shifts));
	if (0)
		% score individuals
		for f=1:length(fids)
			for n=1:length(nids)
				x_rows = (1:n_shifts) + (n-1)*n_shifts;
				y_pred = predict(full_ind_trees{n,f},Xx(x_rows,:)'); 
				val = find(~isnan(Y(fids(f),:)));
				disp(['Feature: ' num2str(fids(f)) ' Neuron: ' num2str(nids(n)) ...
				      ' Pears: ' num2str(corr(y_pred(val),Y(fids(f),val)')) ' Spear: ' num2str(corr(y_pred(val),Y(fids(f),val)', 'type', 'Spearman'))]); 

	  		% cross validated 
		  	y_pred = 0*all_indices';
			  for i=1:params.nfold_cross_validation
  			  y_pred(test_indices{i}) = predict(cross_val_ind_trees{n,f,i}, (Xv_test{i}(x_rows,:))');
  			end
  			val = find(~isnan(Y(fids(f),:))); 
				disp(['Feature: ' num2str(fids(f)) ' Neuron: ' num2str(nids(n)) ...
  			      ' Cross-Val Pears: ' num2str(corr(y_pred(val),Y(fids(f),val)')) ' Spear: ' num2str(corr(y_pred(val),Y(fids(f),val)', 'type', 'Spearman'))]); 

			end
		end
	end

  if (1)
		% score pop
		for f=1:length(fids)
			y_pred = predict(full_grouped_trees{f},Xx'); 
			val = find(~isnan(Y(fids(f),:))); 
%			disp(['Feature: ' num2str(fids(f)) ' All Neurons' ...
%			      ' Pears: ' num2str(corr(y_pred(val),Y(fids(f),val)')) ' Spear: ' num2str(corr(y_pred(val),Y(fids(f),val)', 'type', 'Spearman'))]); 

			% cross validated 
			y_pred = 0*all_indices';
			for i=1:params.nfold_cross_validation
			  y_pred(test_indices{i}) = predict(cross_val_grouped_trees{f,i}, (Xv_test{i})');
			end
			val = find(~isnan(Y(fids(f),:))); 
			disp(['Feature: ' num2str(fids(f)) ' All Neurons' ...
			      ' Cross-Val Pears: ' num2str(corr(y_pred(val),Y(fids(f),val)')) ' Spear: ' num2str(corr(y_pred(val),Y(fids(f),val)', 'type', 'Spearman'))]); 
		end
	end
end
