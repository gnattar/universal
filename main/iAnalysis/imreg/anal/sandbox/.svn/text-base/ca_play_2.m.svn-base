plotRaw = 1;
ESA = s.whiskerBarContactESA;
envPredCaFrac = [];
caPredEnvFrac = [];

colors = [1 0 0 ; 0 1 0 ; 0 0 1 ; 1 0 1 ; 1 1 0 ; 0 1 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ( 1 == 1)



%	ESA = s.whiskerBarContactClassifiedESA;
	N = length(ESA.esa);
%for ri= [67]
R= [1 42 17 38 19 67 65 79 51 ];
R = 65;
% 117061 NLS::64n 270n 35y 75n 97n 60n 152y 118y 172n 86n 98n [worst->best]
R =42;
Nf=ceil(sqrt(length(R)));
figure;
for r=1:length(R)
  figh(r) = subplot(Nf,Nf,r);
end

for r=1:length(R)
  ri = R(r);
  if (plotRaw)
		figure ; 
		hold off;
		s.caTSA.dffTimeSeriesArray.tsa{ri}.plot([0.5 0.5 0.5]);
		hold on;
		s.caTSA.caPeakEventSeriesArray.esa{ri}.plot([0 0 0],-0.5+[0 -0.2]);
	%	 s.caTSA.caPeakEventSeriesArray.esa{ri}.plot([0 0 0],-0.5+[0 -0.2*(N+1)]);
		for e=1:N
			ESA.esa{e}.plot(colors(e,:), -0.5+[-0.2*e -0.2*(e+1)])
		end
	end

	% now do index windows
	ies = s.caTSA.caPeakEventSeriesArray.esa{ri};
	iestu = s.caTSA.timeUnit;
	[idxMat timeMat timeVec] = session.timeSeries.getIndexWindowsAroundEventsS(s.caTSA.time, s.caTSA.timeUnit, ...
		[-2 0], 2, ies.eventTimes, iestu,[],[],[],1);
	caidx = reshape(idxMat,[],1);
	caidx = caidx(find(~isnan(caidx)));
%	if (plotRaw) ; plot(s.caTSA.time(caidx), -0.5*ones(1,length(caidx)), 'bo'); end

	sf = 4; % framse / window 

	for e=1:N
		ies = ESA.esa{e};

		% build excluded
		xesTimes = [];
		for x=setdiff(1:N, e)
     xesTimes = union(xesTimes,ESA.esa{x}.eventTimes);
		end
		iestu = s.caTSA.timeUnit;
		[idxMat timeMat timeVec] = session.timeSeries.getIndexWindowsAroundEventsS(s.caTSA.time, s.caTSA.timeUnit, ...
			[0 0], 2, ies.eventTimes, iestu,[-2 2],xesTimes,iestu,0);
		widx = reshape(idxMat,[],1);
		widx = widx(find(~isnan(widx)));
%		if (plotRaw) ; plot(s.caTSA.time(widx), (-0.2*e)+(-0.5*ones(1,length(widx))), 'x', 'Color', colors(e,:)); end

		% how well does this sensory variable PREDICT firing (what fraction?)
		ni = length(intersect(widx,caidx));
		envPredCaFrac(e) = ni/length(caidx);

		% how reliably does this cell encode the sensory variable (FOLLOW it)?
		caPredEnvFrac(e) = ni/length(widx);

		disp([ies.idStr ' envPredCaFrac: ' num2str(envPredCaFrac(e)) ' caPredEnvFrac: ' num2str(caPredEnvFrac(e))]);
	end
	subplot(figh(r));
	bar(caPredEnvFrac);
	a = axis;
%	axis([a(1) a(2) 0 1]);
	for e=1:N
%		text(e,a(4)/2, ESA.esa{e}.idStr, 'Rotation', 90);
		title({s.dateStr, num2str(ri)});
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;
for r=1:length(R)
  figh(r) = subplot(Nf,Nf,r);
end

for r=1:length(R)
  ri = R(r);
  if (plotRaw)
		figure ; 
		hold off;
		s.caTSA.dffTimeSeriesArray.tsa{ri}.plot([0.5 0.5 0.5]);
		hold on;
		s.caTSA.caPeakEventSeriesArray.esa{ri}.plot([0 0 0],-0.5+[0 -0.2]);
	%	 s.caTSA.caPeakEventSeriesArray.esa{ri}.plot([0 0 0],-0.5+[0 -0.2*(N+1)]);
		for e=1:N
			ESA.esa{e}.plot(colors(e,:), -0.5+[-0.2*e -0.2*(e+1)])
		end
	end

	% now do index windows
	ies = s.caTSA.caPeakEventSeriesArray.esa{ri};
	iestu = s.caTSA.timeUnit;
	[idxMat timeMat timeVec] = session.timeSeries.getIndexWindowsAroundEventsS(s.caTSA.time, s.caTSA.timeUnit, ...
		[0 0], 2, ies.eventTimes, iestu,[],[],[],1);
	caidx = reshape(idxMat,[],1);
	caidx = caidx(find(~isnan(caidx)));
	if (plotRaw) ; plot(s.caTSA.time(caidx), -0.5*ones(1,length(caidx)), 'bo'); end

	sf = 4; % framse / window 

	for e=1:N
		ies = ESA.esa{e};

		% build excluded
		xesTimes = [];
		for x=setdiff(1:N, e)
    %  xesTimes = union(xesTimes,ESA.esa{x}.eventTimes);
		end
		iestu = s.caTSA.timeUnit;
		[idxMat timeMat timeVec] = session.timeSeries.getIndexWindowsAroundEventsS(s.caTSA.time, s.caTSA.timeUnit, ...
			[0 2], 2, ies.eventTimes, iestu,[-2 2],xesTimes,iestu,0);
		widx = reshape(idxMat,[],1);
		widx = widx(find(~isnan(widx)));
		if (plotRaw) ; plot(s.caTSA.time(widx), (-0.2*e)+(-0.5*ones(1,length(widx))), 'x', 'Color', colors(e,:)); end

		% how well does this sensory variable PREDICT firing (what fraction?)
		ni = length(intersect(widx,caidx));
		envPredCaFrac(e) = ni/length(caidx);

		% how reliably does this cell encode the sensory variable (FOLLOW it)?
		caPredEnvFrac(e) = ni/length(widx);

		disp([ies.idStr ' envPredCaFrac: ' num2str(envPredCaFrac(e)) ' caPredEnvFrac: ' num2str(caPredEnvFrac(e))]);
	end
	subplot(figh(r));
%	bar(caPredEnvFrac);
	bar(envPredCaFrac, 'r');
	a = axis;
%	axis([a(1) a(2) 0 1]);
	for e=1:N
%		text(e,a(4)/2, ESA.esa{e}.idStr, 'Rotation', 90);
		title({s.dateStr, num2str(ri)});
	end
end

end
