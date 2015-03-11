function [collected_data,collected_summary] = Collect_Contact_CaTrials_data()
% global collected_data
% global collected_summary
collected_data = {};
collected_summary = {};
% basedatapath = get(handles.contact_Sig_datapath,'String');
% if(length(basedatapath)<10)
%     basedatapath = '/Volumes/';
% end
% cd (basedatapath);
count=0;
  def={'131','150227','1','1','5:13,15,16,18,21,22,24,29,31,32,34,35,40,42,44,53,54,59,61,65,68,70,75,81,82,83,90,92,96'};
while(count>=0)
    [filename,pathName]=uigetfile('contact_CaTrial*.mat','Load contact_CaTrials*.mat file');
    if isequal(filename, 0) || isequal(pathName,0)
        break
    end
    count=count+1;
    load( [pathName filesep filename], '-mat');
    %     set(handles.wSigSum_datapath,'String',pathName);
    cd (pathName);
    prompt={'Mouse name','Session name','Reg','Fov','Enter the dends to collect'};
    name='Dends to collect';
    numlines=5;
   
    d = inputdlg(prompt,name,numlines,def) ;
    def=d;
    collected_summary{count}.mousename = d{1}; 
	collected_summary{count}.sessionname = d{2}; 
    collected_summary{count}.reg = str2num(d{3}); 
	collected_summary{count}.fov = str2num(d{4}); 
    collected_summary{count}.dends =str2num(d{5}); 
    
    dends =  str2num(d{5});
    all = [1:size(contact_CaTrials(1).dff,1)];
    rem = setxor(all,dends);
    temp = contact_CaTrials;
    for i = 1:size(contact_CaTrials,2)
        temp(i).dff(rem,:) = [];
    end
    collected_data{count} = temp;
   
end
folder = uigetdir;
cd (folder);
save('collected_data','collected_data');
save ('collected_summary','collected_summary');