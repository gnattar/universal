%% script to call prep(d)
%% load the dolo data file first 
%% move to folder containg .whisker files
function Batch_whiskers_preprocess(nogopos,gopos)
d = pwd;
%%load solo_data
cd ([d '/solo_data']);
list = dir('solodata_*.mat');
load(list(1).name);
solo_obj=obj;
cd ..
%% make sessionInfo obj
sessionInfo = struct('pxPerMm', 31.25, 'mouseName', solo_obj.mouseName,'sessionName',solo_obj.sessionName(end-6:end),'SoloTrialStartEnd',obj.trialStartEnd,'whiskerPadOrigin_nx',[390,30],'whiskerImageDim',[560,440],...
    'bar_coords',[],'bar_time_window',[0.5,2],'whisker_trajIDs',[0,1],'theta_kappa_roi',[0,20,150,170],'gotrials',[],'nogotrials',[]);


cd([d '/whisker_data']);
list = dir('2012_*');
cd (list(1).name);
d =pwd;

[barposmat,barposmatall,nogopix,gopix]= prep(d,solo_obj,nogopos,gopos);
save ('barposmat.mat','barposmat');
save ('barposmatall.mat','barposmatall');
% cd and save
cd ..
cd ..
% save ('barposmat.mat');
% list = dir('SessionInfo_*.mat');
% load(list(1).name);

%%
sessionInfo.bar_coords = [];
sessionInfo.bar_coords = barposmat(:,[1,2]);

sessionInfo.nogotrials = find(barposmatall(:,1)==nogopix(1,1));
 sessionInfo.gotrials = find(barposmatall(:,1)~=nogopix(1,1));
% % % sessionInfo.gotrials = find((round(cell2mat(saved_history.MotorsSection_motor_position)/1000)*1000)~=saved.MotorsSection_nogo_position);
% % % sessionInfo.nogotrials = find((round(cell2mat(saved_history.MotorsSection_motor_position)/1000)*1000)==saved.MotorsSection_nogo_position);

sessionInfo.gopos =unique(barposmatall(sessionInfo.gotrials));
sessionInfo.gopos(:,2)=barposmatall(1,2);
sessionInfo.nogopos = unique(barposmatall(sessionInfo.nogotrials));
sessionInfo.nogopos(:,2)=barposmatall(1,2);
name = ['SessionInfo_' solo_obj.mouseName '_' datestr(now,'mmddyy') ];
save(name,'sessionInfo');
end

function [barposmat,barposmatall,nogopix,gopix]= prep(d,solo_obj,nogopos,gopos)
    %% to make the barposmat conversion
    %d =
    %load('data_*'); %load solodata

    %% evaluate tracker files
    files = dir('*.whiskers');
    temp=struct2cell(files);
    trialnames= temp(1,:)';
    names = char(trialnames);
    whisknumind = str2num(names(:,30:33));   

    files = dir('*.measurements');
    temp=struct2cell(files);
    trialnames= temp(1,:)';
    names = char(trialnames);
    measnumind = str2num(names(:,30:33)); 

    files = dir('*.mp4');
    temp=struct2cell(files);
    trialnames= temp(1,:)';
    names = char(trialnames);
    mp4numind = str2num(names(:,30:33)); 
    incomplete =0;

    if (length (whisknumind) == length(measnumind))
        if(length(whisknumind)== length (mp4numind))
            'OK go ahead with analysis'
        else
            ['incomplete data:' num2str(length(whisknumind)) 'whiskers and' num2str(length(mp4numind)) 'mp4']
            %incomplete=1;
        end
    else
           ['incomplete data:' num2str(length(whisknumind)) 'whiskers and' num2str(length(measnumind)) 'measurements']
            incomplete =1;
    end

    if (incomplete)
        %% get list of files to delete
           deletewhisk = zeros(length(whisknumind),1);
        for i=1:length(whisknumind)
           check = find(measnumind==whisknumind(i));
           if isempty(check)
               deletewhisk(i) = whisknumind(i);
           end
        end


       deletemeas = zeros(length(measnumind),1);
        for i=1:length(measnumind)
           check = find(whisknumind==measnumind(i));
           if isempty(check)
               deletemeas(i) = measnumind(i);
           end
        end
        pause(1)
      end   

    %% make barposmat
    files = dir('*.whiskers');
    temp=struct2cell(files);
    trialnames= temp(1,:)';
    names = char(trialnames);
    trialnumind = str2num(names(:,30:33));

%     pos = saved_history.MotorsSection_motor_position;
    barpos = solo_obj.polePositions';
%     barpos = cell2mat(pos);
    barpos = round(barpos/1000)/10;
    %yscaling 10.6e5 = 270pxls
    %xscaling 10.6e5 = 20pxls
    
    
    
          %GR rig 2c373 120912
        coordsatfirst = [ 510, 320];
        coordsatnext = [1, 320];
        barposatfirst = 0; 
        barposatnext = 20;   
    
% % %       %GR rig 2c373 120822
% % %         coordsatfirst = [ 450, 300];
% % %         coordsatnext = [25, 300];
% % %         barposatfirst = 3; 
% % %         barposatnext = 20;   
    
    
    
% % %       %GR rig 2c373 120814
% % %         coordsatfirst = [ 281, 205];
% % %         coordsatnext = [13, 205];
% % %         barposatfirst = 8; 
% % %         barposatnext = 19;   

    
    
% % %         %GR rig 2c373 120823
% % %         coordsatfirst = [ 258, 325];
% % %         coordsatnext = [28, 325];
% % %         barposatfirst = 8; 
% % %         barposatnext = 19;   
    
% % %         %GR rig 2c373 120824
% % %         coordsatfirst = [ 283, 265];
% % %         coordsatnext = [28, 265];
% % %         barposatfirst = 9; 
% % %         barposatnext = 19;   
    messups=find(barpos<barposatfirst);
    barpos(messups,:) = barposatnext(1,:); %%overwririntg any wierd zeros with nogo position 

    % % %     %GR rig 2c373 120710
    % % %     coordsatzero = [418 , 317];
    % % %     coordsatnext = [122, 317];
    % % %     barposatnext = 12;
    %GR rig 2c373 120613
    % % % coordsatzero = [490 , 340];
    % % % coordsatnext = [220, 320];
    % % % barposatnext = 10.6;
    % 2Prig NX before 051712
    % % % coordsatzero = [46 , 58];
    % % % coordsatnext = [346, 60];%AT 12
    % % % barposatnext = 12;
    % % % % 2Prig NX 051712
    % % % coordsatzero = [109 , 47];

    % % % coordsatnext = [405, 45];%AT 12
    % % % barposatnext = 12;


    coordsdiff = abs(coordsatfirst-coordsatnext);
    barposdiff = abs(barposatfirst-barposatnext);
    barposmatall = zeros(length(barpos),2);
    factor = coordsdiff/barposdiff;
    barposmatall(:,1) = repmat(coordsatfirst(1),length(barpos),1)- (barpos(:,1)-barposatfirst(1))*factor(1) ;
    if(factor(2)~=0)
        barposmatall(:,2) = repmat(coordsatfirst(2),length(barpos),1)-(barpos(:,1)-barposatfirst(2))*factor(2);
    else
        barposmatall(:,2) = coordsatfirst(2);
    end
% % %     barposmatall(:,1) = repmat(coordsatfirst(1),length(barpos),1)-(coordsdiff(1)*(barpos(:,1)./barposatnext));
% % %     barposmatall(:,2) = repmat(coordsatfirst(2),length(barpos),1)-(coordsdiff(2)*(barpos(:,1)./barposatnext));

    %2Prig NX 051712
    % % % barposmatall(:,1) = repmat(coordsatzero(1),length(barpos),1)+(diff(1)*(barpos(:,1)./barposatnext));
    % % % barposmatall(:,2) = repmat(coordsatzero(2),length(barpos),1)+(diff(2)*(barpos(:,1)./barposatnext));

    barposmatall=round(barposmatall);
    
    nogopix(:,1) = repmat(coordsatfirst(1),length(nogopos),1)- (nogopos(:,1)-barposatfirst(1))*factor(1) ;
    if(factor(2)~=0)
         nogopix(:,2)= repmat(coordsatfirst(2),length(nogopos),1)-(nogopos(:,1)-barposatfirst(2))*factor(2);
    else
        nogopix(:,2) = coordsatfirst(2);
    end
    
    gopos =gopos';
    gopix(:,1) = repmat(coordsatfirst(1),length(gopos),1)- (gopos(:,1)-barposatfirst(1))*factor(1) ;
    if(factor(2)~=0)
         gopix(:,2)= repmat(coordsatfirst(2),length(gopos),1)-(gopos(:,1)-barposatfirst(2))*factor(2);
    else
        gopix(:,2) = coordsatfirst(2);
    end
    

    barposmat = barposmatall(trialnumind,:);
    ['no trials =' num2str(length(trialnumind))]
    ['no. whisker files =' num2str(length(whisknumind))]
    ['no. meas files =' num2str(length(measnumind))]
    ['length of barposmat =' num2str(length(barposmat))]

end
