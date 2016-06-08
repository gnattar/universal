function [pref,nonpref,slopes] = get_slope_data(pooled_contactCaTrials_locdep,cell,ploc,nploc)

 slopes(:,1) = pooled_contactCaTrials_locdep{cell}.fitmean.NLslopes(:,:,1);
% slopes(:,2) = pooled_contactCaTrials_locdep{cell}.fitmean.Lslopes(:,:,1);
% 
 slopes(:,4) = pooled_contactCaTrials_locdep{cell}.fitmean.NLslopes(:,:,2);
% slopes(:,5) = pooled_contactCaTrials_locdep{cell}.fitmean.Lslopes(:,:,2);

pref(:,3) = pooled_contactCaTrials_locdep{cell}.fitmean.NL_sigpeak(:,ploc,1);
pref(:,4) = pooled_contactCaTrials_locdep{cell}.fitmean.NL_re_totaldK(:,ploc,1);

% pref(:,8) = pooled_contactCaTrials_locdep{cell}.fitmean.L_sigpeak(:,ploc,1);
% pref(:,9) = pooled_contactCaTrials_locdep{cell}.fitmean.L_re_totaldK(:,ploc,1);

nonpref(:,3) = pooled_contactCaTrials_locdep{cell}.fitmean.NL_sigpeak(:,nploc,1);
nonpref(:,4) = pooled_contactCaTrials_locdep{cell}.fitmean.NL_re_totaldK(:,nploc,1);

% nonpref(:,8) = pooled_contactCaTrials_locdep{cell}.fitmean.L_sigpeak(:,nploc,1);
% nonpref(:,9) = pooled_contactCaTrials_locdep{cell}.fitmean.L_re_totaldK(:,nploc,1);

y = pref(find(~isnan(pref(:,3))),3);
x = pref(find(~isnan(pref(:,4))),4);

[p] = polyfit(x,y,1);

pref(1,1) = p(1);
pref(1,2) = p (2);

% y = pref(find(~isnan(pref(:,8))),8);
% x = pref(find(~isnan(pref(:,9))),9);
% 
% [p] = polyfit(x,y,1);
% 
% pref(1,6) = p(1);
% pref(1,7) = p (2);

%%
y = nonpref(find(~isnan(nonpref(:,3))),3);
x = nonpref(find(~isnan(nonpref(:,4))),4);

[p] = polyfit(x,y,1);

nonpref(1,1) = p(1);
nonpref(1,2) = p (2);

% y = nonpref(find(~isnan(nonpref(:,8))),8);
% x = nonpref(find(~isnan(nonpref(:,9))),9);
% 
% [p] = polyfit(x,y,1);
% 
% nonpref(1,6) = p(1);
% nonpref(1,7) = p (2);

%% 
pref = round(pref.*1000)./1000;
nonpref = round(nonpref.*1000)./1000;