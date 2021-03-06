function [obj] = ephusTrialArray_gr(mouseName, sessionName,ephuspath)
% obj = ephusTrialArray_gr(mouseName, sessionName,ephuspath);%
cd (ephuspath);
files=dir('*.xsg');
obj=struct('licks',{},'poleposition',{},'bitcode',{},'trialname',{},'ephusstep',{},'photostimV',{},'photostimPD',{});
for i=1:length(files)
    fname = files(i).name;
    try
       load(fname,'-mat');
       numsamples = length(data.acquirer.trace_1);
       obj(i).licks=data.acquirer.trace_1;
       obj(i).bitcode=data.acquirer.trace_2;
       obj(i).poleposition=data.acquirer.trace_4;
       obj(i).trialname = fname(length(fname)-7:length(fname)-4);
       obj(i).ephuststep = [1:numsamples]/header.acquirer.acquirer.sampleRate;
       if ~isempty(data.acquirer.trace_3)
            obj(i).photostimV = data.acquirer.trace_3;
       end
       if ~isempty(data.acquirer.trace_5)
            obj(i).photostimPD = data.acquirer.trace_5;
       end
       
    catch
       numsamples=0;
       obj(i).licks=[];
       obj(i).bitcode=[];
       obj(i).poleposition=[];
       obj(i).trialname = fname(length(fname)-7:length(fname)-4);
       obj(i).ephuststep = [];
    end
end
