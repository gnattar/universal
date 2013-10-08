%
% Static method for registering a roiArray masterImage to a stack.
%
% USAGE:
%
%   roi.roiArray.registerToRefStackS(refStackPath, roiArrays, params)
%
% ARGUMENTS:
%
%   refStackPath: full path of the refStack (tif) to use.  NOTE: if you pass
%                 params.preprocessedVimPath, this will not be loaded.
%   roiArrays: single roiArray object, path thereof, or cell array of objects
%              or paths ; it will update objects. It is up to you of course
%              to then save the objects.  refStackRelPath and refStackMap get
%              assigned to each.
%   params: structure with some optional variables (* means required)
%     *params.guessZ: for each roiArrays, guess z in stack
%      params.fpvParams: params structure for fit_all_planes_to_vol_warpfield;
%                         see that method for details.
%      params.rootOutName: root output name to use for temp files ; see 
%                          fit_all_planes_to_vol_warpfield.  FULL PATH or it 
%                          gets dropped in pwd
%      params.preprocessedVimPath: if you already processed vim sometime and 
%                                  have a .MAT file with the vim variable in 
%                                  it, put the file's path here.
%
function registerToRefStackS (refStackPath, roiArrays, params)

  %% --- input handling
  if (nargin < 3)
	  help('roi.roiArray.registerToRefStackS');
		error('Must pass all arguments.');
	end
 
	% first, what kind of roiArray was passed?
	if (isobject(roiArrays)) % straight object? wrap it
	  roiArrays = {roiArrays};
	elseif (ischar(roiArrays))
	  load (roiArrays);
		roiArrays = obj;
		roiArrays = {roiArrays};
	elseif (iscell(roiArrays) && ischar(roiArrays{1})) % array of paths? load
	  nra = {};
		for r=1:length(roiArrays)
		  load(roiArrays{r});
			nra{r} = obj;
		end
		roiArrays = nra;
	end

	% params struct handling
	rootOutName = [pwd filesep 'registerToRefStack_data'];
	evalStr = assign_vars_from_struct(params, 'params', 'guessZ');
	eval(evalStr);
	if (~exist('fpvParams','var'))
		fpvParams.skip_plotting = 1;
	end
	if (length(fileparts(rootOutName)) == 0) ; rootOutName = [pwd filesep rootOutName] ; end

  %% --- calculation

	% load volume
	if (isstruct(params) && isfield(params, 'preprocessedVimPath'))
	  disp('roi.roiArray.registerToRefStackS: not loading volume since you have processed already.');
		vim = params.preprocessedVimPath;
	else
		vim = load_image(refStackPath);
	end

	% assign path
	refStackRelPath = strrep(refStackPath, get_root_data_path, '<%rootDataPath%>');

	% main call
  [X Y Z] = fit_all_planes_to_vol_warpfield(vim, roiArrays, guessZ, rootOutName, fpvParams);
 
  % update roiArray objects
  for r=1:length(roiArrays)
	  roiArrays{r}.refStackRelPath = refStackRelPath;
	  roiArrays{r}.refStackMap.X = X{r};
	  roiArrays{r}.refStackMap.Y = Y{r};
	  roiArrays{r}.refStackMap.Z = Z{r};
	end



	
  
