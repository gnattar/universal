%
% computes pixel value/photon (i.e., system gain)
%
function pix_per_photon
	pmt_volt = 500:100:800;
  pidx = 4;
  
	colors = [1 0 0 ; 0 1 0 ; 0 0 1 ; 0 0 0 ; 1 0 1];

  figure;
	hold on;
  
	sg = [];
	vmg = [];
	for p=1:length(pmt_volt)
	  pmtv = pmt_volt(p);
	  fl = dir(['ppp_pmt_' sprintf('%03d', pmtv) '_power*001.tif']);
		fn = {};
		power = [];
		for f=1:length(fl)
     fl(f).name
		  i_ = find(fl(f).name == '_');
			power(f) = str2num(fl(f).name(i_(pidx)+1:i_(pidx+1)-1));
			fn{f} = fl(f).name;
		end
		[sg(p) vmg(p)] = compute_ppp(fn, power, pmtv, colors(p,:));
	end

	% legends
	A = axis;
	R1 = range(A(1:2));
	R2 = range(A(3:4));
	for p=1:length(pmt_volt)
	  text(A(1)+0.5*R1, A(2)+0.8*R2 - (p/length(pmt_volt))*R2/4, ...
		  ['PMT voltage: .' num2str(pmt_volt(p)) ' gain from v/m: ' num2str(vmg(p)) ' slope: ' num2str(sg(p))], ...
			'Color', colors(p,:));
	end
	set (gca,'TickDir','out');
	xlabel('mean pixel value');
	ylabel('variance of pixel values');

%
% process single setting across powers
%
function [slopeGain varMuGain] = compute_ppp(fn, power, pmtv, color)
  for p=1:length(power)
	  disp(['processing ' fn{p}]);
	  im = load_image(fn{p});
    
		% vectorize middle
    S = size(im);
    S4 = round(S/4);
		vec = reshape(im(S4(1):3*S4(1), S4(2):3*S4(2),:),[],1);

		% mean, sd
		mu(p) = mean(vec);

		% variance
		v(p) = var(vec);

		% gain factor
		g(p) = v(p)/mu(p);
	end

  % fit polynomial
  pf = polyfit(mu,v,1);

  % give results
  disp(['PMT voltage: ' num2str(pmtv) ' v/mu method: ' num2str(mean(g)) ' (sd: ' num2str(std(g)) ')']);
  disp(['PMT voltage: ' num2str(pmtv) ' slope fit method: ' num2str(pf(1)) ' offset: ' num2str(pf(2))]);

	% offset-corrected v/mu
	corrv = v-pf(2);
	corrg = corrv./mu;
  disp(['PMT voltage: ' num2str(pmtv) ' offset corrected v/mu method: ' num2str(mean(corrg)) ' (sd: ' num2str(std(corrg)) ')']);

	% plot
  plot (mu,v,'ko');
	plot(mu,polyval(pf,mu),'-', 'Color', color);

	% return
	slopeGain = pf(1);
	varMuGain = mean(corrg);


