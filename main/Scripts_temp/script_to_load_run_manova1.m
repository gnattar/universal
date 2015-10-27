
dec='linear';src='def';train_test=0;plot_on =1; 
%%[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder_manova1(pooled_contactCaTrials_locdep,par,cond,str,train_test,pos,disc_func,src,plot_on)

load([ d '/145_150430_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder_manova1(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','145 150430',train_test,[18.0  10.5 9.0 7.5 6.0],dec,src,plot_on)
clear pooled_contactCaTrials_locdep; close all;

load([ d '/149_150521_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder_manova1(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','145 150521',train_test,[10.5 9.0 7.5 6.0],dec,src,plot_on)
clear pooled_contactCaTrials_locdep;close all;

load([ d '/149_150525_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder_manova1(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','149 150525',train_test,[10.5 9.0 7.5 6.0 ],dec,src,plot_on)
clear pooled_contactCaTrials_locdep;close all;

load([ d '/149_150529_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder_manova1(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','149 150529',train_test,[10.5 9.0 7.5 6.0],dec,src,plot_on)
clear pooled_contactCaTrials_locdep;close all;

load([ d '/149_150602_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder_manova1(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','149 150602',train_test,[10.5 9.0 7.5 6.0],dec,src,plot_on)
clear pooled_contactCaTrials_locdep;close all;

load([ d '/156_150711_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder_manova1(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','156 150711',train_test,[ 10.5 9.0 7.5 6.0],dec,src,plot_on)
clear pooled_contactCaTrials_locdep;close all;

load([ d '/156_150714_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder_manova1(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','156 150714',train_test,[ 15 10.5 9 7.5 6],dec,src,plot_on)
clear pooled_contactCaTrials_locdep;close all;
% load('/Volumes/GR_Ext_Analysis_01/Analysis/Location preference silencing/Smootheddata/Decoder/analysis/DC subtraction on PCs/156_150717_pooled_contactCaTrials_locdep_smth.mat')
% [pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','156 150717',0,[10.5 9 7.5 6],dec,src,1,1)
% clear;close all;
load([ d '/157_150723_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder_manova1(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','157 150723',train_test,[15 10.5 9 7.5],dec,src,plot_on)
clear pooled_contactCaTrials_locdep;close all;

load([ d '/158_150712_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder_manova1(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','158 150712',train_test,[12 11 10 9 8],dec,src,plot_on)
clear pooled_contactCaTrials_locdep;close all;

load([ d '/158_150718_pooled_contactCaTrials_locdep_smth.mat'])
[pooled_contactCaTrials_locdep] = whiskloc_dependence_decoder_manova1(pooled_contactCaTrials_locdep,'sigpeak','ctrl_mani','158 150718',train_test,[15 13.5 12 10.5 9 7.5],dec,src,plot_on)
clear pooled_contactCaTrials_locdep;close all;