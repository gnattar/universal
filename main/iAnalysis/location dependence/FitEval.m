function [param,paramCI,fitevals,f] = FitEval(x,y,fittype)
f = [];
fitevals =[];
param =[];
paramCI = [];
switch fittype
    case 'lin'
% st line fit
        [param,S]  = polyfit(x,y,1);
        paramCI = polyparci(param,S); 
        f =  polyval(param,x);
        sse = sum((y-f).^2);
        ssr =sum( (f - mean(y)).^2);
        sst = sum((y-mean(y)).^2);
        num = length(x); m = 2;
        adjR= 1 - ((sse *(num-1) )/(sst* (num-m)));
        
        
    case 'exp'
        % exp fit
        [param]  = polyfit(x,log(y),1);
        f =  exp(polyval(param,x));
        sse = sum((y-f).^2);ssr =sum( (f - mean(y)).^2);
        sst = sum((y-mean(y)).^2);
        num = length(x); m = 2;
        adjR= 1 - ((sse *(num-1) )/(sst* (num-m)));
        
    case 'sig'
%         %Sigmoid fit
        [param,stat]=sigm_fit(x,y,[0, NaN , NaN , NaN], [], 0);
%         fsigm = @(param,xval) param(1)+(param(2)-param(1))./(1+10.^((param(3)-xval)*param(4)));
%         f=fsigm(param,x);
        f = stat.ypred;
        paramCI = [0 0 ; stat.paramCI]';
        sse = sum((y-f).^2);ssr =sum( (f - mean(y)).^2);sst = sum((y-mean(y)).^2);
        num = length(x); m = 4;
        adjR= 1 - ((sse *(num-1) )/(sst* (num-m)));
end
fitevals = [sse ssr adjR];