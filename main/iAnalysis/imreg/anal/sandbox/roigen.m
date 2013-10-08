fovs = [1 2 3 4];

cd /data/an148378/rois

gen_date = '2011_09_23';
clear rA rB;
for fi=1:length(fovs)
  f = fovs(fi);
  load (['2011_09_12_fov_00' num2str(f)]);
	rA{fi} = obj;
	rA{fi}.generateDerivedRoiArrays({['/data/an148378/' gen_date '/scanimage/fov_00' num2str(f) '/fluo_batch_out/']}, {[gen_date '_fov_00' num2str(f)]},pwd);

	rB{fi} = load([gen_date '_fov_00' num2str(f)]); 
	rB{fi} = rB{fi}.obj;
end
