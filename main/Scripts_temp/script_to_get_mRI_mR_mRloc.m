mRI{n} = cellfun(@(x) x.meanResp.NL_locPI,pooled_contactCaTrials_locdep,'uni',0)';
mRloc {n}= cellfun(@(x) x.meanResp.NL_PrefLoc,pooled_contactCaTrials_locdep,'uni',0)';
mR {n}= cellfun(@(x) max(x.meanResp.NL),pooled_contactCaTrials_locdep,'uni',0)';

mR_a=cell2mat([mR{1};mR{2};mR{3};mR{4};mR{5};mR{6};mR{7};mR{8};mR{9};mR{10};mR{11};mR{12};mR{13}]);
mRloc_a=cell2mat([mRloc{1};mRloc{2};mRloc{3};mRloc{4};mRloc{5};mRloc{6};mRloc{7};mRloc{8};mRloc{9};mRloc{10};mRloc{11};mRloc{12};mRloc{13}]);
mRI_a=cell2mat([mRI{1};mRI{2};mRI{3};mRI{4};mRI{5};mRI{6};mRI{7};mRI{8};mRI{9};mRI{10};mRI{11};mRI{12};mRI{13}]);