function plot_touchAmp_Evolution_Fit(data,obj,str)
numtouches = 10;
tA_L=cellfun(@(x) x.touchAmp,data(obj.lT),'uni',0);
tA_NL=cellfun(@(x) x.touchAmp,data(obj.nlT),'uni',0);
temp_nl=cellfun(@(x) cell2mat(x)', tA_NL,'uni',0)';
temp_l=cellfun(@(x) cell2mat(x)', tA_L,'uni',0)';
temp = cell2mat(cellfun(@size,tA_NL,'uni',0)');
num_nl = temp(:,2);
temp = cell2mat(cellfun(@size,tA_L,'uni',0)');
num_l = temp(:,2);
tA_nl=nan(length(num_nl),35);
tA_l=nan(length(num_l),35);

for i = 1:length(num_nl)
twave = temp_nl{i};
if length(twave)>1
tA_nl(i,1:length(twave)) = twave;
else
end
end
for i = 1:length(num_l)
twave = temp_l{i};
if length(twave)>1
tA_l(i,1:length(twave)) = twave;
else
end
end
% figure;
% e1=errorbar(nanmean(tA_nl),nanstd(tA_nl)./sqrt(sum(~isnan(tA_nl))),'ko-');hold on;
% e2=errorbar(nanmean(tA_l),nanstd(tA_l)./sqrt(sum(~isnan(tA_l))),'ro-');
% axis([0 10 0 10]);
% title([str 'Amp Evolve'])
x=[1:numtouches]';
temp=nanmean(tA_nl)';
y=temp(1:numtouches);

 f1=fit(x,y,'exp1');CI1=round(1./confint(f1)*100)./100;
figure;plot(f1,x,y,'ko'); hold on ; text(numtouches-1.5,f1.a-1,[ num2str(1/f1.b) ' ( ' num2str(CI1(:,2)') ')']);
 x=[1:numtouches]';
temp=nanmean(tA_l)';
y=temp(1:numtouches);

 f2=fit(x,y,'exp1');CI2=round(1./confint(f2)*100)./100;
 plot(f2,x,y,'ro'); tb=text(numtouches-1,f2.a-1,[ num2str(1/f2.b) ' ( ' num2str(CI2(:,2)') ')']);set(tb,'color','r');
 
title([str ' Amp Evolve Fit' num2str(numtouches)])
ylabel(' Amp (deg)');
xlabel('# touches');

saveas(gca,[str ' TouchAmp Evolve Fit' num2str(numtouches)],'fig');
print( gcf ,'-depsc2','-painters','-loose',[str ' TouchAmp Evolve Fit ' num2str(numtouches)]);

obj.fit_NL_5T = f1;
obj.fit_L_5T = f2;
obj.fit_NL_CI_5T=CI1;
obj.fit_L_CI_5T=CI2;
save('obj','obj')