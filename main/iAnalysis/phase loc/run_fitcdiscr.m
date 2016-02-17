function [fr_correct] = run_fitcdiscr(train_X,train_Y,test_X,test_Y,tt,disc_func,plot_on,mdl_list, num_tests,txt)


dist_aligned = zeros(num_tests,1);
dist_shuff = zeros(num_tests,1);
dist=zeros(num_tests,1);
dist_all = zeros(num_tests,3,3);


    r= 1;
    c=4;


testsetsize = 50;
uL = 10;
bw=0.1;
bins = [ 0:bw:uL];
numbins = size(bins,2);
train_numtrials = size(train_X,1);
test_numtrials = size(test_X,1);

hist_all = zeros(numbins,3,3);
chist_all = zeros(numbins,3,3);


%% predicting 
for s = 1:num_tests
     ['--test run aligned--' num2str(s)]
    test = randperm(test_numtrials,testsetsize)';
    if tt
        train = setxor([1:test_numtrials],test);
    
    else
        train = randperm(train_numtrials,train_numtrials)';
    end
    
    S = test_X(test,:);
    Y = train_X(train,:);
%     if tt
%          Mdl = fitcdiscr(Y,train_Y(train),'DiscrimType',disc_func);
        class = classify(S,Y,train_Y(train),disc_func);
%     else
%          Mdl = mdl_list{s};
%     end
%     label = predict(Mdl,S);
%     class = label;

    actual = test_Y(test,1);
    dist = sqrt((actual - class).^2);
    dist_aligned (s,1,1) = sum(dist)./testsetsize;
    dist_aligned_err{s} =  (actual-class);

%     mdl_list{s} = Mdl;
end

if plot_on
    sc = get(0,'ScreenSize');
    h1=figure('position', [1000, sc(4), sc(3)/1.5, sc(4)/4], 'color','w');
end
%% shuffled control 
for s = 1:num_tests
        ['--test run shuff --' num2str(s)]
    test = randperm(test_numtrials,testsetsize)';
    if tt
        train = setxor([1:test_numtrials],test);
    else
        train = randperm(train_numtrials,train_numtrials)';
    end
    numtrain = size(train,1);
    shuff1 = randperm(numtrain,numtrain)';shuff2 = randperm(numtrain,numtrain)';
    S = test_X(test,:);
    Y = train_X(train(shuff1),:);
    all_Y = unique(train_Y);
    all_Y_ind = 1:length(all_Y);
    shuff_Y_train = round(min(all_Y_ind) + (max(all_Y_ind)-min(all_Y_ind)).*rand(length(shuff1),1));
    shuff_Y_test = round(min(all_Y_ind) + (max(all_Y_ind)-min(all_Y_ind)).*rand(length(test),1));
    shuff_Y_train = all_Y(shuff_Y_train);
    shuff_Y_test = all_Y(shuff_Y_test);

%     Mdl = fitcdiscr(Y,shuff_Y_train,'DiscrimType',disc_func);
%     label = predict(Mdl,S);
%     class = label;  
        class = classify(S,Y,train_Y(train),disc_func);

    actual = shuff_Y_test;
    dist = sqrt((actual - class).^2);
    dist_shuff (s ,1) = sum(dist)./testsetsize;
    dist_shuff_err{s} = (actual-class);
end
if plot_on
    plotcount =1;
    figure(h1); subplot(r,c,plotcount); plot(dist_shuff,'r','linewidth',2); hold on; axis([0 num_tests 0 uL]);
    figure(h1); subplot(r,c,plotcount);plot(dist_aligned,'k','linewidth',2); hold on;  title(txt); set(gca,'FontSize',16);plotcount=plotcount+1;
    xlabel('run #');ylabel('mean prediction error (mm)');
end

hista=hist(dist_aligned,[0:bw:uL])./num_tests;hists=hist(dist_shuff,[0:bw:uL])./num_tests;
if plot_on
    figure(h1); subplot(r,c,plotcount);plot([0:bw:uL],hista,'k','linewidth',2); hold on; plot([0:bw:uL],hists,'r','linewidth',2);  set(gca,'FontSize',16);plotcount=plotcount+1;
    xlabel('Prediction error (mm)');ylabel('Pr');
end
[h,p] = kstest2(dist_aligned,dist_shuff);
p_all(1,1,1) = p;
temp = min([hista;hists]);
pOL_all(1,1,1) = sum(temp);
if plot_on
    tb = text(2,.105, ['pO = ' num2str(sum(temp))],'FontSize',12);set(tb,'color','k');
    tb = text(2,.125, ['p = ' num2str(p)],'FontSize',12);set(tb,'color','k');
end
chista = cumsum(hista);chists = cumsum(hists);
if plot_on
    figure(h1); subplot(r,c,plotcount);plot([0:bw:uL],chista,'k','linewidth',2); hold on; plot([0:bw:uL],chists,'r','linewidth',2);  set(gca,'FontSize',16); axis([0 uL 0 1]);plotcount=plotcount+1;
    xlabel('Prediction error (mm)');ylabel('C.Pr');
end


dist_all(:,1,1) = dist_aligned;
dist_all(:,2,1) = dist_shuff;
dist_err (:,1,1) = cell2mat(dist_aligned_err');
dist_err (:,2,1) = cell2mat(dist_shuff_err');
hist_all(:,1,1) = hista;
hist_all(:,2,1) = hists;
chist_all(:,1,1) = chista;
chist_all(:,2,1) = chists;

mEr_all(1,1,1) = prctile(dist_aligned,50);
mEr_all(1,2,1) = prctile(dist_shuff,50);
if plot_on
    tb = text(2,.6, num2str(mEr_all(1,1,1)),'FontSize',12);set(tb,'color','k');
    tb = text(2,.8, num2str(mEr_all(1,2,1)),'FontSize',12);set(tb,'color','r');
end


    numtotal(1,1) = length(dist_err(:,1,1));numtotal(1,2) = length(dist_err(:,2,1));
    tw = abs(dist_err(find(dist_err(:,1,1)~=0),1,1));
    binw = min(tw);binm=max(dist_err(:,2,1))+1;

    histal = hist(dist_err(:,1,1),unique(dist_err))./numtotal(1,1);
    histsh=hist(dist_err(:,2,1),unique(dist_err))./numtotal(1,2)
if plot_on
    figure(h1); subplot(r,c,plotcount);plot(unique(dist_err),histal,'k','linewidth',2); hold on; plot(unique(dist_err),histsh,'r','linewidth',2); set(gca,'FontSize',16); axis([-binm binm 0 1]);plotcount=plotcount+1;
    xlabel('Prediction error (mm)');ylabel('C.Pr');
end

binnew = unique(dist_err);
zerobin = find(binnew ==0);
fr_correct(1,1,1) = histal(zerobin);
fr_correct(1,2,1) = histsh(zerobin);

if plot_on
    tb = text(2,.6, num2str(fr_correct(1,1,1)),'FontSize',12);set(tb,'color','k');
    tb = text(2,.8, num2str(fr_correct(1,2,1)),'FontSize',12);set(tb,'color','r');
end
