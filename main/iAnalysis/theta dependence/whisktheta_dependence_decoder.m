function [pooled_contactCaTrials_locdep] = whisktheta_dependence_decoder(pooled_contactCaTrials_locdep,cond,str,train_test,thetabins,disc_func,src,plot_on)
p = thetabins; 
par = 'sigpeak';
num_runs = 1;
num_tests = 100;
ol = [.0005,2.5];
if strcmp(cond,'ctrl' )
    l_trials= pooled_contactCaTrials_locdep{1}.lightstim;
else
    switch src
        case 'def'
            l_trials = cell2mat(cellfun(@(x) x.lightstim, pooled_contactCaTrials_locdep,'uniformoutput',0));
            l_trials = l_trials(:,1);
    end
    
end



if strcmp(cond,'ctrl' )
    tk = cell2mat(cellfun(@(x) x.re_totaldK, pooled_contactCaTrials_locdep,'uniformoutput',0));
    th = cell2mat(cellfun(@(x) x.phase.theta_binned, pooled_contactCaTrials_locdep,'uniformoutput',0));
    
    resp = cell2mat(cellfun(@(x) x.(par), pooled_contactCaTrials_locdep,'uniformoutput',0));
%     temp_wave =abs(tk(:,1));
%     outlier_touches = find((temp_wave>ol(2))|(temp_wave<ol(1)));
%     outlier_touches=[];
%     tk(outlier_touches,:) = [];
%     pl(outlier_touches,:) = [];
%     resp(outlier_touches,:) = [];   
        
    numtrials = size(tk,1);
    pl = pl(:,1);
    [vals,plid,valsid] = unique(th);
    pos = p(valsid)';
     
        train_resp = resp; test_resp = resp;

    train_th = pl; test_th = pl;
    train_tk = tk; test_tk = tk;
    train_pos=pos;test_pos = pos;
    mdl_list = cell(num_tests,1);
    
     w = waitbar(0, 'Start ctrl LDA runs  ...');
    for n = 1:num_runs
        [dist_n,dist_err_n,hist_n,chist_n,mEr_n,fr_correct_n,pOL_n,p_n] = run_classify(train_resp,train_pos,train_tk,test_resp,test_pos,test_tk,train_test,disc_func,plot_on,src,mdl_list,num_tests);
        dist_all{n} = dist_n;
        dist_err{n} = dist_err_n;
        hist_all{n} =hist_n;
        chist_all{n} =chist_n;
        fr_correct{n}=fr_correct_n;
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
    summary.ctrl.dist_err=dist_err;
    summary.ctrl.chist = chist_all;
    summary.ctrl.mEr = mEr_all;
    summary.ctrl.fr_correct = fr_correct;
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
    summary.ctrl.mFrCor(1,1,1) = mean(cellfun(@(x) x(1,1,1), fr_correct)');
    summary.ctrl.sFrCor(1,1,1) = std(cellfun(@(x) x(1,1,1), fr_correct)');
    summary.ctrl.mFrCor(1,2,1) = mean(cellfun(@(x) x(1,2,1), fr_correct)');
    summary.ctrl.sFrCor(1,2,1) = std(cellfun(@(x) x(1,2,1), fr_correct)');
    summary.info =  [str];
    save([str ' decoder results'],'summary');
    
    
elseif strcmp(cond,'ctrl_mani')
    switch src
        case 'def'
            tk_all = cell2mat(cellfun(@(x) x.re_totaldK, pooled_contactCaTrials_locdep,'uniformoutput',0));
                th_all = cell2mat(cellfun(@(x) x.theta, pooled_contactCaTrials_locdep,'uniformoutput',0));

            resp_all = cell2mat(cellfun(@(x) x.(par), pooled_contactCaTrials_locdep,'uniformoutput',0));

    end
    
    %run ctrl
    
    tk = tk_all(l_trials == 0,:);
    th = th_all(l_trials == 0,:);
    resp = resp_all(l_trials == 0,:);
    
%     temp_wave =abs(tk(:,1));
%     outlier_touches = find((temp_wave>ol(2))|(temp_wave<ol(1)));
%     
%     tk(outlier_touches,:) = [];
%     pl(outlier_touches,:) = [];
%     resp(outlier_touches,:) = []; 
    
    numtrials = size(tk,1);
    
    th = th(:,1);
    [vals,plid,valsid] = unique(th);
    pos = p(valsid)';
    if (size(pos,2)>size(pos,1))
        pos = pos';
    end

        train_resp = resp; test_resp = resp;

    train_th = th; test_th = th;
    train_tk = tk; test_tk = tk;
    train_pos=pos;test_pos = pos;
    nin = find(isnan(train_resp));
    if ~isempty(nin)
        nin
        error('error: there are nans in train resp')
    end
    nin = find(isnan(test_resp));
    if ~isempty(nin)
        nin
        error('error: there are nans in test resp')
    end
    mdl_list = cell(num_tests,1);
    w = waitbar(0, 'Start ctrl LDA runs  ...');
    for n = 1:num_runs
        [dist_n,dist_err_n,hist_n,chist_n,mEr_n,fr_correct_n,pOL_n,p_n,numpred,mdl_list,warnings_n]=run_classify(train_resp,train_pos,train_tk,test_resp,test_pos,test_tk,1,disc_func,plot_on,src,mdl_list, num_tests);
        dist_all{n} = dist_n;
        dist_err{n} = dist_err_n;
        hist_all{n} =hist_n;
        chist_all{n} =chist_n;
        mEr_all{n} =mEr_n;
        fr_correct{n} = fr_correct_n;
        pOL_all{n} =pOL_n;
        p_all{n} =p_n;
         num_predictors{n} = numpred;
         warnings{n} = warnings_n;
        mdls{n} = mdl_list;
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
    summary.ctrl.dist_err=dist_err;
    summary.ctrl.chist = chist_all;
    summary.ctrl.mEr = mEr_all;
    summary.ctrl.fr_correct = fr_correct;
    summary.ctrl.pvalue=p_all;
    summary.ctrl.percentoverlap = pOL_all;
    summary.ctrl.mmEr(1,1,1) = mean(cellfun(@(x) x(1,1,1), mEr_all)'); % aligned
    summary.ctrl.smEr(1,1,1) = std(cellfun(@(x) x(1,1,1), mEr_all)')./sqrt(num_runs);
    summary.ctrl.mmEr(1,2,1) = mean(cellfun(@(x) x(1,2,1), mEr_all)'); % shuffled
    summary.ctrl.smEr(1,2,1) = std(cellfun(@(x) x(1,2,1), mEr_all)')./sqrt(num_runs);
    summary.ctrl.mpercentoverlap(1,1,1) = mean(cellfun(@(x) x(1,1,1), pOL_all)');
    summary.ctrl.spercentoverlap (1,1,1)= std(cellfun(@(x) x(1,1,1), pOL_all)')./sqrt(num_runs);
    summary.ctrl.mFrCor(1,1,1) = mean(cellfun(@(x) x(1,1,1), fr_correct)');
    summary.ctrl.sFrCor(1,1,1) = std(cellfun(@(x) x(1,1,1), fr_correct)')./sqrt(num_runs);
    summary.ctrl.mFrCor(1,2,1) = mean(cellfun(@(x) x(1,2,1), fr_correct)');
    summary.ctrl.sFrCor(1,2,1) = std(cellfun(@(x) x(1,2,1), fr_correct)')./sqrt(num_runs);
    summary.ctrl.num_predictors = num_predictors;
    summary.ctrl.mdl_list = mdls;
    summary.ctrl.warnings = warnings;
    %run mani
    
    tk = tk_all(l_trials == 1,:);
    th = th_all(l_trials == 1,:);
    resp = resp_all(l_trials == 1,:);
    
%     temp_wave =abs(tk(:,1));
%     outlier_touches = find((temp_wave>ol(2))|(temp_wave<ol(1)));
%     
%     tk(outlier_touches,:) = [];
%     pl(outlier_touches,:) = [];
%     resp(outlier_touches,:) = []; 
    
    numtrials = size(tk,1);
    th = th(:,1);
    [vals,plid,valsid] = unique(th);
    pos = p(valsid)';
   if (size(pos,2)>size(pos,1))
        pos = pos';
    end
    if train_test == 1

            train_resp = resp; test_resp = resp;
             mdl_list = cell(num_tests,1);
            nin = find(isnan(train_resp));
            if ~isempty(nin)
                nin
                train_resp(nin) = 0;
                %             error('error: there are nans in train resp')
            end
            nin = find(isnan(test_resp));
            if ~isempty(nin)
                nin
                test_resp(nin) = 0;
                %             error('error: there are nans in test resp')
            end
            
            
            
        train_th = th; test_th = th;
        train_tk = tk; test_tk = tk;
        train_pos=pos;test_pos = pos;
        
         w = waitbar(0, 'Start mani LDA runs  ...');
        for n = 1:num_runs
            [dist_n,dist_err_n,hist_n,chist_n,mEr_n,fr_correct_n,pOL_n,p_n,numpred,mdl_list,warnings_n]=run_classify(train_resp,train_pos,train_tk,test_resp,test_pos,test_tk,train_test,disc_func,plot_on,src,mdl_list, num_tests);
            dist_all{n} = dist_n;
            dist_err{n} = dist_err_n;
            hist_all{n} =hist_n;
            chist_all{n} =chist_n;
            mEr_all{n} =mEr_n;
            fr_correct{n} = fr_correct_n;
            pOL_all{n} =pOL_n;
            p_all{n} =p_n;
            num_predictors{n} = numpred;
            mdls{n} = mdl_list;
            warnings{n}=warnings_n;
            waitbar((n+1)/(num_runs), w,[num2str(n) '/' num2str(num_runs)]);
        end
        close (w);
        tag = 'selftrain';
        
    elseif train_test == 0
        

            test_resp = resp;
            nin = find(isnan(test_resp));
            if ~isempty(nin)
                nin
                test_resp(nin) = 0;
                %             error('error: there are nans in test resp')
            end

        test_th = th;
        test_tk = tk;
        test_pos = pos;
        
        nin = find(isnan(train_resp));
        if ~isempty(nin)
             nin
             train_resp(nin) = 0;
%             error('error: there are nans in train resp')
        end
        nin = find(isnan(test_resp));
        if ~isempty(nin)
            nin
            test_resp(nin) = 0;
%             error('error: there are nans in test resp')
        end
         w = waitbar(0, 'Start mani LDA runs  ...');
        for n = 1:num_runs
            [dist_n,dist_err_n,hist_n,chist_n,mEr_n,fr_correct_n,pOL_n,p_n,numpred,mdl_list,warnings] =run_classify(train_resp,train_pos,train_tk,test_resp,test_pos,test_tk,train_test,disc_func,plot_on,src,mdl_list, num_tests);
            dist_all{n} = dist_n;
            dist_err{n} = dist_err_n;
            hist_all{n} =hist_n;
            chist_all{n} =chist_n;
            mEr_all{n} =mEr_n;
            fr_correct{n} = fr_correct_n;
            pOL_all{n} =pOL_n;
            p_all{n} =p_n;
            num_predictors{n} = numpred;
            mdls{n} = mdl_list;
            warnings{n}=warnings_n;
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
    summary.mani.dist_err=dist_err;
    summary.mani.chist = chist_all;
    summary.mani.mEr = mEr_all;
    summary.mani.fr_correct = fr_correct;
    summary.mani.pvalue=p_all;
    summary.mani.percentoverlap = pOL_all;
    summary.mani.mmEr(1,1,1) = mean(cellfun(@(x) x(1,1,1), mEr_all)'); % aligned
    summary.mani.smEr(1,1,1) = std(cellfun(@(x) x(1,1,1), mEr_all)')./sqrt(num_runs);
    summary.mani.mmEr(1,2,1) = mean(cellfun(@(x) x(1,2,1), mEr_all)'); % shuffled
    summary.mani.smEr(1,2,1) = std(cellfun(@(x) x(1,2,1), mEr_all)')./sqrt(num_runs);
    summary.mani.mpercentoverlap(1,1,1) = mean(cellfun(@(x) x(1,1,1), pOL_all)');
    summary.mani.spercentoverlap (1,1,1)= std(cellfun(@(x) x(1,1,1), pOL_all)')./sqrt(num_runs);
    summary.mani.mFrCor(1,1,1) = mean(cellfun(@(x) x(1,1,1), fr_correct)');
    summary.mani.sFrCor(1,1,1) = std(cellfun(@(x) x(1,1,1), fr_correct)')./sqrt(num_runs);
    summary.mani.mFrCor(1,2,1) = mean(cellfun(@(x) x(1,2,1), fr_correct)');
    summary.mani.sFrCor(1,2,1) = std(cellfun(@(x) x(1,2,1), fr_correct)')./sqrt(num_runs);
    summary.mani.num_predictors = num_predictors;
    summary.mani.mdl_list = mdls;
    summary.mani.warnings = warnings;
    summary.info =  [str ' ' tag];
    save([str ' ' disc_func ' '  tag ' decoder results'],'summary');
    
end

function [dist_all,dist_err,hist_all,chist_all,mEr_all,fr_correct,pOL_all,p_all,numpred,mdl_list,warnings] = run_classify(train_resp,train_pos,train_tk,test_resp,test_pos,test_tk,tt,disc_func,plot_on,src,mdl_list, num_tests)


% num_tests = 1000;
dist_aligned = zeros(num_tests,1);
dist_shuff = zeros(num_tests,1);
dist=zeros(num_tests,1);
dist_all = zeros(num_tests,3,3);
plotjustcasig =1;

if plotjustcasig
    r= 1;
    c=4;
else
    r=3;
    c=4;
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
warnings= cell(num_tests,1);
%% predicting locations from CaSig alone
parfor s = 1:num_tests
    ['--test run aligned--' num2str(s)]
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
    if tt
        %     class = classify(S,Y,train_pos(train),disc_func);
        Mdl = fitcdiscr(Y,train_pos(train),'DiscrimType',disc_func);
        va = size(S,2);
        %regularization
         wm = warning('off','all'); 
        [err,gamma,delta,numpred] = cvshrink(Mdl,'NumGamma',30,'NumDelta',30,'Verbose',0);
        
        [msglast, msgidlast] = lastwarn;
        if strcmp(msgidlast,'stats:cvpartition:KFoldMissingGrp')
            warnings{s}=1;
        else
            warnings{s}=0;
        end
        wm = warning('off','all'); % turn display of all warnings off
        warning('FineId','fine') % becomes the last warning
        warning(wm) % turn display of all warnings on
        wm = warning('on','all')
        %     figure; plot(err,numpred,'k.');xlabel('Error rate');ylabel('Number of predictors');
        ids = find(numpred <.1 * max(max(numpred))); %% ensures at least 10% of predictors
        numpred(ids)=nan;delta(ids) = nan; err(ids) = nan;
        minerr = min(min(err));
%         [p q] = find(err < minerr + .025); % 1e-4 Subscripts of err producing minimal error
        [p q]= find(err<= prctile(reshape(err,size(err,1)*size(err,2),1),5));
        
        numel(p);
        idx = sub2ind(size(delta),p,q); % Convert from subscripts to linear indices
        ideal_numpred=round(median(numpred(idx)));
        [va,tempid] = min(abs(numpred(idx) - ideal_numpred));
        if ( length(tempid)>1)
            tempid = tempid(1);
        end
        va = numpred(idx(tempid)) ;
%         [va,tempid] = min(numpred(idx));
        [gamma(p) delta(idx)];
        Mdl.Gamma = gamma(p(tempid));
        Mdl.Delta = delta(idx(tempid));
        
    else
        Mdl = mdl_list{s};
        warnings{s}=0;
    end
    label = predict(Mdl,S);
    class = label;
    
    actual = test_pos(test,1);
    dist = sqrt((actual - class).^2);
    dist_aligned (s,1,1) = sum(dist)./testsetsize;
    dist_aligned_err{s} =  (actual-class);
    if tt
        dist_aligned_numpred {s} = va;
    else
        dist_aligned_numpred {s} = size(S,2);
    end
    
    mdl_list{s} = Mdl;
    %      figure(dummy); plot(actual); hold on; plot(class,'r');hold off;
end
% dummy = figure;
if plot_on
    sc = get(0,'ScreenSize');
    h1=figure('position', [1000, sc(4), sc(3)/1.5, sc(4)/4], 'color','w');
end
%% shuffled control for CaSig alone
for s = 1:num_tests
        ['--test run shuff --' num2str(s)]
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
    all_pos = unique(train_pos);
    all_pos_ind = 1:length(all_pos);
    shuff_pos_train = round(min(all_pos_ind) + (max(all_pos_ind)-min(all_pos_ind)).*rand(length(shuff1),1));
    shuff_pos_test = round(min(all_pos_ind) + (max(all_pos_ind)-min(all_pos_ind)).*rand(length(test),1));
   shuff_pos_test2 = round(min(all_pos_ind) + (max(all_pos_ind)-min(all_pos_ind)).*rand(length(test),1));

    shuff_pos_train = all_pos(shuff_pos_train);
    shuff_pos_test = all_pos(shuff_pos_test);
% % %     class = classify(S,Y,train_pos(train(shuff2),1),disc_func);
% % %     actual = test_pos(test,1);
%     class = classify(S,Y,shuff_pos_train,disc_func);
    Mdl = fitcdiscr(Y,shuff_pos_train,'DiscrimType',disc_func);
     %regularization
%      [err,gamma,delta,numpred] = cvshrink(Mdl,'NumGamma',24,'NumDelta',24,'Verbose',1);
%     figure; plot(err,numpred,'k.');xlabel('Error rate');ylabel('Number of predictors');
%     minerr = min(min(err))
%     [p q] = find(err < minerr + 1e-4); % Subscripts of err producing minimal error
%     numel(p)
%     idx = sub2ind(size(delta),p,q); % Convert from subscripts to linear indices
%     [gamma(p) delta(idx)]
%     Mdl.Gamma = gamma(p);
%     Mdl.Delta = delta(idx);
    label = predict(Mdl,S);
    class = label;
    
    class = shuff_pos_test;
    actual =all_pos(shuff_pos_test2);
    dist = sqrt((actual - class).^2);
    dist_shuff (s ,1) = sum(dist)./testsetsize;
    dist_shuff_err{s} = (actual-class);
    % figure(dummy);plot(actual); hold on; plot(class,'r');hold off;
end
if plot_on
    plotcount =1;
    figure(h1); subplot(r,c,plotcount); plot(dist_shuff,'r','linewidth',2); hold on; axis([0 num_tests 0 uL]);
    figure(h1); subplot(r,c,plotcount);plot(dist_aligned,'k','linewidth',2); hold on;  title('Phase from Ca signal alone'); set(gca,'FontSize',16);plotcount=plotcount+1;
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
numpred(:,1) = dist_aligned_numpred;

mEr_all(1,1,1) = prctile(dist_aligned,50);
mEr_all(1,2,1) = prctile(dist_shuff,50);
if plot_on
    tb = text(2,.6, num2str(mEr_all(1,1,1)),'FontSize',12);set(tb,'color','k');
    tb = text(2,.8, num2str(mEr_all(1,2,1)),'FontSize',12);set(tb,'color','r');
end


    numtotal(1,1) = length(dist_err(:,1,1));numtotal(1,2) = length(dist_err(:,2,1));
    tw = abs(dist_err(find(dist_err(:,1,1)~=0),1,1));
    binw = min(tw);binm=max(dist_err(:,2,1))+1;
%     histal = hist(dist_err(:,1,1),[-binm:binw:binm])./numtotal(1,1);
%     histsh=hist(dist_err(:,2,1),[-binm:binw:binm])./numtotal(1,2)
    histal = hist(dist_err(:,1,1),unique(dist_err))./numtotal(1,1);
    histsh=hist(dist_err(:,2,1),unique(dist_err))./numtotal(1,2)
if plot_on
    figure(h1); subplot(r,c,plotcount);plot(unique(dist_err),histal,'k','linewidth',2); hold on; plot(unique(dist_err),histsh,'r','linewidth',2); set(gca,'FontSize',16); axis([-binm binm 0 1]);plotcount=plotcount+1;
    xlabel('Prediction error (mm)');ylabel('C.Pr');
end
% binnew = [-binm:binw:binm];
binnew = unique(dist_err);
zerobin = find(binnew ==0);
fr_correct(1,1,1) = histal(zerobin);
fr_correct(1,2,1) = histsh(zerobin);


% pdt=hista.*hists;
% temp = (hista+hists).*(pdt>1);
if plot_on
    tb = text(2,.6, num2str(fr_correct(1,1,1)),'FontSize',12);set(tb,'color','k');
    tb = text(2,.8, num2str(fr_correct(1,2,1)),'FontSize',12);set(tb,'color','r');
end
if ~plotjustcasig
 
end
