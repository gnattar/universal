function formatForSpark_justImages(direc, wc, numChans, channelNum, cropp)
 
 
opt.numchannels=numChans;
opt.channel=channelNum;
opt.justHdr=0;
 
files=dir([direc filesep '*' wc '*.tif']);
 
%get info on first image
 
InfoImage=imfinfo([direc filesep files(1).name]);
numFiles=numel(files);
 
%for datasize, assume all images look like the first
DataSize(1)=InfoImage(1).Width;
DataSize(2)=InfoImage(1).Height;
 
%prepare output vector for these subfiles
if ~isempty(cropp)
    tmp=zeros(DataSize(1),DataSize(2));
    tmp=imcrop(tmp,cropp);
 
    DataSize(1)=size(tmp,1);
    DataSize(2)=size(tmp,2);
end
 
 
finalData_si=zeros(DataSize(1)*DataSize(2),((numel(InfoImage)/numChans)*numFiles),'double');
 
%loop to populate array with image data
imCountBegin=1;
for ii=1:numFiles
    ii
    %%%SCANIMAGE DATA%%%
    
    %load the stack
    FileTif=[direc filesep files(ii).name];
    opt.data_type='double';
    [im improps] = load_image(FileTif, -1, opt);
   
    
    %crop if necessary
    if ~isempty(cropp)
        im=im(cropp(2):cropp(2)+cropp(4),cropp(1):cropp(1)+cropp(3),1:end);
    end
   
    %mImage=improps.width;
    mImage=size(im,1);
    %nImage=improps.height;
    nImage=size(im,2);
    NumberImages=size(im,3);
    imCountEnd=imCountBegin+(NumberImages-1);
    
    finalData_si(:,imCountBegin:imCountEnd)=reshape(im,mImage*nImage,NumberImages);
    
    imCountBegin=imCountEnd+1;
    
end
 
 
%make pixel identity matrix
colIndsPix=repmat(1:DataSize(1),1,DataSize(2));
rowIndsPix=repmat(1:DataSize(2),[DataSize(1),1]);
rowIndsPix=rowIndsPix(:);
z=ones(size(rowIndsPix));
 
F = [colIndsPix' rowIndsPix z finalData_si];
 
%write the data
size(finalData_si)
 
f=fopen([direc filesep 'sparkImOut.bin'],'w');
fwrite(f,F','uint16');
 
close all
clear all
end
 
