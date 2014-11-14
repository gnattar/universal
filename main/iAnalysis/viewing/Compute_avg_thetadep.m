function  [pooled_contactCaTrials_thetadep] = Compute_avg_thetadep(collected_data,collected_summary)

pooled_contactCaTrials_thetadep = [];
count =1;
for i = 1: size(collected_summary,2) 
    d = length(collected_summary{1,i}.dends);
    for j = 1:d
        data = cell2mat(arrayfun(@(x) x.dff(j,:), collected_data{1,i},'uniformoutput',0)');
        sampling_time = collected_data{1,i}(1).FrameTime;
        winsize = round(.2/sampling_time);
        temp_data = filter(ones(1,winsize)/winsize,1,data,[],2);
        temp_totalKappa = cell2mat(arrayfun(@(x) x.total_touchKappa(1), collected_data{1,i},'uniformoutput',0)');
        temp_poleloc = cell2mat(arrayfun(@(x) x.barpos(1), collected_data{1,i},'uniformoutput',0)');
        temp_lightstim = cell2mat(arrayfun(@(x) x.lightstim(1), collected_data{1,i},'uniformoutput',0)');
        polelocs = unique(temp_poleloc);
       
        if max(temp_lightstim) >0
          avg_sigmag = zeros(2,length(polelocs),2);
          avg_loc = zeros (size(temp_data,2),length(polelocs),2);
          std_loc = zeros (size(temp_data,2),length(polelocs),2);  
          avg_totmodKappa = zeros(2,length(polelocs));
          std_totmodKappa = zeros(2,length(polelocs));
          num_trials =  zeros(2,length(polelocs));
          
        else
          avg_sigmag = zeros(1,length(polelocs),2);
          avg_loc = zeros (size(temp_data,2),length(polelocs),1);
          std_loc = zeros (size(temp_data,2),length(polelocs),1);
           avg_totmodKappa = zeros(1,length(polelocs));
           std_totmodKappa = zeros(1,length(polelocs));
           num_trials = zeros(1,length(polelocs));
        end
        
        for k = 1: length(polelocs)
            curr_poleloc_trials = (temp_poleloc == polelocs(k));
            if max(temp_lightstim) >0
                curr_loc_L_trials = temp_data (find(curr_poleloc_trials & temp_lightstim),:);
                curr_loc_NL_trials = temp_data (find(curr_poleloc_trials & ~temp_lightstim),:);
                curr_loc_L_Kappa = temp_totalKappa (find(curr_poleloc_trials & temp_lightstim));
                curr_loc_NL_Kappa = temp_totalKappa (find(curr_poleloc_trials & ~temp_lightstim));
                num_trials (2,k) = size(curr_loc_L_Kappa ,1);
                num_trials (1,k) = size(curr_loc_NL_Kappa ,1);
                avg_loc(:,k,2) = nanmean(curr_loc_L_trials,1);
                std_loc(:,k,2) = nanstd(curr_loc_L_trials,[],1)./sqrt(num_trials (2,k)+2);
                nancount= sum(isnan(curr_loc_L_trials));
                delpnts = find(nancount>num_trials (2,k)/3);
                avg_loc(delpnts,k,2) = nan;
                std_loc(delpnts,k,2) = nan;
                
                avg_loc(:,k,1) = nanmean(curr_loc_NL_trials,1);
                std_loc(:,k,1) = nanstd(curr_loc_NL_trials,[],1)./sqrt(num_trials (1,k)+2);
                nancount= sum(isnan(curr_loc_NL_trials));
                delpnts = find(nancount>num_trials (1,k)/3);
                avg_loc(delpnts,k,1) = nan;
                std_loc(delpnts,k,1) = nan;
                avg_sigmag(2,k,1) = nansum(avg_loc(:,k,2));
                avg_sigmag(1,k,1) = nansum(avg_loc(:,k,1));      
                avg_sigmag(2,k,2) = nansum(std_loc(:,k,2));
                avg_sigmag(1,k,2) = nansum(std_loc(:,k,1));   
                avg_totmodKappa(2,k) = nanmean(abs(curr_loc_L_Kappa ));
                avg_totmodKappa(1,k) = nanmean(abs(curr_loc_NL_Kappa ));
                
                std_totmodKappa(2,k) = nanstd(abs(curr_loc_L_Kappa));
                std_totmodKappa(1,k) = nanstd(abs(curr_loc_NL_Kappa));

            else
                num_trials (1,k) = size(curr_loc_NL_Kappa ,1);
                curr_loc_NL_trials = temp_data (curr_poleloc_trials & ~temp_lightstim);
                curr_loc_NL_Kappa = temp_totalKappa (curr_poleloc_trials & ~temp_lightstim);
                avg_loc(:,k,1) = nanmean(curr_loc_NL_trials,1);
                std_loc(:,k,1) = nanstd(curr_loc_NL_trials,[],1)./sqrt(num_trials (1,k)+1);                
                avg_sigmag(1,k,1) = nansum(avg_loc(:,k,1));
                avg_sigmag(1,k,2) = nansum(std_loc(:,k,1));   
                avg_totmodKappa(1,k) = nanmean(abs(curr_loc_NL_Kappa ));
                std_totmodKappa(1,k) = nanstd(abs(curr_loc_NL_Kappa ));
                
            end

        end

        
        pooled_contactCaTrials_thetadep {count}.rawdata = temp_data;
        pooled_contactCaTrials_thetadep {count}.sigmag = nansum(temp_data,2);
        pooled_contactCaTrials_thetadep {count}.FrameTime = sampling_time;
        pooled_contactCaTrials_thetadep {count}.totalKappa = temp_totalKappa;
        pooled_contactCaTrials_thetadep{count}.poleloc= temp_poleloc ;
        pooled_contactCaTrials_thetadep{count}.lightstim=   temp_lightstim ;
        pooled_contactCaTrials_thetadep{count}.num_trials=   num_trials;
        pooled_contactCaTrials_thetadep{count}.avg_loc = avg_loc;
        pooled_contactCaTrials_thetadep{count}.avg_sigmag= avg_sigmag;
        pooled_contactCaTrials_thetadep{count}.avg_totmodKappa = avg_totmodKappa;
        pooled_contactCaTrials_thetadep{count}.std_totmodKappa = std_totmodKappa;
        pooled_contactCaTrials_thetadep{count}.mousename= collected_summary{i}.mousename;
        pooled_contactCaTrials_thetadep{count}.sessionname= collected_summary{i}.sessionname;
        pooled_contactCaTrials_thetadep{count}.reg= collected_summary{i}.reg;
        pooled_contactCaTrials_thetadep{count}.fov= collected_summary{i}.fov;
        pooled_contactCaTrials_thetadep{count}.dend= collected_summary{i}.dends(j);
           
        count = count+1;
    end
end
save('pooled_contactCaTrials_thetadep','pooled_contactCaTrials_thetadep');


function plot_thetadep_L_NL(pooled_contactCaTrials_thetadep,n)
numloc = size(pooled_contactCaTrials_thetadep{n}.avg_loc,2);
sc = get(0,'ScreenSize');
h_fig1 = figure('position', [1000, sc(4)/10-100, sc(3)*1/3, sc(4)*1/3], 'color','w');
for i = 1:numloc 
    subplot(1,numloc,i); plot([1:length(pooled_contactCaTrials_thetadep{n}.avg_loc(:,i,1))]* pooled_contactCaTrials_thetadep{n}.FrameTime,pooled_contactCaTrials_thetadep{n}.avg_loc(:,i,1),'k'); hold on; 
    plot([1:length(pooled_contactCaTrials_thetadep{n}.avg_loc(:,i,1))]* pooled_contactCaTrials_thetadep{n}.FrameTime,pooled_contactCaTrials_thetadep{n}.avg_loc(:,i,2),'r');axis( [0 5 -50 150]);
    title([ num2str(pooled_contactCaTrials_thetadep{n}.num_trials(1,i)) ' NL ' num2str(pooled_contactCaTrials_thetadep{n}.num_trials(2,i)) ' L ' ]);
end
suptitle([ 'Dend ' num2str(n)]);



