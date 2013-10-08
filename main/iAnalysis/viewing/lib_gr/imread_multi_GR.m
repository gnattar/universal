function [im, header] = imread_multi_GR(filename, channel)
% Input: filename - scanimage tiff file name.
%        channel - 'g' or 'green', 'r' or 'red'
% Output: im - uint16 image matrix
%         header - scanimage header info.
%
% NX 3/11/2009

finfo = imfinfo(filename); 
if isfield(finfo, 'ImageDescription')
   % header = parseHeader(finfo(1).ImageDescription);  %%GRchange 19/7/2012
   [header] = extern_scim_opentif(filename); %%GRchange 19/7/2012

      n_channel = length(header.SI4.channelsSave);
%     header.width = header.acq.pixelsPerLine;
%     header.height = header.acq.linesPerFrame;

    header.n_frame = length(finfo);
end

%for now using this only after registration so always n_channel = 1

 n_channel = 1;
        
header.width = finfo(1).Width;
header.height = finfo(1).Height;
if nargin>1 || n_channel > 1
    if strncmpi(channel, 'g', 1)
        firstframe = 1;
        step = n_channel;
    elseif strncmpi(channel, 'r', 1)
        firstframe = 2;
        step = n_channel;
    else
        error('unknown channel name?')
        
    end
else
    firstframe = 1;
    step = 1;
end

im = zeros(header.height, header.width, header.n_frame/step, 'uint16');

count = 0;
for i = firstframe : step : length(finfo)
    count = count+1;
    im (:,:,count) = imread(filename, i);
end;