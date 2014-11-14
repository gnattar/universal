% collect_snr(obj)

count = 1;
count_L =1;
count_NL=1;
alln_L = [];
alln_NL = [];
for i = 1:size(obj,2)
    samplingtime = obj{i}.FrameTime;
    inds = [1: round(0.7/samplingtime)];
    n{i} = nanstd(obj{i}.rawdata(:,inds),[],2);

    m{i} = nanmean(obj{i}.rawdata(:,inds),2);
    num= length( n{i} );
    alln(count:count+num-1) = nanstd(obj{i}.rawdata(:,inds),[],2);
    allm(count:count+num-1) = nanmean(obj{i}.rawdata(:,inds),2);
    l = find(obj{i}.lightstim==1);
    nl = find(obj{i}.lightstim==0);
    
    nL{i}=nanstd(obj{i}.rawdata(l,inds),[],2);
    nNL{i}=nanstd(obj{i}.rawdata(nl,inds),[],2);
    
    alln_L(count_L:count_L+length(l)-1) = nanstd(obj{i}.rawdata(l,inds),[],2);
    allm_L(count_L:count_L+length(l)-1) = nanmean(obj{i}.rawdata(l,inds),2);  
       
    alln_NL(count_L:count_L+length(nl)-1) = nanstd(obj{i}.rawdata(nl,inds),[],2);
    allm_NL(count_L:count_L+length(nl)-1) = nanmean(obj{i}.rawdata(nl,inds),2);  
    count = count+num +1;
    count_L = count_L + length(l);
    count_NL = count_NL + length(nl);
    
end
    
hNLn = histnorm(alln_NL,[0:50]);
hLn = histnorm(alln_L,[0:50]);
h = hist(alln,[0:50]);
hn = histnorm(alln,[0:50]);
hL = hist(alln_L,[0:50]);
hNL = hist(alln_NL,[0:50]);

figure;plot([0:50],h,'b');hold on; plot([0:50],hL,'r');hold on ; plot([0:50],hNL,'k')
figure;plot([0:50],hn,'b');hold on; plot([0:50],hLn,'r');hold on ; plot([0:50],hNLn,'k')
figure;

for i = 1:length(nL)
    plot(repmat(i,length(nL{i}),1),nL{i},'r*');hold on;
end

figure;
for i = 1:length(nNL)
    plot(repmat(i,length(nNL{i}),1),nNL{i},'k*');hold on;
end