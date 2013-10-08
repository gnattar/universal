%
% S Peron 2010 June
%
% This will generate plots for NLS-GCaMP 3.3 data
%
% 1) compare distribution of events in various ways -- regular v. NLS gcamp [few sessions]
% 2) compare time constants rise, fall vs. regular [few sessions]
% 3) compare luminance evolution over time [all sessions]
%
function gcamp_nls_plots()
	nls_an = {'an91712'};
	nls_sess_best = {{'2010_03_11'}};
	nls_sess_all = {{'2010_02_24', '2010_03_11', '2010_03_23', '2010_03_31', '2010_04_08', '2010_04_15'}};
	an91712_laser_power = [25 35 35 35 35 35]; % PMT gain fixed -- .735
	an94953_laser_power_pmt = [20 .700; 25 .68 ; 30 .67 ;25 .68 ; 25 .68 ; 35 .67 ; 25 .68 ; ...
	                           30 .68 ; 25 .66 ; 25 .66 ;25 .66 ; 25 .66; 25 .66; 25 .68; ...
														 25 .66 ; 22 .66 ; 22 .66 ;20 .66 ;18 .66 ; 18 .66 ];

  % 2 best/healthiest animals
	reg_an = {'an94953', 'an38596'};
	reg_sess_best = {{'2010_04_01', '2010_04_02'}, {'2010_02_03', '2010_02_04'}};
	reg_sess_all = {{'2010_03_31', '2010_04_01', '2010_04_02', '2010_04_05', '2010_04_06', '2010_04_07' , '2010_04_08', ...
	                 '2010_04_09', '2010_04_12', '2010_04_13', '2010_04_14', '2010_04_15', '2010_04_16', '2010_04_19', ...
	                 '2010_04_20', '2010_04_22', '2010_04_23', '2010_04_26', '2010_04_27', '2010_04_30'}, ...
									 {'2010_02_02', '2010_02_03', '2010_02_04', '2010_02_05', '2010_02_08', '2010_02_09', '2010_02_11', ...
									  '2010_02_15', '2010_02_16', '2010_02_17', '2010_02_18', '2010_02_19', '2010_02_20', '2010_02_22', ...
									   '2010_02_23','2010_02_24', '2010_02_25', '2010_02_26', '2010_03_01', '2010_03_02'}};


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % --- load analysis
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% future gcamp_nls_analysis
	
	if (0 == 1 | exist('~/sci/anal/tmp/gcamp_nls_analysis.mat', 'file') ~= 2) 
		% ---- 1) event distribution
		[nls_n_events nls_n_events_per_sec] = get_event_distro_data(nls_an, nls_sess_best);
		[reg_n_events reg_n_events_per_sec] = get_event_distro_data(reg_an, reg_sess_best);
		% ---- 2) brightness
	  [nls_brightness] = get_roi_changes(nls_an, nls_sess_all);
	  [reg_brightness] = get_roi_changes({reg_an{1}}, reg_sess_all);
		save('~/sci/anal/tmp/gcamp_nls_analysis.mat', 'nls_n_events' , 'nls_n_events_per_sec', 'reg_n_events' , 'reg_n_events_per_sec', ...
		     'nls_brightness', 'reg_brightness');
	else
	  load('~/sci/anal/tmp/gcamp_nls_analysis.mat');
	end
	
 

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % --- massage data 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % --- cumulative fractions
	% compute cumulative distributions for each one
	cnevps = 0:0.00005:0.1;
  for c=1:length(cnevps)
	  nls_cfrac_nevps(c) = length(find(nls_n_events_per_sec < cnevps(c)));
	  reg_cfrac_nevps(c) = length(find(reg_n_events_per_sec < cnevps(c)));
  end
	nls_cfrac_nevps = nls_cfrac_nevps/max(nls_cfrac_nevps);
	reg_cfrac_nevps = reg_cfrac_nevps/max(reg_cfrac_nevps);

	% --- day #
	for d=1:length(nls_sess_all{1});
    day_num_nls(d) = datenum(nls_sess_all{1}{d});
	end
	day_num_nls = day_num_nls - min(day_num_nls) + 22; % surgery on 2/2 ; 2/24 was first imaging day (min(day_num_nls))
	for d=1:length(reg_sess_all{1});
    day_num_reg(d) = datenum(reg_sess_all{1}{d});
	end
	day_num_reg = day_num_reg - min(day_num_reg) + 22; % surgery on 3/9 ; fist imaging on 3/31

	nls_brite = nls_brightness{1};
	nls_brite(find(nls_brite == 0)) = NaN;
	reg_brite = reg_brightness{1};
	reg_brite(find(reg_brite == 0)) = NaN;

  % --- time constant change . . . 
	[nls_ksd_taus nls_min_taus] = time_constant_analysis(nls_an{1});
	[reg1_ksd_taus reg1_min_taus] = time_constant_analysis('an94953');
	dayf_nls_ksd_taus = nls_ksd_taus(1,:);
	dayl_nls_ksd_taus = nls_ksd_taus(6,:);
	dayf_reg_ksd_taus = reg1_ksd_taus(2,:);
	dayl_reg_ksd_taus = reg1_ksd_taus(size(reg1_ksd_taus,1),:);
	ctau = 0:5:5000;
  for c=1:length(ctau)
	  df_nls_cfrac_taus(c) = length(find(dayf_nls_ksd_taus < ctau(c)));
	  dl_nls_cfrac_taus(c) = length(find(dayl_nls_ksd_taus < ctau(c)));
	  df_reg_cfrac_taus(c) = length(find(dayf_reg_ksd_taus < ctau(c)));
	  dl_reg_cfrac_taus(c) = length(find(dayl_reg_ksd_taus < ctau(c)));
  end
	df_nls_cfrac_taus = df_nls_cfrac_taus/max(df_nls_cfrac_taus);
	dl_nls_cfrac_taus = dl_nls_cfrac_taus/max(dl_nls_cfrac_taus);
	df_reg_cfrac_taus = df_reg_cfrac_taus/max(df_reg_cfrac_taus);
	dl_reg_cfrac_taus = dl_reg_cfrac_taus/max(dl_reg_cfrac_taus);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % --- plot it
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 
  % --- time constant change . . . 
  figure;

  nls_ksd_tau_mean = nanmean(nls_ksd_taus');
  nls_ksd_tau_sd = nanstd(nls_ksd_taus');
 	subplot(2,2,1);
	hold on;
	plot_with_errorbar(day_num_nls, nls_ksd_tau_mean, nls_ksd_tau_sd/sqrt(size(nls_ksd_taus,2)), [1 0 0]);
  reg1_ksd_tau_mean = nanmean(reg1_ksd_taus');
  reg1_ksd_tau_sd = nanstd(reg1_ksd_taus');
	plot_with_errorbar(day_num_reg, reg1_ksd_tau_mean, reg1_ksd_tau_sd/sqrt(size(reg1_ksd_taus,2)), [0 0 1]);
	set(gca, 'TickDir', 'out');
	text(60,200,'NLS', 'Color', [1 0 0]);
	text(60,500,'Regular', 'Color', [0 0 1]);
	ylabel('modal (ksd) tau (mu+/-SE)');
	xlabel('day post-injection');
	title('NLS');
	axis([20 80 0 1500]);

  subplot(2,2,2);
	reg_taus = reshape(reg1_ksd_taus,[],1);
	nls_taus = reshape(nls_ksd_taus,[],1);
	valn = find(~isnan(nls_taus));
	valr = find(~isnan(reg_taus));
	[n1 xout] = hist(nls_taus(valn), 25:100:4975);
	[n2 xout] = hist(reg_taus(valr), 25:100:4975);
%	bar(xout,n,'r');
	h = bar([xout],[n1/length(nls_taus(valn)) ; n2/length(reg_taus(valr))]','grouped');
	set(h(1), 'FaceColor', [1 0 0]);
	set(h(2), 'FaceColor', [0 0 1]);	
	xlabel('decay tau (ms)');
	rs = ranksum(nls_taus(valn), reg_taus(valr));
	text(1000, 0.1, ['rank sum pval: ' num2str(rs)]);
	legend('NLS', 'Regular');
	set(gca, 'TickDir', 'out');
	axis([0 5000 0 0.2]);
	title('Distribution of modal taus; all days pooled');

  figure;
	subplot(2,2,1);
	valf = find(~isnan(dayf_nls_ksd_taus));
	vall = find(~isnan(dayl_nls_ksd_taus));
	[n1 xout] = hist(dayf_nls_ksd_taus(valf), 25:100:4975);
	[n2 xout] = hist(dayl_nls_ksd_taus(vall), 25:100:4975);
%	bar(xout,n,'r');
	h = bar([xout],[n1/length(valf) ; n2/length(vall)]','grouped');
	set(h(1), 'FaceColor', [1 0 1]);
	set(h(2), 'FaceColor', [0 1 1]);	
	xlabel('decay tau (ms)');
	legend('First day', 'Last day');
	set(gca, 'TickDir', 'out');
	axis([0 5000 0 0.2]);
	title('NLS Animal');
	
	subplot(2,2,2);
	valf = find(~isnan(dayf_reg_ksd_taus));
	vall = find(~isnan(dayl_reg_ksd_taus));
	[n1 xout] = hist(dayf_reg_ksd_taus(valf), 25:100:4975);
	[n2 xout] = hist(dayl_reg_ksd_taus(vall), 25:100:4975);
%	bar(xout,n,'r');
	h = bar([xout],[n1/length(valf) ; n2/length(vall)]','grouped');
	set(h(1), 'FaceColor', [1 0 1]);
	set(h(2), 'FaceColor', [0 1 1]);	
	xlabel('decay tau (ms)');
	legend('First day', 'Last day');
	set(gca, 'TickDir', 'out');
	axis([0 5000 0 0.2]);
	title('Regular Animal');
	

  subplot(2,2,3);
  plot(ctau, df_nls_cfrac_taus, 'Color', [1 0 1]);
	hold on;
  plot(ctau, dl_nls_cfrac_taus, 'Color', [0 1 1]);
	legend('First day', 'Last day');
	title('NLS GCaMP');
	valf = find(~isnan(dayf_nls_ksd_taus));
	vall = find(~isnan(dayl_nls_ksd_taus));
%	[irr ksp] = kstest(dayl_nls_ksd_taus(vall),[ctau; df_nls_cfrac_taus]');
	rs = ranksum(dayl_nls_ksd_taus(vall), dayf_nls_ksd_taus(valf));
	text(3000, 0.2, ['Ranksum pval: ' num2str(rs)]);
	set(gca, 'TickDir', 'out');
	xlabel('decay tau (ms)');
	ylabel('cumulative fraction');
	axis([0 5000 0 1]);

  subplot(2,2,4);
  plot(ctau, df_reg_cfrac_taus, 'Color', [1 0 1]);
	hold on;
  plot(ctau, dl_reg_cfrac_taus, 'Color', [0 1 1]);
	title('Regular GCaMP');
	valf = find(~isnan(dayf_reg_ksd_taus));
	vall = find(~isnan(dayl_reg_ksd_taus));
%	[irr ksp] = kstest(dayl_reg_ksd_taus(vall),[ctau; df_reg_cfrac_taus]');
	rs = ranksum(dayl_reg_ksd_taus(vall), dayf_reg_ksd_taus(valf));
	set(gca, 'TickDir', 'out');
	text(3000, 0.2, ['Ranksum pval: ' num2str(rs)]);
	xlabel('decay tau (ms)');
	ylabel('cumulative fraction');
	axis([0 5000 0 1]);

  

	pause;

  % --- progression of brightness : laser power
  figure;
	subplot(2,2,1);
	plot(day_num_nls, an91712_laser_power, 'mo', 'MarkerSize', 5, 'MarkerFaceColor', [1 0 1]);
	hold on;
	title('NLS');
	xlabel('day post-injection');
	ylabel('laser power % (pmt .735)');
	set(gca, 'TickDir', 'out');
	axis([20 80 10 40]);

	subplot(2,2,2);
	plot(day_num_reg, an94953_laser_power_pmt(:,1), 'mo', 'MarkerSize', 5, 'MarkerFaceColor', [1 0 1]);
	hold on;
	title('regular');
	xlabel('day post-injection');
	ylabel('laser power % ');
	set(gca, 'TickDir', 'out');
	axis([20 80 10 40]);

	subplot(2,2,4);
	plot(day_num_reg, an94953_laser_power_pmt(:,2), 'co', 'MarkerSize', 5, 'MarkerFaceColor', [0 1 1]);
	hold on;
	title('regular');
	xlabel('day post-injection');
	ylabel('pmt gain');
	set(gca, 'TickDir', 'out');
	axis([20 80 .6 .8]);

  % --- progression of brightness : ROI b4/after
	figure;
 	subplot(2,2,1);
	val = find(~isnan(nls_brite(:,2)) & ~isnan(nls_brite(:,size(nls_brite,2))));
	plot(nls_brite(val,2), nls_brite(val,size(nls_brite,2)), 'ro', 'MarkerSize', 5, 'MarkerFaceColor', [1 0 0]);
	hold on;
	plot ([0 3000], [0 3000], 'k:');
	set(gca, 'TickDir', 'out');
	xlabel(['luminance ' num2str(day_num_nls(2)) ' days PI']);
	ylabel(['luminance ' num2str(day_num_nls(end)) ' days PI']);
	title('ROI luminance before/after::GCaMP NLS [same pwr,pmt]');
	axis([0 3000 0 3000]);

 	subplot(2,2,2);
	val = find(~isnan(reg_brite(:,2)) & ~isnan(reg_brite(:,size(reg_brite,2)-6)));
	plot(reg_brite(val,1), reg_brite(val,size(reg_brite,2)-6), 'bo', 'MarkerSize', 5, 'MarkerFaceColor', [0 0 1]);
	hold on;
	plot ([0 3000], [0 3000], 'k:');
	set(gca, 'TickDir', 'out');
	xlabel(['luminance ' num2str(day_num_reg(2)) ' days PI']);
	ylabel(['luminance ' num2str(day_num_reg(end-6)) ' days PI']);
	title('ROI luminance before/after::GCaMP regular [same power/pmt gain]');
	axis([0 2000 0 2000]);

 	subplot(2,2,4);
	val = find(~isnan(reg_brite(:,2)) & ~isnan(reg_brite(:,size(reg_brite,2))));
	plot(reg_brite(val,1), reg_brite(val,size(reg_brite,2)), 'bo', 'MarkerSize', 5, 'MarkerFaceColor', [0 0 1]);
	hold on;
	plot ([0 3000], [0 3000], 'k:');
	set(gca, 'TickDir', 'out');
	xlabel(['luminance ' num2str(day_num_reg(2)) ' days PI']);
	ylabel(['luminance ' num2str(day_num_reg(end)) ' days PI']);
	title('ROI luminance before/after::GCaMP regular');
	axis([0 2000 0 2000]);


  % --- progression of brightness : actual luminance
	figure;
	brite_mean = nanmean(nls_brite);
	brite_sd = nanstd(nls_brite);

 	subplot(2,2,1);
	plot(day_num_nls, nls_brite');
	hold on;
	set(gca, 'TickDir', 'out');
	ylabel('ROI basal fluorescence (raw)');
	title('GCaMP NLS');
	xlabel('day post-injection');
	axis([20 80 0 3500]);


 	subplot(2,2,3);
	hold on;
	plot_with_errorbar(day_num_nls, brite_mean, brite_sd, [0 0 0]);
	set(gca, 'TickDir', 'out');
	ylabel('ROI basal fluorescence (mean+/-SD ; a.u.)');
	xlabel('day post-injection');
	axis([20 80 0 2000]);

	brite_mean = nanmean(reg_brite);
	brite_sd = nanstd(reg_brite);

 	subplot(2,2,2);
	plot(day_num_reg, reg_brite');
	hold on;
	set(gca, 'TickDir', 'out');
	ylabel('ROI basal fluorescence (raw)');
	title('GCaMP regular');
	xlabel('day post-injection');
	axis([20 80 0 3500]);


 	subplot(2,2,4);
	hold on;
	plot_with_errorbar(day_num_reg, brite_mean, brite_sd, [0 0 0]);
	set(gca, 'TickDir', 'out');
	ylabel('ROI basal fluorescence (mean+/-SD ; a.u.)');
	xlabel('day post-injection');
	axis([20 80 0 2000]);

 

  % --- stuff pertaining to n_events
  figure;

  % distro
	subplot(2,2,1);
	hold on;
	[n1 xout] = hist(nls_n_events, 2.5:5:147.5);
	[n2 xout] = hist(reg_n_events, 2.5:5:147.5);
%	bar(xout,n,'r')

	h = bar([xout],[n1/length(nls_n_events) ; n2/length(reg_n_events)]','grouped');
	set(h(1), 'FaceColor', [1 0 0]);
	set(h(2), 'FaceColor', [0 0 1]);	
	set(gca, 'TickDir', 'out');
	xlabel('event count');
	legend('NLS', 'regular');
	axis([0 150 0 1]);

	subplot(2,2,2);
	hold on;
	
	[n1 xout] = hist(nls_n_events_per_sec, 0.00125:0.0025:0.07875);
	[n2 xout] = hist(reg_n_events_per_sec, 0.00125:0.0025:0.07875);
%	bar(xout,n,'r');
	h = bar([xout],[n1/length(nls_n_events_per_sec) ; n2/length(reg_n_events_per_sec)]','grouped');
	set(h(1), 'FaceColor', [1 0 0]);
	set(h(2), 'FaceColor', [0 0 1]);	
	xlabel('event rate (Hz)');
	rs = ranksum(nls_n_events_per_sec, reg_n_events_per_sec);
	text(0.01, 0.5, ['rank sum pval: ' num2str(rs)]);
	set(gca, 'TickDir', 'out');
	axis([0 0.08 0 1]);

	subplot(2,2,4);
	hold on;
	
	h = bar([xout],[n1/length(nls_n_events_per_sec) ; n2/length(reg_n_events_per_sec)]','grouped');
	set(h(1), 'FaceColor', [1 0 0]);
	set(h(2), 'FaceColor', [0 0 1]);	
	xlabel('event rate (Hz)');
	rs = ranksum(nls_n_events_per_sec, reg_n_events_per_sec);
	text(0.01, 0.5, ['rank sum pval: ' num2str(rs)]);
	set(gca, 'TickDir', 'out');
	axis([0 0.08 0 0.1]);
 

  % cum distro
	subplot(2,2,3);
	plot(cnevps,nls_cfrac_nevps,'r-');
	hold on;
	plot(cnevps,reg_cfrac_nevps,'b-');
	[irr ksp] = kstest(nls_n_events_per_sec,[cnevps ; reg_cfrac_nevps]')
	[irr ksp_control] = kstest(reg_n_events_per_sec,[cnevps ; reg_cfrac_nevps]')
	text(0.03, 0.6, ['KS pval: ' num2str(ksp)]);
	ylabel('cumulative fraction');
	xlabel('event rate (Hz)');
	legend('nls', 'regular');
	set(gca,'TickDir', 'out');
  
%
% Preps time constant data
%
function [ksd_taus min_taus] = time_constant_analysis(an_id)
	% single mouse plots
	load (['~/data/mouse_gcamp_learn/' an_id '/session/gcamp_health_analysis.mat']);

	% NaN-ify it!
	min_tau_mat(find(min_tau_mat == 0)) = NaN;
	ksd_tau_mat(find(ksd_tau_mat == 0)) = NaN;

	% omit absurd
	min_tau_mat(find(min_tau_mat > 5000)) = NaN;
	ksd_tau_mat(find(ksd_tau_mat > 5000)) = NaN;

	ksd_taus = ksd_tau_mat;
	min_taus = min_tau_mat;
	
  

%
% gathers event distro data
%  roi_lums: matrix with luminance for each day, roi
%
function [roi_lums] = get_roi_changes(anms, sesss)
  for a=1:length(anms)
	  an = anms{a};
	  for s=1:length(sesss{a})
		  sess = sesss{a}{s};

			% load the session
			roi_fname = ['~/data/mouse_gcamp_learn/' an '/roi/' an '_' sess '.mat']
			load (roi_fname);

      % init matrices
			if (s == 1)
			  roi_lums{a} = zeros(length(obj.rois), length(sesss{a}));
      end

			% looop over rois
			for r=1:length(obj.rois)
			  roi_lums{a}(r,s) = mean(obj.masterImage(obj.rois{r}.indices));
			end
		end
	end
  
%
% gathers event distro data
%  n_events -- # events / roi
%  n_events_per_sec -- # events / roi / sec
%
function [n_events n_events_per_sec] = get_event_distro_data(anms, sesss)
  for a=1:length(anms)
	  an = anms{a};
	  for s=1:length(sesss{a})
		  sess = sesss{a}{s};

			% load the session
			sess_fname = ['~/data/mouse_gcamp_learn/' an '/session/sess_' an '_' sess '.mat']
			load (sess_fname);

      % determine each trial length
			for ts=1:length(session.trial(1).timeseries)
			  if (session.trial(1).timeseries(ts).type_id == 1)
				  tsi = ts;
					dt = session.trial(1).timeseries(ts).dt;
				end
			end
			for t=1:length(session.trial)
			  t_length_in_ms(t) = dt*length(session.trial(t).timeseries(tsi).time);
			end
			total_length_in_ms = sum(t_length_in_ms);

      % how many eventseries?
			esi_val = [];
			esi_roi_idx = [];
			for e=1:length(session.trial(1).eventseries)
			  if (session.trial(1).eventseries(e).type_id == 7)
				  esi_val = [esi_val e];
					esi_roi_idx = [esi_roi_idx session.trial(1).eventseries(e).unique_id];
				end
		  end

			% matrices
			n_events = zeros(1,length(esi_val));

			% loop thru event series
			for e=1:length(esi_val)
			  ev_count = 0;
				for t=1:length(session.trial)
				  ev_count = ev_count + length(session.trial(t).eventseries(esi_val(e)).time);
				end
				n_events(e) = ev_count;
				n_events_per_sec(e) = ev_count/total_length_in_ms*1000;
			end
		end
	end
