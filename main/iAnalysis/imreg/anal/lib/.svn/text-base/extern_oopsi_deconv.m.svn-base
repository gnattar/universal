function [n_best P_best V_best C_best X] = extern_oopsi_deconv (sig,fr,thr_mad,tau,minRate, mindff, thr_sd, expRate)
X = [];
V.dt   = 1/fr;
V.tau  = tau;
P.gam  = (1-V.dt/V.tau);
T      = length(sig);
minSig = max([thr_mad*mad(sig,1)*1.4826 mindff thr_sd*std(sig(find(sig<0)))]);
filtLength  = ceil(3*(V.tau/V.dt));
h = zeros(1,filtLength);
h = exp(-[0:filtLength-1]*V.dt/V.tau);
[q r] = deconv(sig,h*minSig);
P.lam = expRate;
% First round
[n_best P_best V_best C_best]=extern_fast_oopsi_diego(sig,V,P);
rate = length(find(n_best>0.1))/T;
if rate >= minRate && length(find(n_best>0.5)>5)
    X     = [ones(length(sig),1) C_best]\sig;
    C_est = C_best*X(2) + X(1);
    resid  = sig - C_est;
    F      = detrend(resid);
    F      = F-min(F)+eps;
    P.sig  = mad(F)*1.4826;
    F      = detrend(sig);
    P.b    = X(1)-min(F);
    P.a    = X(2);
%     P.b    = X(1);
%     minNbest = quantile (n_best(find(n_best>0.01)),0.05);
%     minSig = mean(C_best (find(n_best>0.01 & n_best <= minNbest)))*X(2)+X(1);
    minSig = max([thr_mad*P.sig mindff thr_sd*std(sig(find(sig<0)))]);
    % Estimation of tau
    [pks loc] = findpeaks(n_best,'MINPEAKHEIGHT',0.5);
    jj        = loc(2:end) - loc(1:end-1);
    hh        = find(jj>filtLength) ;
    kk        = loc(hh(1:end-1));
    if length(kk)>10
        shape = zeros(length(kk),filtLength);
        for i=1:length(kk), 
            auxSig     = sig(kk(i)-1:kk(i)+filtLength-1);
            [mm nn]    = max(auxSig);
            shape(i,:) = sig(kk(i)+nn-2:kk(i)+filtLength+nn-3)/mm;
        end
        expShape  = median(shape);
        s = fitoptions('Method','NonlinearLeastSquares','Lower',[0,-Inf],'Upper',[Inf,Inf],'Startpoint',[V.tau 0]);
        f = fittype('exp(-a*x)+b','options',s);
        c2 = fit([0:V.dt:(filtLength-1)*V.dt]',expShape',f);
        changeTau = abs(c2.a-V.tau)/V.tau;
        if changeTau < 0.5
            V.tau = c2.a;
        end
%         filtLength  = ceil(3*(V.tau/V.dt));
%         h = zeros(1,filtLength);
%         h = exp(-[0:filtLength-1]*V.dt/V.tau);
        P.gam  = (1-V.dt/V.tau);
        h= expShape;
    end
    [q r] = deconv(sig,h*minSig);
    P.lam = sum(q(find(q>1)))/T;
    % Second round
    [n_best P_best V_best C]=extern_fast_oopsi_diego(sig,V,P);
    X     = [ones(length(sig),1) C_best]\sig;
    C_best = C_best*X(2) + X(1);

end
