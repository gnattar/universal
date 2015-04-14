function [xname, yname, wname, method, span, degree] = cfinitviewdata(dataset)
% CFINITVIEWDATA is a helper function for the cftool GUI. 

% Copyright 2001-2011 The MathWorks, Inc.

ds = handle(dataset);

xname = ds.xname;
yname = ds.yname;
wname = ds.weightname;

source = ds.source;

if isempty(source)
    method = '';
    span = '';
    degree = '';
	return;
end

source = source(end,:);

mthd = source{4};

switch (mthd)
	case 'moving'
		method = getString(message('curvefit:cftoolgui:MovingAverage'));
	case 'lowess'
		method = getString(message('curvefit:cftoolgui:LowesslinearFit'));
	case 'loess'
		method = getString(message('curvefit:cftoolgui:LoessquadraticFit'));
	case 'sgolay'
		method = getString(message('curvefit:cftoolgui:SavitzkyGolay'));
	case 'rlowess'
		method = getString(message('curvefit:cftoolgui:RobustLowesslinearFit'));
	case 'rloess'
		method = getString(message('curvefit:cftoolgui:RobustLoessquadraticFit'));
	otherwise
		method = getString(message('curvefit:cftoolgui:UnknownMethod'));
end

span = num2str(source{3});
if strcmp(mthd, 'sgolay')
    degree = num2str(source{5});
else
    degree = '';
end





