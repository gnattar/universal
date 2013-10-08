% summary plotter ; assumes file is loaded
% variables:
%   kappaDiff  
%   kappaDiffRelMedian  
%   lenDiff             
%   maxD             
%   mp4files        
%   polyD           
%   seqfiles         
%   thetaDiff
%
% USAGE:
%
%   mp4vseq_plotter(kappaDiff, kappaDiffRelMedian , lenDiff , maxD , mp4files , polyD , seqfiles, thetaDiff)
%
function mp4vseq_plotter(kappaDiff, kappaDiffRelMedian , lenDiff , maxD , mp4files , polyD , seqfiles, thetaDiff)

% data to use
trAgD = 2; 
trAgW = 2;
trSingEx = 13;

lprD = '/Users/speron/writing/presentations/misc/2011_12_28_mp4vsseq';
lpr = 1;

% -- difference in polynomials (polyD, maxD)
plotAvgDifference(polyD, 'mean polynomial distance (pixels)');
if (lpr) ; print ('-dpng', [lprD filesep 'avgdiff_meanPolyD.png']); end
plotSingleExample(polyD, 'mean polynomial distance (pixels)',trSingEx);
if (lpr) ; print ('-dpng', [lprD filesep 'singex_meanPolyD.png']); end
plotTrialAggregate (polyD, 'mean polynomial distance(pixels)', trAgD, trAgW, 1:3500, 0:0.1:10);
if (lpr) ; print ('-dpng', [lprD filesep 'tragg_meanPolyD.png']); end

plotAvgDifference(maxD, 'max polynomial distance (pixels)');
if (lpr) ; print ('-dpng', [lprD filesep 'avgdiff_maxPolyD.png']); end
plotSingleExample(maxD, 'max polynomial distance (pixels)',trSingEx);
if (lpr) ; print ('-dpng', [lprD filesep 'singex_maxPolyD.png']); end
plotTrialAggregate (maxD, 'max polynomial distance(pixels)', trAgD, trAgW, 1:3500, 0:1:50);
if (lpr) ; print ('-dpng', [lprD filesep 'tragg_maxPolyD.png']); end

% -- difference in lengths
plotAvgDifference(lenDiff, 'length difference (pixels)');
if (lpr) ; print ('-dpng', [lprD filesep 'avgdiff_lenD.png']); end
plotSingleExample(lenDiff, 'length difference (pixels)',trSingEx);
if (lpr) ; print ('-dpng', [lprD filesep 'singex_lenD.png']); end
plotTrialAggregate (lenDiff, 'length difference(pixels)', trAgD, trAgW, 1:3500, -50:1:50);
if (lpr) ; print ('-dpng', [lprD filesep 'tragg_lenD.png']); end

% -- difference in theta
plotAvgDifference(thetaDiff, 'theta difference (deg)');
if (lpr) ; print ('-dpng', [lprD filesep 'avgdiff_thetaD.png']); end
plotSingleExample(thetaDiff, 'theta difference (deg)',trSingEx);
if (lpr) ; print ('-dpng', [lprD filesep 'singex_thetaD.png']); end
plotTrialAggregate (thetaDiff, 'theta difference(deg)', trAgD, trAgW, 1:3500, -5:.05:5);
if (lpr) ; print ('-dpng', [lprD filesep 'tragg_thetaD.png']); end

% -- difference in kappas
plotAvgDifference(kappaDiff, 'kappa difference (1/pixels)');
if (lpr) ; print ('-dpng', [lprD filesep 'avgdiff_kappaD.png']); end
plotSingleExample(kappaDiff, 'kappa difference (1/pixels)',trSingEx);
if (lpr) ; print ('-dpng', [lprD filesep 'singex_kappaD.png']); end
plotTrialAggregate (kappaDiff, 'kappa difference(1/pix)', trAgD, trAgW, 1:3500, -0.0005:.00001:.0005);
if (lpr) ; print ('-dpng', [lprD filesep 'tragg_kappaD.png']); end

plotAvgDifference(kappaDiffRelMedian, 'kappa difference, normd to median trial kappa (unitless)');
if (lpr) ; print ('-dpng', [lprD filesep 'avgdiff_normKappaDD.png']);  end
plotSingleExample(kappaDiffRelMedian, 'kappa difference, normd to median trial kappa (unitless)',10);
if (lpr) ; print ('-dpng', [lprD filesep 'singex_normKappaDD.png']);  end
plotTrialAggregate (kappaDiffRelMedian, 'kappa difference normd to med', trAgD, trAgW, 1:3500, -1:0.05:1);
if (lpr) ; print ('-dpng', [lprD filesep 'tragg_normKappaDD.png']);  end

function plotTrialAggregate (var, varname, d, w, xvals, yvals)
  figure ; 
	ax = axes;

	hold on ;
	nt = length(var{d});
	mdi = 2*median(abs(diff(yvals)));

  heatmat = zeros(length(yvals),length(xvals));

  for t=1:nt
	  % pull vector
		if (size(var{d}{1},1) > size(var{d}{1},2)) 
			vec = var{d}{t}(:,w);
		else
			vec = var{d}{t}(w,:);
		end
		fi = 1:length(vec);
		valfi = fi(find(ismember(fi,xvals)));
     
		% count ... only if near yvals
		xi = 1;
    for f=valfi
		  [md yvi]= min(abs(yvals - vec(f)));

			if (md < mdi)
				heatmat(yvi, xi) = heatmat(yvi,xi) + 1;
			end
			xi = xi+1;
		end
	end

%  imshow(heatmat, [0 max(max(heatmat))], 'Parent', ax);
  imagesc(heatmat, 'Parent' , ax);
	colormap(jet);

  dv = floor(length(yvals)/12);
  for v=1:11
	  yt(v) = dv*v;
    yv(v) = yvals(yt(v));
		yl{v} = num2str(yv(v));
  end
  
  % tickmark at zero
  if (min(yvals) <= 0 & max(yvals) >= 0 & ~ismember(0, yv))
    yzero = interp1(yv, yt, 0, 'linear', 'extrap');
    yt(v+1) = yzero;
    [yt idx] = sort(yt);
    yl{v+1} = '0';
    yl = yl(idx);
  end
  
  set (ax, 'YTickMode', 'manual', 'YTick' ,  yt, 'YTickLabel', yl, 'TickDir', 'out');

	xlabel('frame');
	ylabel (varname);
	title('Density across all trials (S-M)');
	colorbar;


function plotSingleExample (var, varname, trialnum)
  figure ; 
	wtags = {{'c2'},{'c1','c2','c3'}};

	hold on ;

  colors = [0 0 0; 1 0 0 ; 0 1 0 ; 0 0 1 ; 1 1 0 ; 1 0 1];
  nd = length(var);
	ci = 1;
	mvec = [];
	for d=1:nd
	  nt = length(var{d});


    nw = min(size(var{d}{1},1), size(var{d}{1},2)); 

		for w=1:nw
      if (size(var{d}{1},1) > size(var{d}{1},2)) 
				vec = var{d}{trialnum}(:,w);
			else
				vec = var{d}{trialnum}(w,:);
			end
			plot(vec,  'Color', colors(ci,:));
      
			lstr{ci} = ['Day '  num2str(d)  ' ' wtags{d}{w}];
			ci = ci+1;
		end
	end
	legend(lstr);

	xlabel('frame');
	ylabel ( varname);



function plotAvgDifference (var, varname)
  figure ; 

	subplot (2,1,1);
	hold on ;
	wtags = {{'c2'},{'c1','c2','c3'}};

  colors = [0 0 0; 1 0 0 ; 0 1 0 ; 0 0 1 ; 1 1 0 ; 1 0 1];
  nd = length(var);
	ci = 1;
	mvec = [];
	for d=1:nd
	  nt = length(var{d});


    nw = min(size(var{d}{1},1), size(var{d}{1},2)); 

		for w=1:nw
		  vec = nan*zeros(1,nt);
      if (size(var{d}{1},1) > size(var{d}{1},2)) 
				for t=1:nt ; vec(t) = nanmean(var{d}{t}(w,:)); end
			else
				for t=1:nt ; vec(t) = nanmean(var{d}{t}(:,w)); end
			end
			mvec = [mvec vec];
			plot(vec, '.', 'Color', colors(ci,:));
      
			lstr{ci} = ['Day '  num2str(d) ' ' wtags{d}{w}];
			ci = ci+1;
		end
	end
	legend(lstr);

	xlabel('trial');
	lab = ['mean ' varname];
	spidx = find(lab == ' ');
	spi = ceil(length(spidx)/2);
	labc = {lab(1:spidx(spi)),lab(spidx(spi)+1:end)};
	ylabel(labc);

	% histo
  subplot(2,1,2);
	hist(mvec,100);
	xlabel ([ 'mean ' varname]);
	ylabel('count');


