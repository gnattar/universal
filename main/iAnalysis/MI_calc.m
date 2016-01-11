function [MI,obj]=MI_calc(obj)
for n = 1: size(obj,2)
    ca = obj{n}.sigpeak;
% %  ca = pooled_contactCaTrials_locdep{n}.sigpeak;
% % ca = fn{n}.sigpeak;
% ca = fd{n}.sigpeak;

p=obj{n}.poleloc;
R= (ca-min(ca))./(max(ca)-min(ca));
bins = [0:.2:1];
ploc = unique(p);
trials = length(p);
p_r = hist(R,bins)./trials;
for i = 1: length(ploc)
    ind = find(p==ploc(i));
    rl = R(ind);
    p_r_l = hist(rl,bins)./length(ind);
    pl(i) = length(ind)./trials;
    tempw = p_r_l./p_r;
    tempw2 = p_r_l.* log2(tempw);
    sum_over_R (i) = pl(i).*nansum(tempw2);
end

MI(n) =nansum(sum_over_R);
% pooled_contactCaTrials_locdep{n}.MI = MI(n);
% fn{n}.MI = MI(n);
% fd{n}.MI = MI(n);
obj{n}.MI = MI(n);
end


% gen_fakenoise()
% numcells = size(pooled_contactCaTrials_locdep,2);
% p=pooled_contactCaTrials_locdep{1}.poleloc;
% for nc = 1:numcells
% ploc = unique(p);
% for i =  1: length(ploc)
%     ind = find(p==ploc(i));
%     fakenoise(ind) = rand(length(ind),1);
% end
% fn{nc}.sigpeak = fakenoise;
% fn{nc}.poleloc = p;
% end
% 
% genfakedata()
% numcells = size(pooled_contactCaTrials_locdep,2);
% p=pooled_contactCaTrials_locdep{1}.poleloc;
% for nc = 1:numcells
% ploc = unique(p);
% f=linspace(0,1,length(ploc));
% nl=1;
% for i =  1: length(ploc)
%     ind = find(p==ploc(i));
%     r = -nl + (nl-(-nl)).*rand(length(ind),1);
%     fakedata(ind) = f(i)+r;
% end
% fd{nc}.sigpeak = fakedata;
% fd{nc}.poleloc = p;
% end