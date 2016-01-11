
cd ('/Volumes/GR_Ext_Analysis/Analysis/Location preference silencing/Analysis v2/Decoder/Linear DCsub Data')

dec='linear';src='def';train_test=0;proj =0;
load([ d '/145_150430_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','145 150430',train_test,[18.0  10.5 9.0 7.5 6.0],dec,src,1,proj)
clear pooled_contactCaTrials_locdep; close all;
load([ d '/149_150521_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','149 150521',train_test,[ 10.5 9.0 7.5 6.0 ],dec,src,1,proj)
clear pooled_contactCaTrials_locdep;close all;
load([ d '/149_150525_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','149 150525',train_test,[ 10.5 9.0 7.5 6.0 ],dec,src,1,proj)
clear pooled_contactCaTrials_locdep;close all;
load([ d '/149_150529_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','149 150529',train_test,[10.5 9.0 7.5 6.0],dec,src,1,proj)
clear pooled_contactCaTrials_locdep;close all;
load([ d '/149_150602_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','149 150602',train_test,[10.5 9.0 7.5 6.0],dec,src,1,proj)
clear pooled_contactCaTrials_locdep;close all;
load([ d '/156_150711_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','156 150711',train_test,[ 10.5 9.0 7.5 6.0],dec,src,1,proj)
clear pooled_contactCaTrials_locdep;close all;
load([ d '/156_150714_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','156 150714',train_test,[15 10.5 9 7.5 6],dec,src,1,proj)
clear pooled_contactCaTrials_locdep;close all;
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/DC subtraction on PCs/156_150717_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','156 150717',0,[10.5 9 7.5 6],dec,src,1,1)
% clear;close all;
load([ d '/157_150723_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','157 150723',train_test,[15 10.5 9 7.5],dec,src,1,proj)
clear pooled_contactCaTrials_locdep;close all;
load([ d '/158_150712_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','158 150712',train_test,[12 11 10 9 8],dec,src,1,proj)
clear pooled_contactCaTrials_locdep;close all;
load([ d '/158_150718_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','158 150718',train_test,[15 13.5 12 10.5 9 7.5],dec,src,1,proj)
clear pooled_contactCaTrials_locdep;close all;
% 
% cd ('/Volumes/GR_Ext_Analysis/Analysis/Location preference silencing/Analysis v2/Decoder/Linear DCsub PC1')
% 
% dec='linear';src='def';train_test=0;proj =1;
% load([ d '/145_150430_pooled_contactCaTrials_locdep_smth.mat'])
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','145 150430',train_test,[18.0  10.5 9.0 7.5 6.0],dec,src,1,proj)
% clear pooled_contactCaTrials_locdep; close all;
% load([ d '/149_150521_pooled_contactCaTrials_locdep_smth.mat'])
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','149 150521',train_test,[ 10.5 9.0 7.5 6.0 ],dec,src,1,proj)
% clear pooled_contactCaTrials_locdep;close all;
% load([ d '/149_150525_pooled_contactCaTrials_locdep_smth.mat'])
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','149 150525',train_test,[ 10.5 9.0 7.5 6.0 ],dec,src,1,proj)
% clear pooled_contactCaTrials_locdep;close all;
% load([ d '/149_150529_pooled_contactCaTrials_locdep_smth.mat'])
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','149 150529',train_test,[10.5 9.0 7.5 6.0],dec,src,1,proj)
% clear pooled_contactCaTrials_locdep;close all;
% load([ d '/149_150602_pooled_contactCaTrials_locdep_smth.mat'])
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','149 150602',train_test,[10.5 9.0 7.5 6.0],dec,src,1,proj)
% clear pooled_contactCaTrials_locdep;close all;
% load([ d '/156_150711_pooled_contactCaTrials_locdep_smth.mat'])
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','156 150711',train_test,[ 10.5 9.0 7.5 6.0],dec,src,1,proj)
% clear pooled_contactCaTrials_locdep;close all;
% load([ d '/156_150714_pooled_contactCaTrials_locdep_smth.mat'])
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','156 150714',train_test,[15 10.5 9 7.5 6],dec,src,1,proj)
% clear pooled_contactCaTrials_locdep;close all;
% % load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/DC subtraction on PCs/156_150717_pooled_contactCaTrials_locdep_smth.mat')
% % [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','156 150717',0,[10.5 9 7.5 6],dec,src,1,1)
% % clear;close all;
% load([ d '/157_150723_pooled_contactCaTrials_locdep_smth.mat'])
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','157 150723',train_test,[15 10.5 9 7.5],dec,src,1,proj)
% clear pooled_contactCaTrials_locdep;close all;
% load([ d '/158_150712_pooled_contactCaTrials_locdep_smth.mat'])
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','158 150712',train_test,[12 11 10 9 8],dec,src,1,proj)
% clear pooled_contactCaTrials_locdep;close all;
% load([ d '/158_150718_pooled_contactCaTrials_locdep_smth.mat'])
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','158 150718',train_test,[15 13.5 12 10.5 9 7.5],dec,src,1,proj)
% clear pooled_contactCaTrials_locdep;close all;
%%%%%%%%%%%%%%%%%%%%%

%%ctrl data

dec='linear';src='def';train_test=0;
proj =0;
load([d filesep '131_Comb_pooled_contactCaTrials_locdep_Comb_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl','131_150311_12',0,[18.0 12 10.5 9.0 7.5 6.],'linear','def',1,proj)
clear pooled_contactCaTrials_locdep
close all

load([d filesep '136_150330_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl','136_150330',0,[9.0 7.5 6.0 4.5],'linear','def',1,proj)
clear pooled_contactCaTrials_locdep
close all

load([d filesep '136_150403_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl','136_150403',0,[18 10.5 9.0 7.5 6.0 ],'linear','def',1,proj)
clear pooled_contactCaTrials_locdep
close all

load([d filesep '136_150411_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl','136_150411',0,[10.5 9.0 7.5 6.0],'linear','def',1,proj)
clear pooled_contactCaTrials_locdep
close all

load([d filesep '149_150426_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl','149_150426',0,[18.0 12 10.5 9.0 7.5 6.0],'linear','def',1,proj)
clear pooled_contactCaTrials_locdep
close all

load([d filesep '149_150515_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl','149_150515',0,[18.0 12 10.5 9.0 7.5 6.0],'linear','def',1,proj)
clear pooled_contactCaTrials_locdep
close all
