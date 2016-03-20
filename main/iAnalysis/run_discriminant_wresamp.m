function [mdl,results,accuracy,testarray] = run_discriminant_wresamp(pcopy_array,par,reg)
numruns = size(pcopy_array,2);
numtests = numruns -1;
for run = 1:numruns
    ['run' num2str(run)]
    pcopy = pcopy_array{run};
    ca = cell2mat(cellfun(@(x) x.sigpeak,pcopy,'uni',0));
    if strcmp(par,'phase')
     ph=pcopy{1}.phase;
    elseif strcmp(par,'theta') 
    ph=pcopy{1}.theta;
    end
    ls=pcopy{1}.lightstim;
    
    ca_nl(:,:) = ca(find(ls==0),:); 
    ca_l(:,:) = ca(find(ls==1),:);     
    ph_nl(:,1) = ph(find(ls==0));
    ph_l(:,1) = ph(find(ls==1));
    
    
    Mdldiag = fitcdiscr(ca_nl,ph_nl,'DiscrimType','diaglinear','Prior','uniform');
    if reg
    [err,gamma,delta,numpred] = cvshrink(Mdldiag,'Gamma',1,'NumDelta',100,'Verbose',0);
    %figure; plot(err,numpred,'k.');xlabel('Error rate');ylabel('Number of predictors');
    ids = find(numpred <.1 * max(max(numpred)));
    numpred(ids)=nan;delta(ids) = nan; err(ids) = nan;
     minerr = min(min(err));
     [p q]= find(err <= prctile(reshape(err,size(err,1)*size(err,2),1),5));
    idx = sub2ind(size(delta),p,q); % Convert from subscripts to linear indices
    ideal_numpred=round(median(numpred(idx)));
    [va,tempid] = min(abs(numpred(idx) - ideal_numpred));
    va = numpred(idx(tempid));
    
    if length(tempid)>1
           tempid = tempid(1)
    end
    Mdldiag.Delta = delta(idx(tempid));
    end
    mdl{run} = Mdldiag;
    
    
    test_array = setxor([1:numruns], run);
    numtests = size(test_array,2);
  
    % selecting the same number of trials of each cond for test
    p=unique(ph_l);
    for n=1:length(p)
        c(n) = length(find(ph_l ==p(n)));
        inds{n} = find(ph_l ==p(n));
    end
    l_limit = min(c);
    temp_test_set = zeros(l_limit,length(p));
    for n=1:length(p)
    temp = randperm(c(n),l_limit);
    temp_test_set(:,n) = inds{n}(temp);
    end    
    test_set=reshape(temp_test_set,l_limit*length(p),1);
    
    [labeldiag,scoresdiag] = predict(Mdldiag,ca_l(test_set,:));
    errors = (labeldiag - ph_l(test_set));
    labels_l{numtests+1}.sorted = [labeldiag,ph_l(test_set),scoresdiag,errors];
    accuracy_l{numtests+1}.sorted = sum(labeldiag==ph_l(test_set))./length(labeldiag);
    
    % shuffled
    shuff = randperm(size(test_set,1),size(test_set,1));
    shuff2= randperm(size(test_set,1),size(test_set,1));
    [labeldiag,scoresdiag] = predict(Mdldiag,ca_l(test_set(shuff),:));
    errors = (labeldiag - ph_l(test_set(shuff2)));
    labels_l{numtests+1}.shuff = [labeldiag,ph_l(test_set(shuff2)),scoresdiag,errors];
    accuracy_l{numtests+1}.shuff = sum(labeldiag==ph_l(test_set(shuff2)))./length(labeldiag);    
    
    c=[];ind={};temp_test_set=[];test_set=[];
    
    for test = 1:numtests
        pcopy = pcopy_array{test_array(test)};
        ca = cell2mat(cellfun(@(x) x.sigpeak,pcopy,'uni',0));
        if strcmp(par,'phase')
            ph=pcopy{1}.phase;
        elseif strcmp(par,'theta')
            ph=pcopy{1}.theta;
        end
        ls=pcopy{1}.lightstim;

        ca_nl(:,:) = ca(find(ls==0),:); 
        ca_l(:,:) = ca(find(ls==1),:);     
        ph_nl(:,1) = ph(find(ls==0));
        ph_l(:,1) = ph(find(ls==1));
        
        % selecting the same number of trials of each cond for test
        p=unique(ph_nl);
        for n=1:length(p)
            c(n) = length(find(ph_nl ==p(n)));
            inds{n} = find(ph_nl ==p(n));
        end
        l_limit = min(c);
        temp_test_set = zeros(l_limit,length(p));
        for n=1:length(p)
            temp = randperm(c(n),l_limit);
            temp_test_set(:,n) = inds{n}(temp);
        end
        test_set=reshape(temp_test_set,l_limit*length(p),1);

        [labeldiag,scoresdiag] = predict(Mdldiag,ca_nl(test_set,:));
        errors = (labeldiag - ph_nl(test_set));
        results_nl{test}.sorted = [labeldiag,ph_nl(test_set),scoresdiag,errors];
        accuracy_nl{test}.sorted = sum(labeldiag==ph_nl(test_set))./length(labeldiag);
 
        % shuffled
        shuff = randperm(size((test_set),1),size((test_set),1));
        shuff2= randperm(size((test_set),1),size((test_set),1));
        [labeldiag,scoresdiag] = predict(Mdldiag,ca_nl(test_set(shuff),:));
        errors = (labeldiag - ph_nl(test_set(shuff2)));
        results_nl{test}.shuff = [labeldiag,ph_nl(test_set(shuff2)),scoresdiag,errors];
        accuracy_nl{test}.shuff = sum(labeldiag==ph_nl(test_set(shuff2)))./length(labeldiag);
        
         c=[];ind={};temp_test_set=[];test_set=[];
        
        % selecting the same number of trials of each cond for test
        p=unique(ph_l);
        for n=1:length(p)
            c(n) = length(find(ph_l ==p(n)));
            inds{n} = find(ph_l ==p(n));
        end
        l_limit = min(c);
        temp_test_set = zeros(l_limit,length(p));
        for n=1:length(p)
            temp = randperm(c(n),l_limit);
            temp_test_set(:,n) = inds{n}(temp);
        end
        test_set=reshape(temp_test_set,l_limit*length(p),1);
        
        [labeldiag,scoresdiag] = predict(Mdldiag,ca_l(test_set,:));
        errors = (labeldiag - ph_l(test_set));
        results_l{test}.sorted = [labeldiag,ph_l(test_set),scoresdiag,errors];
        accuracy_l{test}.sorted = sum(labeldiag==ph_l(test_set))./length(labeldiag);
        

        % shuffled
        shuff = randperm(size(test_set,1),size(test_set,1));
        shuff2= randperm(size(test_set,1),size(test_set,1));
        [labeldiag,scoresdiag] = predict(Mdldiag,ca_l(test_set(shuff),:));
        errors = (labeldiag - ph_l(test_set(shuff2)));
        results_l{test}.shuff = [labeldiag,ph_l(test_set(shuff2)),scoresdiag,errors];
        accuracy_l{test}.shuff = sum(labeldiag==ph_l(test_set(shuff2)))./length(labeldiag);   
        
         c=[];ind={};temp_test_set=[];test_set=[];
        clear ca_nl ca_l
    end
  testarray{run} = test_array;  
  results{run}.nl = results_nl;  
  results{run}.l = results_l;
  
  accuracy{run}.nl = accuracy_nl;  
  accuracy{run}.l = accuracy_l;
  
end


%%
% minlist_noresamp = floor(minlist./2);
% minlist = minlist_noresamp;
% for i = 1:size(pooled_contactCaTrials_locdep,2)
%     ind_all = []; count =0;
%     for p = 1:size(minlist,1)
%     lind = find(pooled_contactCaTrials_locdep{i}.loc == p & pooled_contactCaTrials_locdep{i}.lightstim == 1);
%     sel_lind= randperm(length(lind),minlist(p,1));
%     remain = setxor([1:length(lind)],sel_lind);
%     test_lind = remain(randperm(length(remain),minlist(p,1)));
%     nlind = find(pooled_contactCaTrials_locdep{i}.loc == p & pooled_contactCaTrials_locdep{i}.lightstim == 0);
%     sel_nlind= randperm(length(nlind),minlist(p,2));   
%     remain = setxor([1:length(nlind)],sel_nlind);
%     test_nlind = remain(randperm(length(remain),minlist(p,2)));
%     temp = [lind(sel_lind);nlind(sel_nlind)];
%     test_temp = [lind(test_lind);nlind(test_nlind)];
%     num = length(temp);
%     ind_all(count+1:count+num) = temp;
%     ind_all_test(count+1:count+num) = test_temp;
%     count = count+num;
%     end    
%     pcopy{i}.sigpeak = pooled_contactCaTrials_locdep{i}.sigpeak(ind_all');
%     pcopy{i}.lightstim = pooled_contactCaTrials_locdep{i}.lightstim(ind_all');
%     pcopy{i}.phase = pooled_contactCaTrials_locdep{i}.phase(ind_all');
% %       pcopy{i}.theta = pooled_contactCaTrials_locdep{i}.theta(ind_all');
%             pcopy{i}.theta = pooled_contactCaTrials_locdep{i}.theta_binned_new(ind_all');
% 
%      pcopy{i}.loc = pooled_contactCaTrials_locdep{i}.loc(ind_all'); 
% %       pcopy{i}.poleloc = pooled_contactCaTrials_locdep{i}.poleloc(ind_all'); 
%     pcopy{i}.re_totaldK = pooled_contactCaTrials_locdep{i}.re_totaldK(ind_all');
%     pcopy{i}.mousename = pooled_contactCaTrials_locdep{i}.mousename;
%      pcopy{i}.sessionname = pooled_contactCaTrials_locdep{i}.sessionname;
%       pcopy{i}.reg_fov = pooled_contactCaTrials_locdep{i}.reg_fov;
%      pcopy{i}.dend = pooled_contactCaTrials_locdep{i}.dend;   
%          pcopy{i}.CellID = pooled_contactCaTrials_locdep{i}.CellID;   
%          
%              pcopy_test{i}.sigpeak = pooled_contactCaTrials_locdep{i}.sigpeak(ind_all_test');
%     pcopy_test{i}.lightstim = pooled_contactCaTrials_locdep{i}.lightstim(ind_all_test');
%     pcopy_test{i}.phase = pooled_contactCaTrials_locdep{i}.phase(ind_all_test');
% %       pcopy_test{i}.theta = pooled_contactCaTrials_locdep{i}.theta(ind_all_test');
%             pcopy_test{i}.theta = pooled_contactCaTrials_locdep{i}.theta_binned_new(ind_all_test');
%             
%      pcopy_test{i}.loc = pooled_contactCaTrials_locdep{i}.loc(ind_all_test'); 
% %       pcopy_test{i}.poleloc = pooled_contactCaTrials_locdep{i}.poleloc(ind_all_test'); 
%     pcopy_test{i}.re_totaldK = pooled_contactCaTrials_locdep{i}.re_totaldK(ind_all_test');
%     pcopy_test{i}.mousename = pooled_contactCaTrials_locdep{i}.mousename;
%      pcopy_test{i}.sessionname = pooled_contactCaTrials_locdep{i}.sessionname;
%       pcopy_test{i}.reg_fov = pooled_contactCaTrials_locdep{i}.reg_fov;
%      pcopy_test{i}.dend = pooled_contactCaTrials_locdep{i}.dend;   
%          pcopy_test{i}.CellID = pooled_contactCaTrials_locdep{i}.CellID;   
% end
% pcopy_array{r} = pcopy;
% pcopy_test_array{r} = pcopy_test;
% 
% 
% clear pcopy
% clear pcopy_test