function changefilename(d)
files = dir('WDBP*');
for i =length(files):-1:1
    name = files(i).name;
    uscores = find(ismember(name,'_'));
    num = name(uscores(4)+1:uscores(5)-1);
    newnum = str2num(num)+1;
    if (newnum < 10)
        nn = ['000' num2str(newnum)];
    elseif (newnum < 100)
        nn = ['00' num2str(newnum)];
    else
        nn = ['0' num2str(newnum)];
    end
    newname = strrep(name,['_' num '_'],['_' nn '_']);
    java.io.File(name).renameTo(java.io.File(newname))

end
