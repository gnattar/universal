#
# this will cleanup tmog stuff
#

# 1) cleanup the logs (2d old or more GONE!)
cd /groups/svoboda/wdbp/reprocessed/logs
find . -name '*' -mtime +2 -type f -print0 | xargs -0 rm -f

# 2) requeue dropped reprocess whisk jobs
cd /groups/magee/mageelab/GR_dm11/imreg_on_cluster_GR/reprocessed/
chmod -R 777 *
for s in `find $PWD -name parfiles -type d `; do if [[ `ls $s/ready_for_linking.done | wc -l` -eq 1 && `ls $s/*tmp | wc -l` -gt 0 && `ls $s/redone | wc -l` -eq 0 ]] ; then cd $s ; ~/untmp.sh ; mv ready_for_linking.done ready_for_linking ; touch redone ; cd /groups/svoboda/wdbp/reprocessed ; else echo $s already done so I skip it ; fi ; done

