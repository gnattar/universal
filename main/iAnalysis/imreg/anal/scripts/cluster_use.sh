echo This is a weekly usage reminder for dm10 share WDBP. > /groups/svoboda/wdbp/usage.txt
echo Data older than 1 week is automatically deleted, so take this moment to transfer relevant data. >> /groups/svoboda/wdbp/usage.txt
echo >> /groups/svoboda/wdbp/usage.txt
echo General wdbp usage: >> /groups/svoboda/wdbp/usage.txt
du -hsc --apparent-size /groups/svoboda/wdbp/* >> /groups/svoboda/wdbp/usage.txt
echo >> /groups/svoboda/wdbp/usage.txt
echo Linked whisker data usage -- Clack linker: >> /groups/svoboda/wdbp/usage.txt
du -hsc --apparent-size /groups/svoboda/wdbp/processed/* >> /groups/svoboda/wdbp/usage.txt
echo >> /groups/svoboda/wdbp/usage.txt
echo Newly transmogrified data usage: >> /groups/svoboda/wdbp/usage.txt
du -hsc --apparent-size /groups/svoboda/wdbp/unprocessed/* >> /groups/svoboda/wdbp/usage.txt
echo >> /groups/svoboda/wdbp/usage.txt
echo Image registration data usage: >> /groups/svoboda/wdbp/usage.txt
du -hsc --apparent-size /groups/svoboda/wdbp/imreg/* >> /groups/svoboda/wdbp/usage.txt
echo >> /groups/svoboda/wdbp/usage.txt
echo Linked whisker data usage -- Peron linker: >> /groups/svoboda/wdbp/usage.txt
du -hsc --apparent-size /groups/svoboda/wdbp/reprocessed/* >> /groups/svoboda/wdbp/usage.txt
#cat /groups/svoboda/wdbp/usage.txt | mail -s dm10-wdbp-usage perons@janelia.hhmi.org
cat /groups/svoboda/wdbp/usage.txt | mail -s dm10_wdbp_usage ~KarelSvobodasGroupAll@janelia.hhmi.org
cat /groups/svoboda/wdbp/usage.txt | mail -s dm10_wdbp_usage xun@janelia.hhmi.org
