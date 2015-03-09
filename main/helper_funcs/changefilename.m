function changefilename(d)

files = dir('*.xsg');


%% to change file number for new = old +1; !!!!  i =length(files):-1:1
%% if new = old-1 change iteration to 1:length(files) !!!!
% 
% for  i =length(files):-1:1
%     name = files(i).name;
%     uscores = find(ismember(name,'_'));
%     num = name(uscores(4)+1:uscores(5)-1);
%     newnum = str2num(num)+1;
%     if (newnum < 10)
%         nn = ['000' num2str(newnum)];
%     elseif (newnum < 100)
%         nn = ['00' num2str(newnum)];
%     else
%         nn = ['0' num2str(newnum)];
%     end
%     newname = strrep(name,['_' num '_'],['_' nn '_']);
%     java.io.File(name).renameTo(java.io.File(newname))
% 
% end
%% to change date number
% for i =length(files):-1:1
%     name = files(i).name;
%     uscores = find(ismember(name,'_'));
%     datenum = name(uscores(3)+1:uscores(3)+2);
%     newdatenum = '03';
%     newname = strrep(name,datenum,newdatenum);
%     java.io.File(name).renameTo(java.io.File(newname))
% end

% to trial number
for i =9:length(files)
    name = files(i).name;
    trialnum = name(12:14);
    newnum = ['0' num2str(str2num(trialnum)-24)];
    newname = strrep(name,trialnum,newnum);
    java.io.File(name).renameTo(java.io.File(newname))
end