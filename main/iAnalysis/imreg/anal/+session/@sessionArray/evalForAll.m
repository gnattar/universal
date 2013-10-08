%
% SP FEb 2011
%
% Loops through obj.sessions, and for each one, evaluates command using eval.
%  So if you want to call, e.g., s.caTSA.runBestPracticesDffAndEvdet for each
%  session object "s" within sessionArray, you would invoke:
%  
%   sA.evalForAll('caTSA.runBestPracticesDffAndEvdet')
%
% USAGE:
%
%		sA.evalForAll(command)
%
%    command: The command, appended to obj.sessions{x}., that is eval'd.
%
function obj = evalForAll(obj, command)
  for s=1:length(obj.sessions) 
	  eStr = ['obj.sessions{' num2str(s) '}.' command];
		eval(eStr);
	end

