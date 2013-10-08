%
% plots good & bad taus for given roi, session.
%  1) good/bad traces
%  2) peak dff norm'd good/bad traces
%  3) good/bad tau distro
%  4) good/bad dff peak distro
%
% c: s.caTSA object
% rid: roi ID
% ax: axes (2)
%
function ca_time_constants_plot_goodbad(c, rid, ax)
  ri = find(c.ids == rid);
	ntpp = 20; % assume uniform timing for now . . .
	ntpn = 4; % before ...

  % setup if no axes
	if ( nargin < 3 || length(ax) == 0)
	  figure;
	  ax(1) = subplot(2,3,1);
		ax(2) = subplot(2,3,2);
	  ax(3) = subplot(2,3,4);
		ax(4) = subplot(2,3,5);
		ax(5) = subplot(2,3,3);
		ax(6) = subplot(2,3,6);
	end

  % for ease of use
	esa = c.caPeakEventSeriesArray.esa{ri};
	dect = esa.decayTimeConstants;
	L = length(c.time);

  % sanity!
	if (length(dect) > 0)
	  goodidx = find(dect > 0);
    badidx = find(dect< 0);

    % get good/bad taus
		goodtaus = dect(goodidx);
		badtaus = -1*dect(badidx);

		% skip if :(
		if (length(goodtaus) < 1 | length(badtaus) < 1) ; return ; end
		% setup matrices
		goodmat = nan*zeros(length(goodidx), ntpn+ntpp);
		badmat = nan*zeros(length(badidx), ntpn+ntpp);

    % get pooling good/bad traces data ...
		for g=1:length(goodidx)
		  pi = find(c.time == esa.eventTimes(goodidx(g)));
			si = max(1, pi-ntpn);
			ei = min(L, pi+ntpp-1);
			if (pi-ntpn <= 0) ; disp('akk') ; continue ;end
			goodmat(g,1:(ei-si+1)) = c.dffTimeSeriesArray.valueMatrix(ri,si:ei);
		end
		for b=1:length(badidx)
		  pi = find(c.time == esa.eventTimes(badidx(b)));
			si = max(1, pi-ntpn);
			ei = min(L, pi+ntpp-1);
			if (pi-ntpn <= 0) ; disp('akk'); continue ;end
			badmat(b,1:(ei-si+1)) = c.dffTimeSeriesArray.valueMatrix(ri,si:ei);
		end

		% get good/bad peak dff
		goodpeakdff = goodmat(:,ntpn+1);
		badpeakdff = badmat(:,ntpn+1);

		% 1) dff RAW of good/bad 
    axes(ax(1));
		cla;
		hold on;
		dt = mode(diff(c.time));
		timevec = dt*(-1*ntpn:ntpp-1);
	
		for g=1:length(goodidx)
		  plot(timevec, goodmat(g,:), 'k-');
		end
		A1 = axis;
%	  plot(timevec, nanmean(goodmat), 'r-', 'LineWidth', 2);
    axes(ax(2));
		cla;
		hold on;
		for b=1:length(badidx)
		  plot(timevec, badmat(b,:), 'r-');
		end
		A2 = axis;
%	  plot(timevec, nanmean(badmat), 'r-', 'LineWidth', 2);

    % same axis ..
		tb(1) = (floor(min(timevec)/1000))*1000;
		tb(2) = (ceil(max(timevec)/1000))*1000;
		axes(ax(1)) ; axis([tb(1) tb(2) min(A1(3),A2(3)) max(A1(4),A2(4))]);
		title(['accepted (roi ID ' num2str(rid) ')']);
		axes(ax(2)) ; axis([tb(1) tb(2) min(A1(3),A2(3)) max(A1(4),A2(4))]);
		title(['rejected (' strrep(c.roiArray.idStr, '_','-') ')' ]);

		% 2) dff peak norm'dof good/bad 
    axes(ax(3));
		cla;
		hold on;
		dt = mode(diff(c.time));
		timevec = dt*(-1*ntpn:ntpp-1);
		for g=1:length(goodidx)
		  plot(timevec, goodmat(g,:)/goodmat(g,ntpn+1), 'Color', [0.5 0.5 0.5]);
		end
		nmgd = nanmean(goodmat);
	  plot(timevec(ntpn+1:end), nmgd(ntpn+1:end)/nmgd(ntpn+1), 'k-', 'LineWidth', 2);
    axes(ax(4));
		cla;
		hold on;
		for b=1:length(badidx)
		  plot(timevec, badmat(b,:)/badmat(b,ntpn+1), 'Color', [1 0.5 0.5]);
		end
		nmbd = nanmean(badmat);
	  plot(timevec(ntpn+1:end), nmbd(ntpn+1:end)/nmbd(ntpn+1), 'r-', 'LineWidth', 2);
	  plot(timevec(ntpn+1:end), nmgd(ntpn+1:end)/nmgd(ntpn+1), 'k-', 'LineWidth', 2);

    % same axis ..
		axes(ax(3)) ; axis([tb(1) tb(2) -0.25 1.25]);
		axes(ax(4)) ; axis([tb(1) tb(2) -0.25 1.25]);


    % 3) good/bad tau distro
		% plot good/bad taus
		axes(ax(5));
		cla;
		plot(1+0*goodtaus, goodtaus, 'ko');
		hold on;
		plot([0.8 1.2] , [1 1]*nanmedian(goodtaus), 'k-');
		if (length(goodtaus) > 2)
			[pdf xi] = ksdensity(goodtaus);
			[irr idx] = max(pdf);
			modetau = xi(idx);
			plot(1.3, modetau, 'ko', 'MarkerFaceColor', [0 0 0]);
		end

		plot(2+0*badtaus, badtaus, 'ro');
		plot([1.8 2.2] , [1 1]*nanmedian(badtaus), 'r-');
		if (length(badtaus) > 2)
			[pdf xi] = ksdensity(badtaus);
			[irr idx] = max(pdf);
			modetau = xi(idx);
			plot(1.7, modetau, 'ro', 'MarkerFaceColor', [1 0 0]);
		end
		A = axis;
		axis([0 3 0 5000]);
		title('Decay taus (-:median ; o:PDF peak)');


    % 4) good/bad dff peak distro

		% plot good/bad peakdff
		axes(ax(6));
		cla;
		plot(1+0*goodpeakdff, goodpeakdff, 'ko');
		hold on;
		plot([0.8 1.2] , [1 1]*nanmedian(goodpeakdff), 'k-');

		plot(2+0*badpeakdff, badpeakdff, 'ro');
		plot([1.8 2.2] , [1 1]*nanmedian(badpeakdff), 'r-');
		A = axis;
		axis([0 3 0 2]);
		title('Peak dF/F');
	end
