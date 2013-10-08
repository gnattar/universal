%
% S Peron 2010 May
%
% This will go thru all directories specified in dirList and, using the rois
%  in the calling roiArray object, construct new roiArrays with 
%  findMatchingRoisInNewImage.  The new roiArray will have idStr set either
%  to what is passed or, if it is blank, it will simply go and find the
%  string [filesep 'an'], and go from there until the next filesep, assuming
%  you have directories like an38596/2010_02_03; then the id for that would
%  be an38596_2010_02_03.
%
% Usage: obj.generateDerivedRoiArrays(dirList, idStr, outputPath)
%
% Params: dirList: either a list of directories or, if a string containing a
%                  '%' character, it will parse with get_fluo_dirs_from_wc.m
%         idStr: the idStr for the new roiArray 
%         outputPath: directory where all stuff is stored ; each roiArray ends
%                     up in [outputPath filesep idStr '.mat']
%
function generateDerivedRoiArrays(obj, dirList, idStr, outputPath)
  % --- dir list
	if (~ iscell(dirList) & length(strfind(dirList,'%')) > 0)
	  dirList = get_fluo_dirs_from_wc(dirList);
	end

	% --- id str extract
	if (~ iscell(dirList)) ; dirList = {dirList} ; end
	if (length(idStr) == 0)
	  for d=1:length(dirList)
		  anidx = strfind(dirList{d}, [filesep 'an']);
			fsi = strfind(dirList{d},filesep);
			fsi = fsi(min(find(fsi > anidx))+1);
      dstr = dirList{d}(anidx+1:fsi-1);
			dstr = strrep(dstr,filesep,'_');
		  idStr{d} = dstr;
		end
	end

	% --- go thru 
	for d=1:length(dirList)
	  % filenames
		masterImregFile = [dirList{d} 'session_mean.tif'];
	  outFile = [outputPath filesep idStr{d} '.mat'];

	  % do the files exist?
		if(exist(masterImregFile,'file') == 2)
		  disp(['Processing ' dirList{d}]);
		  if (exist(outFile,'file') == 2)
			  disp(['generateDerivedRoiArrays::' outFile ' already exists ; move/delete it to overwrite']);
			else % GO for it!
			  rA_s = roi.roiArray();
				rA_s.idStr = idStr{d};
				rA_s.masterImage = masterImregFile;
				obj.findMatchingRoisInNewImage(obj, rA_s); % with default settings
        rA_s.saveToFile(outFile,1);
			end
		else 
		  disp(['generateDerivedRoiArrays::no master_imreg_image.tif file found in ' dirList{d}]);
		end
	end

