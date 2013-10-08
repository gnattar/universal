%
% SP 2010 Aug
% 
% Currently a wrapper that uses Dan's whiskers class to load Nathan's .whiskers .
%  file.  Should eventually be standalone.
%
function obj = loadDotWhiskersFile(obj)
  if (obj.messageLevel >= 1) ; disp(['loadDotWhiskersFile::loading ' obj.dotWhiskersPath ' ; note that this will RESET whiskerData.']); end
  if (obj.messageLevel >= 2) ; disp(['loadDotWhiskersFile::Note that this WHOLE PACKAGE assumes your face is in the top-right, with anterior being to the LEFT.  Notebook D pg. 207 has notes on how to fix this -- should be quick and dirty.']); end
	whiskerData = loadWhiskersFileAsStruct(obj.dotWhiskersPath);
 
  % pull unique whiskerIds
	whiskerIds = [];
	for f=1:length(whiskerData) % loop over frames
		% whiskerIds
    whiskerIds = union(whiskerIds, whiskerData(f).whiskerId);
	end

	% assign whisker Ids
	obj.whiskerIds = sort(whiskerIds,'ascend');

	% data raw
	obj.whiskerData = whiskerData;
  obj.whiskerDataUpdated=1; 

	% frames
	obj.frames = 1:length(obj.whiskerData);
	obj.numFrames = length(obj.whiskerData);

	% frame times: assume 500 Hz 
	obj.frameTimes = (2*obj.frames)-2; 

	% look in file name -- if before 4/12/10, useBadFrameTimes
	try 
  	useBadFrameTimesLastDate = datenum('2010_04_12', 'yyyy_mm_dd');
    dashIdx = find(obj.basePathName == '-'); 
		wtDate = datenum(obj.basePathName(dashIdx(1)+1:dashIdx(2)-1), 'yyyy_mm_dd');
	  if (wtDate <= useBadFrameTimesLastDate) ; obj.useBadFrameTimes() ; end
	catch me % blank catch but I dont want to do error condition checks so this is easy way to do thta
	end


	% assign default movie frames
	for f=1:length(obj.frames)
	  obj.whiskerMovieFrames{f} = [];
	end

	% update positionMatrix?
	if (length(obj.positionMatrix) > 0)
	  obj.updatePositionMatrix();
	end

%
% Reads as struct -- different thatn Whisker.load_whiskers_file, but hopefully
%  much faster.  Shamelessly lifted from DHO ;)
%
function whiskerData = loadWhiskersFileAsStruct(wFilePath)
  % sanity
	if ~exist(wFilePath,'file')
		disp(['loadDotWhiskersFile::File ' wFilePath ' could not be found.']);
	end

  % open file
	fid = fopen(wFilePath,'rb');
	str = fread(fid,12,'uint8=>char')'; % header is 12 bytes.

  % format?  only whiskbin1
	if ~isempty(strfind(str,'whiskbin1'))     % .whiskers file is in binary whiskbin1 format.
		% -- header

    % Get number of whiskers:
    fseek(fid,-4,'eof'); % 4 bytes for 'int' on Win32.
    nsegs = fread(fid,1,'int');
    
    fseek(fid,12,'bof'); % Start of non-header data.
    
    r = cell(1,nsegs);
    frameNum = zeros(nsegs,1,'single');
    segID = zeros(nsegs,1,'single');
    len = zeros(nsegs,1,'single');
    
    xdat = cell(nsegs,1);
    ydat = cell(nsegs,1);
    thickdat = cell(nsegs,1);
    scoredat = cell(nsegs,1);

		% -- body of file
    % loop thru and acquire segments ...
    for k=1:nsegs
			segID(k) = fread(fid,1,'int')';
			frameNum(k) = fread(fid,1,'int')';
			len(k) = fread(fid,1,'int')';
			dat = fread(fid,4*double(len(k)),'float')';
      xdat{k} = dat(1:len(k))';
      ydat{k} = dat((len(k)+1):(2*len(k)))';
      thickdat{k} = dat((2*len(k)+1):(3*len(k)))';
      scoredat{k} = dat((3*len(k)+1):(4*len(k)))';
    end

		% -- convert raw data into a structure for return
    frames = unique(frameNum);
    nframes = length(frames);
    r = cell(1,nframes);
    for f=1:nframes % frame loop
		  ind = find(frameNum == frames(f));
		  for w=1:length(xdat(ind)) % whisker loop
				whiskerData(f).whisker(w).x = xdat{ind(w)};
				whiskerData(f).whisker(w).y = ydat{ind(w)};
%				whiskerData(f).whisker(w).thick = thickdat{ind(w)};

        % original segment ID -- for .measurements compatibility
				whiskerData(f).originalSegId(w) = segID(ind(w));

        % follicle XY based on face conventino
		    [minY minYIdx] = min(whiskerData(f).whisker(w).y);
   			minYy = minY;
	  		minYx = whiskerData(f).whisker(w).x(minYIdx);
        whiskerData(f).whisker(w).follicleXY = [minYx minYy];
        whiskerData(f).whisker(w).polynomialIntersectXY = [nan nan]; % intersect of the polynomial 
        whiskerData(f).whisker(w).polynomialArcPosition = nan; % position along polynomial arc 

				whiskerData(f).whisker(w).dilatedIndices = []; % default blank 

				% length
        len = max(cumsum(sqrt([0 diff(whiskerData(f).whisker(w).x')].^2 + [0 diff(whiskerData(f).whisker(w).y')].^2)));
				whiskerData(f).whiskerLength(w) = len;
				whiskerData(f).whiskerId(w) = segID(ind(w));
			end
    end
  else
    % Reject other formats
    disp(['loadDotWhiskersFile::File ' filename ' is not in binary (whiskbin1) format.  FAIL!']);
  end
  fclose(fid);



