%
% behavioral plots
%

% steps to do ..
generate = 0;
perform_v_pos = 1;

if (generate)
	rootpath = '/data/an148378/2011_09_23/behav/';
	sfl = dir([rootpath 'data_@pole_detect_spobj_*a.mat']);
	S = {};
	for f=3:length(sfl)

		sfp = [rootpath sfl(f).name];

		behavSoloParams{1} = {1, 1, 'Beam Breaks', [1 0 1], 1};
		behavSoloParams{2} = {2, 43, 'Water Valve', [0 0 1], 2};
		behavSoloParams{3} = {2, 44, 'Drinking Allowed Period', [0 0 0.5], 2};
		behavSoloParams{4} = {2, 49, 'Airpuff', [1 0.5 0], 2};
		behavSoloParams{5} = {3, [41 50], 'Pole Movement', [0 0 0], 2}; % ME

		s = session.session();
		s.generateBehavioralDataStructures(sfp, behavSoloParams);
		S{length(S)+1} = s;
	end
end

if (perform_v_pos)
  sessions_used = 10; % restrict to sessions analyzed
  positions = [];
	correct = [];
	session_idx = [];

  for si = 1:length(sessions_used)
	  s = sA.sessions{sessions_used(si)};
    s_positions = zeros(1,length(s.trial));
    s_correct = zeros(1,length(s.trial)); % 0 incorrect ; 1 correct
	 
		% definition -- what class constitutes what?
		hit = find(strcmp(s.trialTypeStr,'Hit'));
		miss = find(strcmp(s.trialTypeStr,'Miss'));
		fa = find(strcmp(s.trialTypeStr,'FA'));
		cr = find(strcmp(s.trialTypeStr,'CR'));

		% get position & determine if the animal performed correctly
		for t=1:length(s.trial)
			s_positions(t) = s.trial{t}.stimulus;
			class(t) = s.trial{t}.typeIds(1); % only pull first type-id since we assume 1-4
			if (class(t) == hit | class(t) == cr) ; s_correct(t) = 1; end
		end

		% now combine data across sessions
		positions = [positions s_positions];
		correct = [correct s_correct];
		session_idx = [session_idx si*ones(1,length(s.trial))];
	end

	% plot it
	dp = 10000;
  pos_range = [0:dp:180000];
	frac_correct = zeros(1,length(pos_range)-1);
	n_trials = zeros(1,length(pos_range)-1);
  for p=1:length(pos_range)-1
	  idx = find(positions >= pos_range(p) & positions < pos_range(p+1));
	  n_trials(p) = length(idx);
	  frac_correct(p) = sum(correct(idx))/length(idx);
	end

  figure;
	subplot(2,1,1);
	plot(pos_range(1:end-1)+(dp/2), 100*frac_correct, 'ro', 'MarkerSize',5,'MarkerFaceColor',[1 0 0]);
	set (gca, 'TickDir', 'out');
	set (gca,'XTick',[]);
	ylabel('Performance (%)');
	subplot(2,1,2);
	plot(pos_range(1:end-1)+(dp/2), n_trials, 'bo', 'MarkerSize',5,'MarkerFaceColor',[0 0 1]);
	set (gca, 'TickDir', 'out');
	xlabel('Position (Zaber motor command)');
	ylabel('Number of trials');
end
