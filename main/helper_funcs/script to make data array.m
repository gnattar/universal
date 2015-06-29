%% script to make data array for Jeremy
for d = 1: 36

cadata=pooled_contactCaTrials_locdep{d}.filtdata';
cadata = reshape(cadata,1,364*76);

temp = cell2mat(cellfun(@(x) x,pooled_contactCaTrials_locdep{d}.touchdeltaKappa,'uniformoutput',0));
ind = ~isnan(temp(1,:));
temp =temp(:,ind);
temp=temp';
s = [1:16.4474:455000]';e = s+16.4474;
s=floor(s);e=floor(e); e(end) = 455000;
kdataabs=abs(reshape(temp,1,364*1250));
for i = 1:27664
    kdatafilt(i) = max(kdataabs(s(i):e(i)));
end


ptemp=pooled_contactCaTrials_locdep{d}.poleloc;
p=repmat(ptemp,1,76)';
poledata=reshape(p,1,76*364);

data(1,:,d) = cadata;
data(2,:,d)=kdatafilt;
data(3,:,d) = poledata;

end