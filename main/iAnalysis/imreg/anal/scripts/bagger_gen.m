%
% For kicking off bagger 
%
function bagger_gen()
  % base data path
	if (strcmp(computer, 'GLNXA64'))
    basePath = '/media/';
	elseif (strcmp(computer,'MACI64'))
		basePath = '/Volumes/';
	else
	  disp('Unrecognized computer.');
	  return;
	end

	% cluster?
	on_cluster = 0;
	[irr hname] = system('hostname');
	if (strfind(hname, 'int.janelia.org'))
	  on_cluster = 1;
		basePath = '/groups/svoboda/wdbp/tree/perons/';
	end

  s = [];
	dsp = {};
	doAnimal = {'160508'};
%	doAnimal = {'160508_beh'};
%	doAnimal = {'161322_beh'};
%	doAnimal = {'163522_beh'};
	doAnimal = {'166555','166558'};
	doAnimal = {'167951'};
	doAnimal = {'171923','160508'};
	doAnimal = {'167951','171923','160508'};

	%% --- 167951
	di = find(strcmp(doAnimal, '167951'));
  if (sum(di) > 0)
	  if (~on_cluster) ; basePath = '/data/'; end
		an = doAnimal{di};
		vols = 1:16;

		baseAnDir = [basePath 'an' an 'a' filesep];
		if(on_cluster) ; baseAnDir = [basePath 'an' an filesep]; end
		sessDir = [baseAnDir 'session_merged' filesep];


		for v=1:length(vols)
			pargenDir = sprintf('%s%ctree_parfiles%can%s_vol_%02d%c', baseAnDir, filesep, filesep, an, vols(v), filesep);
			mkdir(pargenDir);

      cd (sessDir);
		  pargen_single([sessDir 'an' an '_vol_' sprintf('%02d',vols(v)) '_sess.mat'], pargenDir);
		end
  end

	%% --- 160508
	di = find(strcmp(doAnimal, '160508'));
  if (sum(di) > 0)
		an = doAnimal{di};
		vols = 1:11;

		baseAnDir = [basePath 'an' an 'b' filesep];
		if(on_cluster) ; baseAnDir = [basePath 'an' an filesep]; end
		sessDir = [baseAnDir 'session_merged' filesep];


		for v=1:length(vols)
			pargenDir = sprintf('%s%ctree_parfiles%can%s_vol_%02d%c', baseAnDir, filesep, filesep, an, vols(v), filesep);
			mkdir(pargenDir);

      cd (sessDir);
		  pargen_single([sessDir 'an' an '_vol_' sprintf('%02d',vols(v)) '_sess.mat'], pargenDir);
		end
  end

	%% --- 171923
	di = find(strcmp(doAnimal, '171923'));
  if (sum(di) > 0)
		an = doAnimal{di};
		vols = 1:16;

		baseAnDir = [basePath 'an' an 'a' filesep];
		if(on_cluster) ; baseAnDir = [basePath 'an' an filesep]; end
		sessDir = [baseAnDir 'session_merged' filesep];

		for v=1:length(vols)
			pargenDir = sprintf('%s%ctree_parfiles%can%s_vol_%02d%c', baseAnDir, filesep, filesep, an, vols(v), filesep);
			mkdir(pargenDir);

      cd (sessDir);
		  pargen_single([sessDir 'an' an '_vol_' sprintf('%02d',vols(v)) '_sess.mat'], pargenDir);
		end
  end

%
% generates parfiles for a single bagger iteration
%
function pargen_single(sess_path, par_out_path)
  load(sess_path);
  
	roiIds = s.caTSA.ids;

	%% --- prep work 

	% get punishment trials -- these are to be omitted
	punTrials = [];
	punES = s.behavESA.getEventSeriesByIdStr('Punishment');
	if (length(punES) > 0)
	  if (~iscell(punES)) ; punES = {}; end
		for e=1:length(punES)
		  punTrials = union(punTrials, punES{e}.eventTrials);
		end
	end

	% validTrialIds -- use to implement punishment trial restriction
	s.validTrialIds = setdiff(s.validTrialIds, punTrials);
	s.caTSA.deleteTrials(punTrials, 1);
	s.derivedDataTSA.deleteTrials(punTrials);

	disp(['bagger_gen::for ' sess_path ' using ' num2str(length(s.validTrialIds)) ...
	      ' trials (excluding ' num2str(length(punTrials)) ' punishment trials).']);
	
	%% --- Whisking

	% straight decoder
	clear treeBaggerParams;
	treeBaggerParams.roiIdList = roiIds;
	treeBaggerParams.featureIdList = [10000 10010 10020 10021];
	treeBaggerParams.filePerCell = 1;
	treeBaggerParams.runModes = [0 0 0 0 1 0 0];
	s.setupTreeBaggerPar(par_out_path,treeBaggerParams, s.caTSA.eventBasedDffTimeSeriesArray);
	
	%% --- Touch

  % straight decoder
	clear treeBaggerParams;
	treeBaggerParams.roiIdList = roiIds;
	treeBaggerParams.featureIdList = [20001 20011 20021 20031 21010 21011 21012];
	treeBaggerParams.runModes = [0 0 0 0 1 0 0];
	treeBaggerParams.typeVec = [0 0 0 0 1 1 1];
	treeBaggerParams.filePerCell = 1;
	s.setupTreeBaggerPar(par_out_path,treeBaggerParams, s.caTSA.eventBasedDffTimeSeriesArray);

	% double decoder
	clear treeBaggerParams;
	treeBaggerParams.roiIdList = roiIds;
	treeBaggerParams.featureIdList2Step{1} = [20001 20011 20021 20031];
	treeBaggerParams.featureIdList2Step{2} = [21010 21011 21012];
	treeBaggerParams.runModes = [0 0 0 0 0 0 1];
	treeBaggerParams.typeVec2Step{1} = [0 0 0 0];
	treeBaggerParams.typeVec2Step{2} = [1 1 1];
	s.setupTreeBaggerPar(par_out_path,treeBaggerParams, s.caTSA.eventBasedDffTimeSeriesArray);

	%% --- Licking

  % straight decoder
	clear treeBaggerParams;
	treeBaggerParams.roiIdList = roiIds;
	treeBaggerParams.featureIdList = [30001 30002 30000 30003];
	treeBaggerParams.runModes = [0 0 0 0 1 0 0];
	treeBaggerParams.filePerCell = 1;
	s.setupTreeBaggerPar(par_out_path,treeBaggerParams, s.caTSA.eventBasedDffTimeSeriesArray);

	%% --- Reward

  % straight decoder
	clear treeBaggerParams;
	treeBaggerParams.roiIdList = roiIds;
	treeBaggerParams.featureIdList = [50001 50002 50000 50005];
	treeBaggerParams.runModes = [0 0 0 0 1 0 0];
	treeBaggerParams.typeVec = [1 1 1 1];
	treeBaggerParams.filePerCell = 1;
	s.setupTreeBaggerPar(par_out_path,treeBaggerParams, s.caTSA.eventBasedDffTimeSeriesArray);

	%% --- (Punishment -- will not be here)

	%% --- Pole Movement

  % straight decoder
	clear treeBaggerParams;
	treeBaggerParams.roiIdList = roiIds;
	treeBaggerParams.featureIdList = [40001 40002 40000];
	treeBaggerParams.runModes = [0 0 0 0 1 0 0];
	treeBaggerParams.typeVec = [1 1 1];
	treeBaggerParams.filePerCell = 1;
	s.setupTreeBaggerPar(par_out_path,treeBaggerParams, s.caTSA.eventBasedDffTimeSeriesArray);

	%% --- "Higher" category stuff

  % straight decoder
	clear treeBaggerParams;
	treeBaggerParams.roiIdList = roiIds;
	treeBaggerParams.featureIdList = [60000 60100 60200 60300 60400 60500 60600 60002 60003 60004];
	treeBaggerParams.runModes = [0 0 0 0 1 0 0];
	treeBaggerParams.typeVec = [1 1 1 1 1 1 1 0 0 0];
	treeBaggerParams.filePerCell = 1;
	s.setupTreeBaggerPar(par_out_path,treeBaggerParams, s.caTSA.eventBasedDffTimeSeriesArray);


