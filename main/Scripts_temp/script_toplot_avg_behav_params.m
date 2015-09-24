

num_anm = size(wSigSum_anmArch,2);
fa_fr_nogo = nan(num_anm,8);
fa_fr_total = nan(num_anm,8);
dprime_contact = nan(num_anm,8);
PC_contact = nan(num_anm,8);

for anm = 1:num_anm
    numsess = size(wSigSum_anmArch{anm},2);
fa=cell2mat(cellfun(@(x) length(x.FAtrialnums{1}),wSigSum_anmArch{anm},'uni',0));
nogo=cell2mat(cellfun(@(x) length(x.nogotrialnums{1}),wSigSum_anmArch{anm},'uni',0));
go=cell2mat(cellfun(@(x) length(x.gotrialnums{1}),wSigSum_anmArch{anm},'uni',0));
total_trials = nogo + go;

fa_fr_nogo(anm,[1:numsess]) = fa./nogo;
fa_fr_total(anm,[1:numsess]) = fa./total_trials;

dprime_contact(anm,[1:numsess])=cell2mat(cellfun(@(x) nanmean(x.solodata.Dprime_contact),wSigSum_anmArch{anm},'uni',0));
PC_contact(anm,[1:numsess])=cell2mat(cellfun(@(x) nanmean(x.solodata.PC_contact),wSigSum_anmArch{anm},'uni',0));

end

A_fa_fr_nogo_m = nanmean(fa_fr_nogo);
A_fa_fr_total_m = nanmean(fa_fr_total);
A_dprime_contact_m = nanmean(dprime_contact);
A_PC_contact_m = nanmean(PC_contact);

A_fa_fr_nogo_s = nanstd(fa_fr_nogo)./sqrt(num_anm+1);
A_fa_fr_total_s = nanstd(fa_fr_total)./sqrt(num_anm+1);
A_dprime_contact_s = nanstd(dprime_contact)./sqrt(num_anm+1);
A_PC_contact_s = nanstd(PC_contact)./sqrt(num_anm+1);

%  sc = get(0,'ScreenSize');
% figure('position', [1000, sc(4)/10-100, sc(3)*1/2, sc(4)*1/4], 'color','w');
% % subplot(2,2,1);e=errorbar(fa_fr_nogo_m,fa_fr_nogo_s,'ko-');set(e,'markersize',6);title('fa r nogo');
% subplot(1,3,1);e=errorbar(A_fa_fr_total_m,A_fa_fr_total_s,'ro-');set(e,'markersize',6);title('fa r total');axis([0 9 0 .3]);hold on;
% subplot(1,3,2);e=errorbar(A_dprime_contact_m,A_dprime_contact_s,'ro-');set(e,'markersize',6);title('dprime'); axis([0 9 0 1.5]);hold on;
% subplot(1,3,3);e=errorbar(A_PC_contact_m,A_PC_contact_s,'ro-');set(e,'markersize',6);title('PC');axis([0 9 0 1]);hold on;

%%********************************************************

num_anm = size(wSigSum_anmCtrl,2);
fa_fr_nogo = nan(num_anm,8);
fa_fr_total = nan(num_anm,8);
dprime_contact = nan(num_anm,8);
PC_contact = nan(num_anm,8);

for anm = 1:num_anm
    numsess = size(wSigSum_anmCtrl{anm},2);
fa=cell2mat(cellfun(@(x) length(x.FAtrialnums{1}),wSigSum_anmCtrl{anm},'uni',0));
nogo=cell2mat(cellfun(@(x) length(x.nogotrialnums{1}),wSigSum_anmCtrl{anm},'uni',0));
go=cell2mat(cellfun(@(x) length(x.gotrialnums{1}),wSigSum_anmCtrl{anm},'uni',0));
total_trials = nogo + go;

fa_fr_nogo(anm,[1:numsess]) = fa./nogo;
fa_fr_total(anm,[1:numsess]) = fa./total_trials;

dprime_contact(anm,[1:numsess])=cell2mat(cellfun(@(x) nanmean(x.solodata.Dprime_contact),wSigSum_anmCtrl{anm},'uni',0));
PC_contact(anm,[1:numsess])=cell2mat(cellfun(@(x) nanmean(x.solodata.PC_contact),wSigSum_anmCtrl{anm},'uni',0));

end

C_fa_fr_nogo_m = nanmean(fa_fr_nogo);
C_fa_fr_total_m = nanmean(fa_fr_total);
C_dprime_contact_m = nanmean(dprime_contact);
C_PC_contact_m = nanmean(PC_contact);

C_fa_fr_nogo_s = nanstd(fa_fr_nogo)./sqrt(num_anm+1);
C_fa_fr_total_s = nanstd(fa_fr_total)./sqrt(num_anm+1);
C_dprime_contact_s = nanstd(dprime_contact)./sqrt(num_anm+1);
C_PC_contact_s = nanstd(PC_contact)./sqrt(num_anm+1);



%%***************************************************

 sc = get(0,'ScreenSize');
figure('position', [1000, sc(4)/10-100, sc(3)*1/2, sc(4)*1/4], 'color','w');
% subplot(2,2,1);e=errorbar(fa_fr_nogo_m,fa_fr_nogo_s,'ko-');set(e,'markersize',6);title('fa r nogo');
subplot(1,3,1);e=errorbar(A_fa_fr_total_m,A_fa_fr_total_s,'ro-');set(e,'markersize',6);title('fa r total');axis([0 9 0 .3]);hold on;
subplot(1,3,2);e=errorbar(A_dprime_contact_m,A_dprime_contact_s,'ro-');set(e,'markersize',6);title('dprime'); axis([0 9 0 1.5]);hold on;
subplot(1,3,3);e=errorbar(A_PC_contact_m,A_PC_contact_s,'ro-');set(e,'markersize',6);title('PC');axis([0 9 0 1]);hold on;
% subplot(2,2,1);e=errorbar(fa_fr_nogo_m,fa_fr_nogo_s,'ko-');set(e,'markersize',6);title('fa r nogo');
subplot(1,3,1);hold on;e=errorbar(C_fa_fr_total_m,C_fa_fr_total_s,'ko-');set(e,'markersize',6);title('fa r total');axis([0 9 0 .3]);
subplot(1,3,2);hold on;e=errorbar(C_dprime_contact_m,C_dprime_contact_s,'ko-');set(e,'markersize',6);title('dprime'); axis([0 9 0 1.5]);
subplot(1,3,3);hold on;e=errorbar(C_PC_contact_m,C_PC_contact_s,'ko-');set(e,'markersize',6);title('PC');axis([0 9 0 1]);
suptitle ('Ctrl Arch')