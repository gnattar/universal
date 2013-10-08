%
% SP 2010 Dec
%
% This will compute change in kappa relative baseline, where baseline is the
%  angle that the kappa for a particular theta range when bar is NOT in reach.
%  It invokes the static computeDeltaKappas.
%
% USAGE:
%
%   wt.computeDeltaKappasWrapper()
%
function obj = computeDeltaKappasWrapper(obj)
  if (obj.messageLevel >= 1) ; disp(['computeDeltaKappas::processing ' obj.basePathName]); end
  obj.deltaKappas = session.whiskerTrial.computeDeltaKappas(obj.kappas, obj.thetas, obj.barInReach);
