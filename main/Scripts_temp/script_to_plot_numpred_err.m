temp = cell2mat(summary.ctrl.num_predictors{1})
minpred= zeros(length(temp),1)
runid= zeros(length(temp),1)
for n = 1: length(temp)
[v,i] = (min(temp));
minpred(n) = v;
runid(n) = i
temp(i) = nan;
end
save('minpred','minpred');
save('runid','runid');

numruns = 100;% =100;

inds = [(1:50:50*numruns)]';
inds(:,2) = inds(:,1)+49;
err_all = summary.ctrl.dist_err{1,1}(:,1);

for i = 1:numruns
temp = err_all(inds(i,1):inds(i,2));
frc= sum(temp==0);
err_coll(i) = frc;
end
frCor=err_coll./50;
frCor_sorted = frCor(runid);
frCor_sorted = (frCor(runid))';

figure;plot(minpred,frCor_sorted,'ko');
[P,S] = polyfit(minpred,frCor_sorted,1)
Y=polyval(P,[1:123]);
hold on ; plot([1:123],Y,'k');

title('Fraction Correct vs. Numpredictors');
xlabel('numpred');ylabel('Fraction Correct');
save('frCor_sorted_ctrl','frCor_sorted');

inds = [(1:50:50*numruns)]';
inds(:,2) = inds(:,1)+49;
err_all = summary.mani.dist_err{1,1}(:,1);

for i = 1:numruns
temp = err_all(inds(i,1):inds(i,2));
frc= sum(temp==0);
err_coll(i) = frc;
end
frCor=err_coll./50;
frCor_sorted = frCor(runid);
frCor_sorted = (frCor(runid))';

hold on;plot(minpred,frCor_sorted,'ro')
[P,S] = polyfit(minpred,frCor_sorted,1)
Y=polyval(P,[1:123]);
hold on ; plot([1:123],Y,'r');

saveas(gca,'FrCo Numpred','fig');set(gcf,'PaperPositionMode','manual');
print( gcf ,'-depsc2','-painters','-loose','FrCor Numpred');
save('frCor_sorted_mani','frCor_sorted');

%%
load pcopy.mat

[pooled_contactCaTrials_locdep] = prep_pcopy(pcopy,'phase');
[pooled_contactCaTrials_locdep] = prep_pcopy(pcopy,'theta');

r=['all cells'];
dends = [1:123];
[data] = Collect_phase_summary__frompcopy_T2(dends,r);
light =1;[data] = plot_normResp_phase(data,1,r);
[data] = Collect_theta_summary__frompcopy_T2(dends,r);
light =1;[data] = plot_normResp_theta(data,1,r);


m=94;
mkdir (['R' num2str(m) ' ' num2str(minpred(find(runid==m))) ' cells'])
 % runid with desired numpred

dends = find(summary.ctrl.mdl_list{1}{m}.DeltaPredictor > summary.ctrl.mdl_list{1}{m}.Delta)
r=[num2str(m) 'high']

[data] = Collect_theta_summary__frompcopy_T2(dends,r)
light =1;[data] = plot_normResp_theta(data,1,r) 

[data] = Collect_phase_summary__frompcopy_T2(dends,r)
light =1;[data] = plot_normResp_phase(data,1,r) 

dends = setxor([1:123],find(summary.ctrl.mdl_list{1}{m}.DeltaPredictor > summary.ctrl.mdl_list{1}{m}.Delta))
r=[num2str(m) 'low']

[data] = Collect_theta_summary__frompcopy_T2(dends,r)
light =1;[data] = plot_normResp_theta(data,1,r) 

[data] = Collect_phase_summary__frompcopy_T2(dends,r)
light =1;[data] = plot_normResp_phase(data,1,r) 

%%
Temp_coeffs = summary.ctrl.mdl_list{1}{m}.DeltaPredictor;
Delta_crit = summary.ctrl.mdl_list{1}{m}.Delta;
inds= find(Temp_coeffs>Delta_crit);

load('Phase Summary Data rall cells.mat');
PPI_ctrl = data.PPI_ctrl{1};
PPI_mani = data.PPI_mani{1};
% load('Theta Summary Data rall cells.mat');
figure;plot(Temp_coeffs',PPI_ctrl,'o','color',[.5 .5 .5])
hold on; plot(Temp_coeffs(inds)',PPI_ctrl(inds),'ko')
vline(Delta_crit,'k--')
ylabel('Phase Pref Index');xlabel('Delta Predictor')

plot(Temp_coeffs',PPI_mani,'o','color',[.85 .5 .5])
hold on; plot(Temp_coeffs(inds)',PPI_mani(inds),'ro')
title('Delta Predictor Coeff vs Phase Pref ')
title(['Delta Predictor Coeff vs Phase Pref R'  num2str(m)])

inc=((PPI_mani-PPI_ctrl)>0);
dec=((PPI_ctrl-PPI_mani)>0);
contrib=(Temp_coeffs>Delta_crit)';
bright=find(inc&contrib);
hold on; plot(Temp_coeffs(bright)',PPI_ctrl(bright),'ko','markerfacecolor',[.5 .5 .5]);
hold on; plot(Temp_coeffs(bright)',PPI_mani(bright),'ro','markerfacecolor',[.85 .5 .5]);



load('Theta Summary Data rall cells.mat');
TPI_ctrl = data.TPI_ctrl{1};
TPI_mani = data.TPI_mani{1};
% load('Theta Summary Data rall cells.mat');
figure;plot(Temp_coeffs',TPI_ctrl,'o','color',[.5 .5 .5])
hold on; plot(Temp_coeffs(inds)',TPI_ctrl(inds),'ko')
vline(Delta_crit,'k--')
ylabel('Theta Pref Index');xlabel('Delta Predictor')

plot(Temp_coeffs',TPI_mani,'o','color',[.85 .5 .5])
hold on; plot(Temp_coeffs(inds)',TPI_mani(inds),'ro')
title('Delta Predictor Coeff vs Theta Pref ')
title(['Delta Predictor Coeff vs Theta Pref R'  num2str(m)])

inc=((TPI_mani-TPI_ctrl)>0);
dec=((TPI_ctrl-TPI_mani)>0);
contrib=(Temp_coeffs>Delta_crit)';
bright=find(inc&contrib);
hold on; plot(Temp_coeffs(bright)',TPI_ctrl(bright),'ko','markerfacecolor',[.5 .5 .5]);
hold on; plot(Temp_coeffs(bright)',TPI_mani(bright),'ro','markerfacecolor',[.85 .5 .5]);