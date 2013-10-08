function A = scanfile(file)
fid=fopen(file);
ln=0;
while 1
    ln=ln+1;
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    if ln==5, % get number of satellites in first header
        %disp(tline); 
        A=str2num(tline);break;
    end
end
fclose(fid);
