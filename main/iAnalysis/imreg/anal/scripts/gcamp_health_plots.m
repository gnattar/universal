%
% This generates plots for GCaMP health 
%
function gcamp_health_plots()
  fill_mode = 1; % 1: manual ; 2: roiArray.detectFilledRois() based
	print_on = 0; % 1: will output to ~/Desktop/tau
	taus_used = 1; % 1: peak based 2: last point above thresh based (D HUber style)

  tau2t12 = 0.693; % t_1/2 = tau*0.693
	an_ids = {'an38596', 'an91710', 'an93098', 'an94953'};
%	ce_thresh = [.975 .99 1 1]; % center-edge threshold for each animal -- greater means it is filled
%	days = {[11 12 13],[10 12],[13 15 17 18],[15 16 17 18]};
	days = {[12 13],[12],[13 15 ],[15 17]}; % DAN used : 38596 2/19 2/20 ; 91710 3/11 ; 93098 3/25 3/29 ; 94953 4/16 4/19
	key_rois ={[17 65 42 88 23 94 5 6 11], [25 93 185], [46 59 8 11 17 68 115], [12 2 5 52 30 46 111 171 151]};
	filled_rois = {[2 4 58 10 5 6 51 50 61],[58 72 9 12 32 15 39 154],[8 9 4 121 7 59 6 114],[27 48]};


	filled_tau_min_vec = [];
	unfilled_tau_min_vec = [];
	filled_tau_ksd_vec = [];
	unfilled_tau_ksd_vec = []; 
  for a=1:length(an_ids)
		an_id = an_ids{a};

		% single mouse plots
		load (['~/data/mouse_gcamp_learn/' an_id '/session/gcamp_health_analysis.mat']);

		% which taus?
		if (taus_used == 2)
		  min_tau_mat = min_last_tau_mat;
		  ksd_tau_mat = ksd_last_tau_mat;
		end
	
		% NaN-ify it!
		ce_rat_mat(find(ce_rat_mat == 0)) = NaN;
		lum_rat_mat(find(lum_rat_mat == 0)) = NaN;
		min_tau_mat(find(min_tau_mat == 0)) = NaN;
		ksd_tau_mat(find(ksd_tau_mat == 0)) = NaN;

		% omit absurd
		min_tau_mat(find(min_tau_mat > 5000)) = NaN;
		ksd_tau_mat(find(ksd_tau_mat > 5000)) = NaN;

		% convert key_rois{a} to roi indices
		kr = [];
		for k=1:length(key_rois{a})
		  kr(k) = find(roi_ids == key_rois{a}(k));
		end
		fr = [];
		for k=1:length(filled_rois{a})
		  fr(k) = find(roi_ids == filled_rois{a}(k));
		end

    % Single-animal plot
		single_animal_gcamp_health_plot(an_id, f_id_str, filled_mat, ce_rat_mat, lum_rat_mat, min_tau_mat, ksd_tau_mat,kr, print_on);

    for d=1:length(days{a})
		  day_id = days{a}(d);
			% determine what was filled/not
 
      if (fill_mode == 1)
				filled_idx = fr;
				unfilled_idx = setdiff(1:size(ksd_tau_mat,2), filled_idx);
			elseif (fill_mode == 2)
				filled_idx = find(filled_mat(day_id,:));
				unfilled_idx = find(~filled_mat(day_id,:));
	    end

      % populate vec's
			filled_tau_ksd_vec = [filled_tau_ksd_vec ksd_tau_mat(day_id,filled_idx)];
			unfilled_tau_ksd_vec = [unfilled_tau_ksd_vec ksd_tau_mat(day_id,unfilled_idx)];
			filled_tau_min_vec = [filled_tau_min_vec min_tau_mat(day_id,filled_idx)];
			unfilled_tau_min_vec = [unfilled_tau_min_vec min_tau_mat(day_id,unfilled_idx)];
		end
  end

	% compute cumulative distributions for each one
	ctau = 0:1:(3000/0.693);
  for c=1:length(ctau)
	  min_cfrac_filled(c) = length(find(filled_tau_min_vec < ctau(c)));
	  min_cfrac_unfilled(c) = length(find(unfilled_tau_min_vec < ctau(c)));
	  ksd_cfrac_filled(c) = length(find(filled_tau_ksd_vec < ctau(c)));
	  ksd_cfrac_unfilled(c) = length(find(unfilled_tau_ksd_vec < ctau(c)));
  end
	min_cfrac_filled = min_cfrac_filled/max(min_cfrac_filled);
	min_cfrac_unfilled = min_cfrac_unfilled/max(min_cfrac_unfilled);
	ksd_cfrac_filled = ksd_cfrac_filled/max(ksd_cfrac_filled);
	ksd_cfrac_unfilled = ksd_cfrac_unfilled/max(ksd_cfrac_unfilled);

  % disp
	allvec = [filled_tau_ksd_vec unfilled_tau_ksd_vec];
	val = find(~isnan(allvec));
	allvec = allvec(val);
	L = length(allvec);
	allvec = sort(allvec);
	vec25 = allvec(round(L/4));
	vec75 = allvec(round(3*L/4));
	disp(['Median KSD tau: ' num2str(median(allvec)) ' 25th %ile: ' num2str(vec25) ' 75th: ' num2str(vec75)]);

	allvec = filled_tau_ksd_vec;
	val = find(~isnan(allvec));
	allvec = allvec(val);
	L = length(allvec);
	allvec = sort(allvec);
	vec25 = allvec(round(L/4));
	vec75 = allvec(round(3*L/4));
	disp(['Median KSD FILLED tau: ' num2str(median(allvec)) ' 25th %ile: ' num2str(vec25) ' 75th: ' num2str(vec75)]);

	allvec = unfilled_tau_ksd_vec;
	val = find(~isnan(allvec));
	allvec = allvec(val);
	L = length(allvec);
	allvec = sort(allvec);
	vec25 = allvec(round(L/4));
	vec75 = allvec(round(3*L/4));
	disp(['Median KSD UNFILLED tau: ' num2str(median(allvec)) ' 25th %ile: ' num2str(vec25) ' 75th: ' num2str(vec75)]);

	% plot
	f1 = figure;
	subplot(2,2,1);
	plot(tau2t12*ctau,ksd_cfrac_filled,'r-');
	hold on;
	plot(tau2t12*ctau,ksd_cfrac_unfilled,'b-');
	ksd_rs = ranksum(ksd_cfrac_filled, ksd_cfrac_unfilled);
	text(1000, 0.5, ['rank sum pval: ' num2str(ksd_rs)]);
	title('ksd-based taus');
	ylabel('cumulative fraction');
	xlabel('t-1/2 (ms)');
	legend('filled' , 'unfilled');
	set(gca,'TickDir', 'out');


	% plot
	subplot(2,2,2);
	plot(tau2t12*ctau,min_cfrac_filled,'r-');
	hold on;
	plot(tau2t12*ctau,min_cfrac_unfilled,'b-');
	min_rs = ranksum(min_cfrac_filled, min_cfrac_unfilled);
	text(1000, 0.5, ['rank sum pval: ' num2str(min_rs)]);
	title('min-based taus');
	ylabel('cumulative fraction');
	xlabel('t-1/2 (ms)');
	legend('filled' , 'unfilled');
	set(gca,'TickDir', 'out');

	% histograms of distros ...
  subplot(2,2,3);
	hold on;
	[n1 xout] = hist(filled_tau_min_vec, 50:100:4950);
%	bar(xout,n,'r');
	[n2 xout] = hist(filled_tau_ksd_vec, 50:100:4950);
	h = bar([xout],[n1 ; n2]','grouped');
	set(h(1), 'FaceColor', [0 1 1]);
	set(h(2), 'FaceColor', [1 0 1]);
	legend('min', 'ksd');
	xlabel('tau (ms)');
	title('filled cells');
	set(gca,'TickDir', 'out');

	% histograms of distros ...
  subplot(2,2,4);
	hold on;
	[n1 xout] = hist(unfilled_tau_min_vec, 50:100:4950);
%	bar(xout,n,'r');
	[n2 xout] = hist(unfilled_tau_ksd_vec, 50:100:4950);
	h = bar([xout],[n1 ; n2]','grouped');
	set(h(1), 'FaceColor', [0 1 1]);
	set(h(2), 'FaceColor', [1 0 1]);
	legend('min', 'ksd');
	xlabel('tau (ms)');
	title('unfilled cells');
	set(gca,'TickDir', 'out');

  % print?
	if (print_on)
		figure(f1);
		print('-dpdf', ['~/Desktop/tau/selected_dates_animals_pooled_tau_distros.pdf']);
	end



	% ------------------
  %	labeled fill/not fill
	if ( 0 == 1 )
		datroot = '~/data/mouse_gcamp_learn/an94953/roi/';
		fl = dir([datroot 'an94953_2010*']); datfn = {};
		for f=1:length(fl) ; datfn{f} = fl(f).name; end
		plot_roi_files(datroot, datfn);
		datroot = '~/data/mouse_gcamp_learn/an93098/roi/';
		fl = dir([datroot 'an93098_2010*']); datfn = {};
		for f=1:length(fl) ; datfn{f} = fl(f).name; end
		plot_roi_files(datroot, datfn);
		datroot = '~/data/mouse_gcamp_learn/an38596/roi/';
		fl = dir([datroot '2010*']); datfn = {};
		for f=1:length(fl) ; datfn{f} = fl(f).name; end
		plot_roi_files(datroot, datfn);
		datroot = '~/data/mouse_gcamp_learn/an91710/roi/';
		fl = dir([datroot '2010*']); datfn = {};
		for f=1:length(fl) ; datfn{f} = fl(f).name; end
		plot_roi_files(datroot, datfn);
	end

%
% plots a series of roi files ...
%
function plot_roi_files(datroot, datfn)

  % tiff output
  for f=1:length(datfn)
	  ff = figure;
	  load ([datroot datfn{f}]);
    obj.colorByFilled();
		obj.plotImage(1,0,0);
		text(10,10,strrep(obj.idStr,'_', '-'), 'Color', [1 0 1]);
		%% TEMP
		print('-dtiff', ['~/Desktop/tau/filled_' obj.idStr '.tif']);
		close(ff);
	end

%
% single animal plot of tau etc. evo
%
function single_animal_gcamp_health_plot(an_id, f_id_str, filled_mat, ce_rat_mat, lum_rat_mat, min_tau_mat, ksd_tau_mat, key_rois, print_on)
  plot_max_min_tau = 5000;
  plot_max_ksd_tau = 5000;

  % compile day-by-day
	for f=1:length(f_id_str)
	  % get day # for this day
		undscr_idx = find(f_id_str{f} == '_');
		dot_idx = find(f_id_str{f} == '.');
		date_str = strrep(f_id_str{f}(undscr_idx(length(undscr_idx)-2)+1:dot_idx(length(dot_idx))-1),'_','/');
		date_str = strrep(date_str,'a','');
		date_str = strrep(date_str,'b','');
		date_str = strrep(date_str,'c','');
		day_num(f) = datenum(date_str);

		% compile parameters
		ce_rat(f) = nanmean(ce_rat_mat(f,:));
		ce_rat_sd(f) = nanstd(ce_rat_mat(f,:));
		nce(f) = length(find(~isnan(ce_rat_mat(f,:))));
		lum_rat(f) = nanmean(lum_rat_mat(f,:));
		lum_rat_sd(f) = nanstd(lum_rat_mat(f,:));
		nlum(f) = length(find(~isnan(lum_rat_mat(f,:))));
		min_tau(f) = nanmean(min_tau_mat(f,:));
		min_tau_sd(f) = nanstd(min_tau_mat(f,:));
		nmintau(f) = length(find(~isnan(min_tau_mat(f,:))));
		ksd_tau(f) = nanmean(ksd_tau_mat(f,:));
		ksd_tau_sd(f) = nanstd(ksd_tau_mat(f,:));
		nksdtau(f) = length(find(~isnan(ksd_tau_mat(f,:))));
		pct_filled(f) = length(find(filled_mat(f,:)))/length(filled_mat(f,:));
	end
	day_num = day_num - min(day_num); % align day # to 0

	f1 = figure;
  % dirty plot of taus -- all taus 
	subplot(2,2,1);
	hold on;
	plot(ksd_tau_mat);
	title([an_id ': raw taus']);
	xlabel('day');
	ylabel('tau (ms) ksd based');
	axis([-1 31 0 plot_max_ksd_tau]);

	% now plot taus across ROIs, weighed equally per ROI
	subplot(2,2,2);
	hold on;
	plot_with_errorbar(day_num, ksd_tau, ksd_tau_sd./sqrt(nksdtau), [1 0 1]);
	plot_with_errorbar(day_num, min_tau, min_tau_sd./sqrt(nmintau), [0 1 1]);
	set(gca, 'TickDir', 'out');
	title('mean +/- SE (ALL plots)');
	ylabel('tau (ms) [mag=ksd ; cyan=min]');
	xlabel('day');
	axis([-1 31 0 2000]);

	% plot c/e ratio
	subplot(2,2,3);
	hold on;
	plot_with_errorbar(day_num, ce_rat, ce_rat_sd./sqrt(nce), [0 0 0]);
	set(gca, 'TickDir', 'out');
	ylabel('Center:Edge lum. ratio');
	xlabel('day');
	axis([-1 31 0.8 1.2]);

	% lum:median lum ratio
	subplot(2,2,4);
	hold on;
	plot_with_errorbar(day_num, lum_rat, lum_rat_sd./sqrt(nlum), [0 0 0]);
	set(gca, 'TickDir', 'out');
	ylabel('roi lum:median img lum ratio');
	xlabel('day');
	m = floor(10*min(lum_rat))/10;
	axis([-1 31 m m+0.6]);


	f2 = figure;
  % # filled
	subplot(2,2,1);
	hold on;
	plot(day_num, 100*pct_filled, 'ko', 'MarkerFaceColor', [0 0 0]);
	title(an_id);
	xlabel('day');
	ylabel('% filled');
	set(gca, 'TickDir', 'out');
	axis([-1 31 0 40]);

	% ksd tau min tau corr
	ksd_tau_vec = reshape(ksd_tau_mat,[],1);
	min_tau_vec = reshape(min_tau_mat,[],1);
  ce_rat_vec = reshape(ce_rat_mat, [], 1);
  filled_vec = reshape(filled_mat, [], 1);
  lum_rat_vec = reshape(lum_rat_mat, [], 1);
	val = find(~isnan(ksd_tau_vec) & ~isnan(min_tau_vec) & ~isnan(ce_rat_vec) & ~isnan(lum_rat_vec));
	filled = intersect(val, find(filled_vec));
	subplot(2,2,2);
	plot(ksd_tau_vec(val),min_tau_vec(val),'bo', 'MarkerFaceColor', [0 0 1]);
	hold on;
	plot(ksd_tau_vec(filled),min_tau_vec(filled),'ro', 'MarkerFaceColor', [1 0 0]);
	xlabel('ksd tau');
	ylabel('min tau');
	set(gca, 'TickDir', 'out');
	axis([0 plot_max_ksd_tau 0 plot_max_ksd_tau]);

  % ce v lum
	subplot(2,2,3);
	plot(ce_rat_vec(val),lum_rat_vec(val),'bo', 'MarkerFaceColor', [0 0 1]);
	hold on;
	plot(ce_rat_vec(filled),lum_rat_vec(filled),'ro', 'MarkerFaceColor', [1 0 0]);
	xlabel('c:e ratio');
	ylabel('lum ratio');
	set(gca, 'TickDir', 'out');
	axis([0 2 0 10]);

  % fill v. tau corr 
	subplot(2,2,4);
	hold on;
	plot(ksd_tau_vec(val),ce_rat_vec(val),'ko', 'MarkerFaceColor', [0 0 0]);
	xlabel('ksd tau');
	ylabel('c:e ratio');
	set(gca, 'TickDir', 'out');
	axis([0 plot_max_ksd_tau 0 2]);



  % --- key rois
	f3 = figure;
	colors = [0 0 0 ; 1 0 0 ; 0 1 0; 0 0 1; 1 0 1 ; 0 1 1 ; 0.5 0 0 ; 0 0.5 0 ; 0 0 0.5];
	for k=1:length(key_rois)
	  min_taus = min_tau_mat(:,key_rois(k));
	  ksd_taus = ksd_tau_mat(:,key_rois(k));
	  ce_rats = ce_rat_mat(:,key_rois(k));
	  filled_rois = filled_mat(:,key_rois(k));
	  lum_rats = lum_rat_mat(:,key_rois(k));

		% plot ..
		subplot(2,2,1); if (k == 1) ; hold on; set(gca, 'TickDir', 'out'); end
		plot(day_num, ksd_taus, 'o-', 'MarkerFaceColor', colors(k,:), 'MarkerSize', 5, 'Color', colors(k,:));

		subplot(2,2,2); if (k == 1) ; hold on; set(gca, 'TickDir', 'out'); end
		plot(day_num, min_taus, 'o-', 'MarkerFaceColor', colors(k,:), 'MarkerSize', 5, 'Color',  colors(k,:));

		subplot(2,2,3); if (k == 1) ; hold on; set(gca, 'TickDir', 'out'); end
		plot(day_num, ce_rats, 'o-', 'MarkerFaceColor', colors(k,:), 'MarkerSize', 5, 'Color',  colors(k,:));
		if (k <= 5)
			text(5*(k-1)+1, .35, num2str(key_rois(k)), 'Color', colors(k,:));
		else
			text(5*(k-6)+1, .1, num2str(key_rois(k)), 'Color', colors(k,:));
		end

		subplot(2,2,4); if (k == 1) ; hold on; set(gca, 'TickDir', 'out'); end
		plot(day_num, lum_rats, 'o-', 'MarkerFaceColor', colors(k,:), 'MarkerSize', 5, 'Color',  colors(k,:));
	end
	% plot clean
	subplot(2,2,1);
	title(an_id);
	ylabel('ksd tau');
	xlabel('day');
	axis([-1 31 0 plot_max_ksd_tau]);

	subplot(2,2,2);
	ylabel('min tau');
	xlabel('day');
	axis([-1 31 0 plot_max_min_tau]);

	subplot(2,2,3);
	ylabel('c:e lum ratio');
	xlabel('day');
	plot([-1 31], [1.05 1.05], 'k:');
	axis([-1 31 0 2]);

	subplot(2,2,4);
	ylabel('roi:img lum ratio');
	xlabel('day');
	axis([-1 31 0 4]);

  % print
	if (print_on)
	  figure(f1);
		print('-dpdf', ['~/Desktop/tau/' an_id '_summ1.pdf']);
	  figure(f2);
		print('-dpdf', ['~/Desktop/tau/' an_id '_summ2.pdf']);
	  figure(f3);
		print('-dpdf', ['~/Desktop/tau/' an_id '_key_rois.pdf']);
  end
