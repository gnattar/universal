
files = dir('*.tif');
num= size(files,1);
fper=zeros(num,1);
frate= zeros(num,1);
for i=1:num
    name = files(i).name;
    [header] = extern_scim_opentif(name);
    fper(i)= header.SI4.scanFramePeriod;
    frate(i)=header.SI4.scanFrameRate;
end