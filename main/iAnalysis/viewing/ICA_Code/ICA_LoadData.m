function AllData = ICA_LoadData(DataDir,FileBaseName,FileNums,Twindow)
% function AllData = LoadData(BaseDir, FileNums)
% function AllData = LoadData(FileNum)
% Simple function to process multiple tiff files and output
% a concantenated data

% Shaul Druckmann, JFRC, February 2010

AllData = [];
DataSize = [256 256]; %initialize
files = dir([DataDir filesep FileBaseName '*.tif']);

 if ~exist('FileNums','var')
    FileNums = 1: length(files);
 elseif length(FileNums)>length(files)
    FileNums = 1: length(files); 
 end
 
 hw = waitbar(0, 'Loading Imaging data ...');

for ii=1:length(FileNums)

 [Aout,header] = imread_multi_GR(fullfile(DataDir, files(FileNums(ii)).name),'g');
 if header.SI4.fastZEnable
     tpts = round(Twindow / header.SI4.fastZPeriod);
 elseif (~header.SI4.fastZEnable)
     tpts = round(Twindow / header.SI4.scanFramePeriod);
 end
 frames = tpts(1) : tpts(2);
  Aout = double(Aout(:,:,frames));
  DataSize = [size(Aout,1) size(Aout,2)];
  AllData = [AllData; reshape(Aout,DataSize(1)*DataSize(2)...
    ,size(Aout,3))'];

  waitbar(ii/length(FileNums), hw, sprintf('Loading Imaging data, %d/%d trials', ii, length(FileNums)));  
end
 delete(hw)
