p=pooled_contactCaTrials_locdep{1}.poleloc;
unique(p)
 
 
 load('/Users/ranganathang/Documents/MATLAB/universal/main/helper_funcs/mycmap3.mat');
 d = 2;
  t=find(p == 335);
  
 tempca = pooled_contactCaTrials_locdep{d}.filtdata(t,:);
   temp = cell2mat(pooled_contactCaTrials_locdep{d}.touchdeltaKappa(t));
   notnan = find(~isnan(temp(1,:)));
   tempka  = temp(:,notnan);
 l = pooled_contactCaTrials_locdep{d}.lightstim(t);
%  l = l.*400;
%  tempca(find(l==0),1) = l;
 figure;subplot(2,2,1);imagesc(tempca(find(l==0),:),[0 200]); title('NL');subplot(2,2,2);imagesc(tempca(find(l==1),:),[0 200]); colormap(mycmap3); title('L')
 subplot(2,2,3);imagesc(abs(tempka(find(l==0),:)),[0 4]); title('NL dK');subplot(2,2,4);imagesc(abs(tempka(find(l==1),:)),[0 4]); title('L dK'); colormap(mycmap3)
 suptitle(['cell ' num2str(d)]);
 