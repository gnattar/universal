%
% For a given ISI file, this will return an image of intensity change due to
%  signal.
%
% USAGE:
%
%  im = get_qcam_meanmap(fname, nchunks)
%
% PARAMS:
%
%  im: the returned map
%
%  fname: qcam file(s) to process (cell if many)
%  nchunks: how many repeats (5 default)
%
% S Peron Feb 2012
function im = get_qcam_meanmap(fname, nchunks)

  % --- settings
	gaussSize = 10; % in pixels, size of 2d gaussian to filter w/
	stimPeriod = 1:4; 
	basePeriod = 11:20; 
	chunksize = 20; 

  % --- input processing
	if (~iscell(fname))
	  fname = {fname};
	end
	nfiles = length(fname);
	if nfiles < 1
		error('Must input at least one file name.')
	end

	if (nargin < 2) ; nchunks = 5; end

  % --- main load loop
	for j=1:nfiles
			fn = fname{j};
			x = strfind(fn,'.qcamraw');
			if ~isempty(x) % argument includes .qcamraw extension
					fn = fn(1:(x-1));
			end
			if ~exist([fn '.qcamraw'],'file')
					error(['File not found: ' fn '.qcamraw'])
			end

			f = 1;
			for k = 1:nchunks
					rep = read_qcamraw([fn '.qcamraw'], f:(f+chunksize-1));
					stim = mean(rep(:,:,stimPeriod),3);
					base = mean(rep(:,:,basePeriod),3);
					if k==1
							stimMean = stim;
							baseMean = base;
							diffMean = stim-base;
					else
							stimMean = (stimMean + stim)/2;
							baseMean = (baseMean + base)/2;
							diffMean = (diffMean + (stim-base))/2;
					end
					f = f+chunksize;
			end

			if j==1
					m = diffMean;
			else
					m = m + diffMean;
			end
	end

	m = m ./ nfiles;
	im = m';
	G = fspecial('gaussian',[1 1]*gaussSize,3);
	im = imfilter(im,G);
	%     imtool(m)


