function [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder_manova1(pooled_contactCaTrials_locdep,par,cond,str,train_test,pos,disc_func,src,plot_on)
%[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,cond,str,train_test,pos)
% cond 'ctrl' or 'ctrl_mani'
% pos pole positions
% train_test =1 if mani is to be trained with mani trials, =0 if it is to
% be trained with ctrl trials
% disc_func 'linear' or 'diagquadratic'
p = pos; %[15 13.5 12 10.5 9 7.5];
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
    pl = cell2mat(cellfun(@(x) x.poleloc, pooled_contactCaTrials_locdep,'uniformoutput',0));
    resp = cell2mat(cellfun(@(x) x.(par), pooled_contactCaTrials_locdep,'uniformoutput',0));
    numtrials = size(resp,1);
    pl = pl(:,1);
    [vals,plid,valsid] = unique(pl);
    pos = p(valsid)';
    
    train_resp = resp; test_resp = resp;
    train_pos=pos;test_pos = pos;
    tt =1;
    [dist_aligned,dist_shuff,hista,hists,p_val,dist_aligned2,dist_shuff2,hista2,hists2,p_val2] = run_manova1(train_resp,train_pos,test_resp,test_pos,tt,plot_on,src);
    dist_all{1} = dist_aligned;dist_all{2} = dist_shuff;
    hist_all{1} = hista; hist_all{2} =hists;
    means_all{1} = mean(dist_aligned)';means_all{2} = mean(dist_shuff)';
    p_all{1} =p_val;
    
    dist_all2{1} = dist_aligned2;dist_all2{2} = dist_shuff2;
    hist_all2{1} = hista2; hist_all2{2} =hists2;
    means_all2{1} = mean(dist_aligned2)';means_all2{2} = mean(dist_shuff2)';
    p_all2{1} =p_val2;
    
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
    summary.ctrl.pvalue=p_all;
    summary.ctrl.meanFrCo=means_all;
    summary.info =  [str];
    save([str ' decoder results'],'summary');
    
    
elseif strcmp(cond,'ctrl_mani')
    switch src
        case 'def'
            pl_all = cell2mat(cellfun(@(x) x.poleloc, pooled_contactCaTrials_locdep,'uniformoutput',0));
            resp_all = cell2mat(cellfun(@(x) x.(par), pooled_contactCaTrials_locdep,'uniformoutput',0));
        case 'LAD'
            pl_all = cell2mat(cellfun(@(x) x.decoder.LAD.poleloc, pooled_contactCaTrials_locdep,'uniformoutput',0));
            resp_all = cell2mat(cellfun(@(x) x.decoder.LAD.(par), pooled_contactCaTrials_locdep,'uniformoutput',0));
        case 'NLS'
            pl_all = cell2mat(cellfun(@(x) x.decoder.NLS.poleloc, pooled_contactCaTrials_locdep,'uniformoutput',0));
            resp_all = cell2mat(cellfun(@(x) x.decoder.NLS.(par), pooled_contactCaTrials_locdep,'uniformoutput',0));
        case 'NC'
            pl_all = cell2mat(cellfun(@(x) x.decoder.NC.poleloc, pooled_contactCaTrials_locdep,'uniformoutput',0));
            resp_all = cell2mat(cellfun(@(x) x.decoder.NC.(par), pooled_contactCaTrials_locdep,'uniformoutput',0));
        otherwise
            pl_all = cell2mat(cellfun(@(x) x.poleloc, pooled_contactCaTrials_locdep,'uniformoutput',0));
            resp_all = cell2mat(cellfun(@(x) x.(par), pooled_contactCaTrials_locdep,'uniformoutput',0));
    end
    
    %run ctrl
    pl = pl_all(l_trials == 0,:);
    resp = resp_all(l_trials == 0,:);
    numtrials = size(resp,1);
    
    pl = pl(:,1);
    [vals,plid,valsid] = unique(pl);
    pos = p(valsid)';
    
    train_resp = resp; test_resp = resp;
    train_pos=pos;test_pos = pos;
    tt=1;
    [dist_aligned,dist_shuff,hista,hists,p_val,dist_aligned2,dist_shuff2,hista2,hists2,p_val2]= run_manova1(train_resp,train_pos,test_resp,test_pos,tt,plot_on,src);
    dist_all{1} = dist_aligned;dist_all{2} = dist_shuff;
    hist_all{1} = hista; hist_all{2} =hists;
    means_all{1} = mean(dist_aligned)';means_all{2} = mean(dist_shuff)';
    p_all{1} =p_val;
    
    dist_all2{1} = dist_aligned2;dist_all2{2} = dist_shuff2;
    hist_all2{1} = hista2; hist_all2{2} =hists2;
    means_all2{1} = mean(dist_aligned2)';means_all2{2} = mean(dist_shuff2)';
    p_all2{1} =p_val2;
    
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
    summary.ctrl.pvalue=p_all;
    summary.ctrl.meanFrCo=means_all;
    
    %run mani
    
    pl = pl_all(l_trials == 1,:);
    resp = resp_all(l_trials == 1,:);
    numtrials = size(resp,1);
    pl = pl(:,1);
    [vals,plid,valsid] = unique(pl);
    pos = p(valsid)';
    
    if train_test == 1
        
        train_resp = resp; test_resp = resp;
        train_pos=pos;test_pos = pos;
        tt =1;
        [dist_aligned,dist_shuff,hista,hists,p_val,dist_aligned2,dist_shuff2,hista2,hists2,p_val2] = run_manova1(train_resp,train_pos,test_resp,test_pos,tt,plot_on,src);
        dist_all{1} = dist_aligned;dist_all{2} = dist_shuff;
        hist_all{1} = hista; hist_all{2} =hists;
        means_all{1} = mean(dist_aligned)';means_all{2} = mean(dist_shuff)';
        p_all{1} =p_val;
        
        tag = 'selftrain';
        
    elseif train_test == 0
        
        test_resp = resp;
        test_pos = pos;
        tt=0;
        [dist_aligned,dist_shuff,hista,hists,p_val,dist_aligned2,dist_shuff2,hista2,hists2,p_val2] = run_manova1(train_resp,train_pos,test_resp,test_pos,tt,plot_on,src);
        dist_all{1} = dist_aligned;dist_all{2} = dist_shuff;
        hist_all{1} = hista; hist_all{2} =hists;
        means_all{1} = mean(dist_aligned)';means_all{2} = mean(dist_shuff)';
        p_all{1} =p_val;
        
        dist_all2{1} = dist_aligned2;dist_all2{2} = dist_shuff2;
        hist_all2{1} = hista2; hist_all2{2} =hists2;
        means_all2{1} = mean(dist_aligned2)';means_all2{2} = mean(dist_shuff2)';
        p_all2{1} =p_val2;
        
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
    summary.mani.pvalue=p_all;
    summary.mani.meanFrCo=means_all;
    summary.info =  [str ' ' tag];
    save([str ' ' disc_func ' '  tag ' manova1 results'],'summary');
    
end

function [dist_aligned,dist_shuff,hista,hists,p_val,dist_aligned2,dist_shuff2,hista2,hists2,p_val2] = run_manova1(train_resp,train_pos,test_resp,test_pos,tt,plot_on,src)

num_tests = 5000;
dist_aligned = zeros(num_tests,1);
dist_shuff = zeros(num_tests,1);
dist_aligned2 = zeros(num_tests,1);
dist_shuff2 = zeros(num_tests,1);
dist=zeros(num_tests,1);


r= 1;
c=2;

uL = 1.0;
bw=0.05;
bins = [ 0:bw:uL];
numbins = size(bins,2);

%% predicting locations from CaSig alone
p = unique(train_pos);
for cp = 1:length(p)
    current_pos = p(cp);
    testsetfr = 0.25;
    
    for s = 1:num_tests
        cptrials = find(train_pos == current_pos); %
        optrials  = find(train_pos ~= current_pos);
        temp_cp_setsize = round(testsetfr*length(cptrials));
        r_cp = randperm(length(cptrials));
        cp_train =  train_resp(cptrials(r_cp(temp_cp_setsize+1:end),1),:);
        temp_op_setsize = round(testsetfr*length(optrials));
        r_op = randperm(length(optrials));
        op_train =  train_resp(optrials(r_op(temp_op_setsize+1:end),1),:);
        Train = [cp_train;op_train];
        groupVar = [ones(size(cp_train,1),1); ones(size(op_train,1),1)*2];
        
        if tt
            cp_test =  test_resp(cptrials(r_cp(1:temp_cp_setsize),1),:);
            op_test =  test_resp(optrials(r_op(1:temp_op_setsize),1),:);
        else
            cptrials = find(test_pos == current_pos); %
            optrials  = find(test_pos ~= current_pos);
            temp_cp_setsize = round(testsetfr*length(cptrials));
            r_cp = randperm(length(cptrials));
            cp_test = test_resp(cptrials(r_cp(1:temp_cp_setsize),1),:);
            temp_op_setsize = round(testsetfr*length(optrials));
            r_op = randperm(length(optrials));
            op_test = test_resp(optrials(r_op(1:temp_op_setsize),1),:);
            
        end
        Test= [cp_test;op_test];
        actual = [ones(size(cp_test,1),1); ones(size(op_test,1),1)*2];
        
        % data aligned
        [d,pv,stats] = manova1(Train,groupVar);
        w_1 = stats.eigenvec(:,1); w_2 = eig(stats.B);
        
        means = [mean(w_1'*cp_train'), mean(w_1'*op_train')];
        means2 = [mean(w_2'*cp_train'), mean(w_2'*op_train')];
        crit =  means(1) - (means(1)-means(2))/2;
        crit2 =  means2(1) - (means2(1)-means2(2))/2;
        projw_1 = (w_1' *  Test')';
        projw_2 = (w_2' *  Test')';
        [y,prediction] = min(abs(repmat(projw_1,1,2)-repmat(means,length(projw_1),1)),[],2);
        [y2,prediction2] = min(abs(repmat(projw_2,1,2)-repmat(means,length(projw_2),1)),[],2);
        percent_correct = sum(actual == prediction)./size(actual,1) ;
        percent_correct2 = sum(actual == prediction2)./size(actual,1) ;
        dist_aligned (s,cp,1) = percent_correct;
        dist_aligned2 (s,cp,1) = percent_correct2;
        
        % data shuffled
        shuff1 = randperm(size(Train,1),size(Train,1))';shuff2 = randperm(size(Train,1),size(Train,1))';
        x_shuff = Train(shuff1,:); groupVar_shuff = groupVar(shuff2,:);
        [d,pv,stats] = manova1(x_shuff,groupVar_shuff);
        w_1shuff = stats.eigenvec(:,1);w_2shuff = eig(stats.B);
        means = [mean(w_1shuff'*cp_train'), mean(w_1shuff'*op_train')];
        means2 = [mean(w_2'*cp_train'), mean(w_2'*op_train')];
        crit =  means(1) - (means(1)-means(2))/2;
        crit2 = means2(1) - (means2(1)-means2(2))/2;
        shuff3 = randperm(size(Test,1),size(Test,1))';
        projw_1shuff = (w_1shuff' *  Test(shuff3,:)')';
        projw_2shuff = (w_2shuff' *  Test(shuff3,:)')';
        [y, prediction] = min(abs(repmat(projw_1shuff,1,2)-repmat(means,length(projw_1shuff),1)),[],2);
        [y2, prediction2] = min(abs(repmat(projw_2shuff,1,2)-repmat(means,length(projw_2shuff),1)),[],2);
        percent_correct_shuff = sum(actual == prediction)./size(actual,1) ;
        percent_correct_shuff2 = sum(actual == prediction2)./size(actual,1) ;
        dist_shuff (s,cp,1) = percent_correct_shuff;
        dist_shuff2 (s,cp,1) = percent_correct_shuff2;
    end
    
end

%first plot from eigvect
if plot_on
    sc = get(0,'ScreenSize');
    h1=figure('position', [1000, sc(4), sc(3)/1.5, sc(4)/4], 'color','w');
    
    plotcount =1;
    figure(h1); subplot(r,c,plotcount); plot(dist_shuff,'r','linewidth',1); hold on; axis([0 num_tests 0 uL]);
    figure(h1); subplot(r,c,plotcount); plot(dist_aligned,'k','linewidth',1); hold on;  title('Position from Ca signal alone'); set(gca,'FontSize',16);plotcount=plotcount+1;
    xlabel('run #');ylabel('Percent Correct ');
end

hista=hist(dist_aligned,[0:bw:uL])./num_tests;hists=hist(dist_shuff,[0:bw:uL])./num_tests;
if plot_on
    figure(h1); subplot(r,c,plotcount);plot([0:bw:uL],hista,'k','linewidth',2); hold on; plot([0:bw:uL],hists,'r','linewidth',2);  set(gca,'FontSize',16);plotcount=plotcount+1;
    xlabel('Avg Percent Correct ');ylabel('Pr');
end

for cp = 1:length(p)
    [h,pval] = ttest2(dist_aligned(:,cp),dist_shuff(:,cp));
    p_val(cp,1,1) = pval;
    temp = mean([hista(:,cp);hists(:,cp)]);
    
    if plot_on
        tb = text(cp*.1,cp*.125, ['p = ' num2str(pval)],'FontSize',12);set(tb,'color','k');
    end
    
end

% %now plot from eigval of B
% if plot_on
%     
%     figure(h1); subplot(r,c,plotcount); plot(dist_shuff2,'r','linewidth',1); hold on; axis([0 num_tests 0 uL]);
%     figure(h1); subplot(r,c,plotcount); plot(dist_aligned2,'k','linewidth',1); hold on;  title('Position from Ca signal alone'); set(gca,'FontSize',16);plotcount=plotcount+1;
%     xlabel('run #');ylabel('Percent Correct ');
% end
% 
hista2=hist(dist_aligned2,[0:bw:uL])./num_tests;hists2=hist(dist_shuff2,[0:bw:uL])./num_tests;
% if plot_on
%     figure(h1); subplot(r,c,plotcount);plot([0:bw:uL],hista2,'k','linewidth',2); hold on; plot([0:bw:uL],hists2,'r','linewidth',2);  set(gca,'FontSize',16);plotcount=plotcount+1;
%     xlabel('Avg Percent Correct ');ylabel('Pr');
% end
% 
for cp = 1:length(p)
    [h2,pval2] = ttest2(dist_aligned2(:,cp),dist_shuff2(:,cp));
    p_val2(cp,1,1) = pval2;
    temp = mean([hista2(:,cp);hists2(:,cp)]);
    
%     if plot_on
%         tb = text(cp*.1,cp*.125, ['p = ' num2str(pval)],'FontSize',12);set(tb,'color','k');
%     end
    
end
'end'
