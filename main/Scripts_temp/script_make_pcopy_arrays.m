%% script_make pcopy_array and pcopy_test_array

%%
minlist_noresamp = floor(minlist./2);
minlist = minlist_noresamp;
for r = 1:100
for i = 1:size(pooled_contactCaTrials_locdep,2)
    ind_all = []; count =0;
    for p = 1:size(minlist,1)
    lind = find(pooled_contactCaTrials_locdep{i}.loc == p & pooled_contactCaTrials_locdep{i}.lightstim == 1);
    sel_lind= randperm(length(lind),minlist(p,1));
    remain = setxor([1:length(lind)],sel_lind);
    test_lind = remain(randperm(length(remain),minlist(p,1)));
    nlind = find(pooled_contactCaTrials_locdep{i}.loc == p & pooled_contactCaTrials_locdep{i}.lightstim == 0);
    sel_nlind= randperm(length(nlind),minlist(p,2));   
    remain = setxor([1:length(nlind)],sel_nlind);
    test_nlind = remain(randperm(length(remain),minlist(p,2)));
    temp = [lind(sel_lind);nlind(sel_nlind)];
    test_temp = [lind(test_lind);nlind(test_nlind)];
    num = length(temp);
    ind_all(count+1:count+num) = temp;
    ind_all_test(count+1:count+num) = test_temp;
    count = count+num;
    end    
    pcopy{i}.sigpeak = pooled_contactCaTrials_locdep{i}.sigpeak(ind_all');
    pcopy{i}.lightstim = pooled_contactCaTrials_locdep{i}.lightstim(ind_all');
    pcopy{i}.phase = pooled_contactCaTrials_locdep{i}.phase(ind_all');
%       pcopy{i}.theta = pooled_contactCaTrials_locdep{i}.theta(ind_all');
            pcopy{i}.theta = pooled_contactCaTrials_locdep{i}.theta_binned_new(ind_all');

     pcopy{i}.loc = pooled_contactCaTrials_locdep{i}.loc(ind_all'); 
%       pcopy{i}.poleloc = pooled_contactCaTrials_locdep{i}.poleloc(ind_all'); 
    pcopy{i}.re_totaldK = pooled_contactCaTrials_locdep{i}.re_totaldK(ind_all');
    pcopy{i}.mousename = pooled_contactCaTrials_locdep{i}.mousename;
     pcopy{i}.sessionname = pooled_contactCaTrials_locdep{i}.sessionname;
      pcopy{i}.reg_fov = pooled_contactCaTrials_locdep{i}.reg_fov;
     pcopy{i}.dend = pooled_contactCaTrials_locdep{i}.dend;   
         pcopy{i}.CellID = pooled_contactCaTrials_locdep{i}.CellID;   
         
             pcopy_test{i}.sigpeak = pooled_contactCaTrials_locdep{i}.sigpeak(ind_all_test');
    pcopy_test{i}.lightstim = pooled_contactCaTrials_locdep{i}.lightstim(ind_all_test');
    pcopy_test{i}.phase = pooled_contactCaTrials_locdep{i}.phase(ind_all_test');
%       pcopy_test{i}.theta = pooled_contactCaTrials_locdep{i}.theta(ind_all_test');
            pcopy_test{i}.theta = pooled_contactCaTrials_locdep{i}.theta_binned_new(ind_all_test');
            
     pcopy_test{i}.loc = pooled_contactCaTrials_locdep{i}.loc(ind_all_test'); 
%       pcopy_test{i}.poleloc = pooled_contactCaTrials_locdep{i}.poleloc(ind_all_test'); 
    pcopy_test{i}.re_totaldK = pooled_contactCaTrials_locdep{i}.re_totaldK(ind_all_test');
    pcopy_test{i}.mousename = pooled_contactCaTrials_locdep{i}.mousename;
     pcopy_test{i}.sessionname = pooled_contactCaTrials_locdep{i}.sessionname;
      pcopy_test{i}.reg_fov = pooled_contactCaTrials_locdep{i}.reg_fov;
     pcopy_test{i}.dend = pooled_contactCaTrials_locdep{i}.dend;   
         pcopy_test{i}.CellID = pooled_contactCaTrials_locdep{i}.CellID;   
end
pcopy_array{r} = pcopy;
pcopy_test_array{r} = pcopy_test;


clear pcopy
clear pcopy_test
end
