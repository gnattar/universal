function cfaddbuttons(cffig)
%CFADDBUTTONS Add buttons to the curve fitting plot figure window

%   Copyright 2001-2011 The MathWorks, Inc.

% Clear out any old stuff
h0 = findall(cffig,'Type','uicontrol','Style','pushbutton');
if ~isempty(h0), delete(h0); end

% Define information for the buttons
strings = {getString(message('curvefit:cftoolgui:button_Data')) ...
           getString(message('curvefit:cftoolgui:button_Fitting')) ...
           getString(message('curvefit:cftoolgui:button_Exclude')) ...
           getString(message('curvefit:cftoolgui:button_Plotting')) ...
           getString(message('curvefit:cftoolgui:button_Analysis'))};
tips = {getString(message('curvefit:cftoolgui:ImportSmoothViewRenameAndDeleteData')) ...
        getString(message('curvefit:cftoolgui:AddOrChangeAFittedLine')) ...
        getString(message('curvefit:cftoolgui:CreateViewAndRenameExclusionRules')) ...
        getString(message('curvefit:cftoolgui:ControlWhichItemsArePlotted')) ...
        getString(message('curvefit:cftoolgui:PredictInterpolateDifferentiateEtc'))};
cbacks = {@cbkimport @cbkfit @cbkexclude @cbkplot @cbkanalyze};

% *** "tags" also defined in cfadjustlayout, and they must match
tags = {'cfimport' 'cffit' 'cfexclude' 'cfplot' 'cfanalyze'};

% Add the buttons to the figure
for j=1:length(strings)
   uicontrol(cffig,'Units','normalized', ...
                    'Position',[.2*j-.1,.9,.15,.05],...
                    'String',strings{j}, 'TooltipString',tips{j}, ...
                    'Callback',cbacks{j}, 'Tag',tags{j});
end

% ---------------------- callback for Import button
function cbkimport(varargin)
%CBKIMPORT Callback for Import button

delete(findall(gcbf,'Tag','cfstarthint'));

awtinvoke('com.mathworks.toolbox.curvefit.DataManager', 'showDataManager(I)', 0);

% ---------------------- callback for Exclude button
function cbkexclude(varargin)
%CBKEXCLUDE Callback for Exclude button

awtinvoke('com.mathworks.toolbox.curvefit.Exclusion', 'showExclusion');

% ---------------------- callback for Fit button
function cbkfit(varargin)
%CBKFIT Callback for Fit button

% createFitting creates a fitting panel only if one does not yet exist.
awtinvoke('com.mathworks.toolbox.curvefit.Fitting','showFitting');

% ---------------------- callback for Plot button
function cbkplot(varargin)
%CBKPLOT0 Callback for Plot button

awtinvoke('com.mathworks.toolbox.curvefit.Plotting', 'showPlotting');

% ---------------------- callback for Analysis button
function cbkanalyze(varargin)
%CBKANALYZE Callback for Analysis button

awtinvoke('com.mathworks.toolbox.curvefit.Analysis', 'showAnalysis');
