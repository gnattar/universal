%
% S Peron 2010 May
%
% This generates the default roiGroupArray and roiGroup objects.
%
function defaultGroupArray = generateDefaultGroupArray()
  % === create groups
	g{1} = roi.roiGroup(9000, 'Automatically Moved', [0 0 1]);
	g{2} = roi.roiGroup(9001, 'Guessed Position', [1 1 0]);
	g{3} = roi.roiGroup(1000, 'Excitatory', [0 0 1]);
	g{4} = roi.roiGroup(1001, 'Inhibitory', [1 0 0]);
	g{5} = roi.roiGroup(2000, 'Soma', [1 0 0]);
	g{6} = roi.roiGroup(2001, 'Apical dendrite', [0 1 0]);
	g{7} = roi.roiGroup(2002, 'Proximal dendrite', [0 0 1]);
	g{8} = roi.roiGroup(8000, 'Filled', [1 0 0]);
	g{9} = roi.roiGroup(8001, 'Ambiguous', [1 0 1]);
	g{10} = roi.roiGroup(8002, 'Not Filled', [0 0 1]);

	% === put them into groupArray
	defaultGroupArray = roi.roiGroupArray(g);

	% === put groups into sets
	defaultGroupArray.addSet(1000, 'Cell Type', [1000 1001]);
	defaultGroupArray.addSet(2000, 'Neurite Type', [2000 2001 2002]);
	defaultGroupArray.addSet(8000, 'Nuclear Filling', [8000 8001 8002]);
	defaultGroupArray.addSet(9000, 'Movement Correction', [9000 9001]);
end
