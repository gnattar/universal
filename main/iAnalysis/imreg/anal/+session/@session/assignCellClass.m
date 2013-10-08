%
% Using cellFeatures hash, this will assign classes to cells (whisk, touch, 
%  lick, reward, pole move).
%
% USAGE: 
%
%  obj.assignCelClass(params)  
%
% SP Jan 2012
%
function assignCellClass(obj, params)
  % --- check that cellFeatures hash is good
	if (~isobject(obj.cellFeaturesHash))
	  disp('assignCellClass::must first run generateCellFeaturesHash.');
		return;
	end

	% ---    
	cellClasses = {'touch','whisk','lick', 'reward','polemove'};
	cellClassColor = {[]};

  % ----------------------------------------------
	% whisk cells FIRST -- score without touch, lick
  

