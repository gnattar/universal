
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

cd ('/Volumes/GR_Ext_Analysis/Analysis/Location preference silencing/Analysis v2/Decoder/Linear DCsub PC1')

dec='linear';src='def';train_test=0;proj =1;
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
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/Linear with PCs/145_150430_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'ctrl_mani','145 150430',0,[18.0  10.5 9.0 7.5 6.0],'linear','def',0,1)
% clear
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/Linear with PCs/149_150521_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'ctrl_mani','149 150521',0,[ 10.5 9.0 7.5 6.0 ],'linear','def',0,1)
% clear
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/Linear with PCs/149_150525_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','149 150525',0,[ 10.5 9.0 7.5 6.0 ],'linear','def',1,1)
% clear
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/Linear with PCs/149_150529_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','149 150529',0,[10.5 9.0 7.5 6.0],'linear','def',1,1)
% clear
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/Linear with PCs/149_150602_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','149 150602',0,[10.5 9.0 7.5 6.0],'linear','def',1,1)
% clear
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/Linear with PCs/156_150711_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','156 150711',0,[ 10.5 9.0 7.5 6.0],'linear','def',1,1)
% clear
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/Linear with PCs/156_150714_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','156 150714',0,[15 10.5 9 7.5 6],'linear','def',1,1)
% clear
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/Linear with PCs/156_150717_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','156 150717',0,[10.5 9 7.5 6],'linear','def',1,1)
% clear
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/Linear with PCs/157_150723_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','157 150723',0,[15 10.5 9 7.5],'linear','def',1,1)
% clear
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/Linear with PCs/158_150712_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','158 150712',0,[12 11 10 9 8],'linear','def',1,1)
% clear
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/Linear with PCs/158_150718_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','158 150718',0,[15 13.5 12 10.5 9 7.5],'linear','def',1,1)
% 
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/DC subtraction on PCs/145_150430_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','145 150430',0,[18.0  10.5 9.0 7.5 6.0],'linear','NC',1,1)
% clear;close all;
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/DC subtraction on PCs/149_150521_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','149 150521',0,[ 10.5 9.0 7.5 6.0 ],'linear','NC',1,1)
% clear;close all;
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/DC subtraction on PCs/149_150525_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','149 150525',0,[ 10.5 9.0 7.5 6.0 ],'linear','NC',1,1)
% clear;close all;
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/DC subtraction on PCs/149_150529_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','149 150529',0,[10.5 9.0 7.5 6.0],'linear','NC',1,1)
% clear;close all;
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/DC subtraction on PCs/149_150602_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','149 150602',0,[10.5 9.0 7.5 6.0],'linear','NC',1,1)
% clear;close all;
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/DC subtraction on PCs/156_150711_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','156 150711',0,[ 10.5 9.0 7.5 6.0],'linear','NC',1,1)
% clear;close all;
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/DC subtraction on PCs/156_150714_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','156 150714',0,[15 10.5 9 7.5 6],'linear','NC',1,1)
% clear;close all;
% % load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/DC subtraction on PCs/156_150717_pooled_contactCaTrials_locdep_smth.mat')
% % [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','156 150717',0,[10.5 9 7.5 6],'linear','NC',1,1)
% % clear;close all;
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/DC subtraction on PCs/157_150723_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','157 150723',0,[15 10.5 9 7.5],'linear','NC',1,1)
% clear;close all;
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/DC subtraction on PCs/158_150712_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','158 150712',0,[12 11 10 9 8],'linear','NC',1,1)
% clear;close all;
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/DC subtraction on PCs/158_150718_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','158 150718',0,[15 13.5 12 10.5 9 7.5],'linear','NC',1,1)