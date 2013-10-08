%
% SP Aug 2010
%
% Will load specified movie frames by calling mmread.  Note that if the frames
%  are already loaded, nothing happens.
%
%  frames: indices of frames to load
%
function obj = loadMovieFrames(obj, frames)
  if (~ iscell(obj.whiskerMovieFrames)) 
		for f=1:obj.numFrames
		  obj.whiskerMovieFrames{f} = {};
		end
	end
	 for f=1:length(frames)
	  modPath = strrep(obj.whiskerMoviePath,'~','/home/speron'); % stupid mmread needs EXACT path
		if (length(obj.whiskerMovieFrames{frames(f)}) == 0) % missing?
			if (length(which('mmread')) > 0) % default is mmread 
				frm = mmread(modPath,frames(f));
				obj.whiskerMovieFrames{frames(f)}.cdata = frm.frames(1).cdata(:,:,1);
				obj.whiskerMovieFrames{frames(f)}.width = frm.width;
				obj.whiskerMovieFrames{frames(f)}.height= frm.height;
			else % ffmpeg -- and in that case, we load the WHOLE thing, instead of piecemeal - slow, but will work on kluster
				ffmpegDir = ['tmp_' datestr(now,'yymmddHHMMSSFFF')];

        % assure unique filename in case of parallel execution
        while(exist(ffmpegDir,'dir') == 7)
					ffmpegDir = ['tmp_' datestr(now,'yymmddHHMMSSFFF')];
					pause(.5);
				end

				% 1: create dir 
				mkdir(ffmpegDir);

				% 2: ffmpeg
				%ffmpegCmd = ['. ~/.bashrc; ffmpeg -i ' modPath ' ' ffmpegDir filesep '%5d.tif']
				ffmpegCmd = ['/usr/local/bin/ffmpeg -i ' modPath ' ' ffmpegDir filesep '%5d.tif'];
				system(ffmpegCmd);

				% 3: load it
				fl = dir([ffmpegDir filesep '*tif']);
				imi = imfinfo([ffmpegDir filesep fl(1).name]);
				for f=1:length(fl)
					disp(num2str(f));
					obj.whiskerMovieFrames{f}.cdata = imread([ffmpegDir filesep fl(f).name]);
					if (size(obj.whiskerMovieFrames{f}.cdata,3) > 1) % rgb? nuke it!
					  S = size(obj.whiskerMovieFrames{f}.cdata);
						nmf = zeros(S(1),S(2));
						nmf = obj.whiskerMovieFrames{f}.cdata(:,:,1);
						obj.whiskerMovieFrames{f}.cdata = nmf;
					end
					obj.whiskerMovieFrames{f}.width = imi.Width;
					obj.whiskerMovieFrames{f}.height = imi.Height;
				end

				% 4: clear it
				delete([ffmpegDir filesep '*tif']);
				rmdir(ffmpegDir);
			end
		end
	end
