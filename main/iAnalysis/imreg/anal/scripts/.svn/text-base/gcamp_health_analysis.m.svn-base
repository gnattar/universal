%
% Loop thru all session collecting tau, luminance ratios...
%

anims = {'an93098' ,'an38596', 'an91710', 'an94953'};
anims = {'an91712'};
for i=1:length(anims)
  an = anims{i};
	root_dir = ['~/data/mouse_gcamp_learn/' an '/session/'];

	flist = dir([root_dir 'sess_*mat']);
	% main loop ...
	for f=1:length(flist)  
		session_file_path = [root_dir flist(f).name];
		disp(['Processing ' session_file_path]);
		load(session_file_path);
		rA = session.roiArray;
		rA.workingImage = rA.masterImage;

		f_id_str{f} = flist(f).name;

		% index session
		es_roi_idx = -1*ones(1,length(session.trial(1).eventseries));
		for i=1:length(session.trial(1).eventseries)
			es = session.trial(1).eventseries(i);
			if (es.type_id == 7) % ROI dF/F event series
				es_roi_idx(i) = es.unique_id;
			end
		end

		% Prepare data matrices -- if pass 1
		if (f == 1)
			ksd_last_tau_mat = zeros(length(flist),length(rA.rois));
			min_last_tau_mat = zeros(length(flist),length(rA.rois));
			ksd_tau_mat = zeros(length(flist),length(rA.rois));
			min_tau_mat = zeros(length(flist),length(rA.rois));
			ce_rat_mat = zeros(length(flist),length(rA.rois));
			lum_rat_mat = zeros(length(flist),length(rA.rois));
			filled_mat = zeros(length(flist),length(rA.rois));
			roi_ids = rA.roiIds;
		end

		% process it ...
		median_lum = median(reshape(rA.masterImage,[],1));
		for r=1:length(rA.rois)
			mean_lum(r) = mean(rA.masterImage(rA.rois{r}.indices));
		end
		median_roi_lum = median(mean_lum);
		for r=1:length(rA.rois)
			try
				esi = find(es_roi_idx == rA.rois{r}.id);
				if (length(esi) == 1)
					taus = [];
					last_taus = [];
					% gather all taus
					for t=1:length(session.trial)
						cand_taus = session.trial(t).eventseries(esi).params(3).value;
						val_tau = find(cand_taus > 0);
						taus = [taus cand_taus(val_tau)];
						cand_last_taus = session.trial(t).eventseries(esi).params(4).value;
						val_tau = find(cand_last_taus > 0);
						last_taus = [last_taus cand_last_taus(val_tau)];
					end

					% get median via ksdensity -- OR min
					if (length(taus) > 0)
						[fval xi] = ksdensity(taus); 
						[irr m_i] = max(fval);
						ksd_tau_mat(f,r) = xi(m_i);
						min_tau_mat(f,r) = min(taus);
						[fval xi] = ksdensity(last_taus); 
						[irr m_i] = max(fval);
						ksd_last_tau_mat(f,r) = xi(m_i);
						min_last_tau_mat(f,r) = min(last_taus);
						ce_rat_mat(f,r) = rA.computeCenterEdgeLuminanceRatio(rA.rois{r}.id);
						lum_rat_mat(f,r) = mean(rA.masterImage(rA.rois{r}.indices))/median_lum;
						lum_rat2_mat(f,r) = mean(rA.masterImage(rA.rois{r}.indices))/median_roi_lum;
						filled_mat(f,r) = rA.detectFilledRois(rA.rois{r}.id);
					end
				end
			catch
				disp(['gcamp_health_analysis failed on roi ' num2str(r)]);
			end
		end
	end
		
	% save? f_id_str, roi_id_str, tau_mat, ce_rat_mat, lum_rat_mat
	save([root_dir 'gcamp_health_analysis.mat'], 'f_id_str', 'roi_ids', 'ksd_tau_mat', 'min_tau_mat', 'ksd_last_tau_mat', 'min_last_tau_mat', 'ce_rat_mat', 'lum_rat_mat', 'lum_rat2_mat', 'filled_mat');
		
	% clear
	clear session f_id_str roi_ids ksd_last_tau_mat min_last_tau_mat ksd_tau_mat min_tau_mat ce_rat_mat lum_rat_mat filled_mat
end
