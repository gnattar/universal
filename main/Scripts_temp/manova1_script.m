edit classify
edit manova
clc
cd /Volumes/GR_Ext_Analysis_01/
load('131_Comb_pooled_contactCaTrials_locdep_Comb_smth rem Tag233.mat')
clc
load('131_Comb_pooled_contactCaTrials_locdep_Comb_smth.mat')
resp = cellfun(@(x) x.sigpeak,pooled_contactCaTrials_locdep,'uni',0);
resp = cell2mat(cellfun(@(x) x.sigpeak,pooled_contactCaTrials_locdep,'uni',0));
size(resp)
pole=pooled_contactCaTrials_locdep{1}.poleloc;
doc manova1
[d,p,stats] = manova1(resp,pole);
d
p
stats
eigenvec(:,1)
stats.eigenvec(:,1)
bar(eigenvec)
figure; bar(stats.eigenvec)
figure; bar(stats.eigenval)
unique(pole)
x = ones(size(pol,1));
x = ones(size(pole,1));
size(x)
x = ones(size(pole,1),1);
x
x(pole==42)=2;
[d,p,stats] = manova1(resp,pole);
[d,p,stats] = manova1(resp,x);
figure, bar(stats.eigenval)
clc
clear
load('149_150602_pooled_contactCaTrials_locdep_smth.mat')
clc
resp = cell2mat(cellfun(@(x) x.sigpeak,pooled_contactCaTrials_locdep,'uni',0));
pole=pooled_contactCaTrials_locdep{1}.poleloc;
l=pooled_contactCaTrials_locdep{1}.lightstim;
resp_NL = resp(l==0,:);
resp_L = resp(l==1,:);
pole_NL = pole(l==0,:);
pole_L = pole(l==1,:);
p = pole_L;
pp = pole_NL;
size(p)
size(pp)
size(pole_NL)
pole_NL
unique(pole)
find(pole_NL) = 225
find(pole_NL) == 225
find(pole_NL==225)

f = find(pole_NL==225)
doc find
clear find
f = find(pole_NL==225);
fTY
r = randperm(length(f))
trainOnePos = resp_NL(f(1:30),:);
testOnePos = resp_NL(f(31:end),:);
f = find(pole_NL~=225)
size(f)
r = randperm(length(f));
testOtherPos = resp_NL(f(r(1:130)));
testOtherPos = resp_NL(f(r(1:130)),:);
size(testOtherPos)
size(testOnePos)
trainOtherPos = resp_NL(f(r(1:130)),:);
testOtherPos = resp_NL(f(r(131:end)),:);
x = [trainOnePos; trainOtherPos];
size(x)
groupVar = [ones(size(trainOnePos,1),1); ones(size(trainOtherPos,1),1)*2]
[d,p,stats] = manova1(x,groupVar)
p
w = stats.eigenvec(:,1);
figure, bar(w*trainOnePos)
size(trainOnePos)
figure, bar(w*trainOnePos')
size(w)
figure, bar(w'*trainOnePos')
figure, bar([w'*trainOnePos' w'*trainOnePos])
figure, bar([w'*trainOnePos' w'*trainOnePos'])
figure, bar([w'*trainOnePos' w'*trainOtherPos'])
mean(w'*trainOnePos')
mean(w'*trainOtherPos')
figure, bar([w'*trainOnePos' w'*trainOtherPos']-1.8)
figure, bar([w'*testOnePos' w'*testOtherPos']-1.8)
mean(w'*testOtherPos')
mean(w'*testOnePos')
size(testOnePos)
figure, bar([w'*testOnePos' w'*testOtherPos']-1)
f = find(pole_L==225)
lightPolOnePos = resp_L(f,:);
size(lightPolOnePos)
lightPolOtherPos = resp_L(f,:
f = find(pole_L~=225)
lightPolOtherPos = resp_L(f,:)
size(lightPolOtherPos)
figure, bar([w'*lightPolOnePos' w'*lightPolOtherPos'])
mean(w'*lightPolOnePos')
mean(w'*lightPolOtherPos')
figure, bar([w'*lightPolOnePos' w'*lightPolOtherPos']-0.6)
size(lightPolOnePos)
binVec = [-2:0.1:4]
n = histc(w'*lightPolOnePos',binVec)
nn = histc(w'*lightPolOtherPos',binVec)
figure; bar(n,'b')
hold on; bar(nn,'r')
hold on; bar(n,'b')
m = histc(w'*testOnePos',binVec)
mm = histc(w'*testOtherPos',binVec)
figure;
bar(mm,'r')
hold on, bar(m,'b')
[~,ix] = sort(pole_L)
figure, imagesc(resp_L(ix,1))
figure, bar(resp_L(ix,1))
[c,ia,ib] = unique(pole_L)
for ii=1:4; m(ii) = mean(resp_L(pole_L==c(ii)),1); end
,
m
for ii=1:4; t(ii) = mean(resp_L(pole_L==c(ii)),1); end
t
t = zeros(19,4);
for ii=1:4; t(:,ii) = mean(resp_L(pole_L==c(ii))); end
t
for ii=1:4; t(:,ii) = mean(resp_L(pole_L==c(ii),:),2); end
for ii=1:4; t(:,ii) = mean(resp_L(pole_L==c(ii),:)); end
t
figure, imagesc(t)
t
for ii=1:4; s(:,ii) = std(resp_L(pole_L==c(ii),:)); end
s
t(1:5,:)
s(1:5,:)
help manova1