%
% Saves to file ; static
%
% dataFormat -- 1: redundant -- use object model
%               2: roi structure
%               3: rtrk structure
%
function saveToFile(obj, outputPath, dataFormat)

  % --- defaults
	if (nargin == 1)
	  outputPath = '';
  end
	if (nargin <= 2)
		dataFormat = 1;
	end

  % --- invoke GUI if the output path is blank, a directory
	if (length(outputPath) == 0)
		% go to appropriate directory
		cwd = pwd();
		% dialog
	  [pathstr name ext] = fileparts(obj.roiFileName);
		if (isdir(pathstr)) ; cd (pathstr); else ; global rootDataPath ; cd(rootDataPath) ; end
		[filename, pathname, filt] = ... 
			uiputfile({'*.mat'}, 'Save ROI data to file', 'ROI.mat');
		outputPath = [pathname filesep filename];
		% return to previous directory
		cd(cwd);
	elseif (isdir(outputPath))
		% go to appropriate directory
		cwd = pwd();
		% dialog
		cd (outputPath);
		[filename, pathname, filt] = ... 
			uiputfile({'*.mat'}, 'Save ROI data to file', 'ROI.mat');
		% return to previous directory
		outputPath = [pathname filesep filename];
		cd(cwd);
	end

  % --- sanity
	if (strcmp(outputPath, filesep )) ; disp('No filename to save to; aborting.'); return ; end
	if (length(strtrim(strrep(outputPath,filesep,''))) < 3)
	  disp('No filename to save to; aborting.'); return ; 
	end

  % --- dataformat based switch

	% store new roi filen ame
	obj.roiFileName = outputPath;
  
	switch dataFormat
		case 1
			save(outputPath, 'obj');
		case 2
			n_rois = length(obj.rois);
			for r=1:length(obj.rois)
				roi(r).color = obj.rois{r}.color;
				roi(r).corners = obj.rois{r}.corners;
				roi(r).n_corners = length(obj.rois{r}.corners);
				roi(r).indices= obj.rois{r}.indices;
				roi(r).poly_indices = obj.rois{r}.borderIndices;
				roi(r).raw_fluo = [];
				roi(r).groups= obj.rois{r}.groups;
				roi(r).misc_vals = [];
			end
			save(outputPath, 'roi', 'n_rois');
		case 3
			n_rois = length(obj.rois);
			for r=1:length(obj.rois)
				roi(r).color = obj.rois{r}.color;
				roi(r).corners = obj.rois{r}.corners;
				roi(r).n_corners = length(obj.rois{r}.corners);
			end
			extern_roi2rtrk(roi, outputPath);
	end

  disp(['roiArray.saveToFile::wrote ' outputPath]);
