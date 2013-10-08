#
# sh file for generating session encode/decode with trees -- basically all this
#  does is start MATLAB and runs tree_matgen.m
#
/usr/local/matlab-2012a/bin/matlab -nojvm -nosplash -r "cd ..; path(path,genpath(pwd)); tree_matgen; exit;"
