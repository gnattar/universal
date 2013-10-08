%
% SP Oct 2010
%
% Logs a message to a file with a timestamp.
%
% USAGE:
%
%  log2file(logFilePath, message, suppressDisp, suppressTimeStamp)
%
%  logFilePath: where to put stuff
%  message: what to write to file (timestamp and \n is added)
%  suppressDisp: if 1, message will NOT be displayed via disp (default behavior
%    is to display the message)
%  suppressTimeStamp: if 1, no timestamp
%
function log2file(logFilePath, message, suppressDisp, suppressTimeStamp)
  if (nargin < 3) ; suppressDisp = 0; elseif (length(suppressDisp) == 0) ; suppressDisp = 0; end
  if (nargin < 4) ; suppressTimeStamp = 0; elseif (length(suppressTimeStamp) == 0) ; suppressTimeStamp= 0; end


  % construct full message (with timestamp)
	if (suppressTimeStamp)
		fullMessage = [message '\n'];
	else
		fullMessage = [datestr(now,31) ':' message '\n'];
	end

  % echo?
  if (~suppressDisp)
	  disp(strrep(fullMessage,'\n', ''));
	end

  % to file
  fid = fopen(logFilePath, 'at');
	fprintf(fid, fullMessage);
  fclose(fid);


