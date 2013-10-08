%
% Plotter for ca time constants
%
function ca_time_constant_plots
	fl = {'an38596',	'an107028','an94953','an107029',...
      'an93098','jf25609','jf26707','jf27332', ...
			'jf25607', 'jf100601'};
	doffs = [21 21 22 20 21 14 21 20 14 20]; % post injection
	rids = {[42 38 65 19 6 2 57],[236 2 12 202 208 13 108],[2 12 5 158 243 ], ...
	  [1 266 36 4 140 233],[17 8 12 213 46 132],...
		[11 30 124 271 21], [12 19 52 47 103], [107 42 67 136 126 234], ...
		[48 35 286 70 112 183],[25 12 13 120 85]};
  
	% who to show
	F = 1:10;
	N=length(F);

	% --- plot across days one animal / panel
	ftau = figure;
	flums = figure;

	for f=F
		load (['~/Desktop/ca_tc_plots/' fl{f} '/session2/ca_time_constants_output.mat']);

		% tau ACROSS DAYS pooled cross ROIS
		figure(ftau);
	  subplot(5,2,f);
		colors = [1 0 0 ; 0 0 1 ; 0 0 0];
		taus_pooled_cross_day_plot(out, doffs(f), [1 1 1], colors);
		title(fl{f});
		axis([10 60 0 1000]);
		if (f == 8) ; xlabel('Days post injection'); end
		if (f == 3) ; ylabel('Time constant (ms)'); end
		if (f == 4)
			text(50,600, 't_1_/_2 modal tau', 'Color', colors(1,:));
			text(50,800, 'GOF modal tau', 'Color', colors(2,:));
			text(50,400, 'GOF 10th quantile tau', 'Color', colors(3,:));
		end

		% lums ACROSS DAYS pooled cross ROIS
		figure(flums);
	  subplot(5,2,f);
		colors = [1 0 0; 0 0 1];
		lums_pooled_cross_day_plot(out, doffs(f), [1 1], colors);
		title(fl{f});
		axis([10 60 0.5 1.5]);
		if (f == 8) ; xlabel('Days post injection'); end
		if (f == 3) ; ylabel('Luminance ratio'); end
		if (f == 4)
			text(50,1.2, 'Center:Surround', 'Color', colors(1,:));
			text(50,0.8, 'Center:Edge', 'Color', colors(2,:));
		end
	end

	% --- plot across days, one parameter / panel
	fcrossam = figure;

	colors = [1 0 0; 0 1 0; 0 0 1; 1 0 1 ; 0 1 1];

	figure(fcrossam);
	F2 = 1:5; % list of animals
	for fi=1:length(F2)
	  f = F2(fi);
		load (['~/Desktop/ca_tc_plots/' fl{f} '/session2/ca_time_constants_output.mat']);

		% GOF modal tau
		tcolors = [colors(fi,:) ; colors(fi,:) ; colors(fi,:)];
	  subplot(5,2,1);
		taus_pooled_cross_day_plot(out, doffs(f) + (fi-1)*0.1 - 0.4, [0 1 0], tcolors);
		title('GOF modal tau');
		axis([10 60 250 1000]);

		% 'legend'
		text(11,200 + fi*100, fl{f}, 'Color', colors(fi,:))

		% t12 modal tau
		tcolors = [colors(fi,:) ; colors(fi,:) ; colors(fi,:)];
	  subplot(5,2,3);
		taus_pooled_cross_day_plot(out, doffs(f) + (fi-1)*0.1 - 0.4, [1 0 0], tcolors);
		title('t12 modal tau');
		axis([10 60 0 750]);

		% gof 10th q tau
		tcolors = [colors(fi,:) ; colors(fi,:) ; colors(fi,:)];
	  subplot(5,2,5);
		taus_pooled_cross_day_plot(out, doffs(f) + (fi-1)*0.1 - 0.4, [0 0 1], tcolors);
		title('GOF 10th quantile tau tau');
		axis([10 60 0 750]);

		% C:S ratio
		tcolors = [colors(fi,:) ; colors(fi,:)];
	  subplot(5,2,7);
		lums_pooled_cross_day_plot(out, doffs(f) + (fi-1)*0.1 - 0.4, [1 0], tcolors);
		title('Center:Surround');
		axis([10 60 0.9 1.2]);

		% C:E ratio
		tcolors = [colors(fi,:) ; colors(fi,:)];
	  subplot(5,2,9);
		lums_pooled_cross_day_plot(out, doffs(f) + (fi-1)*0.1 - 0.4, [0 1], tcolors);
		title('Center:Edge');
		axis([10 60 0.7 1.1]);
		xlabel('Days post injection');
	end

	% --- plot across days, one parameter / panel
	colors = [1 0 0; 0 1 0; 0 0 1; 1 0 1 ; 0 1 1];

	figure(fcrossam);
	F2 = 6:10; % list of animals
	for fi=1:length(F2)
	  f = F2(fi);
		load (['~/Desktop/ca_tc_plots/' fl{f} '/session2/ca_time_constants_output.mat']);

		% GOF modal tau
		tcolors = [colors(fi,:) ; colors(fi,:) ; colors(fi,:)];
	  subplot(5,2,2);
		taus_pooled_cross_day_plot(out, doffs(f) + (fi-1)*0.1 - 0.4, [0 1 0], tcolors);
		title('GOF modal tau');
		axis([5 35 250 1000]);

		% 'legend'
		text(11,200 + fi*100, fl{f}, 'Color', colors(fi,:))

		% t12 modal tau
		tcolors = [colors(fi,:) ; colors(fi,:) ; colors(fi,:)];
	  subplot(5,2,4);
		taus_pooled_cross_day_plot(out, doffs(f) + (fi-1)*0.1 - 0.4, [1 0 0], tcolors);
		title('t12 modal tau');
		axis([5 35 0 750]);

		% gof 10th q tau
		tcolors = [colors(fi,:) ; colors(fi,:) ; colors(fi,:)];
	  subplot(5,2,6);
		taus_pooled_cross_day_plot(out, doffs(f) + (fi-1)*0.1 - 0.4, [0 0 1], tcolors);
		title('GOF 10th quantile tau');
		axis([5 35 0 750]);

		% C:S ratio
		tcolors = [colors(fi,:) ; colors(fi,:)];
	  subplot(5,2,8);
		lums_pooled_cross_day_plot(out, doffs(f) + (fi-1)*0.1 - 0.4, [1 0], tcolors);
		title('Center:Surround');
		axis([5 35 0.9 1.4]);

		% C:E ratio
		tcolors = [colors(fi,:) ; colors(fi,:)];
	  subplot(5,2,10);
		lums_pooled_cross_day_plot(out, doffs(f) + (fi-1)*0.1 - 0.4, [0 1], tcolors);
		title('Center:Edge');
		axis([5 35 0.7 1.3]);
		xlabel('Days post injection');
	end

	% --- plot across days, one parameter per roi-session  -- assume rids = ridx(!)
	frgmtau = figure();
	frg10qtau = figure();
	frt12mtau = figure();
	fgtau = figure();
	ft12tau = figure();
	fcelum = figure();
	fcslum = figure();
	for f=F
		load (['~/Desktop/ca_tc_plots/' fl{f} '/session2/ca_time_constants_output.mat']);
		colors = [1 0 0 ; 0 0 1 ; 1 0 1; 0 1 0; 0 1 1 ; 1 0.5 0 ; 0 0 0];

		% tau ACROSS DAYS for individual ROIs
		figure(frgmtau);
	  subplot(5,2,f);
		ridx = rids{f};
		for r=1:min(7,length(ridx))
      oneroi_taus_pooled_cross_day_plot(out, doffs(f)-0.3 + 0.1*r, ridx(r), [0 0 1 0 0], colors(r,:))
			text(11+5*mod(r,2),r*200, [num2str(ridx(r))], 'Color', colors(r,:));
		end
		title([fl{f} ' GOF tau mode']);
		axis([10 60 0 2500]);
		if (f == N) ; xlabel('Days post injection'); end
		if (f == 1) ; ylabel('Time constant (ms)'); end

		% tau ACROSS DAYS for individual ROIs
		figure(frg10qtau);
	  subplot(5,2,f);
		ridx = rids{f};
		for r=1:min(7,length(ridx))
      oneroi_taus_pooled_cross_day_plot(out, doffs(f)-0.3 + 0.1*r, ridx(r), [0 0 0 1 0], colors(r,:))
			text(11+5*mod(r,2),r*200, [num2str(ridx(r))], 'Color', colors(r,:));
		end
		title([fl{f} ' GOF tau 10th quantile']);
		axis([10 60 0 2500]);
		if (f == N) ; xlabel('Days post injection'); end
		if (f == 1) ; ylabel('Time constant (ms)'); end

		% tau ACROSS DAYS for individual ROIs
		figure(frt12mtau);
	  subplot(5,2,f);
		ridx = rids{f};
		for r=1:min(7,length(ridx))
      oneroi_taus_pooled_cross_day_plot(out, doffs(f)-0.3 + 0.1*r, ridx(r), [0 0 0 0 1], colors(r,:))
			text(11+5*mod(r,2),r*200, [num2str(ridx(r))], 'Color', colors(r,:));
		end
		title([fl{f} ' T12 tau mode']);
		axis([10 60 0 2500]);
		if (f == N) ; xlabel('Days post injection'); end
		if (f == 1) ; ylabel('Time constant (ms)'); end

		% tau ACROSS DAYS for individual ROIs
		figure(fgtau);
	  subplot(5,2,f);
		ridx = rids{f};
		for r=1:min(7,length(ridx))
      oneroi_taus_pooled_cross_day_plot(out, doffs(f)-0.3 + 0.1*r, ridx(r), [1 0 0 0 0], colors(r,:))
			text(11+5*mod(r,2),r*200, [num2str(ridx(r))], 'Color', colors(r,:));
		end
		title([fl{f} ' T12 tau distro']);
		axis([10 60 0 2500]);
		if (f == N) ; xlabel('Days post injection'); end
		if (f == 1) ; ylabel('Time constant (ms)'); end

		% tau ACROSS DAYS for individual ROIs
		figure(ft12tau);
	  subplot(5,2,f);
		ridx = rids{f};
		for r=1:min(7,length(ridx))
      oneroi_taus_pooled_cross_day_plot(out, doffs(f)-0.3 + 0.1*r, ridx(r), [0 1 0 0 0], colors(r,:))
			text(11+5*mod(r,2),r*200, [num2str(ridx(r))], 'Color', colors(r,:));
		end
		title([fl{f} ' GOF tau distro']);
		axis([10 60 0 2500]);
		if (f == N) ; xlabel('Days post injection'); end
		if (f == 1) ; ylabel('Time constant (ms)'); end

		% lums ACROSS DAYS for individual ROIs
		figure(fcelum);
	  subplot(5,2,f);
		ridx = rids{f};
		for r=1:min(7,length(ridx))
      oneroi_lums_pooled_cross_day_plot(out, doffs(f)-0.3 + 0.1*r, ridx(r), [0 1], colors(r,:))
			text(11+5*mod(r,2),0.5+r*0.2, [num2str(ridx(r))], 'Color', colors(r,:));
		end
		title([fl{f} ' Center:Edge distro']);
		axis([10 60 0.5 2.5]);
		if (f == N) ; xlabel('Days post injection'); end
		if (f == 1) ; ylabel('Time constant (ms)'); end

		% lums ACROSS DAYS for individual ROIs
		figure(fcslum);
	  subplot(5,2,f);
		ridx = rids{f};
		for r=1:min(7,length(ridx))
      oneroi_lums_pooled_cross_day_plot(out, doffs(f)-0.3 + 0.1*r, ridx(r), [1 0], colors(r,:))
			text(11+5*mod(r,2),0.5+r*0.5, [num2str(ridx(r))], 'Color', colors(r,:));
		end
		title([fl{f} ' Center:Surround distro']);
		axis([10 60 0.5 5]);
		if (f == N) ; xlabel('Days post injection'); end
		if (f == 1) ; ylabel('Time constant (ms)'); end
	end

return
	% goodbad time constant fits
	rid = rids{find(strcmp(fl,'an38596'))};
	example_GOF_fit('~/data/an38596/session2/an38596_2010_02_05_sess.caTSA.mat', rid);
	example_GOF_fit('~/data/an38596/session2/an38596_2010_02_25_sess.caTSA.mat', rid);
	rid = rids{find(strcmp(fl,'an107028'))};
	example_GOF_fit('~/data/an107028/session2/an107028_2010_08_05_sess.caTSA.mat', rid);
	example_GOF_fit('~/data/an107028/session2/an107028_2010_08_20_sess.caTSA.mat', rid);

%
% wrapper for ca_time_constants_plot_goodbad
%
function example_GOF_fit(fname, rid)
  load(fname);
	obj = saveVar;

	% we need to rerun updateEvents ...
	obj.evdetOpts.evdetMethod = 1; % SD thresh via MAD
	obj.evdetOpts.threshMult = 4; % event must be this much greater 
	obj.evdetOpts.threshStartMult =2;
	obj.evdetOpts.threshEndMult =2;
	obj.evdetOpts.minEvDur = 500; % ms
	obj.evdetOpts.minInterEvInterval = 500; 
	obj.evdetOpts.madPool = 2; % use inactive cells
	obj.evdetOpts.filterType = 2; % prefilter with median
	obj.evdetOpts.filterSize = 10; % in s
	obj.evdetOpts.riseDecayMethod = 2;  % fast DH style
	obj.updateEvents();

	% call it
	for r=1:length(rid)
    ca_time_constants_plot_goodbad(obj, rid(r));
	end



function lums_pooled_cross_day_plot(out, doffs, vars_plotted, colors)
	datevec = get_datevec(out,doffs);

  % --- compute IQRs
	for d=1:length(out.gofTau)
	  cs{d} = out.lumStats{d}.csLumRatios;
	  ce{d} = out.lumStats{d}.ceLumRatios;
	end

	% --- plot out.t12 mode
	hold on;
	if(vars_plotted(1));plot_iqr(datevec, cs, colors(1,:));end
	if(vars_plotted(2));plot_iqr(datevec+0.2, ce, colors(2,:));end

	% misc 
	set(gca,'TickDir', 'out');

function oneroi_lums_pooled_cross_day_plot(out, doffs, ridx, vars_plotted, color)
	datevec = get_datevec(out,doffs);

  % --- compute IQRs
	for d=1:length(out.gofTau)
		cs(d) = out.lumStats{d}.csLumRatios(ridx);
	  ce(d) = out.lumStats{d}.ceLumRatios(ridx);
	end

	% --- plot out
	hold on;
	if (vars_plotted(1)) ;plot (datevec, cs, 'o-', 'Color', color, 'MarkerFaceColor', color); end
	if (vars_plotted(2)) ;plot (datevec, ce, 'o-', 'Color', color, 'MarkerFaceColor', color); end

	% misc 
	set(gca,'TickDir', 'out');

function taus_pooled_cross_day_plot(out, doffs, vars_plotted, colors)
	datevec = get_datevec(out,doffs);
  % loop days 

  % --- compute IQRs
	for d=1:length(out.gofTau)
	  gofmin{d} = out.gofTau{d}.roiMinTau;
	  gofmode{d} = out.gofTau{d}.roiModeTau;
		t12mode{d} = out.t12decayTau{d}.roiModeTau;

	  % calculate 10 %ile tau
		gof10th{d} = nan*gofmin{d};
		for r=1:length(out.gofTau{d}.roiTaus)
		  rts = out.gofTau{d}.roiTaus{r};
			rts = rts(find(rts > 0));
			if (length(rts) > 0)
				gof10th{d}(r) = quantile(rts, 0.1);
			end
		end
			
	end

	% --- plot out
	hold on;
	if (vars_plotted(1)) ; plot_iqr(datevec, t12mode, colors(1,:)); end
	if (vars_plotted(2)) ;plot_iqr(datevec+0.2, gofmode, colors(2,:)); end
%	if (vars_plotted(3)) ;plot_iqr(datevec-0.2, gofmin, colors(3,:)); end
	if (vars_plotted(3)) ;plot_iqr(datevec-0.2, gof10th, colors(3,:)); end

	% misc 
	set(gca,'TickDir', 'out');


function oneroi_taus_pooled_cross_day_plot(out, doffs, ridx, vars_plotted, color)
	datevec = get_datevec(out,doffs);

  % --- compute IQRs
	for d=1:length(out.gofTau)
	  goftaus{d} = out.gofTau{d}.roiTaus{ridx};
		goftaus{d} = goftaus{d}(find(goftaus{d} > 0));
		t12taus{d} = out.t12decayTau{d}.roiTaus{ridx};
		t12taus{d} = t12taus{d}(find(t12taus{d} > 0));

    gof10th(d) = quantile(goftaus{d},0.1);
	  gofmode(d) = out.gofTau{d}.roiModeTau(ridx);
	  gofmin(d) = out.gofTau{d}.roiMinTau(ridx);
	  t12mode(d) = out.t12decayTau{d}.roiModeTau(ridx);
	end

	% --- plot out
	hold on;
	if (vars_plotted(1)) ; plot_iqr(datevec, t12taus, color); end
	if (vars_plotted(2)) ;plot_iqr(datevec+0.2, goftaus, color); end
	if (vars_plotted(3)) ;plot (datevec, gofmode, 'o-', 'Color', color, 'MarkerFaceColor', color); end
	if (vars_plotted(4)) ;plot (datevec, gof10th, 'o-', 'Color', color, 'MarkerFaceColor', color); end
%	if (vars_plotted(4)) ;plot (datevec, gofmin, 'o-', 'Color', color, 'MarkerFaceColor', color); end
	if (vars_plotted(5)) ;plot (datevec, t12mode, 'o-', 'Color', color, 'MarkerFaceColor', color); end

	% misc 
	set(gca,'TickDir', 'out');

%
% wrapper for IQR plotting
%
function plot_iqr(xvals, ycells, color)
	med = nan*(1:length(ycells));
	pct25 = med;
	pct75 = med;
	
	 % --- compute IQRs
	for d=1:length(ycells)
	  v = find(~isnan(ycells{d}));
		vals= ycells{d}(v);
		if (length(vals) > 5)
			med(d) = median(vals);
			pct25(d) = quantile(vals,.25);
			pct75(d) = quantile(vals,.75);
		end
	end

	% --- plot 
	plot_with_errorbar2(xvals, med, pct75-med, med-pct25, color);


function datevec = get_datevec(out, doffs)
  % loop days 
	for f=1:length(out.fname)
		% rip out date, make date vec
		S = out.fname{f};
    if (f == 1) ; disp(S) ; end % for fun
		i1 = strfind(S,'2010_');
		i2 = strfind(S,'_sess');
		if (length(i1) > 0)
			dn(f) = datenum(S(i1:i2-1), 'yyyy_mm_dd');
		else
		  i1 = strfind(S,'x');
			dn(f) = datenum(S(i1+1:i2-1), 'mmddyy');
		end
	end
	datevec = dn-min(dn) + doffs;


