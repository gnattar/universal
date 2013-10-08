#!/usr/bin/env python

####################################################################################
#
# S Peron 2011 Sept
#
#   1) looks for any new imreg.xml files
#   2) kicks off cluster-based breakup_volume_images
#   3) generates parfiles for cluster-based registration
#
####################################################################################
import sys, struct, os, re, string, shutil, random, subprocess, glob;
import xml.dom.minidom;

# definitely (?) fixed -- where you go huntin for dem whiska files
root_search_path = "/groups/magee/mageelab/GR_dm11/imreg/";
matlab_root = "/groups/magee/mageelab/GR_dm11/imreg_on_cluster_GR/anal";
tmppar_root = "/groups/magee/mageelab/GR_dm11/imreg_on_cluster_GR/partmp";
logs_path = "/groups/magee/mageelab/GR_dm11/imreg_on_cluster_GR/logs";
qsub_path = "/sge/8.0.1p4/bin/lx-amd64/qsub";
par_execute_path = "/groups/magee/mageelab/GR_dm11/imreg_on_cluster_GR/anal/par/par_execute_cluster";

print par_execute_path

# path passed?
if (len(sys.argv) > 1):
	root_search_path = sys.argv[1];

#
# This will take a single xml file - specified by xmlpath - and execute it via imreg_par_from_xml
#
def process_xml_file(xmlpath):
	# Run the MATLAB
	uid = "%08d" % (random.random()*100000000) # so we don't collide
	matlab_command = 'cd ' + matlab_root + ';';
	matlab_command = matlab_command + 'path(path,genpath(pwd)); rmpath(genpath([pwd filesep \'par/par_execute_cluster_mcr\']));';
	matlab_command = matlab_command + "dep_file_path = ''; funcname = 'imreg_par_fromxml' ; params = '" + xmlpath + ".done' ;";
	matlab_command = matlab_command + "save('" + tmppar_root + "/parfile_" + uid + "_imreg_tmp.mat', 'params', 'funcname', 'dep_file_path'); exit;";
	print matlab_command
	matlab_call = '/usr/local/matlab-2012a/bin/matlab -nojvm -nosplash -r "' + matlab_command + '"';
	print matlab_call
	os.system(matlab_call);

	# Move xml to xml.done
	shutil.copyfile(xmlpath,xmlpath + ".done");
	os.remove(xmlpath);

	# qsub the parfile
	jobname = "breakup_image_" + uid;
	dispatch_cmd = qsub_path + ' -l excl=true -N ' + jobname + ' -j y -o /dev/null -b y -cwd -V "' + par_execute_path + ' ' + tmppar_root + ' > ' + logs_path + '/breakup_' +uid + '.log"';
	print dispatch_cmd
	os.system(dispatch_cmd);


####################################################################################
#
# "crawls" a single directory going thru its files looking for imreg*.xml
#
####################################################################################
def parse_directory(arg, dirname, names):
	try:
		# --- does the imreg*.xml file exist?
		cmd = "ls " + dirname + "/imreg*.xml";
		print dirname

		# --- execute!a
		for xmlfile in glob.glob( os.path.join(dirname, 'imreg*.xml')):
			print "DOING: " + xmlfile;
			cmd = "find " + dirname + " -mmin -2 | grep tif | wc -l";
			print "DOING: " + cmd;
			new_count = int(bash_run(cmd));
			print "DOING: " + xmlfile;
			if (new_count == 0):
				print "ACCEPTED: " + xmlfile;
				process_xml_file(xmlfile);
	except:
		e = sys.exc_info()[0];
		print "failed to process directory " + dirname + " message: ", e;



####################################################################################
#
# Wrapper to get output of a system call
#
####################################################################################
def bash_run(cmd):
	p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE);
	out = p.stdout.read().strip();
	return out;

####################################################################################
#
# The actual directory crawler
#
####################################################################################

# remove bad stuff
os.system("rm " + tmppar_root + "/lock.m");
os.system("rm " + tmppar_root + "/*mat");

# --- go thru each directory at top
os.path.walk(root_search_path, parse_directory, "");

