
anims = {'an93098' ,'an38596', 'an91710', 'an94953'};
anims = {'an91712'};
for i=1:length(anims)
  an = anims{i};
	flist = dir(['~/data/mouse_gcamp_learn/' an '/session/sess_*mat']);
	for f=1:length(flist)  
		session_file_path = ['~/data/mouse_gcamp_learn/' an '/session/' flist(f).name];
		disp(['Processing ' session_file_path]);
		clear global glospvars;
		try
			session_plotter_load_trials(session_file_path, 1);
		
			denoise_f_signal([]);
			event_detect_dff ([]);

			% and save
			global glospvars;
			session = glospvars.session;
			save(session_file_path, 'session');
		catch
			disp([session_file_path ' sessanal failed.']);
		end
	end

	clear flist session_file_path
end
