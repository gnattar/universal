function [peak]=spike_detect4(filt)
fs=10000;

sd=std(filt);

%add iircomb notch filter here!! to remove 60Hz noise
% th=prctile(filt,99.995);   %threshold
% th=0.4;
h=figure;
plot(filt)
[x th]=ginput(1)
% close(h)

%%
peak=zeros(size(filt));
ind=find(filt>th);
for i=1:length(ind)
     start=ind(i)-20;
     stop=ind(i)+20;
     if start<1
         start=1;
     end
     if stop>length(filt)
         stop=length(filt);
     end
     M=max(filt(start:stop));
     m=min(filt(start:stop));
     if filt(ind(i))==M
         if M>m
             peak(ind(i))=1;            
         end
     end
     
end

% figure;subplot(1,2,1);plot(filt,'r');hold on;plot(peak);

%
% peak1=(filt>[filt(2:end);filt(end)])&(filt>[filt(1);filt(1:(end-1))])&(filt>th)&(filt<10);
% figure;plot(filt,'r');hold on;plot(peak1);

%%

% subplot(1,2,2);plot(peak_bin);

%%
ind=find(peak);
ind(ind<30)=[];
% ind(ind>(length(filt)-30))=[];
% waveform=zeros(61,length(ind));
waveform=zeros(26,length(ind));
for i=1:(length(ind)-1)   
%     waveform(:,i)=filt(ind(i)+(-30:30));
    waveform(:,i)=filt(ind(i)+(-5:20));
    waveform(:,i)=waveform(:,i)-mean(waveform(:,i));
end

ntemplate=min(20,size(waveform,2));
peak_value=max(waveform);
[v,idx]=sort(peak_value,'descend');
% template=waveform(:,idx(1:20));
template=waveform(:,idx(1:ntemplate));
template=mean(template,2);
template=template-mean(template);
template=template/norm(template);
proj=waveform'*template;
% res=waveform-template*proj';
% res=sqrt(sum(res.^2));

% th=kmean1D_threshold(proj,0.05);
 th=1
% th=kmean1D_threshold(proj,0.5);
dprime=(mean(proj(proj>th))-mean(proj(proj<th)))/std(proj(proj<th))
% th=3;
figure;
hist(proj,100);
hold on;
plot([th,th],[0,100],'r');

idx=proj>th;


% pc2=v(:,2);
% sd=std(pc2);
% idx(abs(pc2)>4*sd)=0;

subplot(2,3,1);hold on;
nspike=sum(idx==1);
middle=round(nspike/2);
if middle==0 %patch by Hod 20150630
    middle=1;
end
sp=find(idx==1);
noise=find(idx==0);
for i=1:length(sp)
%     plot(v(sp(i),1)*s(1),v(sp(i),2)*s(2),'.','color',[i/nspike,1-i/nspike,0]);
    plot(proj(sp(i),1),0,'.','color',[i/nspike,1-i/nspike,0]);
end
hold on;
% plot(v(noise,1)*s(1),v(noise,2)*s(2),'.k');
plot(proj(noise,1),0,'.k');



for i=1:length(ind)      
    waveform(:,i)=waveform(:,i)-mean(waveform(1:20,i));
end
if length(sp)>1
subplot(2,3,2);
plot(mean(waveform(:,sp(1:middle)),2),'g');
hold on;
plot(mean(waveform(:,sp(middle:end)),2),'r');
plot(mean(waveform(:,noise),2),'k');
end


subplot(2,3,3);hold on;
plot(waveform(:,noise),'color',[1,1,1]*0.5);
plot(waveform(:,sp),'color','r');
peak=zeros(size(filt));
peak(ind(sp))=1;

subplot(2,3,4:6);
plot(ind(sp)/fs,proj(sp,1),'.r');hold on;
plot(ind(noise)/fs,proj(noise,1),'.k');
