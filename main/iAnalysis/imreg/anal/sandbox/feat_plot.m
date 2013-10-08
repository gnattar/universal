
	if (length(strfind(pwd, '171923')) == 1)
		feats = {'WhiskerSetpointCorr', 'MeanWhiskerAmplitudeCorr', 'ContactsForC2AUC','ContactsForC2PProd', ...
						 'ProtractionContactsForC2AUC','ProtractionContactsForC2PProd'};
		feats = {'WhiskerSetpointCorr','ContactsForC2PProd'};
	elseif (length(strfind(pwd, '167951')) == 1)
		feats = {'WhiskerSetpointCorr', 'MeanWhiskerAmplitudeCorr', 'ContactsForC3AUC','ContactsForC3PProd', ...
						 'ProtractionContactsForC3AUC','ProtractionContactsForC3PProd'};
		feats = {'WhiskerSetpointCorr','ContactsForC3PProd'};
	end
if ( 0)
		for f=1:length(feats)
			feat_name = feats{f};
			collect_feats;
			plot_v_pos;
		end
end

% maps . . . 
if (0)
  feat_name = feats{1};
	collect_feats;
	vals = find(feat_value > .025);
	whisk_score = feat_value;

  feat_name = feats{2};
	collect_feats;
	if (length(strfind(feat_name, 'AUC')) > 0)
		vals = find(feat_value > .5);
	end
	if (length(strfind(feat_name, 'PProd')) > 0)
		vals = find(feat_value > .035);
	end
	touch_score = feat_value;
end
if (1)

	feat_value = 0*feat_value;
	feat_value(find(whisk_score > .015)) = 2;
	feat_value(find(touch_score > .02)) = 1;

	s.plotColorRois('',[],[],[0 0 0 ; 1 0 0 ; 0 1 0 ], feat_value);
end


if (0)

  feat_name = feats{1};
	collect_feats;
  plot_v_pos;
	close all;

  sp_mus = mus;
	sp_d_bins = d_bins;
	sp_ses = ses;

  feat_name = feats{2};
	collect_feats;
  plot_v_pos;
	close all;

  figure;
	hold on;
	mus(find(isnan(mus))) = 0;
	ses(find(isnan(ses))) = 0;
	sp_mus(find(isnan(sp_mus))) = 0;
	sp_ses(find(isnan(sp_ses))) = 0;

	%plot_with_errorbar2(d_bins(1:end-1)+ws/2, mus,q95-mus,mus-q05, color);
	color = [1 0 0];
	plot(d_bins(1:end-1)+ws/2, mus, 'Color', color);
	plot(sp_d_bins(1:end-1)+ws/2, sp_mus, 'Color', [0 1 0]);
	legend('Touch','Whisking');
	plot_with_errorbar(d_bins(1:end-1)+ws/2, mus,ses, color);

	color = [0 1 0];
	plot_with_errorbar(sp_d_bins(1:end-1)+ws/2, sp_mus,sp_ses, color);
	%plot_with_errorbar2(d_bins(1:end-1)+ws/2, mus,q95-mus,mus-q05, color);
 
	dn = pwd;
	sidx = find(dn == '/');
	anId = dn(sidx(end-1)+1:sidx(end)-1);
	title(anId);

	set (gca,'TickDir','out');
	xlabel('Distance from PW Barrel Center (um)');
	ylabel('Correlation (whisking) or conditional probability product (touch)');

  d_from_pw_center_touch = d_bins(1:end-1) + ws/2;
	mean_touch = mus;
	sem_touch = ses;
	color_touch = [1 0 0];

  d_from_pw_center_whisk = sp_d_bins(1:end-1) + ws/2;
	mean_whisk = sp_mus;
	sem_whisk = sp_ses;
	color_whisk = [0 1 0];

	save(['~/Desktop/' anId '.mat'], 'd_from_pw_center_touch', 'mean_touch', 'sem_touch', 'color_touch', ...
	   'd_from_pw_center_whisk', 'mean_whisk', 'sem_whisk', 'color_whisk');
end
