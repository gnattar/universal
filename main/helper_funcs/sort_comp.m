function [] = sort_comp(comp_mat,comp_path,type)
num_comp = size(comp_mat,1);
% clim = [max(max(max(max(comp_mat)))) min(min(min(min(comp_mat))))];
clim = [-1.5 1.5];
for i = 1: num_comp
    sc = get(0,'ScreenSize');
    h1 = figure('position', [1000, sc(4)/2, sc(3)/3, sc(4)/2], 'color','w');
%     ah1=axes('Parent',h1); 
    suptitle(['Comp' num2str(i)]);
%     temp_im = mean(squeeze(comp_mat(i,:,:,:)),3);
    temp_im = squeeze(comp_mat(i,:,:));
    imagesc(temp_im); caxis(clim); colormap(othercolor('BuDRd_18'));
    fnam = [type '_Comp' num2str(i)];
    saveas(gcf,[comp_path,filesep,fnam],'jpg');
    close(h1);
end