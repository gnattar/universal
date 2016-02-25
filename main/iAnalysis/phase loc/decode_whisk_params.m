 function [pcopy] = decode_whisk_params(pcopy,num_tests,disc_func,plot_on,train_test,cond)  
 % [pcopy] = decode_whisk_params(pcopy,10,'linear',1,0,'LfromTh') 
num_runs = 1;
str = cond;
tk_all = pcopy{1}.re_totaldK;
 pl_all = pcopy{1}.loc;
setpoint_all =pcopy{1}.setpoint;
phase_all =pcopy{1}.phase;
theta_all = pcopy{1}.theta;
lightstim_all =pcopy{1}.lightstim;
 

l_trials = lightstim_all;
%% ctrl 
tk =tk_all(l_trials == 0,:);
 pl = pl_all(l_trials == 0,:);
setpoint =setpoint_all(l_trials == 0,:);
theta =theta_all(l_trials == 0,:);
phase =phase_all(l_trials == 0,:);
lightstim =lightstim_all(l_trials == 0,:);

switch cond
    case {'PfromL'}
        txt='PfromL';
        train_X = pl; test_X = pl;
        train_Y = phase; test_Y = phase;
    case {'LfromP'}
        txt='LfromP';
        train_X = phase; test_X = phase;
        train_Y = pl; test_Y = pl;
    case {'LfromTh'}
        txt='LfromTh';
        train_X = theta; test_X = theta;
        train_Y = pl; test_Y = pl;
    case {'ThfromL'}
        txt='ThfromL';
        train_X = pl; test_X = pl;
        train_Y = theta; test_Y = theta;
end

 mdl_list = cell(num_tests,1);
 disc_func= 'diagLinear';
 tt=1;

 for n = 1:num_runs
 [fr_correct_n] = run_whiskparams_decoder(train_X,train_Y,test_X,test_Y,tt,disc_func,plot_on,mdl_list, num_tests,txt)
 fr_correct{n} = fr_correct_n;
 end
 
 summary.ctrl.fr_correct = fr_correct;
  summary.ctrl.mFrCor(1,1,1) = mean(cellfun(@(x) x(1,1,1), fr_correct)');
    summary.ctrl.sFrCor(1,1,1) = std(cellfun(@(x) x(1,1,1), fr_correct)')./sqrt(num_runs);
    summary.ctrl.mFrCor(1,2,1) = mean(cellfun(@(x) x(1,2,1), fr_correct)');
    summary.ctrl.sFrCor(1,2,1) = std(cellfun(@(x) x(1,2,1), fr_correct)')./sqrt(num_runs);
     if plot_on
        set(gcf,'PaperUnits','inches');
        set(gcf,'PaperPosition',[1 1 24 18]);
        set(gcf, 'PaperSize', [10,24]);
        set(gcf,'PaperPositionMode','manual');
        pause(.5);
        suptitle([str ' ' disc_func ' CTRL']);
        %     print( gcf ,'-depsc2','-painters','-loose',[str ' ' disc_func ' CTRL']);
        saveas(gcf,[str ' CTRL' txt ],'fig');
        saveas(gcf,[str ' CTRL' txt],'jpg');
     end
    close all;
%% mani
tk =tk_all(l_trials == 1,:);
 pl = pl_all(l_trials == 1,:);
setpoint =setpoint_all(l_trials == 1,:);
theta =theta_all(l_trials == 1,:);
phase =phase_all(l_trials == 1,:);
lightstim =lightstim_all(l_trials == 1,:);

if train_test == 1
    switch cond
        case {'PfromL'}
            txt='PfromL';
            train_X = pl; test_X = pl;
            train_Y = phase; test_Y = phase;
        case {'LfromP'}
            txt='LfromP'
            train_X = phase; test_X = phase;
            train_Y = pl; test_Y = pl;
        case {'LfromTh'}
            txt='ThfromL';
            train_X = pl; test_X = pl;
            train_Y = theta; test_Y = theta;
        case {'ThfromL'}
            txt='LfromTh'
            train_X = theta; test_X = theta;
            train_Y = pl; test_Y = pl;
    end
    
 
 tt=1;
 for n = 1:num_runs
 [fr_correct_n] = run_whiskparams_decoder(train_X,train_Y,test_X,test_Y,tt,disc_func,plot_on,mdl_list, num_tests,txt)
 fr_correct{n} = fr_correct_n;
 end
 tag = 'retrained';
else
    tt=0;
    switch cond
        case {'PfromL'}
            txt='PfromL';
            test_X = pl;
            test_Y = phase;
        case {'LfromP'}
            txt='LfromP'
            test_X = phase;
            test_Y = pl;
        case {'LfromTh'}
            txt='ThfromL';
            test_X = pl;
            test_Y = theta;
        case {'ThfromL'}
            txt='LfromTh'
            test_X = theta;
            test_Y = pl;
    end

 for n = 1:num_runs
 [fr_correct_n] = run_whiskparams_decoder(train_X,train_Y,test_X,test_Y,tt,disc_func,plot_on,mdl_list, num_tests,txt)
 fr_correct{n} = fr_correct_n;
 end  
 tag = 'ctrl trained';

end

    summary.mani.fr_correct = fr_correct;
    summary.mani.mFrCor(1,1,1) = mean(cellfun(@(x) x(1,1,1), fr_correct)');
    summary.mani.sFrCor(1,1,1) = std(cellfun(@(x) x(1,1,1), fr_correct)')./sqrt(num_runs);
    summary.mani.mFrCor(1,2,1) = mean(cellfun(@(x) x(1,2,1), fr_correct)');
    summary.mani.sFrCor(1,2,1) = std(cellfun(@(x) x(1,2,1), fr_correct)')./sqrt(num_runs);
    summary.info =  [str ' ' tag txt];
    save([str ' ' disc_func ' '  tag txt ' decoder results'],'summary');
    
    
    if plot_on
        set(gcf,'PaperUnits','inches');
        set(gcf,'PaperPosition',[1 1 24 18]);
        set(gcf, 'PaperSize', [10,24]);
        set(gcf,'PaperPositionMode','manual');
        pause(.5);
        suptitle([str ' ' disc_func ' MANI']);
        %     print( gcf ,'-depsc2','-painters','-loose',[str ' ' disc_func ' CTRL']);
        saveas(gcf,[str ' MANI' txt],'fig');
        saveas(gcf,[str ' MANI' txt],'jpg');
    end
    
% [fr_correct,mdl_list] = run_fitcdiscr(train_X,train_Y,test_X,test_Y,tt,disc_func,plot_on,mdl_list, num_tests)

