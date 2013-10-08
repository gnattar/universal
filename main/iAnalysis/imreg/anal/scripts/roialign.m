function roialign ()

if (0)
dates = {'2012_04_30','2012_05_01','2012_05_02','2012_05_03','2012_05_04','2012_05_06', ...
         '2012_05_07','2012_05_08','2012_05_09','2012_05_10','2012_05_11'};
root_dir = '/media/an167951a';
roi_fname = 'an167951_%s_fov_%s.mat';
end

if (1)
dates = {'2012_06_04','2012_06_05','2012_06_06','2012_06_07','2012_06_10', ...
         '2012_06_11','2012_06_12','2012_06_13','2012_06_14','2012_06_15','2012_06_16'};
root_dir = '/media/an171923a';
root_dir = '/Volumes/an171923a';
roi_fname = 'an171923_%s_fov_%s.mat';
end

if (0) % generate
  % roi (basis) files
	cd ([root_dir filesep 'rois']);
  base_fl = dir('*_based_fov_*mat');

  % pull fov from rois
	for f=1:length(base_fl)
		fi = strfind(base_fl(f).name, 'fov_');
		mi = strfind(base_fl(f).name, '.mat');
	  base_fov{f} = base_fl(f).name(fi+4:mi-1);
	end

	% now go thru directories
	for d=1:length(dates)
		sdate =  dates{d};
		sub_fl = dir([root_dir filesep sdate filesep 'scanimage' filesep 'fov_*']);

    clear f;
    fi = {};
	  fov = {};
		base_idx = {};
		parfor f=1:length(sub_fl)
			fi{f} = strfind(sub_fl(f).name, 'fov_');
			fov{f} = sub_fl(f).name(fi{f}+4:end);

			% match fov to base ...
			base_idx{f} = find(strcmp(base_fov, fov{f}));
			if (length(base_idx{f}) > 0)
        run_single (base_fl(base_idx{f}).name, fov{f}, root_dir, sdate, roi_fname);
			end
		end
	end
end

if (1) % evaluate
  clear fov scores base tested;
	si = 1;

  % roi (basis) files
	cd ([root_dir filesep 'rois']);
  base_fl = dir('*_based_fov_*mat');

  % pull fov from rois
	for f=1:length(base_fl)
		fi = strfind(base_fl(f).name, 'fov_');
		mi = strfind(base_fl(f).name, '.mat');
	  base_fov{f} = base_fl(f).name(fi+4:mi-1);
	end

	% now go thru directories
	for d=1:length(dates)
		sdate =  dates{d};
		sub_fl = dir([root_dir filesep sdate filesep 'scanimage' filesep 'fov_*']);

		for f=1:length(sub_fl)
			fi = strfind(sub_fl(f).name, 'fov_');
			fov = sub_fl(f).name(fi+4:end);

			% match fov to base ...
			base_idx = find(strcmp(base_fov, fov));
			if (length(base_idx) > 0)
				masterImagePath = [root_dir filesep sdate '/scanimage/fov_' ...
					fov '/fluo_batch_out/session_mean.tif'];
				testedPath = [pwd filesep sprintf(roi_fname, sdate, fov)];

				if (exist (masterImagePath, 'file'))
				  if (exist(testedPath, 'file'))
            base{si} = base_fl(base_idx).name;
						tested{si} = testedPath;
						si = si+1;
					else
					  disp([testedPath ' not found ; skipping']);
					end
				end
			end
		end
	end

	% parfor loop for eval
	if (~exist('roialign_scores.mat', 'file'))
		scores = -1*ones(1,length(base));
		save('roialign_scores.mat', 'scores', 'base','tested');
	else 
	  load ('roialign_scores.mat');
	end
  
	to_process = find(scores == -1);
	to_process = to_process(randperm(length(to_process)));

	parfor pidx=1:length(to_process)
	  p = to_process(pidx);
	  eval_single(base{p}, tested{p}, p);
	end
end

function eval_single (base_fname, tested_fname, idx)
  disp(['Processing ' tested_fname ' ...']);
  load(base_fname)
	rA = obj;
  load(tested_fname);
	rB = obj;
	score = rA.scoreInterdayTransform(rB);

  lock_path = [pwd filesep 'lock.m'];

	% write to file
	while(exist(lock_path,'file'))
	  disp(['Lock file ' lock_path ' exists ; waiting 5 s']);
		pause(5);
	end

	fid = fopen(lock_path, 'w');
	fclose(fid);

  load('roialign_scores.mat');
  scores(idx) = score;
  save('roialign_scores.mat', 'scores','base','tested');

	delete(lock_path);


function run_single (base_fname, fov_str, root_dir, sdate, roi_fname)
  load(base_fname);
	rA = obj;
	masterImagePath = [root_dir filesep sdate '/scanimage/fov_' ...
			fov_str '/fluo_batch_out/session_mean.tif'];
	outPath = [pwd filesep sprintf(roi_fname, sdate, fov_str)];
	if (exist (masterImagePath, 'file'))
		if (~exist(outPath, 'file'))
		  % init
			rB = roi.roiArray();
			rB.masterImage = masterImagePath;
			roi.roiArray.findMatchingRoisInNewImage(rA,rB);
			[fp fn] = fileparts(outPath);
			rB.idStr = fn;
			rB.saveToFile(outPath);

			% test ...
			nProb = length(rA.getAlignmentOutliers(rB));
			if (nProb > 2)
			  params.method = 'image_grid';
				rB = roi.roiArray();
				rB.masterImage = masterImagePath;
				roi.roiArray.findMatchingRoisInNewImage(rA,rB,params);
				[fp fn] = fileparts(outPath);
				rB.idStr = fn;
				rB.saveToFile(outPath);
			end
		else
			disp([outPath ' already exists ; skipping']);
		end
	end

