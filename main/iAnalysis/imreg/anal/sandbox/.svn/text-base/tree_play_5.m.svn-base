% decoder individual data compiler
function tree_play_5(v)
  if (0) % an166555
		% load session
		load ('an166555_2012_04_23_sess.mat');

		% process trees
	  base_dir = '/data/tree_out/tree_touchwhisk_an166555/output_files/';
	  tree_files = dir([base_dir '*mat']);
		allR = {};
		varName = {};
		for f=1:length(tree_files)
			[aR vName] = process_single_file([base_dir tree_files(f).name], s);
			allR{f} = aR;
			varName{f} = vName;
		end
		save(sprintf('tree_output_an166555_vol_%02d.mat', 1), 'allR', 'varName');
	end

  if (0) % an166558
		% load session
		load ('an166558_2012_04_23_sess.mat');

		% process trees
	  base_dir = '/data/tree_out/tree_touchwhisk_an166558/output_files/';
	  tree_files = dir([base_dir '*mat']);
		allR = {};
		varName = {};
		for f=1:length(tree_files)
			[aR vName] = process_single_file([base_dir tree_files(f).name], s);
			allR{f} = aR;
			varName{f} = vName;
		end
		save(sprintf('tree_output_an166558_vol_%02d.mat', 1), 'allR', 'varName');
	end


  if (1) % an160508
%	  for v=[1 2 3 4 5 10]
%	  for v=[6 7 8 9 11]
			% load session
			load (sprintf('an160508_vol_%02d_sess.mat', v));

			% process trees
		  base_dir = sprintf('/data/tree_out/tree_touchwhisk_an160508_%02d/output_files/', v);
		  tree_files = dir([base_dir '*mat']);
			allR = {};
			varName = {};
			for f=1:length(tree_files)
				[allR{f} varName{f}] = process_single_file([base_dir tree_files(f).name], s);
			end
			save(sprintf('tree_output_an160508_vol_%02d.mat', v), 'allR', 'varName');
%		end
	end

% plot it . . . 

% L1: first 2 [0 1999]

% L5: 29-33 [29000 40000]

% L23: 3-18: [2000 18999]

%ax=figure_tight;
%s.plotColorRois('', '', [], [0 1 0], allR, [0 1], ax, 0); 

function [allR varName] = process_single_file(tree_out_file, s)
  load(tree_out_file);

	% pull some basix
	Yo = outstruct_arr{1}.treebagger_par_execute_params.Y;
	Xo =  outstruct_arr{1}.treebagger_par_execute_params.X;
	varName = outstruct_arr{1}.save_vars.feat_name_list;

	% compute R for each cell
	R = 0*outstruct_arr{1}.save_vars.cell_idx;
	for c=1:length(outstruct_arr{1}.save_vars.cell_idx)
		ci = outstruct_arr{1}.save_vars.cell_idx(c);
		Y = treebagger_get_predicted(Xo(c,:), ...
											 outstruct_arr{1}.cross_val_ind_trees(c,:,:), outstruct_arr{1}.treebagger_call_params);
		val = intersect(find(~isnan(Yo)), find(~isnan(Y)));
		R(c)= corr(Yo(val)', Y(val)');
		disp([outstruct_arr{1}.save_vars.feat_name_list ' cell ' num2str(outstruct_arr{1}.save_vars.cell_id_list(c)) ' : ' num2str(R(c)) ]);
	end

	% convert to fov indexing
	allR = 0*s.caTSA.ids;
	allR(outstruct_arr{1}.save_vars.cell_idx) = R;

