function cfsavefit(varnames,cfit)
%CFSAVEFIT

%   Copyright 2001-2006 The MathWorks, Inc.

% CFSAVEFIT(VARNAMES,CFIT)

cf = handle(cfit);
for i = 1 : length(varnames)
    if ~isempty(varnames{i})
        switch i
        case 1
            out = cf.fit;
        case 2
            out = cf.goodness;
        case 3
            out = cf.output;
        otherwise
            error(message('curvefit:cfsavefit:InvalidArgument'));
        end
        assignin('base',varnames{i},out);
    end
end
