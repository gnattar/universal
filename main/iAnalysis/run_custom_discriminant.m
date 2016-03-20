function [mdl,results,accuracy,testarray] = run_custom_discriminant(pcopy_array,pcopy_test_array,par,reg)
numruns = size(pcopy_array,2);
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
    
    
% % % %     test_array = setxor([1:numruns], run);
% % % %     numtests = size(test_array,2);
% % % %   
% % % %     % selecting the same number of trials of each cond for test
% % % %     p=unique(ph_l);
% % % %     for n=1:length(p)
% % % %         c(n) = length(find(ph_l ==p(n)));
% % % %         inds{n} = find(ph_l ==p(n));
% % % %     end
% % % %     l_limit = min(c);
% % % %     temp_test_set = zeros(l_limit,length(p));
% % % %     for n=1:length(p)
% % % %     temp = randperm(c(n),l_limit);
% % % %     temp_test_set(:,n) = inds{n}(temp);
% % % %     end    
% % % %     test_set=reshape(temp_test_set,l_limit*length(p),1);
% % % %     
% % % %     [labeldiag,scoresdiag] = predict(Mdldiag,ca_l(test_set,:));
% % % %     errors = (labeldiag - ph_l(test_set));
% % % %     labels_l{numtests+1}.sorted = [labeldiag,ph_l(test_set),scoresdiag,errors];
% % % %     accuracy_l{numtests+1}.sorted = sum(labeldiag==ph_l(test_set))./length(labeldiag);
% % % %     
% % % %     % shuffled
% % % %     shuff = randperm(size(test_set,1),size(test_set,1));
% % % %     shuff2= randperm(size(test_set,1),size(test_set,1));
% % % %     [labeldiag,scoresdiag] = predict(Mdldiag,ca_l(test_set(shuff),:));
% % % %     errors = (labeldiag - ph_l(test_set(shuff2)));
% % % %     labels_l{numtests+1}.shuff = [labeldiag,ph_l(test_set(shuff2)),scoresdiag,errors];
% % % %     accuracy_l{numtests+1}.shuff = sum(labeldiag==ph_l(test_set(shuff2)))./length(labeldiag);    
    
    c=[];ind={};temp_test_set=[];test_set=[];

        pcopy = pcopy_test_array{run};
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
        results_nl{run}.sorted = [labeldiag,ph_nl(test_set),scoresdiag,errors];
        accuracy_nl{run}.sorted = sum(labeldiag==ph_nl(test_set))./length(labeldiag);
 
        % shuffled
        shuff = randperm(size((test_set),1),size((test_set),1));
        shuff2= randperm(size((test_set),1),size((test_set),1));
        [labeldiag,scoresdiag] = predict(Mdldiag,ca_nl(test_set(shuff),:));
        errors = (labeldiag - ph_nl(test_set(shuff2)));
        results_nl{run}.shuff = [labeldiag,ph_nl(test_set(shuff2)),scoresdiag,errors];
        accuracy_nl{run}.shuff = sum(labeldiag==ph_nl(test_set(shuff2)))./length(labeldiag);
        
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
        results_l{run}.sorted = [labeldiag,ph_l(test_set),scoresdiag,errors];
        accuracy_l{run}.sorted = sum(labeldiag==ph_l(test_set))./length(labeldiag);
        

        % shuffled
        shuff = randperm(size(test_set,1),size(test_set,1));
        shuff2= randperm(size(test_set,1),size(test_set,1));
        [labeldiag,scoresdiag] = predict(Mdldiag,ca_l(test_set(shuff),:));
        errors = (labeldiag - ph_l(test_set(shuff2)));
        results_l{run}.shuff = [labeldiag,ph_l(test_set(shuff2)),scoresdiag,errors];
        accuracy_l{run}.shuff = sum(labeldiag==ph_l(test_set(shuff2)))./length(labeldiag);   
        
         c=[];ind={};temp_test_set=[];test_set=[];
        clear ca_nl ca_l
end
  

%   results = [results_nl;  
%   results{run}.l = results_l;
%   
%   accuracy{run}.nl = accuracy_nl;  
%   accuracy{run}.l = accuracy_l;
  
end


