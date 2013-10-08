%
% SP Dec 2010
%
% This will plot the performance of all sessions in sessionArray.
%
% USAGE:
%  
%   sA.plotPerformance()
%
function plotPerformance (obj)
  % how many trials to pad
	tpad = 10;

  % --- detailed
	% instantiate
	figure;

  % the main loop -- very simple
	toffs = tpad;
	obj.performanceStats = nan*ones(length(obj.sessions),2);
	fHans = [];
  for s=1:length(obj.sessions)
	  retVal = obj.sessions{s}.plotPerformance(toffs, [s length(obj.sessions)], fHans);
	  obj.performanceStats(s,:) = retVal{1};
		fHans = retVal{2};
		toffs = toffs + tpad + length(obj.sessions{s}.trial);
	end

	% --- supplementary plot with *just* d', % correct
  figure;

	subplot(2,1,1); hold on ;
  plot(1:length(obj.sessions), obj.performanceStats(:,2), 'bo'); 
	subplot(2,1,2); hold on ;
  plot(1:length(obj.sessions), obj.performanceStats(:,1), 'bo'); 

	subplot(2,1,1);
	set (gca, 'TickDir', 'out');
	ylabel('d-prime');
	axis([0 length(obj.sessions)+1 -1 3]);
	plot([0 length(obj.sessions)+1], [1.5 1.5], 'k:');
	subplot(2,1,2);
	set (gca, 'TickDir', 'out');
	ylabel('% correct');
	plot([0 length(obj.sessions)+1], [75 75], 'k:');
	for s=1:length(obj.sessions)
		text(s,-20, obj.dateStr{s}(1:6) , 'Rotation', 90);
	end
	axis([0 length(obj.sessions)+1 -30 100]);

	  

