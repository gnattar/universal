%% plot theta across trials from a session data

% % % d = '/Volumes/mageelab/GR_dm11/Data/WhiskerImagingData/TestData/Aw/anm161343'
% % % cd(d)
% % % %loadwSigTrials
% % % load barposmat
% % % load sessionInfo

%% sessionInfo.gopos = zeros(4,2)
 %%  sessionInfo.nogopos = barposmat(x,:)

 %% get trial nos
    gopos = sessionInfo.gopos;
    nogopos =  sessionInfo.nogopos;  
    numgotrials = zeros(size(gopos,1),1);
    numnogotrials = [];
    gotrials = [];
    nogotrials = [];
    wAmp = zeros(4,2);
    
    k=0;
    trialnum = [];
    for i =1:length(gopos) 
        temp = find(barposmat(:,1) == gopos(i,1));
        numgotrials(i) = length(temp);
        gotrials(k+1:k+numgotrials(i)) = temp;
        k=k+numgotrials(i);
    end
    nogotrials = find(barposmat(:,1) == nogopos(1,1));
    numnogotrials = length(nogotrials);
    gotrials = gotrials';
 % get trial names 
    nogotrialnames = zeros(length(nogotrials),1);
    gotrialnames = zeros(length(gotrials),1);
    for (i=1:length(nogotrials))
        if(nogotrials(i)>size(wSigTrials))
             break
        end
         filename =char(wSigTrials{nogotrials(i)}.trackerFileName);
         nogotrialnames(i) = str2num(filename(30:33));
    end
    for (i=1:length(gotrials))
        if(gotrials(i)>size(wSigTrials))
             break
        end
         filename =char(wSigTrials{gotrials(i)}.trackerFileName);
         gotrialnames(i) = str2num(filename(30:33));
    end

      
    p =  pwd;
 %% get early
    gotrialstoplot = find(50< gotrialnames & gotrialnames < 150);
    nogotrialstoplot = find(50< nogotrialnames & nogotrialnames < 150);
     %%plot go
    tag = 'goE';
   [wAmpm,wAmpsd] =  plotdetails(wSigTrials,gotrials(gotrialstoplot),gopos,nogopos,tag,p);
    close all;
    wAmp(1,1) = wAmpm;
    wAmp(1,2) = wAmpsd;
      
   %  plotnogo
    tag = 'nogoE';
   [wAmpm,wAmpsd]= plotdetails(wSigTrials,nogotrials(nogotrialstoplot),gopos,nogopos,tag,p); 
    close all;
    wAmp(2,1) = wAmpm;
    wAmp(2,2) = wAmpsd;
    %%   get late
    gotrialstoplot = find(170< gotrialnames & gotrialnames <300);
   nogotrialstoplot = find(170< nogotrialnames & nogotrialnames < 300); 
 
    % plot go
    tag = 'goL';
    [wAmpm,wAmpsd]=plotdetails(wSigTrials,gotrials(gotrialstoplot),gopos,nogopos,tag,p);
    close all;
    wAmp(3,1) = wAmpm;
    wAmp(3,2) = wAmpsd;
    %  plotnogo
    tag = 'nogoL';
   [wAmpm,wAmpsd]= plotdetails(wSigTrials,nogotrials(nogotrialstoplot),gopos,nogopos,tag,p); 
    close all;
    wAmp(4,1) = wAmpm;
    wAmp(4,2) = wAmpsd;
    
% %     save ('wAmp.mat')

    