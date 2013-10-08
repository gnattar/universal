#
# sh file for running breakup and then generating image registration parfiles
#
/usr/local/matlab-2012a/bin/matlab -nojvm -nosplash -r "cd ..; path(path,genpath(pwd)); imreg_nogui_sample; exit;"
