function [] = test_decoder_CaSig_v2(pooled_contactCaTrials_locdep,cond,str,train_test)

l_trials = cell2mat(cellfun(@(x) x.lightstim, pooled_contactCaTrials_locdep,'uniformoutput',0));
l_trials = l_trials(:,1);

p = [12.0 10.5 9.0 7.5 6.0];
 
if strcmp(cond,'ctrl' )   
    tk = cell2mat(cellfun(@(x) x.totalKappa_epoch_abs, pooled_contactCaTrials_locdep,'uniformoutput',0));
    pl = cell2mat(cellfun(@(x) x.poleloc, pooled_contactCaTrials_locdep,'uniformoutput',0));
    resp = cell2mat(cellfun(@(x) x.sigpeak, pooled_contactCaTrials_locdep,'uniformoutput',0));
    numtrials = size(tk,1);
    
    pl = pl(:,1);
    [vals,plid,valsid] = unique(pl);
    
    pos = p(valsid)';
    
    run_classify(numtrials,resp,pos,tk)
    suptitle([str ' CTRL']);
    set(gcf,'PaperUnits','inches');
    set(gcf,'PaperPosition',[1 1 24 18]);
    set(gcf, 'PaperSize', [10,24]);
    set(gcf,'PaperPositionMode','manual');
    print( gcf ,'-depsc2','-painters','-loose',[str ' CTRL']);
    saveas(gcf,[str ' CTRL'],'jpg');
    
elseif strcmp(cond,'ctrl_mani')    
    tk_all = cell2mat(cellfun(@(x) x.totalKappa_epoch_abs, pooled_contactCaTrials_locdep,'uniformoutput',0));
    pl_all = cell2mat(cellfun(@(x) x.poleloc, pooled_contactCaTrials_locdep,'uniformoutput',0));
    resp_all = cell2mat(cellfun(@(x) x.sigpeak, pooled_contactCaTrials_locdep,'uniformoutput',0));
    
    %run ctrl
    tk = tk_all(l_trials == 0,:);
    pl = pl_all(l_trials == 0,:);
    resp = resp_all(l_trials == 0,:);
    numtrials = size(tk,1);
    
    pl = pl(:,1);
    [vals,plid,valsid] = unique(pl);
    
    pos = p(valsid)';
    run_classify(numtrials,resp,pos,tk)
    suptitle([str ' CTRL']);
    
    set(gcf,'PaperUnits','inches');
    set(gcf,'PaperPosition',[1 1 24 18]);
    set(gcf, 'PaperSize', [10,24]);
    set(gcf,'PaperPositionMode','manual');
    print( gcf ,'-depsc2','-painters','-loose',[str ' CTRL']);
    saveas(gcf,[str ' CTRL'],'jpg');
    
    
    %run mani 
    if train_test == 1
        tk = tk_all(l_trials == 1,:);
        pl = pl_all(l_trials == 1,:);
        resp = resp_all(l_trials == 1,:);
        numtrials = size(tk,1);

        pl = pl(:,1);
        [vals,plid,valsid] = unique(pl);

        pos = p(valsid)';
        run_classify(numtrials,resp,pos,tk,)
        suptitle([str ' SIL']);

        set(gcf,'PaperUnits','inches');
        set(gcf,'PaperPosition',[1 1 24 18]);
        set(gcf, 'PaperSize', [10,24]);
        set(gcf,'PaperPositionMode','manual');
        print( gcf ,'-depsc2','-painters','-loose',[str ' SIL']);
        saveas(gcf,[str ' SIL'],'jpg');
        
    elseif train_test == 0
        tk = tk_all(l_trials == 1,:);
        pl = pl_all(l_trials == 1,:);
        resp = resp_all(l_trials == 1,:);
        numtrials = size(tk,1);

        pl = pl(:,1);
        [vals,plid,valsid] = unique(pl);

        pos = p(valsid)';
        run_classify(numtrials,resp,pos,tk)
        suptitle([str ' SIL']);

        set(gcf,'PaperUnits','inches');
        set(gcf,'PaperPosition',[1 1 24 18]);
        set(gcf, 'PaperSize', [10,24]);
        set(gcf,'PaperPositionMode','manual');
        print( gcf ,'-depsc2','-painters','-loose',[str ' SIL']);
        saveas(gcf,[str ' SIL'],'jpg');
    end
end

function run_classify(numtrials,resp,pos,tk,tt)
h1 = figure;
% dummy = figure;
num_tests = 1000;
dist_aligned = zeros(num_tests,1);
dist_shuff = zeros(num_tests,1);
dist=zeros(num_tests,1);
dist_all = zeros(num_tests,3,3);
testsetsize = 50;



%% predicting locations from CaSig alone
for s = 1:num_tests
test = randperm(numtrials,testsetsize)';
train = setxor([1:numtrials],test);
S = resp(test,:);
Y = resp(train,:);
class = classify(S,Y,pos(train));
actual = pos(test,1);
dist = sqrt((actual - class).^2);
dist_aligned (s,1,1) = sum(dist)./testsetsize;
% figure(dummy); plot(actual); hold on; plot(class,'r');hold off;
end
figure(h1);

%% shuffled control for CaSig alone
for s = 1:num_tests
test = randperm(numtrials,testsetsize)';
train = setxor([1:numtrials],test);
numtrain = size(train,1);
shuff1 = randperm(numtrain,numtrain)';shuff2 = randperm(numtrain,numtrain)';
S = resp(test,:);
Y = resp(train(shuff1),:);
class = classify(S,Y,pos(train(shuff2),1));
actual = pos(test,1);
dist = sqrt((actual - class).^2);
dist_shuff (s ,1) = sum(dist)./testsetsize;
% figure(dummy);plot(actual); hold on; plot(class,'r');hold off;
end
figure(h1); subplot(3,2,1); plot(dist_shuff,'r','linewidth',2); hold on; axis([0 1000 0 10]);
figure(h1); subplot(3,2,1);plot(dist_aligned,'k','linewidth',2); hold on;  title('Position from Ca signal alone'); set(gca,'FontSize',16);
xlabel('run #');ylabel('mean prediction error (mm)');
hista=hist(dist_aligned,[0:.5:10]);hists=hist(dist_shuff,[0:.5:10]);
figure(h1); subplot(3,2,2);plot([0:.5:10],hista,'k','linewidth',2); hold on; plot([0:.5:10],hists,'r','linewidth',2);  set(gca,'FontSize',16);
xlabel('Prediction error (mm)');ylabel('count');
dist_all(:,1,1) = dist_aligned;
dist_all(:,2,1) = dist_shuff;


%% predicting locations from Kappa alone
dist_aligned = zeros(num_tests,1);
dist_shuff = zeros(num_tests,1);
dist=zeros(num_tests,1);


for s = 1:num_tests
test = randperm(numtrials,testsetsize)';
train = setxor([1:numtrials],test);
S = tk(test,1);
Y = tk(train,1);
class = classify(S,Y,pos(train));
actual = pos(test,1);
dist = sqrt((actual - class).^2);
dist_aligned (s,1) = sum(dist)./testsetsize;
% figure(dummy);plot(actual); hold on; plot(class,'r');hold off;
end


%% shuffled control for Kappa alone
for s = 1:num_tests
test = randperm(numtrials,testsetsize)';
train = setxor([1:numtrials],test);
numtrain = size(train,1);
shuff1 = randperm(numtrain,numtrain)';shuff2 = randperm(numtrain,numtrain)';
S = tk(test,1);
Y = tk(train(shuff1),1);
class = classify(S,Y,pos(train(shuff2),1));
actual = pos(test,1);
dist = sqrt((actual - class).^2);
dist_shuff (s ,1) = sum(dist)./testsetsize;
% figure(dummy);plot(actual); hold on; plot(class,'r');hold off;
end
figure(h1); subplot(3,2,3); plot(dist_shuff,'r','linewidth',2); hold on; axis([0 1000 0 10]);
figure(h1); subplot(3,2,3);plot(dist_aligned,'k','linewidth',2); hold on;  title('Position from Touch mag alone'); axis([0 1000 0 10]); set(gca,'FontSize',16);
xlabel('run #');ylabel('mean prediction error (mm)');
hista=hist(dist_aligned,[0:.5:10]);hists=hist(dist_shuff,[0:.5:10]);
figure(h1); subplot(3,2,4);plot([0:.5:10],hista,'k','linewidth',2); hold on; plot([0:.5:10],hists,'r','linewidth',2);  set(gca,'FontSize',16);
xlabel('Prediction error (mm)');ylabel('count');
dist_all(:,1,2) = dist_aligned;
dist_all(:,2,2) = dist_shuff;

%% Predicting locations from Ca/Ka aligned test sets assuming linear relationship
dist_aligned = zeros(num_tests,1);
dist_shuff = zeros(num_tests,1);
dist=zeros(num_tests,1);

for s = 1:num_tests
test = randperm(numtrials,testsetsize)';
train = setxor([1:numtrials],test);
S = resp(test,:)./tk(test,:);
Y = resp(train,:)./tk(train,:);
class = classify(S,Y,pos(train));
actual = pos(test,1);
dist = sqrt((actual - class).^2);
dist_aligned (s ,1) = sum(dist)./testsetsize;
% figure(dummy);plot(actual); hold on; plot(class,'r');hold off;
end

%% shuffled control location from Ca/Ka , locations are shuffled
for s = 1:num_tests
test = randperm(numtrials,testsetsize)';
train = setxor([1:numtrials],test);
numtrain = size(train,1);
shuff1 = randperm(numtrain,numtrain)';shuff2 = randperm(numtrain,numtrain)';
S = resp(test,:)./tk(test,:);
Y = resp(train(shuff1),:)./tk(train(shuff1),:);
class = classify(S,Y,pos(train(shuff2),1));
actual = pos(test,1);
dist = sqrt((actual - class).^2);
dist_shuffpos (s ,1) = sum(dist)./testsetsize;
% figure(dummy);plot(actual); hold on; plot(class,'r');hold off;
end
figure(h1); subplot(3,2,5); plot(dist_shuffpos,'r','linewidth',2); hold on;


%% shuffled control location from Ca/Ka , Ka are shuffled
for s = 1:num_tests
test1 = randperm(numtrials,testsetsize)';
test2 = randperm(numtrials,testsetsize)';
train = setxor([1:numtrials],test);
numtrain = size(train,1);
shuff3 = randperm(numtrain,numtrain)';shuff4 = randperm(numtrain,numtrain)';
S = resp(test1,:)./tk(test2,:);
Y = resp(train(shuff3),:)./tk(train(shuff4),:);
class = classify(S,Y,pos(train(shuff3),1));
actual = pos(test1,1);
dist = sqrt((actual - class).^2);
dist_shufftk (s ,1) = sum(dist)./testsetsize;
% figure(dummy);plot(actual); hold on; plot(class,'r');hold off;
end

figure(h1);subplot(3,2,5);plot(dist_shufftk,'color',[.85 .5 0 ],'linewidth',2); hold on;  axis([0 1000 0 10]);
figure(h1);subplot(3,2,5); plot(dist_aligned,'k','linewidth',2); hold on;  title('Position from Ca/Touch'); hold on; axis([0 1000 0 10]); set(gca,'FontSize',16);
xlabel('run #');ylabel('mean prediction error (mm)');
dist_all(:,1,3) = dist_aligned;
dist_all(:,2,3) = dist_shuff;
dist_all(:,3,3) = dist_shufftk;
hista=hist(dist_aligned,[0:.5:10]);hists=hist(dist_shuffpos,[0:.5:10]);histstk=hist(dist_shufftk,[0:.5:10]);
figure(h1); subplot(3,2,6);plot([0:.5:10],hista,'k','linewidth',2); hold on; plot([0:.5:10],hists,'r','linewidth',2); hold on; plot([0:.5:10],histstk,'color',[.85 .5 0 ],'linewidth',2);  set(gca,'FontSize',16);
xlabel('Prediction error (mm)');ylabel('count');

