#!/usr/bin/env python

####################################################################################
#
# S Peron 2011 Oct
#
#   Directory recursion wrapper for tmog_whisk_link_matgen.m
#
####################################################################################
import sys, struct, os, re, string, shutil, random, subprocess;
import xml.dom.minidom;

# definitely (?) fixed -- where you go huntin for dem whiska files
root_search_path = "/groups/magee/mageelab/GR_dm11/whisker";
matlab_root = "/groups/magee/mageelab/GR_dm11/imreg_on_cluster_GR/anal";
logs_path = "/groups/magee/mageelab/GR_dm11/imreg_on_cluster/logs";
tmppar_root = "/groups/magee/mageelab/GR_dm11/imreg_on_cluster/partmp";
qsub_path = "/sge/8.0.1p4/bin/lx-amd64/qsub";
par_execute_path = "/groups/magee/mageelab/GR_dm11/imreg_on_cluster/anal/par/par_execute_cluster";

# path passed?
if (len(sys.argv) > 1):
  root_search_path = sys.argv[1];


#
# This will take a single directory and run tmog_whisk_link_matgen for it
#
def process_directory(dirname):
	# Run the MATLAB to generate parfile
	uid = "%08d" % (random.random()*100000000) # so we don't collide
	matlab_command = 'cd ' + matlab_root + ';';
	matlab_command = matlab_command + 'path(path,genpath(pwd)); rmpath(genpath([pwd filesep \'par/par_execute_cluster_mcr\']));';
	matlab_command = matlab_command + "dep_file_path = ''; funcname = 'tmog_whisk_link_matgen' ; params = '" + dirname +  "' ;";
	matlab_command = matlab_command + "save('" + tmppar_root + "/parfile_" + uid + "_tmwlmg_tmp.mat', 'params', 'funcname', 'dep_file_path'); exit;";
	matlab_call = '/usr/local/matlab-2010a/bin/matlab -nojvm -nosplash -r "' + matlab_command + '"';
	print matlab_call
	os.system(matlab_call);

	# Run the submission to cluster
	# qsub the parfile
	jobname = "wlink-matgen-" + uid;
	dispatch_cmd = qsub_path + ' -l short=true -N ' + jobname + ' -j y -o /dev/null -b y -cwd -V "' + par_execute_path + ' ' + tmppar_root + ' > ' + logs_path + '/wlink-matgen-' +uid + '.log"';
#OLD:	dispatch_cmd = qsub_path + ' -l excl=true -N ' + jobname + ' -j y -o /dev/null -b y -cwd -V "' + par_execute_path + ' ' + tmppar_root + ' > ' + logs_path + '/wlink-matgen-' +uid + '.log"';
#  dispatch_cmd = qsub_path + " -N " + jobname + " -l short=true -j y -o /dev/null -b y -cwd -V \"python " + pyscript + " > " + pyscript_log + "\"";

	print dispatch_cmd
	os.system(dispatch_cmd);

####################################################################################
#
# "crawls" a single directory going thru its files looking for ready_for_prelink
#
####################################################################################
def parse_directory(arg, dirname, names):
	try:
		# --- does the ready_for_prelink file exist?
		cmd = "ls " + dirname + "/ready_for_prelink";

		# --- execute!a
		print dirname + "/ready_for_prelink"
		if (os.system(cmd) == 0):
			process_directory(dirname);
	except:
		e = sys.exc_info()[0];
		print "failed to process directory " + dirname + " message: ", e;


####################################################################################
#
# The actual directory crawler
#
####################################################################################

# --- go thru each directory at top
os.path.walk(root_search_path, parse_directory, "");


