function roialign_fix (broken_fname, new_template_date)
  
  un_idx = find(broken_fname == '_');
	fov_idx = strfind(broken_fname, 'fov_');
	date_start_idx = strfind(broken_fname, '2012_');
	date_end_idx = date_start_idx + 9;
	broken_date = broken_fname(date_start_idx:date_end_idx);

  new_template_fname = strrep(broken_fname, broken_date, new_template_date);
	fov_id = broken_fname(fov_idx+4:end);

	fl = dir (['*based*' fov_id '*']);

	% load 
	load(broken_fname) ;
	rBroken = obj;

	load(new_template_fname) ;
	rNewTemplate = obj;

	load(fl(1).name);
  rOriginalTemplate = obj;

  % do
	rNew = roi.roiArray();
	rNew.masterImage = rBroken.masterImage;
	roi.roiArray.findMatchingRoisInNewImage(rNewTemplate,rNew);

	% plot
	close all;
	rOriginalTemplate.plotInterdayTransform(rBroken);
	set(gcf,'Name', [broken_fname ' before'], 'Units', 'Normalized', 'Position' , [0 0 1 1]);
	rOriginalTemplate.plotInterdayTransform(rNew);
	set(gcf,'Name', [broken_fname ' after'], 'Units', 'Normalized', 'Position' , [0 0 1 1]);

	% Save?
	disp ('If you like what you see hit any key ; if not, CTRL-C to preclude save');
	disp(broken_fname);
	pause;
 	rNew.saveToFile(broken_fname);


	
