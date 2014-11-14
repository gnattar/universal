group_Cadata_on_lighteffect
meaneffect.allintarea_L(isnan(meaneffect.allintarea_L(:,1)),:)=0;
netlighteffect = meaneffect.allintarea_NL(:,1)-meaneffect.allintarea_L(:,1);
sd = floor(min([nanstd(meaneffect.allintarea_NL(:,1))/sqrt(size(meaneffect.allintarea_NL,1));nanstd(meaneffect.allintarea_L(:,1))/sqrt(size(meaneffect.allintarea_L,1))]))*2;

dlmwrite('Dist net light effect.txt',netlighteffect,'delimiter',',')

Silenced_Cells = find((netlighteffect>sd));
Opp_Cells = find((netlighteffect<-sd))
IncOrNochange_Cells = find((netlighteffect<sd))
SilencedOrNochange_Cells = find((netlighteffect<-sd))

dlmwrite('Dist SilencedOrNochange Cells.txt',SilencedOrNochange_Cells,'delimiter',',')
dlmwrite('Dist IncOrNochange Cells.txt',IncOrNochange_Cells,'delimiter',',')
dlmwrite('Dist Inc Cells.txt',Opp_Cells,'delimiter',',')
dlmwrite('Dist Silenced Cells.txt',Silenced_Cells,'delimiter',',')

pooled_contact_CaTrials_SilencedOrNochange = pooled_contact_CaTrials(SilencedOrNochange_Cells);
save('SilencedOrNochange_Dist_pooled_contact_CaTrials','pooled_contact_CaTrials_SilencedOrNochange');
