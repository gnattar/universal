% 
% 
% c=['r','g','b','m','k'];figure;
% for anm=1:5
%     count=0;
%     for sess= 1:6
%    temp1= wSigSum_anm{1,anm}.amp{sess,1};
%    temp2= temp1(~isnan(temp1));
% 
%    windowSize=25;
%    temp1=filter(ones(1,windowSize)/windowSize,1,temp1);
%    plot([count+1:count+length(temp1)],temp1,'color',c(anm),'linewidth',2); hold on;
%    count= count+length(temp1);
%    end
%     
% end
% 
 bl=12.78; 
%  bl= 5.61;
% bl= 9.125;
% bl= 8.69;
% bl= 7.18;
    
    

%  h_fig1=figure;ah1=axes('Parent',h_fig1);
%  h_fig2=figure;ah2=axes('Parent',h_fig2);
figure;
 count=0;
for i=1:6
   s= wSigSum_Sessions.setpoint{i,1}(:,1);
   s=s-bl;
   a= wSigSum_Sessions.amp{i,1}(:,1);
   windowSize=25;
   a=filter(ones(1,windowSize)/windowSize,1,a);
   l=s-a/2;
   u=s+a/2;

%    axes(ah1); 
%    jbfill([count+26:count+length(s)],u(26:end)',l(26:end)',[.5 .5 .5],[.5 .5 .5],1,.5); hold on;
    plot([count+26:count+length(s)],s(26:end),'color','b','linewidth',2);hold on;
    x=[count+26:count+length(s)];
%     plotyy(x,s(26:end),x,a(26:end));hold on;
%    axes(ah2); 
     plot([count+26:count+length(a)],a(26:end),'color','r','linewidth',2);hold on;
    
   count=count+1+length(s);
end




