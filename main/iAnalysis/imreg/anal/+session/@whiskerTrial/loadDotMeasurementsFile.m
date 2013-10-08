%
% SP 2010 Oct
% 
% Wrapper using Nathan's (modified) code to load a .measurements file.  It will 
%  thereby assign whiskerData.whiskerId as well as the 2nd column of 
%  positionMatrix.
%
% USAGE:
%  wt.loadDotMeasurementsFile(obj, measurementsFilePath)
%
%  measurementsFilePath: the file in questino ; if blank, it will try basePathName .measurements in pwd.
function obj = loadDotMeasurementsFile(obj, measurementsFilePath)
	% user input
	if (nargin < 2)
	  measurementsFilePath = [obj.basePathName '.measurements'];
	end
	  
  if (obj.messageLevel >= 1) ; disp(['loadDotMeasurementsFile::loading ' measurementsFilePath ' ; note that this will RESET whiskerIds.']); end
  obj.enableWhiskerData();

	% --- file read code -- FROM NATHAN CLACK!!
  % open the file
	fid = fopen( measurementsFilePath, 'rb' );
	try
		% check format signature
		esig = 'measV1';
		sig = fread(fid,8,'uint8=>char')';
		assert( strncmp(esig, sig, length(esig) ), ['Wrong format for measurements file: ',measurementsFilePath]);

		% read dimensions and alloc
		nrows = fread(fid,1,'int32');
		nmeas = fread(fid,1,'int32');

		M = zeros( nrows, nmeas+3 );

		% read in row by row
		for i=1:nrows,
			[row,count] = fread(fid,10,'int32');
			assert( count==10, ['Could not read the measurements file: ',measurementsFilePath] );
			M(i,1:3) = row( [4 2 3] );
			[data,count] = fread(fid, nmeas, 'float64');
			assert( count==nmeas, ['Could not read the measurements file: ',measurementsFilePath] );
			M(i,4:end) = data;
			sts = fseek( fid, nmeas*8, 'cof' );
			assert(sts==0, ['Could not read the measurements file: ',measurementsFilePath] );
		end
		fclose(fid);
	catch ME
		fclose(fid);
		rethrow(ME);
	end

	% --- post-processing - all I care about is column 1, 2 and 3
	whiskerIds = M(:,1)+1; % For Nathan, -1 is 'invalid/unassigned', which is 0 for me; for Nathan, >= 0 is good, for me, > 0 is good
  frameId = M(:,2)+1; % Nathan starts at 0 ; I start @ 1
	segIds = M(:,3);

	% loop thru whiskerData
	for f=1:obj.numFrames
	  mi = find(frameId == f);
		pmi = find(obj.positionMatrix(:,1) == f);
	  for w=1:length(obj.whiskerData(f).whisker)
		  si = find(segIds(mi) == obj.whiskerData(f).originalSegId(w));
			obj.whiskerData(f).whiskerId(w) = whiskerIds(mi(si));
			obj.positionMatrix(pmi(w),2) = whiskerIds(mi(si)); 
		end
	end



