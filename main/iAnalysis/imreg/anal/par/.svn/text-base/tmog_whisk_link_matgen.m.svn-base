%
% SP Oct 2011
%
% Script that will
%  1) build barTemplate.mat and batchParameters.mat for a directory
%  2) generate all parfiles for a directory -- INSIDE THAT DIRECTORY
%
% Note that a ready_for_prelink file must exist in the directory for this to
%  work; otherwise it is assumed something is wrong or linking was done.
%
function tmog_whisk_link_matgen(dirname)
  % check for ready_for_prelink -- delete it
	if (~exist([dirname filesep 'ready_for_prelink'], 'file'))
	  disp(['Skipping ' dirname ' -- no ready_for_prelink.']);
		return;
	end
	delete([dirname filesep 'ready_for_prelink']);

  % generate barTemplate.mat, batchParameters.mat
	generateMatFiles(dirname);

	% generate parfiles...
	parfileDirname = [dirname filesep 'parfiles'];
	mkdir(parfileDirname);
	session.whiskerTrial.generateParFiles([dirname filesep '*whiskers'], parfileDirname);

	% touch ready
	fid = fopen([parfileDirname filesep 'ready_for_linking'], 'w+');
	fclose(fid);


function generateMatFiles(dirname)

  % --- read XML
	fl = dir([dirname filesep '*seq.xml']);
  xml_path = [dirname filesep fl(1).name];

	fid = fopen(xml_path,'r');
	fseek(fid,0,1); file_size = ftell(fid);
	fseek(fid,0,-1) ; file_content = char(fread(fid,file_size))';
	fclose(fid);
 
  % read in file
	tag = {'min_whisker_length','whiskers_present','max_follicle_y', ...
	       'kappa_position','bar_template_trial','bart_frame_number','bart_center', ...
				 'bart_wh', 'polynomial_max_follicle_y','polynomial_distance_from_face', ...
				 'polynomial_offset'};
	for t=1:length(tag)
	  ts = strfind(file_content,['<' tag{t} '>']) + length(tag{t}) + 2;
	  te = strfind(file_content,['</' tag{t} '>']) - 1;
		text{t} = file_content(ts:te);
	end

	% --- barTemplate.mat
	mp4fl = dir([dirname filesep '*mp4']);
  tn = str2num(text{find(strcmp(tag,'bar_template_trial'))});
	wc = sprintf('%04d_20', tn); % will work until 2099...
	fi = 0;
	for f=1:length(mp4fl)
	  if (length(strfind(mp4fl(f).name, wc)))
		  fi = f;
		end
	end
	if (fi == 0 ) ; return ; end % sanity!

	mp4fp = [dirname filesep mp4fl(fi).name];
	whfp = strrep(mp4fp, 'mp4','whiskers');
%if (length(wt) == 0) %~sum(cell2mat(strfind(fieldnames(wt),'frames'))))
%disp('igno')
	wt = session.whiskerTrial(1,whfp, mp4fp);
%end

	frameNum = str2num(text{find(strcmp(tag,'bart_frame_number'))});
  wt.loadMovieFrames(frameNum);

	monoIm = wt.whiskerMovieFrames{frameNum}.cdata;

	% rectangle ... center
	rcStr = text{find(strcmp(tag,'bart_center'))};
	cidx = find(rcStr == ',');
	rc = [str2num(rcStr(1:cidx-1)) str2num(rcStr(cidx+1:end))];

  % width/height
	whStr = text{find(strcmp(tag,'bart_wh'))};
	cidx = find(whStr == ',');
	wh = [str2num(whStr(1:cidx-1)) str2num(whStr(cidx+1:end))];

	% polynomial distance from face (2 values)
	pdffStr = text{find(strcmp(tag,'polynomial_distance_from_face'))};
	cidx = find(pdffStr == ',');
	pdff = [str2num(pdffStr(1:cidx-1)) str2num(pdffStr(cidx+1:end))];

	% pull it ...
	barTemplateIm = monoIm(round(rc(2)-wh(2)/2):round(rc(2)+wh(2)/2), ...
	                       round(rc(1)-wh(1)/2):round(rc(1)+wh(1)/2)); 

  % detect the bar center and radius
	maxRad = floor(min(wh(1)/3, wh(2)/3));
  [barCenter barRadius] = session.whiskerTrial.determineBarCenterAndRadiusForTemplate([2 maxRad], barTemplateIm, 1);

  % write ... ONLY if not already present
	if (~exist([dirname filesep 'barTemplate.mat'], 'file'))
  	save([dirname filesep 'barTemplate.mat'] , 'barCenter', 'barRadius', 'barTemplateIm');
	else
	  disp('tmog_whisk_link_matgen::skipping generation because barTemplate.mat is already there; delete if you want to generate de novo.');
	end

	% --- batchParameters.mat

  % name and # of whiskers
	wpStr = text{find(strcmp(tag,'whiskers_present'))};
	cidx = [0 find(wpStr == ',') length(wpStr)+1];
	whiskerTag = {};
	for c=1:length(cidx)-1
	  whiskerTag{c} = wpStr(cidx(c)+1:cidx(c+1)-1);
	end
  numWhiskers = length(whiskerTag);

	
  kappaPosition = str2num(text{find(strcmp(tag,'kappa_position'))});
  maxFollicleY = str2num(text{find(strcmp(tag,'max_follicle_y'))});
  polynomialFitMaxFollicleY = str2num(text{find(strcmp(tag,'polynomial_max_follicle_y'))});
  polynomialOffset = [ 0 0 str2num(text{find(strcmp(tag,'polynomial_offset'))})];
	minWhiskerLength = str2num(text{find(strcmp(tag,'min_whisker_length'))});

  % dependent semi-preset
	polynomialFitMaxFollicleY = maxFollicleY+10;

	% barFractionTrajectoryInReach, other presets (i.e., 'hard' values)
	barFractionTrajectoryInReach = 1;
	barInReachParameterUsed=3;
	kappaPositionType = 4;
  polynomialDistanceFromFace = pdff;
  positionDirection = -1;
	thetaPosition = 0;
	thetaPositionType = 1;

  % write ... ONLY if not already present
	if (~exist([dirname filesep 'batchParameters.mat'], 'file'))
		save ([dirname filesep 'batchParameters.mat'], 'numWhiskers', 'minWhiskerLength', 'maxFollicleY', 'positionDirection',...
			'polynomialDistanceFromFace', 'polynomialFitMaxFollicleY', 'kappaPositionType', ...
			'kappaPosition', 'thetaPositionType', 'thetaPosition', 'barFractionTrajectoryInReach', ...
			'barInReachParameterUsed', 'whiskerTag', 'polynomialOffset');
	else
	  disp('tmog_whisk_link_matgen::skipping generation because batchParameters.mat is already there; delete if you want to generate de novo.');
	end

  
