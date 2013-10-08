
im_size = 512*512*2;

% find all image starts ...
if (0)
	f_pos = 0;

	fseek(fid,0,'eof');
	f_len = ftell(fid);

	% read 1.5 at a time ...
	starts(500000) = -1; 
	si = 1;
	id_vec = [0 32 0 32 0 0];
	while (f_pos < f_len)
		fseek(fid,f_pos, 'bof');
		end_read = round(min(f_len, f_pos + 1.5*im_size));
		read_size = round((end_read - f_pos)/2);
		read_vec = fread(fid,read_size, 'uint16');

		next_idx = min(strfind(read_vec', id_vec) + length(id_vec));
	 
		if (length(next_idx) > 0)
			f_pos = f_pos + next_idx*2;
			starts(si) = f_pos;
			si = si+1;
			disp(num2str(si));
		else
			f_pos = f_len + 1;
		end
	end
end

% repair
n_frames = 40;
val = find(starts > 0);
n_planes = length(val)/n_frames;
im = zeros(512,512,n_planes);

si = 1;
for p=1:n_planes
  tim = zeros(512,512,n_frames);
  for f=1:n_frames
		fseek(fid,starts(si), 'bof');
		tim(:,:,f) = fread(fid,[512 512],'uint16')';
	  si = si+1;
		disp(num2str(si));
	end
	im(:,:,p) = median(tim,3);
end


