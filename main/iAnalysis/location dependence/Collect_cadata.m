function [] = Collect_cadata()
% [collected_meanRespPref_summary_stats,data] = Collect_meanResp_summary(PrefLocFixed)
%Always have PrefLocFixed=1, doesnt make sense otherwise
%% you need to have run whiskloc_dep_stats & whisk_locdep_plot_contour before this 
% toquickly run them
% [pooled_contactCaTrials_locdep]= whiskloc_dependence_stats(pooled_contactCaTrials_locdep,[1:size(pooled_contactCaTrials_locdep,2)],'re_totaldK','sigpeak', [12 11 10 9 8],0,0);
% for d = 1: size(pooled_contactCaTrials_locdep,2)
%     [ThKmid,R,T,K,Tk,pooled_contactCaTrials_locdep] = whisk_loc_dependence_plot_contour(pooled_contactCaTrials_locdep,d,'re_totaldK','PR',[0 400],'cf',0,[180 210 230 250 270 300]);
% end

collected_cadata = {};
count=0;
def={'136','150322','self'};

ca = []; % get both with fitmean -1  and meanResp - 2
light=[];
poleloc = [];
ka =[];
th = []; 
trlnum=[];
filtdata=[];
mouse=[];
session=[];

info = {};
filename = '';
dendcount = 1;
while(count>=0)
    if strcmp(filename, '');
      [filename,pathName]=uigetfile('*_pooled_contactCaTrials_locdep*.mat','Load pooled data file');
    else
       [filename,pathName]=uigetfile(filename,'Load pooled data file');
    end
    if isequal(filename, 0) || isequal(pathName,0)
        break
    end
    count=count+1;
    load( [pathName filesep filename], '-mat');
    obj = pooled_contactCaTrials_locdep;
    dends = size(obj,2);
  
    for d =1:dends
        
        ca{dendcount} = pooled_contactCaTrials_locdep{d}.sigpeak;      
         light{dendcount} = pooled_contactCaTrials_locdep{d}.lightstim;
        poleloc{dendcount}= pooled_contactCaTrials_locdep{d}.poleloc;
        ka{dendcount}=pooled_contactCaTrials_locdep{d}.re_totaldK;
        th{dendcount}=pooled_contactCaTrials_locdep{d}.Theta_at_contact_Mean;
        trlnum{dendcount}=pooled_contactCaTrials_locdep{d}.trialnum;
        mouse{dendcount}=pooled_contactCaTrials_locdep{d}.mousename;
        session{dendcount}=pooled_contactCaTrials_locdep{d}.sessionname;
        filtdata{dendcount}=pooled_contactCaTrials_locdep{d}.filtdata;
        dendcount =   dendcount+1;
             
        end
end
data.ca=ca;
data.light=light;
data.poleloc=poleloc;
data.ka=ka;
data.th=th;
data.trlnum=trlnum;
data.mouse=mouse;
data.session=session;
data.filtdata=filtdata;
folder = uigetdir;
cd (folder);
save('PooledData','data');

