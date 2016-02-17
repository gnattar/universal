 function [pcopy] = decode_whisk_params(pcopy,num_tests,disc_func,plot_on,train_test,str)  
num_runs = 1;

tk_all = pcopy{1}.re_totaldK;
 pl_all = pcopy{1}.loc;
setpoint_all =pcopy{1}.setpoint;
phase_all =pcopy{1}.phase;
lightstim_all =pcopy{1}.lightstim;
 

l_trials = lightstim_all;
%% ctrl 
tk =tk_all(l_trials == 0,:);
 pl = pl_all(l_trials == 0,:);
setpoint =setpoint_all(l_trials == 0,:);
phase =phase_all(l_trials == 0,:);
lightstim =lightstim_all(l_trials == 0,:);

 train_X = pl; test_X = pl;
 train_Y = phase; test_Y = phase;

 mdl_list = cell(num_tests,1);
 disc_func= 'diagLinear';
 tt=1;
 txt='PfromL';
 for n = 1:num_runs
 [fr_correct_n] = run_fitcdiscr(train_X,train_Y,test_X,test_Y,tt,disc_func,plot_on,mdl_list, num_tests,txt)
 fr_correct{n} = fr_correct_n;
 end
 
 summary.ctrl.fr_correct = fr_correct;
  summary.ctrl.mFrCor(1,1,1) = mean(cellfun(@(x) x(1,1,1), fr_correct)');
    summary.ctrl.sFrCor(1,1,1) = std(cellfun(@(x) x(1,1,1), fr_correct)')./sqrt(num_runs);
    summary.ctrl.mFrCor(1,2,1) = mean(cellfun(@(x) x(1,2,1), fr_correct)');
    summary.ctrl.sFrCor(1,2,1) = std(cellfun(@(x) x(1,2,1), fr_correct)')./sqrt(num_runs);
 
%% mani
tk =tk_all(l_trials == 1,:);
 pl = pl_all(l_trials == 1,:);
setpoint =setpoint_all(l_trials == 1,:);
phase =phase_all(l_trials == 1,:);
lightstim =lightstim_all(l_trials == 1,:);

if train_test == 1
 train_X = pl; test_X = pl;
 train_Y = phase; test_Y = phase;
 tt=1;
 for n = 1:num_runs
 [fr_correct_n] = run_fitcdiscr(train_X,train_Y,test_X,test_Y,tt,disc_func,plot_on,mdl_list, num_tests,txt)
 fr_correct{n} = fr_correct_n;
 end
 tag = 'retrained';
else
    tt=0;
   test_X = pl;
   test_Y = phase;
 for n = 1:num_runs
 [fr_correct_n] = run_fitcdiscr(train_X,train_Y,test_X,test_Y,tt,disc_func,plot_on,mdl_list, num_tests,txt)
 fr_correct{n} = fr_correct_n;
 end  
 tag = '';

end

    summary.mani.fr_correct = fr_correct;
    summary.mani.mFrCor(1,1,1) = mean(cellfun(@(x) x(1,1,1), fr_correct)');
    summary.mani.sFrCor(1,1,1) = std(cellfun(@(x) x(1,1,1), fr_correct)')./sqrt(num_runs);
    summary.mani.mFrCor(1,2,1) = mean(cellfun(@(x) x(1,2,1), fr_correct)');
    summary.mani.sFrCor(1,2,1) = std(cellfun(@(x) x(1,2,1), fr_correct)')./sqrt(num_runs);
    summary.info =  [str ' ' tag];
    save([str ' ' disc_func ' '  tag ' decoder results'],'summary');
    
% [fr_correct,mdl_list] = run_fitcdiscr(train_X,train_Y,test_X,test_Y,tt,disc_func,plot_on,mdl_list, num_tests)

