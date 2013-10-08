function touch_crossday_2(sA, roiId, dffRange)
if (nargin < 3) ; dffRange = [-0.25 2]; end
whiskers = {'c1','c2','c3'};

% -------------------------------------------
% 1) contact-triggered average, all whiskers
clear eparams;
eparams.displayedId = roiId;
eparams.plotMode = [1 1 0 0];
eparams.excludeOthers = 0;
eparams.plotBar = 1;
eparams.whiskerTags = whiskers;
eparams.valueRange = dffRange;
sA.plotEventTriggeredAverageCrossDays(eparams);
set(gcf,'Name',[get(gcf,'Name') ' any contact']);

% -------------------------------------------
% 1a) contact-triggered average, all whiskers
clear eparams;
eparams.displayedId = roiId;
eparams.plotMode = [0 0 0 1];
eparams.excludeOthers = 0;
eparams.plotBar = 1;
%eparams.whiskerTags = whiskers;
eparams.valueRange = dffRange;
eparams.triggeringESA = 'whiskerBarContactESA';
eparams.triggeringESAIds  = {'Contacts for c1', ...
                             'Contacts for c2', ...
                             'Contacts for c3'};
eparams.triggeringESACols = [1 0 0 ; 0 1 0 ; 0 0 1];
sA.plotEventTriggeredAverageCrossDays(eparams);
set(gcf,'Name',[get(gcf,'Name') ' any contact']);

% -------------------------------------------
% 1b) contact-triggered average, all whiskers
clear eparams;
eparams.displayedId = roiId;
eparams.plotMode = [0 0 0 1];
eparams.excludeOthers = 0;
eparams.plotBar = 1;
%eparams.whiskerTags = whiskers;
eparams.valueRange = dffRange;
eparams.triggeringESA = 'whiskerBarContactClassifiedESA';
eparams.triggeringESAIds  = {'Protraction contacts for c1', ...
                             'Retraction contacts for c1', ...
                             'Protraction contacts for c2', ...
                             'Retraction contacts for c2', ...
                             'Protraction contacts for c3', ...
                             'Retraction contacts for c3'};
eparams.triggeringESACols = [1 0 0 ; 1 0 1 ; 0 0 1 ; 0 1 1 ; 0.5 0.5 0.5 ; 0 0 0];
sA.plotEventTriggeredAverageCrossDays(eparams);
set(gcf,'Name',[get(gcf,'Name') ' any contact']);



% -------------------------------------------
% 2) EXCLUSIVE contact-triggered average, all whiskers
clear eparams;
eparams.displayedId = roiId;
eparams.plotMode = [1 1 0 0];
eparams.excludeOthers = 1;
eparams.plotBar = 1;
eparams.whiskerTags = whiskers;
eparams.valueRange = dffRange;
sA.plotEventTriggeredAverageCrossDays(eparams);
set(gcf,'Name',[get(gcf,'Name') ' isolated contacts']);


% -------------------------------------------
% 2a) contact-triggered average, all whiskers
clear eparams;
eparams.displayedId = roiId;
eparams.plotMode = [0 0 0 1];
eparams.excludeOthers = 1;
eparams.plotBar = 1;
%eparams.whiskerTags = whiskers;
eparams.valueRange = dffRange;
eparams.triggeringESA = 'whiskerBarContactESA';
eparams.triggeringESAIds  = {'Contacts for c1', ...
                             'Contacts for c2', ...
                             'Contacts for c3'};
eparams.triggeringESACols = [1 0 0 ; 0 1 0 ; 0 0 1];
sA.plotEventTriggeredAverageCrossDays(eparams);
set(gcf,'Name',[get(gcf,'Name') ' isolated any contact']);

% -------------------------------------------
% 2b) contact-triggered average, all whiskers
clear eparams;
eparams.displayedId = roiId;
eparams.plotMode = [0 0 0 1];
eparams.excludeOthers = 1;
eparams.plotBar = 1;
%eparams.whiskerTags = whiskers;
eparams.valueRange = dffRange;
eparams.triggeringESA = 'whiskerBarContactClassifiedESA';
eparams.triggeringESAIds  = {'Protraction contacts for c1', ...
                             'Retraction contacts for c1', ...
                             'Protraction contacts for c2', ...
                             'Retraction contacts for c2', ...
                             'Protraction contacts for c3', ...
                             'Retraction contacts for c3'};
eparams.triggeringESACols = [1 0 0 ; 1 0 1 ; 0 0 1 ; 0 1 1 ; 0.5 0.5 0.5 ; 0 0 0];
sA.plotEventTriggeredAverageCrossDays(eparams);
set(gcf,'Name',[get(gcf,'Name') ' isolated any contact']);


% -------------------------------------------
% 3) sequences with 2-3 adjancet whiskers
clear eparams;
eparams.displayedId = roiId;
eparams.plotMode = [0 0 0 1];
eparams.excludeOthers = 0;
eparams.valueRange = dffRange;
eparams.plotBar = 1;
eparams.triggeringESA = 'getSequentialWhiskerContactESA({''c1'',''c2'', ''c3''}, 1,2)';
eparams.triggeringESAIds  = 1:6;
eparams.triggeringESACols = [1 0 0 ; 1 0 1 ; 0 0 1 ; 0 1 1 ; 0.5 0.5 0.5 ; 0 0 0];
sA.plotEventTriggeredAverageCrossDays(eparams); 
set(gcf,'Name',[get(gcf,'Name') ' sequential contacts']);


% -------------------------------------------
% 4) EXCLUSIVE sequences with 2-3 adjancet whiskers
clear eparams;
eparams.displayedId = roiId;
eparams.plotMode = [0 0 0 1];
eparams.excludeOthers = 1;
eparams.plotBar = 1;
eparams.valueRange = dffRange;
eparams.triggeringESA = 'getSequentialWhiskerContactESA({''c1'',''c2'', ''c3''}, 1,2)';
eparams.triggeringESAIds  = 1:6;
eparams.triggeringESACols = [1 0 0 ; 1 0 1 ; 0 0 1 ; 0 1 1 ; 0.5 0.5 0.5 ; 0 0 0];
sA.plotEventTriggeredAverageCrossDays(eparams); 
set(gcf,'Name',[get(gcf,'Name') ' isolated sequential contacts']);

% -------------------------------------------
% 5) sequences with 2-3 adjancet whiskers, directional
clear eparams;
eparams.displayedId = roiId;
eparams.plotMode = [0 0 0 1];
eparams.excludeOthers = 0;
eparams.plotBar = 1;
eparams.valueRange = dffRange;
eparams.triggeringESA = 'getSequentialWhiskerContactESA({''Rc1'',''Rc2'', ''Rc3''}, 1,2)';
eparams.triggeringESAIds  = [1 3 5];
eparams.triggeringESACols = [1 0 0 ; 1 0 1 ; 0 0 1 ; 0 1 1 ; 0.5 0.5 0.5 ; 0 0 0];
sA.plotEventTriggeredAverageCrossDays(eparams); 
set(gcf,'Name',[get(gcf,'Name') ' sequential ret contacts']);

eparams.triggeringESA = 'getSequentialWhiskerContactESA({''Pc1'',''Pc2'', ''Pc3''}, 1,2)';
eparams.triggeringESAIds  = [2 4 6];
sA.plotEventTriggeredAverageCrossDays(eparams); 
set(gcf,'Name',[get(gcf,'Name') ' sequential pro contacts']);

% -------------------------------------------
% 6) EXCLUSIVE sequences with 2-3 adjancet whiskers, directional
clear eparams;
eparams.displayedId = roiId;
eparams.plotMode = [0 0 0 1];
eparams.excludeOthers = 1;
eparams.plotBar = 1;
eparams.valueRange = dffRange;
eparams.triggeringESA = 'getSequentialWhiskerContactESA({''Rc1'',''Rc2'', ''Rc3''}, 1,2)';
eparams.triggeringESAIds  = [1 3 5];
eparams.triggeringESACols = [1 0 0 ; 1 0 1 ; 0 0 1 ; 0 1 1 ; 0.5 0.5 0.5 ; 0 0 0];
sA.plotEventTriggeredAverageCrossDays(eparams); 
set(gcf,'Name',[get(gcf,'Name') ' isoalted sequential ret contacts']);

eparams.triggeringESA = 'getSequentialWhiskerContactESA({''Pc1'',''Pc2'', ''Pc3''}, 1,2)';
eparams.triggeringESAIds  = [2 4 6];
sA.plotEventTriggeredAverageCrossDays(eparams); 
set(gcf,'Name',[get(gcf,'Name') ' isolated sequential pro contacts']);

% -------------------------------------------
% 7) combos with 2-3 adjacent whiskers
clear eparams;
eparams.displayedId = roiId;
eparams.plotMode = [0 0 0 1];
eparams.excludeOthers = 0;
eparams.plotBar = 1;
eparams.valueRange = dffRange;
eparams.triggeringESA = 'getCoincidentWhiskerContactESA({''c1'',''c2'', ''c3''}, 2)';
eparams.triggeringESAIds  = 1:3;
eparams.triggeringESACols = [1 0 0 ; 0 0 1 ;  0 0 0];
sA.plotEventTriggeredAverageCrossDays(eparams); 
set(gcf,'Name',[get(gcf,'Name') ' coincident contacts']);


% -------------------------------------------
% 8) EXCLUSIVE combos with 2-3 adjacent whiskers
clear eparams;
eparams.displayedId = roiId;
eparams.plotMode = [0 0 0 1];
eparams.excludeOthers = 1;
eparams.plotBar = 1;
eparams.valueRange = dffRange;
eparams.triggeringESA = 'getCoincidentWhiskerContactESA({''c1'',''c2'',''c3''}, 2)';
eparams.triggeringESAIds  = 1:3;
eparams.triggeringESACols = [1 0 0 ; 0 0 1 ;  0 0 0];
sA.plotEventTriggeredAverageCrossDays(eparams); 
set(gcf,'Name',[get(gcf,'Name') ' isolated coincident contacts']);


% -------------------------------------------
% 9) combos with 2-3 adjacent whiskers ; pro/ret

clear eparams;
eparams.displayedId = roiId;
eparams.plotMode = [0 0 0 1];
eparams.excludeOthers = 0;
eparams.valueRange = dffRange;
eparams.plotBar = 1;
eparams.triggeringESA = 'getCoincidentWhiskerContactESA({''Pc1'',''Pc2'', ''Pc3''}, 2)';
eparams.triggeringESAIds  = 1:3;
eparams.triggeringESACols = [1 0 0 ; 0 0 1 ;  0 0 0];
sA.plotEventTriggeredAverageCrossDays(eparams); 
set(gcf,'Name',[get(gcf,'Name') ' coincident contacts pro']);

eparams.triggeringESA = 'getCoincidentWhiskerContactESA({''Rc1'',''Rc2'', ''Rc3''}, 2)';
sA.plotEventTriggeredAverageCrossDays(eparams); 
set(gcf,'Name',[get(gcf,'Name') ' coincident contacts ret']);


% -------------------------------------------
% 10) combos with 2-3 adjacent whiskers ; pro/ret exclusive

clear eparams;
eparams.displayedId = roiId;
eparams.plotMode = [0 0 0 1];
eparams.excludeOthers = 1;
eparams.plotBar = 1;
eparams.valueRange = dffRange;
eparams.triggeringESA = 'getCoincidentWhiskerContactESA({''Pc1'',''Pc2'', ''Pc3''}, 2)';
eparams.triggeringESAIds  = 1:3;
eparams.triggeringESACols = [1 0 0 ; 0 0 1 ;  0 0 0];
sA.plotEventTriggeredAverageCrossDays(eparams); 
set(gcf,'Name',[get(gcf,'Name') ' isolated coincident contacts pro']);

eparams.triggeringESA = 'getCoincidentWhiskerContactESA({''Rc1'',''Rc2'', ''Rc3''}, 2)';
sA.plotEventTriggeredAverageCrossDays(eparams); 
set(gcf,'Name',[get(gcf,'Name') ' isolated coincident contacts ret']);


