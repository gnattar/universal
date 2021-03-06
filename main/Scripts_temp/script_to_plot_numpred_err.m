
if str == 'theta'
    
    %% find the most contributing cells
        load('pcopy.mat');
        numcells  = size(pcopy,2);
        
        load ('All_cells_phase diaglinear ctrltrain decoder results.mat');
        count=zeros(numcells,1);
        inds={};
        for m=1:100
            Temp_coeffs = summary.ctrl.mdl_list{1}{m}.DeltaPredictor;
            Delta_crit = summary.ctrl.mdl_list{1}{m}.Delta;
            temp = find(Temp_coeffs>Delta_crit);
            inds{m}(1:length(temp))=temp;
            count=count+(Temp_coeffs>Delta_crit)';
        end
        [sorted_count,sorted_cells] = sort(count,'descend');
        %     contrib_cells = sorted_cells(1:50);
        save('cells_sorted_bycontrib','sorted_cells','sorted_count');
        
    
    %%
    load pcopy.mat
    [pooled_contactCaTrials_locdep] = prep_pcopy(pcopy,'theta');
    %% get normplots for all cells
    %%ctrl_norm
    r=['all cells ctrl norm'];
    numcells = size(pcopy,2);
    dends = [1:numcells];
    [data] = Collect_theta_summary__frompcopy_T2(dends,r,'ctrl_norm');
    light =1;[data] = plot_normResp_theta(data,1,r,'ctrl_norm');
    
    r=['all cells self norm'];
    dends = [1:numcells];
    [data] = Collect_theta_summary__frompcopy_T2(dends,r,'self_norm');
    light =1;[data] = plot_normResp_theta(data,1,r,'self_norm');
    %% get normplots for contrib cells
    r=['theta phase coding cells g50 ctrl norm'];
    dends = contrib_cells;
    [data] = Collect_theta_summary__frompcopy_T2(dends,r,'ctrl_norm');
    light =1;[data] = plot_normResp_theta(data,1,r,'ctrl_norm');
    r=['theta phase coding cells g50 self norm'];
    dends = [contrib_cells];
    [data] = Collect_theta_summary__frompcopy_T2(dends,r,'self_norm');
    light =1;[data] = plot_normResp_theta(data,1,r,'self_norm');
   
    %
    % m=94;
    % mkdir (['R' num2str(m) ' ' num2str(minpred(find(runid==m))) ' cells'])
    %  % runid with desired numpred
    % dends = find(summary.ctrl.mdl_list{1}{m}.DeltaPredictor > summary.ctrl.mdl_list{1}{m}.Delta)
    % r=[num2str(m) 'high']
    % [data] = Collect_theta_summary__frompcopy_T2(dends,r,'ctrl_norm')
    % light =1;[data] = plot_normResp_theta(data,1,r,'ctrl_norm')
    % dends = setxor([1:123],find(summary.ctrl.mdl_list{1}{m}.DeltaPredictor > summary.ctrl.mdl_list{1}{m}.Delta))
    % r=[num2str(m) 'low']
    % [data] = Collect_theta_summary__frompcopy_T2(dends,r)
    % light =1;[data] = plot_normResp_theta(data,1,r)
    
    
    %% plot num predictors vs runs
       load ('All_cells_phase diaglinear ctrltrain decoder results.mat');
       load('pcopy.mat')
       numcells = size(pcopy,2);
      mkdir num_pred
    cd('num_pred');
    temp = cell2mat(summary.ctrl.num_predictors{1})
    minpred= zeros(length(temp),1)
    runid= zeros(length(temp),1)
    for n = 1: length(temp)
        [v,i] = (min(temp));
        minpred(n) = v;
        runid(n) = i
        temp(i) = nan;
    end
    save('minpred','minpred');
    save('runid','runid');
    numruns = 100;% =100;
    inds = [(1:50:50*numruns)]';
    inds(:,2) = inds(:,1)+49;
    err_all = summary.ctrl.dist_err{1,1}(:,1);
    for i = 1:numruns
        temp = err_all(inds(i,1):inds(i,2));
        frc= sum(temp==0);
        err_coll(i) = frc;
    end
    frCor=err_coll./50;
    frCor_sorted = frCor(runid);
    frCor_sorted = (frCor(runid))';
    
    figure;subplot(1,2,1);plot(minpred,frCor_sorted,'ko');
    [P,S] = polyfit(minpred,frCor_sorted,1)
    Y=polyval(P,[1:numcells]);
    hold on ; plot([1:numcells],Y,'k');
    title('Fraction Correct vs. Numpredictors');
    subplot(1,2,2);plot(runid,frCor_sorted,'ko');
    hold on ;
    title('Fraction Correct vs. Runid');
    xlabel('Run ID');ylabel('Fraction Correct');
    save('frCor_sorted_ctrl','frCor_sorted');
    inds = [(1:50:50*numruns)]';
    inds(:,2) = inds(:,1)+49;
    err_all = summary.mani.dist_err{1,1}(:,1);
    for i = 1:numruns
        temp = err_all(inds(i,1):inds(i,2));
        frc= sum(temp==0);
        err_coll(i) = frc;
    end
    frCor=err_coll./50;
    frCor_sorted = frCor(runid);
    frCor_sorted = (frCor(runid))';
    subplot(1,2,1);hold on;plot(minpred,frCor_sorted,'ro')
    [P,S] = polyfit(minpred,frCor_sorted,1)
    Y=polyval(P,[1:numcells]);
    hold on ; plot([1:numcells],Y,'r');
    subplot(1,2,2);plot(runid,frCor_sorted,'ro');
    hold on ;
    saveas(gca,'FrCo Numpred Runid','fig');set(gcf,'PaperPositionMode','manual');
    print( gcf ,'-depsc2','-painters','-loose','FrCor Numpred Runid');
    save('frCor_sorted_mani','frCor_sorted');
    
    %% plot preference index vs coeff
    load('Theta Summary Data rall cells.mat');
    TPI_ctrl = data.TPI_ctrl{1};
    TPI_mani = data.TPI_mani{1};
    figure;plot(Temp_coeffs',TPI_ctrl,'o','color',[.5 .5 .5])
    hold on; plot(Temp_coeffs(inds)',TPI_ctrl(inds),'ko')
    vline(Delta_crit,'k--')
    ylabel('Theta Pref Index');xlabel('Delta Predictor')
    plot(Temp_coeffs',TPI_mani,'o','color',[.85 .5 .5])
    hold on; plot(Temp_coeffs(inds)',TPI_mani(inds),'ro')
    title('Delta Predictor Coeff vs Theta Pref ')
    title(['Delta Predictor Coeff vs Theta Pref R'  num2str(m)])
    inc=((TPI_mani-TPI_ctrl)>0);
    dec=((TPI_ctrl-TPI_mani)>0);
    contrib=(Temp_coeffs>Delta_crit)';
    bright=find(inc&contrib);
    hold on; plot(Temp_coeffs(bright)',TPI_ctrl(bright),'ko','markerfacecolor',[.5 .5 .5]);
    hold on; plot(Temp_coeffs(bright)',TPI_mani(bright),'ro','markerfacecolor',[.85 .5 .5]);
    
    %%%%
elseif str == 'phase'
    %% find the most contributing cells
    load ('All_cells_phase diaglinear ctrltrain decoder results.mat');
    load('pcopy.mat');
    numcells  = size(pcopy,2);
    count=zeros(numcells,1);
    inds={};
    for m=1:100
        Temp_coeffs = summary.ctrl.mdl_list{1}{m}.DeltaPredictor;
        Delta_crit = summary.ctrl.mdl_list{1}{m}.Delta;
        temp = find(Temp_coeffs>Delta_crit);
        inds{m}(1:length(temp))=temp;
        count=count+(Temp_coeffs>Delta_crit)';
    end
    [sorted_count,sorted_cells] = sort(count,'descend')
    contrib_cells = highcontrib_phase_g50;%sorted_cells(1:50);
    save('cells_sorted_bycontrib','sorted_cells','sorted_count')
    %%
    load pcopy.mat
     numcells = size(pcopy,2);
     mkdir ('tuning'); cd ('tuning')
    [pooled_contactCaTrials_locdep] = prep_pcopy(pcopy,'phase');
    %% get normplots for all cells
    %%ctrl_norm
    r=['all cells ctrl norm'];
    dends = [1:numcells];
    [data] = Collect_phase_summary__frompcopy_T2(dends,r,'ctrl_norm');
    mkdir ('all'); cd('all')
    light =1;[data] = plot_normResp_phase(data,1,r,'ctrl_norm');    
    cd ..
    r=['all cells self norm'];
    dends = [1:numcells];
    [data] = Collect_phase_summary__frompcopy_T2(dends,r,'self_norm');
     cd('all')
    light =1;[data] = plot_normResp_phase(data,1,r,'self_norm');
    cd ..
    %% get normplots for phase coding cells
    r=['phase cells ctrl norm'];
    dends = phase_cells;
    [data] = Collect_phase_summary__frompcopy_T2(dends,r,'ctrl_norm');
    mkdir ('phase'); cd('phase')
    light =1;[data] = plot_normResp_phase(data,1,r,'ctrl_norm');
    cd ..
    r=['phase cells self norm'];
    dends = [phase_cells];
    [data] = Collect_phase_summary__frompcopy_T2(dends,r,'self_norm');
    cd('phase')
    light =1;[data] = plot_normResp_phase(data,1,r,'self_norm');
    cd ..
        %% get normplots for theta and phase coding cells
    r=['theta phase cells ctrl norm'];
    dends = theta_phase_cells;
    [data] = Collect_phase_summary__frompcopy_T2(dends,r,'ctrl_norm');
     mkdir ('theta_phase'); cd('theta_phase')
    light =1;[data] = plot_normResp_phase(data,1,r,'ctrl_norm');
    cd ..
    r=['theta phase cells self norm'];
    dends = [theta_phase_cells];
    [data] = Collect_phase_summary__frompcopy_T2(dends,r,'self_norm');
    cd('theta_phase')
    light =1;[data] = plot_normResp_phase(data,1,r,'self_norm');
    cd ..
    % m=94;
    % mkdir (['R' num2str(m) ' ' num2str(minpred(find(runid==m))) ' cells'])
    %  % runid with desired numpred
    % dends = find(summary.ctrl.mdl_list{1}{m}.DeltaPredictor > summary.ctrl.mdl_list{1}{m}.Delta)
    % r=[num2str(m) 'high']
    % [data] = Collect_phase_summary__frompcopy_T2(dends,r)
    % light =1;[data] = plot_normResp_phase(data,1,r)
    % dends = setxor([1:123],find(summary.ctrl.mdl_list{1}{m}.DeltaPredictor > summary.ctrl.mdl_list{1}{m}.Delta))
    % r=[num2str(m) 'low']
    % [data] = Collect_phase_summary__frompcopy_T2(dends,r)
    % light =1;[data] = plot_normResp_phase(data,1,r)
    
    cd ..
    %% plot num predictors vs runs
        load ('All_cells_phase diaglinear ctrltrain decoder results.mat');
        load ('pcopy.mat');
        numcells = size(pcopy,2);
    mkdir num_pred
    cd('num_pred');
    temp = cell2mat(summary.ctrl.num_predictors{1})
    minpred= zeros(length(temp),1)
    runid= zeros(length(temp),1)
    for n = 1: length(temp)
        [v,i] = (min(temp));
        minpred(n) = v;
        runid(n) = i
        temp(i) = nan;
    end
    save('minpred','minpred');
    save('runid','runid');
    numruns = 100;% =100;
    inds = [(1:50:50*numruns)]';
    inds(:,2) = inds(:,1)+49;
    err_all = summary.ctrl.dist_err{1,1}(:,1);
    for i = 1:numruns
        temp = err_all(inds(i,1):inds(i,2));
        frc= sum(temp==0);
        err_coll(i) = frc;
    end
    frCor=err_coll./50;
    frCor_sorted = frCor(runid);
    frCor_sorted = (frCor(runid))';
    
    figure;subplot(1,2,1);plot(minpred,frCor_sorted,'ko');
    [P,S] = polyfit(minpred,frCor_sorted,1)
    Y=polyval(P,[1:numcells]);
    hold on ; plot([1:numcells],Y,'k');
    title('Fraction Correct vs. Numpredictors');
    subplot(1,2,2);plot(runid,frCor_sorted,'ko');
    hold on ;
    title('Fraction Correct vs. Runid');
    xlabel('Run ID');ylabel('Fraction Correct');
    save('frCor_sorted_ctrl','frCor_sorted');
    inds = [(1:50:50*numruns)]';
    inds(:,2) = inds(:,1)+49;
    err_all = summary.mani.dist_err{1,1}(:,1);
    for i = 1:numruns
        temp = err_all(inds(i,1):inds(i,2));
        frc= sum(temp==0);
        err_coll(i) = frc;
    end
    frCor=err_coll./50;
    frCor_sorted = frCor(runid);
    frCor_sorted = (frCor(runid))';
    subplot(1,2,1);hold on;plot(minpred,frCor_sorted,'ro')
    [P,S] = polyfit(minpred,frCor_sorted,1)
    Y=polyval(P,[1:numcells]);
    hold on ; plot([1:numcells],Y,'r');
    subplot(1,2,2);plot(runid,frCor_sorted,'ro');
    hold on ;
    saveas(gca,'FrCo Numpred Runid','fig');set(gcf,'PaperPositionMode','manual');
    print( gcf ,'-depsc2','-painters','-loose','FrCor Numpred Runid');
    save('frCor_sorted_mani','frCor_sorted');
    
    %% plot preference index vs coeff
    sc = get(0,'ScreenSize');
    h_fig1 = figure('position', [1000, sc(4), sc(3)/2, sc(4)/2], 'color','w');
    subplot(1,2,1);
    
    load('Phase Summary Data rall cells ctrl norm.mat');
    PPI_ctrl = data.PPI_ctrl{1};
    PPI_mani = data.PPI_mani{1};
    % load('Theta Summary Data rall cells.mat');

    plot(Temp_coeffs',PPI_ctrl,'o','color',[.5 .5 .5])
    hold on; plot(Temp_coeffs(inds)',PPI_ctrl(inds),'ko')
    vline(Delta_crit,'k--')
    ylabel('Phase Pref Index');xlabel('Delta Predictor')
    plot(Temp_coeffs',PPI_mani,'o','color',[.85 .5 .5])
    hold on; plot(Temp_coeffs(inds)',PPI_mani(inds),'ro')
    title(['Coeff vs PhasePref ctrl R'  num2str(m)])
    inc=((PPI_mani-PPI_ctrl)>0);
    dec=((PPI_ctrl-PPI_mani)>0);
    contrib=(Temp_coeffs>Delta_crit)';
    bright=find(inc&contrib);
    hold on; plot(Temp_coeffs(bright)',PPI_ctrl(bright),'ko','markerfacecolor',[.5 .5 .5]);
    hold on; plot(Temp_coeffs(bright)',PPI_mani(bright),'ro','markerfacecolor',[.85 .5 .5]);
    
     hold on; plot(Temp_coeffs(theta_phase_cells)',PPI_ctrl(theta_phase_cells),'o','color',[0.15 .55 .15],'markersize',9,'linewidth',2);
    hold on; plot(Temp_coeffs(theta_phase_cells)',PPI_mani(theta_phase_cells),'o','color',[0.15 0.55 .15],'markersize',9,'linewidth',2);   

    subplot(1,2,2);
    load('Phase Summary Data rall cells self norm.mat');
    PPI_ctrl = data.PPI_ctrl{1};
    PPI_mani = data.PPI_mani{1};
    % load('Theta Summary Data rall cells.mat');

    plot(Temp_coeffs',PPI_ctrl,'o','color',[.5 .5 .5])
    hold on; plot(Temp_coeffs(inds)',PPI_ctrl(inds),'ko')
    vline(Delta_crit,'k--')
    ylabel('Phase Pref Index');xlabel('Delta Predictor')
    plot(Temp_coeffs',PPI_mani,'o','color',[.85 .5 .5])
    hold on; plot(Temp_coeffs(inds)',PPI_mani(inds),'ro')
    title(['Coeff vs PhasePref self R'  num2str(m)])
    inc=((PPI_mani-PPI_ctrl)>0);
    dec=((PPI_ctrl-PPI_mani)>0);
    contrib=(Temp_coeffs>Delta_crit)';
    bright=find(inc&contrib);
    hold on; plot(Temp_coeffs(bright)',PPI_ctrl(bright),'ko','markerfacecolor',[.5 .5 .5]);
    hold on; plot(Temp_coeffs(bright)',PPI_mani(bright),'ro','markerfacecolor',[.85 .5 .5]);
    
%     hold on; plot(Temp_coeffs(phase_cells)',PPI_ctrl(phase_cells),'o','color',[.5 1 .5],'markersize',4);
%     hold on; plot(Temp_coeffs(phase_cells)',PPI_mani(phase_cells),'o','color',[.5 1 .5],'markersize',4);   
     hold on; plot(Temp_coeffs(theta_phase_cells)',PPI_ctrl(theta_phase_cells),'o','color',[0.15 .55 .15],'markersize',9,'linewidth',2);
    hold on; plot(Temp_coeffs(theta_phase_cells)',PPI_mani(theta_phase_cells),'o','color',[0.15 0.55 .15],'markersize',9,'linewidth',2);   

end





























































%%

% load pcopy.mat
