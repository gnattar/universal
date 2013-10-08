%
% SP Nov 2010
% 
% This method checks if whiskerData is populated, and if not, will load it from file
%
function enableWhiskerData(obj)
  % whiskerData -- if needbe, load
  if (length(obj.whiskerData) == 0 & length(obj.whiskerDataFilePath) == 0)
	  disp(['enableWhiskerData::no whiskerDataFilePath but no whiskerData either -- you may be in trouble ...']);
	elseif (length(obj.whiskerData) == 0)
	  disp(['enableWhiskerData::this may take a moment - loading ' obj.whiskerDataFilePath]);
		load (obj.whiskerDataFilePath, '-mat');
	  obj.whiskerData = whiskerData;
	end
