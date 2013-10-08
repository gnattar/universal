rm par_execute_cluster par_execute_cluster_main.c par_execute_cluster_mcc_component_data.c par_execute_cluster.prj run_par_execute_cluster.sh par_execute_cluster.ctf readme.txt 
rm -rf par_execute_cluster_mcr
rm -rf .mcrCache*
/usr/local/matlab-2012a/bin/mcc -m -C -R -nojvm -v par_execute_cluster.m -a imreg_par_fromxml.m -a ../lib/ -a ../+session/ -a ../lib/extern_treeBagger/runScripts -a ../lib/extern_treeBagger/classifierFunctions -a ../lib/extern_treeBagger/graphicalFunctions -a ../lib/extern_treeBagger/helperFunctions -a ../lib/extern_treeBagger/loaderFunctions -a ../lib/extern_treeBagger/par -a ../processors/ -a ../processors/imreg/ -a ../processors/imreg_postprocess/ -a ../processors/imreg_session_stats/ -a ../fluo_gui/ -a tmog_whisk_link_matgen.m
