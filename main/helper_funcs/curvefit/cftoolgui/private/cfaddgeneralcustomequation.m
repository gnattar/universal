function status=cfaddgeneralcustomequation(customgeneral,sp,lower,upper)
% CFADDGENERALCUSTOMEQUATION Helper function for CFTOOL.

% CFADDGENERALCUSTOMEQUATION is called by the custom equations 
% panel to save a custom equation.

%   Copyright 2001-2010 The MathWorks, Inc.

[f, status] = nonlinearEquationFittype(char(customgeneral.getEquation), ...
    {char(customgeneral.getIndependentVariable)}, ...
    char(customgeneral.getDependentVariable));

if isempty(status)
    opts=fitoptions(f);
    opts.StartPoint=sp;
    opts.Lower=lower;
    opts.Upper=upper;
    % Add this fittype to the list
    managecustom('set',char(customgeneral.getEquationName),f,opts,char(customgeneral.getEquationOldName));
    status=java.lang.String('OK');
end
