for i = 34 :-1:11
oldname = names(i).name;
oldname = strrep(oldname,'.mp4','')
newname = strrep(oldname,num2str(nums(i)),num2str(nums(i)+1))

java.io.File(strcat(oldname,'.mp4')).renameTo(java.io.File(strcat(newname,'.mp4')));
java.io.File(strcat(oldname,'.measurements')).renameTo(java.io.File(strcat(newname,'.measurements')));
java.io.File(strcat(oldname,'.whiskers')).renameTo(java.io.File(strcat(newname,'.whiskers')));
java.io.File(strcat(oldname,'.seq.xml')).renameTo(java.io.File(strcat(newname,'.seq.xml')));
end