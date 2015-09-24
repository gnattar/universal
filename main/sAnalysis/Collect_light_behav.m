function [data] = Collect_light_behav()

collected_data = {};
count=0;
filename = '';

while(count>=0)
    
    if strcmp(filename, '');
        [filename,pathName]=uigetfile('*sorted_CaTrials*.mat','Load sorted_CaTrials.mat file');
    else
        [filename,pathName]=uigetfile(filename,'Load sorted_CaTrials.mat file');
    end
    if isequal(filename, 0) || isequal(pathName,0)
        break
    end
    count=count+1;
    load( [pathName filesep filename], '-mat');
    cd (pathName);
    
    i = count;
    fa = sorted_CaTrials.faTNames;
    cr = sorted_CaTrials.crTNames;
    l = sorted_CaTrials.lightstimTNames;
    nl = sorted_CaTrials.nolightstimTNames;
    miss = sorted_CaTrials.missesTNames;
    hit = sorted_CaTrials.hitTNames; 
    touch = sorted_CaTrials.touchTNames;
    notouch = sorted_CaTrials.notouchTNames;
    
    nogo = sort([fa ;cr]);
    go = sort([ hit;miss]);
    
    go_discrim = intersect(go,touch);
    nogo_discrim = intersect(nogo,touch);
    
    cr_discrim = intersect(cr,touch);
    fa_discrim = intersect(fa,touch);
    
    hit_discrim = intersect(hit,touch);
    miss_discrim = intersect(miss,touch);
    
    cr_discrim_l = intersect(cr_discrim,l);
    cr_discrim_nl = intersect(cr_discrim,nl);
    
    fa_discrim_l = intersect(fa_discrim,l);
    fa_discrim_nl = intersect(fa_discrim,nl);
    
    hit_discrim_l = intersect(hit_discrim,l);
    hit_discrim_nl = intersect(hit_discrim,nl);
    
    miss_discrim_l = intersect(miss_discrim,l);
    miss_discrim_nl = intersect(miss_discrim,nl);
    
    go_discrim_l = intersect(go_discrim,l);
    go_discrim_nl = intersect(go_discrim,nl);
    
%     hit_l = intersect(hit,l);
%     hit_nl = intersect(hit,nl);
%     miss_l = intersect(miss,l);
%     miss_nl = intersect(miss,nl);

%     fa_l=intersect(fa,l);
%     fa_nl=intersect(fa,nl);
%     cr_l=intersect(cr,l);
%     cr_nl=intersect(cr,nl);
%     nogo_l = intersect(nogo,l);
%     nogo_nl = intersect(nogo,nl);
    nogo_discrim_l = intersect(nogo_discrim,l);
    nogo_discrim_nl = intersect(nogo_discrim,nl);
    
    totaltrials_l = length(nogo_discrim_l)+length(go_discrim_l);
    totaltrials_nl = length(nogo_discrim_nl)+length(go_discrim_nl);
    nogo_discrim_rate (i,1) = length(cr_discrim_nl)./(length(cr_discrim_nl)+length(fa_discrim_nl));
    nogo_discrim_rate (i,2) = length(cr_discrim_l)./(length(cr_discrim_l)+length(fa_discrim_l));
    
    farate(i,1) = length(fa_discrim_nl)./length(nogo_discrim_nl);
    farate(i,2) = length(fa_discrim_l)./length(nogo_discrim_l);
    
    hitrate(i,1) = length(hit_discrim_nl)./length(go_discrim_nl);
    hitrate(i,2) = length(hit_discrim_l)./length(go_discrim_l);

    
    num_hittrials(i,1) = length(hit_discrim_nl);
    num_hittrials(i,2) = length(hit_discrim_l);
    num_misstrials (i,1) = length(miss_discrim_nl);
    num_misstrials (i,2) = length(miss_discrim_l); 
    
    num_fatrials(i,1) = length(fa_discrim_nl);
    num_fatrials(i,2) = length(fa_discrim_nl);
    num_crtrials (i,1) = length(cr_discrim_nl);
    num_crtrials (i,2) = length(cr_discrim_l);   
    
    num_gotrials(i,1) = length(go_discrim_nl);
    num_gotrials(i,2) = length(go_discrim_l);
    num_nogotrials (i,1) = length(nogo_discrim_nl);
    num_nogotrials (i,2) = length(nogo_discrim_l);
    
    num_correcttrials(i,1) = length(hit_discrim_nl) + length(cr_discrim_nl) ;
    num_correcttrials(i,2) = length(hit_discrim_l) + length(cr_discrim_l);
    num_incorrecttrials (i,1) = length(miss_discrim_nl) + length(fa_discrim_nl) ;
    num_incorrecttrials (i,2) = length(miss_discrim_l) + length(fa_discrim_l) ;
    
    dprime(i,1) = Solo.dprime(hitrate(i,1) ,farate(i,1),num_gotrials(i,1),num_nogotrials (i,1));
    dprime(i,2) = Solo.dprime(hitrate(i,2) ,farate(i,2),num_gotrials(i,2),num_nogotrials (i,2));
    
    PC(i,1) = num_correcttrials(i,1)./(num_gotrials(i,1)+num_nogotrials(i,1));
    PC(i,2) = num_correcttrials(i,2)./(num_gotrials(i,2)+num_nogotrials(i,2));
    
    fName{i} = filename;
    
end

data.farate = farate;
data.hitrate = hitrate;
data.num_hittrials = num_hittrials;
data.num_misstrials = num_misstrials;
data.num_fatrials = num_fatrials;
data.num_crtrials = num_crtrials;
data.num_gotrials = num_gotrials;
data.num_nogotrials = num_nogotrials;
data.num_correcttrials = num_correcttrials;
data.num_incorrecttrials = num_incorrecttrials;
data.nogo_discrim_rate = nogo_discrim_rate;
data.dprime = dprime;
data.PC = PC;
data.filename = fName;


folder = uigetdir;
cd (folder);
save('Behav data NL L','data');

%% quick plot
%% 
figure;
[h,p]=ttest(data.dprime(:,1)-data.dprime(:,2))

m=mean(data.dprime);
 sd=std(data.dprime)./sqrt(size(data.filename,2)+1);
subplot(1,2,1); plot(data.dprime','color',[.5 .5 .5]); hold on; 
 e=errorbar(m,sd,'ko-','markersize',6);
 set(e,'linewidth',1.5,'markersize',10);
 text(1.5,.8,['p=' num2str(p)]);
 title('dprime')
 
 [h,p]=ttest(data.PC(:,1)-data.PC(:,2))
 m=mean(data.PC);
 sd=std(data.PC)./sqrt(size(data.filename,2)+1);
 subplot(1,2,2);plot(data.PC','color',[.5 .5 .5]); hold on; 
 e=errorbar(m,sd,'ko-','markersize',6);
 set(e,'linewidth',1.5,'markersize',10);
 text(1.5,.75,['p=' num2str(p)]);
 title('PC')
%  
%  [h,p]=ttest(data.nogo_discrim_rate(:,1),data.nogo_discrim_rate(:,2))
%  m=mean(data.nogo_discrim_rate);
%  sd=std(data.nogo_discrim_rate)./sqrt(size(data.filename,2)+1);
%  subplot(1,3,3);plot(data.nogo_discrim_rate','color',[.5 .5 .5]); hold on; 
%  e=errorbar(m,sd,'ko-','markersize',6);
%  set(e,'linewidth',1.5);
%  text(1.5,.65,['p=' num2str(p)]);
%  title('Nogo discrim')
 
