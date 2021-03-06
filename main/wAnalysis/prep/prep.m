function [barposmat]= prep(d,saved_history)
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

pos = saved_history.MotorsSection_motor_position;
barpos = cell2mat(pos);
barpos = round(barpos/1000)/10;
%yscaling 10.6e5 = 270pxls
%xscaling 10.6e5 = 20pxls

%GR rig 2c373 120710
coordsatzero = [418 , 317];
coordsatnext = [122, 317];
barposatnext = 12;


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


diff = abs(coordsatzero-coordsatnext);
barposmatall = zeros(length(barpos),2);

barposmatall(:,1) = repmat(coordsatzero(1),length(barpos),1)-(diff(1)*(barpos(:,1)./barposatnext));
barposmatall(:,2) = repmat(coordsatzero(2),length(barpos),1)-(diff(2)*(barpos(:,1)./barposatnext));

%2Prig NX 051712
% % % barposmatall(:,1) = repmat(coordsatzero(1),length(barpos),1)+(diff(1)*(barpos(:,1)./barposatnext));
% % % barposmatall(:,2) = repmat(coordsatzero(2),length(barpos),1)+(diff(2)*(barpos(:,1)./barposatnext));

barposmatall=round(barposmatall);

barposmat = barposmatall(trialnumind,:);
['no trials =' num2str(length(trialnumind))]
['no. whisker files =' num2str(length(whisknumind))]
['no. meas files =' num2str(length(measnumind))]
['length of barposmat =' num2str(length(barposmat))]

end
