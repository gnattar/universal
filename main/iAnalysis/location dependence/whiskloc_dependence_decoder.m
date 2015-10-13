function [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,par,cond,str,train_test,pos,disc_func,src,plot_on,proj_on)
%[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,cond,str,train_test,pos)
% cond 'ctrl' or 'ctrl_mani'
% pos pole positions
% train_test =1 if mani is to be trained with mani trials, =0 if it is to
% be trained with ctrl trials
% disc_func 'linear' or 'diagquadratic'
p = pos; %[15 13.5 12 10.5 9 7.5];
num_runs = 5;
if strcmp(cond,'ctrl' )
    l_trials= pooled_contactCaTrials_locdep{1}.lightstim;
else
    switch src
        case 'def'
            l_trials = cell2mat(cellfun(@(x) x.lightstim, pooled_contactCaTrials_locdep,'uniformoutput',0));
            l_trials = l_trials(:,1);
        case 'LAD'
            l_trials = cell2mat(cellfun(@(x) x.decoder.LAD.lightstim, pooled_contactCaTrials_locdep,'uniformoutput',0));
            l_trials = l_trials(:,1);
        case 'NLS'
            l_trials = cell2mat(cellfun(@(x) x.decoder.NLS.lightstim, pooled_contactCaTrials_locdep,'uniformoutput',0));
            l_trials = l_trials(:,1);
        case 'NC'
            l_trials = cell2mat(cellfun(@(x) x.decoder.NC.lightstim, pooled_contactCaTrials_locdep,'uniformoutput',0));
            l_trials = l_trials(:,1);
        otherwise
            l_trials = cell2mat(cellfun(@(x) x.lightstim, pooled_contactCaTrials_locdep,'uniformoutput',0));
            l_trials = l_trials(:,1);
    end
    
end

% R=cell2mat(cellfun(@(x) x.sigpeak',pooled_contactCaTrials_locdep,'uni',0)')';
% [r,pval]=corrcoef(R);
% temp=tril(r,-1);
% r_collect=r(find(temp~=0));
% map = brewermap(100,'YlOrRd');
% figure; subplot(1,2,1); imagesc(r,[0 1.2]);colormap(map);subplot(1,2,2); plot([0:.1:1],hist(r_collect,[0:.1:1])); suptitle([str]);
% saveas(gcf,[str ' Corrcoef'],'fig');
% saveas(gcf,[str ' Corrcoef'],'jpg');
% save([str ' Corrcoef'],'r');
% save([ str ' PValues'],'pval');

if strcmp(cond,'ctrl' )
    tk = cell2mat(cellfun(@(x) x.re_totaldK, pooled_contactCaTrials_locdep,'uniformoutput',0));
    pl = cell2mat(cellfun(@(x) x.poleloc, pooled_contactCaTrials_locdep,'uniformoutput',0));
    
    resp = cell2mat(cellfun(@(x) x.(par), pooled_contactCaTrials_locdep,'uniformoutput',0));
    numtrials = size(tk,1);
    pl = pl(:,1);
    [vals,plid,valsid] = unique(pl);
    pos = p(valsid)';
    
    if proj_on
        [coeff,score]=pca(resp,'numcomponents',1);
        weights=repmat(coeff',size(resp,1),1);
        proj=resp.*weights;
        train_resp=proj;test_resp=proj;
    else        
        train_resp = resp; test_resp = resp;
    end
    train_pl = pl; test_pl = pl;
    train_tk = tk; test_tk = tk;
    train_pos=pos;test_pos = pos;
    
    
     w = waitbar(0, 'Start ctrl LDA runs  ...');
    for n = 1:num_runs
        [dist_n,hist_n,chist_n,mEr_n,pOL_n,p_n] = run_classify(train_resp,train_pos,train_tk,test_resp,test_pos,test_tk,train_test,disc_func,plot_on,src);
        dist_all{n} = dist_n;
        hist_all{n} =hist_n;
        chist_all{n} =chist_n;
        mEr_all{n} =mEr_n;
        pOL_all{n} =pOL_n;
        p_all{n} =p_n;
        waitbar((n+1)/(num_runs), w,[num2str(n) '/' num2str(num_runs)]);
    end
    close (w);
    if plot_on
        set(gcf,'PaperUnits','inches');
        set(gcf,'PaperPosition',[1 1 24 18]);
        set(gcf, 'PaperSize', [10,24]);
        set(gcf,'PaperPositionMode','manual');
        pause(.5);
        suptitle([str ' ' disc_func ' CTRL']);
        %     print( gcf ,'-depsc2','-painters','-loose',[str ' ' disc_func ' CTRL']);
        saveas(gcf,[str ' CTRL'],'fig');
        saveas(gcf,[str ' CTRL'],'jpg');
    end
    summary.ctrl.hist = hist_all;
    summary.ctrl.dist=dist_all;
    summary.ctrl.chist = chist_all;
    summary.ctrl.mEr = mEr_all;
    summary.ctrl.pvalue=p_all;
    summary.ctrl.percentoverlap = pOL_all;
    summary.ctrl.mEr = mEr_all;
    summary.ctrl.percentoverlap = pOL_all;
        
    summary.ctrl.mmEr(1,1,1) = mean(cellfun(@(x) x(1,1,1), mEr_all)'); % aligned
    summary.ctrl.smEr(1,1,1) = std(cellfun(@(x) x(1,1,1), mEr_all)')./sqrt(num_runs);
    summary.ctrl.mmEr(1,2,1) = mean(cellfun(@(x) x(1,2,1), mEr_all)'); % shuffled
    summary.ctrl.smEr(1,2,1) = std(cellfun(@(x) x(1,2,1), mEr_all)')./sqrt(num_runs);
    summary.ctrl.mpercentoverlap(1,1,1) = mean(cellfun(@(x) x(1,1,1), pOL_all)');
    summary.ctrl.spercentoverlap (1,1,1)= std(cellfun(@(x) x(1,1,1), pOL_all)')./sqrt(num_runs);
    summary.info =  [str];
    save([str ' decoder results'],'summary');
    
    
elseif strcmp(cond,'ctrl_mani')
    switch src
        case 'def'
            tk_all = cell2mat(cellfun(@(x) x.re_totaldK, pooled_contactCaTrials_locdep,'uniformoutput',0));
            pl_all = cell2mat(cellfun(@(x) x.poleloc, pooled_contactCaTrials_locdep,'uniformoutput',0));
            resp_all = cell2mat(cellfun(@(x) x.(par), pooled_contactCaTrials_locdep,'uniformoutput',0));
        case 'LAD'
            tk_all = cell2mat(cellfun(@(x) x.decoder.LAD.re_totaldK, pooled_contactCaTrials_locdep,'uniformoutput',0));
            pl_all = cell2mat(cellfun(@(x) x.decoder.LAD.poleloc, pooled_contactCaTrials_locdep,'uniformoutput',0));
            resp_all = cell2mat(cellfun(@(x) x.decoder.LAD.(par), pooled_contactCaTrials_locdep,'uniformoutput',0));
        case 'NLS'
            tk_all = cell2mat(cellfun(@(x) x.decoder.NLS.re_totaldK, pooled_contactCaTrials_locdep,'uniformoutput',0));
            pl_all = cell2mat(cellfun(@(x) x.decoder.NLS.poleloc, pooled_contactCaTrials_locdep,'uniformoutput',0));
            resp_all = cell2mat(cellfun(@(x) x.decoder.NLS.(par), pooled_contactCaTrials_locdep,'uniformoutput',0));
        case 'NC'
            tk_all = cell2mat(cellfun(@(x) x.decoder.NC.re_totaldK, pooled_contactCaTrials_locdep,'uniformoutput',0));
            pl_all = cell2mat(cellfun(@(x) x.decoder.NC.poleloc, pooled_contactCaTrials_locdep,'uniformoutput',0));
            resp_all = cell2mat(cellfun(@(x) x.decoder.NC.(par), pooled_contactCaTrials_locdep,'uniformoutput',0));        
        otherwise
            tk_all = cell2mat(cellfun(@(x) x.re_totaldK, pooled_contactCaTrials_locdep,'uniformoutput',0));
            pl_all = cell2mat(cellfun(@(x) x.poleloc, pooled_contactCaTrials_locdep,'uniformoutput',0));
            resp_all = cell2mat(cellfun(@(x) x.(par), pooled_contactCaTrials_locdep,'uniformoutput',0));
    end
    
    %run ctrl
    tk = tk_all(l_trials == 0,:);
    pl = pl_all(l_trials == 0,:);
    resp = resp_all(l_trials == 0,:);
    numtrials = size(tk,1);
    
    pl = pl(:,1);
    [vals,plid,valsid] = unique(pl);
    pos = p(valsid)';
    
    if proj_on
        [coeff,score]=pca(resp,'numcomponents',1);
        weights=repmat(coeff',size(resp,1),1);
        proj=resp.*weights;
        train_resp=proj;test_resp=proj;
    else
        train_resp = resp; test_resp = resp;
    end
    train_pl = pl; test_pl = pl;
    train_tk = tk; test_tk = tk;
    train_pos=pos;test_pos = pos;
    
    w = waitbar(0, 'Start ctrl LDA runs  ...');
    for n = 1:num_runs
        [dist_n,hist_n,chist_n,mEr_n,pOL_n,p_n]=run_classify(train_resp,train_pos,train_tk,test_resp,test_pos,test_tk,1,disc_func,plot_on,src);
        dist_all{n} = dist_n;
        hist_all{n} =hist_n;
        chist_all{n} =chist_n;
        mEr_all{n} =mEr_n;
        pOL_all{n} =pOL_n;
        p_all{n} =p_n;
        waitbar((n+1)/(num_runs), w,[num2str(n) '/' num2str(num_runs)]);
    end
    close (w);
    
    if train_test == 1
        tag = 'selftrain';
    else
        tag = 'ctrltrain';
    end
    if plot_on
        set(gcf,'PaperUnits','inches');
        set(gcf,'PaperPosition',[1 1 24 18]);
        set(gcf, 'PaperSize', [10,24]);
        set(gcf,'PaperPositionMode','auto');
        pause(.5);
        suptitle([str ' ' disc_func ' CTRL' tag]);
        %     print( gcf ,'-depsc2','-painters','-loose',[str ' ' disc_func ' CTRL' tag]);
        saveas(gcf,[str ' ' disc_func  ' CTRL' tag ],'fig');
        saveas(gcf,[str ' ' disc_func  ' CTRL' tag ],'jpg');
    end
    summary.ctrl.hist = hist_all;
    summary.ctrl.dist=dist_all;
    summary.ctrl.chist = chist_all;
    summary.ctrl.mEr = mEr_all;
    summary.ctrl.pvalue=p_all;
    summary.ctrl.percentoverlap = pOL_all;
    summary.ctrl.mmEr(1,1,1) = mean(cellfun(@(x) x(1,1,1), mEr_all)'); % aligned
    summary.ctrl.smEr(1,1,1) = std(cellfun(@(x) x(1,1,1), mEr_all)')./sqrt(num_runs);
    summary.ctrl.mmEr(1,2,1) = mean(cellfun(@(x) x(1,2,1), mEr_all)'); % shuffled
    summary.ctrl.smEr(1,2,1) = std(cellfun(@(x) x(1,2,1), mEr_all)')./sqrt(num_runs);
    summary.ctrl.mpercentoverlap(1,1,1) = mean(cellfun(@(x) x(1,1,1), pOL_all)');
    summary.ctrl.spercentoverlap (1,1,1)= std(cellfun(@(x) x(1,1,1), pOL_all)')./sqrt(num_runs);
    
    %run mani
    
    tk = tk_all(l_trials == 1,:);
    pl = pl_all(l_trials == 1,:);
    resp = resp_all(l_trials == 1,:);
    numtrials = size(tk,1);
    pl = pl(:,1);
    [vals,plid,valsid] = unique(pl);
    pos = p(valsid)';
    
    if train_test == 1
        if proj_on
            [coeff,score]=pca(resp,'numcomponents',1);
            weights=repmat(coeff',size(resp,1),1);
            proj=resp.*weights;
            train_resp=proj;test_resp=proj;
        else
            train_resp = resp; test_resp = resp;
        end
        train_pl = pl; test_pl = pl;
        train_tk = tk; test_tk = tk;
        train_pos=pos;test_pos = pos;
         w = waitbar(0, 'Start mani LDA runs  ...');
        for n = 1:num_runs
            [dist_n,hist_n,chist_n,mEr_n,pOL_n,p_n]=run_classify(train_resp,train_pos,train_tk,test_resp,test_pos,test_tk,train_test,disc_func,plot_on,src);
            dist_all{n} = dist_n;
            hist_all{n} =hist_n;
            chist_all{n} =chist_n;
            mEr_all{n} =mEr_n;
            pOL_all{n} =pOL_n;
            p_all{n} =p_n;
            waitbar((n+1)/(num_runs), w,[num2str(n) '/' num2str(num_runs)]);
        end
        close (w);
        tag = 'selftrain';
        
    elseif train_test == 0
        
        if proj_on
            [coeff,score]=pca(resp,'numcomponents',1);
            weights=repmat(coeff',size(resp,1),1);
            proj=resp.*weights;
            test_resp=proj;
        else
            test_resp = resp;
        end
       
        test_pl = pl;
        test_tk = tk;
        test_pos = pos;
         w = waitbar(0, 'Start mani LDA runs  ...');
        for n = 1:num_runs
            [dist_n,hist_n,chist_n,mEr_n,pOL_n,p_n]=run_classify(train_resp,train_pos,train_tk,test_resp,test_pos,test_tk,train_test,disc_func,plot_on,src);
            dist_all{n} = dist_n;
            hist_all{n} =hist_n;
            chist_all{n} =chist_n;
            mEr_all{n} =mEr_n;
            pOL_all{n} =pOL_n;
            p_all{n} =p_n;
            waitbar((n+1)/(num_runs), w,[num2str(n) '/' num2str(num_runs)]);
        end
        close(w);
        tag = 'ctrltrain';
    end
    if plot_on
        set(gcf,'PaperUnits','inches');
        set(gcf,'PaperPosition',[1 1 24 18]);
        set(gcf, 'PaperSize', [10,24]);
        set(gcf,'PaperPositionMode','auto');
        pause(.5);
        suptitle([str ' SIL ' tag]);
        %     print( gcf ,'-depsc2','-painters','-loose',[str ' SIL ' tag]);
        saveas(gcf,[str ' ' disc_func ' SIL ' tag],'fig');
        saveas(gcf,[str ' ' disc_func ' SIL ' tag],'jpg');
    end
    summary.mani.hist = hist_all;
    summary.mani.dist=dist_all;
    summary.mani.chist = chist_all;
    summary.mani.mEr = mEr_all;
    summary.mani.pvalue=p_all;
    summary.mani.percentoverlap = pOL_all;
    summary.mani.mmEr(1,1,1) = mean(cellfun(@(x) x(1,1,1), mEr_all)'); % aligned
    summary.mani.smEr(1,1,1) = std(cellfun(@(x) x(1,1,1), mEr_all)')./sqrt(num_runs);
    summary.mani.mmEr(1,2,1) = mean(cellfun(@(x) x(1,2,1), mEr_all)'); % shuffled
    summary.mani.smEr(1,2,1) = std(cellfun(@(x) x(1,2,1), mEr_all)')./sqrt(num_runs);
    summary.mani.mpercentoverlap(1,1,1) = mean(cellfun(@(x) x(1,1,1), pOL_all)');
    summary.mani.spercentoverlap (1,1,1)= std(cellfun(@(x) x(1,1,1), pOL_all)')./sqrt(num_runs);
    summary.info =  [str ' ' tag];
    save([str ' ' disc_func ' '  tag ' decoder results'],'summary');
    
end

function [dist_all,hist_all,chist_all,mEr_all,pOL_all,p_all] = run_classify(train_resp,train_pos,train_tk,test_resp,test_pos,test_tk,tt,disc_func,plot_on,src)


num_tests = 1000;
dist_aligned = zeros(num_tests,1);
dist_shuff = zeros(num_tests,1);
dist=zeros(num_tests,1);
dist_all = zeros(num_tests,3,3);
plotjustcasig =1;

if plotjustcasig
    r= 1;
    c=3;
else
    r=3;
    c=3;
end

% dummy = figure;
testsetsize = 50;
uL = 10;
bw=0.1;
bins = [ 0:bw:uL];
numbins = size(bins,2);
train_numtrials = size(train_resp,1);
test_numtrials = size(test_resp,1);

hist_all = zeros(numbins,3,3);
chist_all = zeros(numbins,3,3);

mEr_all = zeros(1,3,3);
pOL_all= zeros(1,3,3);
p_all = zeros(1,3,3);
%% predicting locations from CaSig alone
for s = 1:num_tests
    test = randperm(test_numtrials,testsetsize)';
    if tt
        train = setxor([1:test_numtrials],test);
    elseif (strcmp(src,'NC') | strcmp(src,'NLS'))
        train = setxor([1:train_numtrials],test);        
    else
        train = randperm(train_numtrials,train_numtrials)';
    end
    
    S = test_resp(test,:);
    Y = train_resp(train,:);
    class = classify(S,Y,train_pos(train),disc_func);
    actual = test_pos(test,1);
    dist = sqrt((actual - class).^2);
    dist_aligned (s,1,1) = sum(dist)./testsetsize;
%      figure(dummy); plot(actual); hold on; plot(class,'r');hold off;
end
% dummy = figure;
if plot_on
    sc = get(0,'ScreenSize');
    h1=figure('position', [1000, sc(4), sc(3)/1.5, sc(4)/4], 'color','w');
end
%% shuffled control for CaSig alone
for s = 1:num_tests
    test = randperm(test_numtrials,testsetsize)';
    if tt
        train = setxor([1:test_numtrials],test);
    elseif (strcmp(src,'NC') | strcmp(src,'NLS'))
        train = setxor([1:train_numtrials],test);
    else
        train = randperm(train_numtrials,train_numtrials)';
    end
    numtrain = size(train,1);
    shuff1 = randperm(numtrain,numtrain)';shuff2 = randperm(numtrain,numtrain)';
    S = test_resp(test,:);
    Y = train_resp(train(shuff1),:);
    class = classify(S,Y,train_pos(train(shuff2),1),disc_func);
    actual = test_pos(test,1);
    dist = sqrt((actual - class).^2);
    dist_shuff (s ,1) = sum(dist)./testsetsize;
    % figure(dummy);plot(actual); hold on; plot(class,'r');hold off;
end
if plot_on
    plotcount =1;
    figure(h1); subplot(r,c,plotcount); plot(dist_shuff,'r','linewidth',2); hold on; axis([0 num_tests 0 uL]);
    figure(h1); subplot(r,c,plotcount);plot(dist_aligned,'k','linewidth',2); hold on;  title('Position from Ca signal alone'); set(gca,'FontSize',16);plotcount=plotcount+1;
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
hist_all(:,1,1) = hista;
hist_all(:,2,1) = hists;
chist_all(:,1,1) = chista;
chist_all(:,2,1) = chists;

mEr_all(1,1,1) = prctile(dist_aligned,50);
mEr_all(1,2,1) = prctile(dist_shuff,50);
% pdt=hista.*hists;
% temp = (hista+hists).*(pdt>1);
if plot_on
    tb = text(2,.6, num2str(mEr_all(1,1,1)),'FontSize',12);set(tb,'color','k');
    tb = text(2,.8, num2str(mEr_all(1,2,1)),'FontSize',12);set(tb,'color','r');
end
if ~plotjustcasig
    %% predicting locations from Kappa alone
    dist_aligned = zeros(num_tests,1);
    dist_shuff = zeros(num_tests,1);
    dist=zeros(num_tests,1);
    
    for s = 1:num_tests
        test = randperm(test_numtrials,testsetsize)';
        if tt
            train = setxor([1:test_numtrials],test);
        else
            train = randperm(train_numtrials,train_numtrials)';
        end
        S = test_tk(test,1);
        Y = train_tk(train,1);
        class = classify(S,Y,train_pos(train),disc_func);
        actual = test_pos(test,1);
        dist = sqrt((actual - class).^2);
        dist_aligned (s,1) = sum(dist)./testsetsize;
        % figure(dummy);plot(actual); hold on; plot(class,'r');hold off;
    end
    
    
    %% shuffled control for Kappa alone
    for s = 1:num_tests
        test = randperm(test_numtrials,testsetsize)';
        if tt
            train = setxor([1:test_numtrials],test);
        else
            train = randperm(train_numtrials,train_numtrials)';
        end
        
        numtrain = size(train,1);
        shuff1 = randperm(numtrain,numtrain)';shuff2 = randperm(numtrain,numtrain)';
        S = test_tk(test,1);
        Y = train_tk(train(shuff1),1);
        class = classify(S,Y,train_pos(train(shuff2),1),disc_func);
        actual = test_pos(test,1);
        dist = sqrt((actual - class).^2);
        dist_shuff (s ,1) = sum(dist)./testsetsize;
        % figure(dummy);plot(actual); hold on; plot(class,'r');hold off;
    end
    if plot_on
        figure(h1); subplot(r,c,plotcount); plot(dist_shuff,'r','linewidth',2); hold on; axis([0 num_tests 0 uL]);
        figure(h1); subplot(r,c,plotcount);plot(dist_aligned,'k','linewidth',2); hold on;  title('Position from Touch mag alone'); axis([0 1000 0 10]); set(gca,'FontSize',16);plotcount=plotcount+1;
        xlabel('run #');ylabel('mean prediction error (mm)');
        hista=hist(dist_aligned,[0:bw:uL])./num_tests;hists=hist(dist_shuff,[0:bw:uL])./num_tests;
        figure(h1); subplot(3,3,5);plot([0:bw:uL],hista,'k','linewidth',2); hold on; plot([0:bw:uL],hists,'r','linewidth',2);  set(gca,'FontSize',16);
        xlabel('Prediction error (mm)');ylabel('Pr');
    end
    [h,p] = kstest2([dist_aligned,dist_shuff]);
    p_all(1,1,2) = p;
    temp = min([hista;hists]);
    pOL_all(1,1,2) = sum(temp);
    if plot_on
        tb = text(2,.175, [ 'p = ' num2str(sum(temp))],'FontSize',12);set(tb,'color','k');
    end
    chista = cumsum(hista);chists = cumsum(hists);
    if plot_on
        figure(h1); subplot(r,c,plotcount);plot([0:bw:uL],chista,'k','linewidth',2); hold on; plot([0:bw:uL],chists,'r','linewidth',2);  set(gca,'FontSize',16);axis([0 uL 0 1]);plotcount=plotcount+1;
        xlabel('Prediction error (mm)');ylabel('C.Pr');
    end
    dist_all(:,1,2) = dist_aligned;
    dist_all(:,2,2) = dist_shuff;
    hist_all(:,1,2) = hista;
    hist_all(:,2,2) = hists;
    chist_all(:,1,2) = chista;
    chist_all(:,2,2) = chists;
    
    mEr_all(1,1,2) = prctile(dist_aligned,50);
    mEr_all(1,2,2) = prctile(dist_shuff,50);
    if plot_on
        tb = text(2,.6, num2str(mEr_all(1,1,2)),'FontSize',12);set(tb,'color','k');
        tb = text(2,.8, num2str(mEr_all(1,2,2)),'FontSize',12);set(tb,'color','r');
    end
    %% Predicting locations from Ca/Ka aligned test sets assuming linear relationship
    dist_aligned = zeros(num_tests,1);
    dist_shuff = zeros(num_tests,1);
    dist=zeros(num_tests,1);
    
    for s = 1:num_tests
        test = randperm(test_numtrials,testsetsize)';
        if tt
            train = setxor([1:test_numtrials],test);
        else
            train = randperm(train_numtrials,train_numtrials)';
        end
        S = test_resp(test,:)./test_tk(test,:);
        Y = train_resp(train,:)./train_tk(train,:);
        class = classify(S,Y,train_pos(train),disc_func);
        actual = test_pos(test,1);
        dist = sqrt((actual - class).^2);
        dist_aligned (s ,1) = sum(dist)./testsetsize;
        % figure(dummy);plot(actual); hold on; plot(class,'r');hold off;
    end
    
    %% shuffled control location from Ca/Ka , locations are shuffled
    for s = 1:num_tests
        test = randperm(test_numtrials,testsetsize)';
        if tt
            train = setxor([1:test_numtrials],test);
        else
            train = randperm(train_numtrials,train_numtrials)';
        end
        numtrain = size(train,1);
        shuff1 = randperm(numtrain,numtrain)';shuff2 = randperm(numtrain,numtrain)';
        S = test_resp(test,:)./test_tk(test,:);
        Y = train_resp(train(shuff1),:)./train_tk(train(shuff1),:);
        class = classify(S,Y,train_pos(train(shuff2),1),disc_func);
        actual = test_pos(test,1);
        dist = sqrt((actual - class).^2);
        dist_shuffpos (s ,1) = sum(dist)./testsetsize;
        % figure(dummy);plot(actual); hold on; plot(class,'r');hold off;
    end
    if plot_on
        figure(h1); subplot(3,2,5); plot(dist_shuffpos,'r','linewidth',2); hold on;
    end
    
    %% shuffled control location from Ca/Ka , Ka are shuffled
    for s = 1:num_tests
        test1 = randperm(test_numtrials,testsetsize)';
        test2 = randperm(test_numtrials,testsetsize)';
        if tt
            train = setxor([1:test_numtrials],test);
        else
            train = randperm(train_numtrials,train_numtrials)';
        end
        numtrain = size(train,1);
        shuff3 = randperm(numtrain,numtrain)';shuff4 = randperm(numtrain,numtrain)';
        S = test_resp(test1,:)./test_tk(test2,:);
        Y = train_resp(train(shuff3),:)./train_tk(train(shuff4),:);
        class = classify(S,Y,train_pos(train(shuff3),1),disc_func);
        actual = test_pos(test1,1);
        dist = sqrt((actual - class).^2);
        dist_shufftk (s ,1) = sum(dist)./testsetsize;
        % figure(dummy);plot(actual); hold on; plot(class,'r');hold off;
    end
    if plot_on
        figure(h1);subplot(r,c,plotcount);plot(dist_shufftk,'color',[.85 .5 0 ],'linewidth',2); hold on; axis([0 num_tests 0 uL]);
        figure(h1);subplot(r,c,plotcount); plot(dist_aligned,'k','linewidth',2); hold on;  title('Position from Ca/Touch'); hold on; axis([0 1000 0 10]); set(gca,'FontSize',16);plotcount=plotcount+1;
        xlabel('run #');ylabel('mean prediction error (mm)');
    end
    hista=hist(dist_aligned,[0:bw:uL])./num_tests;hists=hist(dist_shuffpos,[0:bw:uL])./num_tests;histstk=hist(dist_shufftk,[0:bw:uL])./num_tests;
    if plot_on
        figure(h1); subplot(r,c,plotcount);plot([0:bw:uL],hista,'k','linewidth',2); hold on; plot([0:bw:uL],hists,'r','linewidth',2); hold on; plot([0:bw:uL],histstk,'color',[.85 .5 0 ],'linewidth',2);  set(gca,'FontSize',16);plotcount=plotcount+1;
        xlabel('Prediction error (mm)');ylabel('count');
    end
    [h,p] = kstest2([dist_aligned,dist_shuffpos]);
    p_all(1,1,3) = p;
    temp = min([hista;hists]);
    pOL_all(1,1,3) = sum(temp);
    if plot_on
        tb = text(2,.175, ['p = ' num2str(sum(temp))],'FontSize',12);set(tb,'color','r');
    end
    [h,p] = kstest2([dist_aligned,dist_shufftk]);
    p_all(1,2,3) = p;
    temp = min([hista;histstk]);
    pOL_all(1,2,3) = sum(temp);
    if plot_on
        tb = text(2,.15, ['p = ' num2str(sum(temp))],'FontSize',12);set(tb,'color',[.85 .5 0 ]);
    end
    chista = cumsum(hista);chists = cumsum(hists);chisttk = cumsum(histstk);
    if plot_on
        figure(h1); subplot(r,c,plotcount);plot([0:bw:uL],chista,'k','linewidth',2); hold on; plot([0:bw:uL],chists,'r','linewidth',2);plot([0:bw:uL],chisttk,'color',[.85 .5 0 ],'linewidth',2);  set(gca,'FontSize',16);axis([0 uL 0 1]);
        xlabel('Prediction error (mm)');ylabel('C.Pr');
    end
    dist_all(:,1,3) = dist_aligned;
    dist_all(:,2,3) = dist_shuffpos;
    dist_all(:,3,3) = dist_shufftk;
    hist_all(:,1,3) = hista;
    hist_all(:,2,3) = hists;
    hist_all(:,3,3) = histstk;
    chist_all(:,1,3) = chista;
    chist_all(:,2,3) = chists;
    chist_all(:,3,3) = chisttk;
    
    mEr_all(1,1,3) = prctile(dist_aligned,50);
    mEr_all(1,2,3) = prctile(dist_shuffpos,50);
    mEr_all(1,2,3) = prctile(dist_shufftk,50);
    % [h,p] = kstest([dist_aligned,dist_shuffpos]);
    % p_all(1,1,3) = p;
    % temp = min([hista;hists]);
    % pOL_all(1,1,3) = sum(temp);
    %
    % [h,p] = kstest([dist_aligned,dist_shufftk]);
    % p_all(1,2,3) = p;
    % temp = min([hista;histstk]);
    % pOL_all(1,2,3) = sum(temp);
    if plot_on
        tb = text(2,.6, num2str(mEr_all(1,1,3)),'FontSize',12);set(tb,'color','k');
        tb = text(2,.8, num2str(mEr_all(1,2,3)),'FontSize',12);set(tb,'color','r');
    end
    
end
