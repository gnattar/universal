%% Batch_ICA_processing_NXJF28050

% data_dirs = {'/Volumes/RAID Data/2P-Imaging Data/NXJF28050/091228/data/NXJF28050_091228_brpA',...
% '/Volumes/RAID Data/2P-Imaging Data/NXJF28050/091228/data/NXJF28050_091228_surfA',...
% '/Volumes/RAID Data/2P-Imaging Data/NXJF28050/091229/data/NXJF28050_091229_surfA',...
% '/Volumes/RAID Data/2P-Imaging Data/NXJF28050/091230/data/NXJF28050_091230_brpA',...
% '/Volumes/RAID Data/2P-Imaging Data/NXJF28050/091231/data/NXJF28050_091231_brpB',...
% '/Volumes/RAID Data/2P-Imaging Data/NXJF28050/091231/data/NXJF28050_091231_brpC',...
% '/Volumes/RAID Data/2P-Imaging Data/NXJF28050/100102/data/NXJF28050_100102_surfB',...   
% '/Volumes/RAID Data/2P-Imaging Data/NXJF28050/100103/data/NXJF28050_100103_brpA',...
% '/Volumes/RAID Data/2P-Imaging Data/NXJF28050/100104/data/NXJF28050_100104_brpA',...
% '/Volumes/RAID Data/2P-Imaging Data/NXJF28050/100104/data/NXJF28050_100104_brpB',...
% '/Volumes/RAID Data/2P-Imaging Data/NXJF28050/100105/data/NXJF28050_100105_surfC'};
% % % 
% % % data_dirs = {'/Volumes/RAID Data/2P-Imaging Data/NXJF28050/100106/data/NXJF28050_100106_surfD_reg',...
% % % '/Volumes/RAID Data/2P-Imaging Data/NXJF28050/100107/data/NXJF28050_100107_surfC_reg',...
% % % '/Volumes/RAID Data/2P-Imaging Data/NXJF28050/100107/data/NXJF28050_100107_surfD_reg',...
% % % '/Volumes/RAID Data/2P-Imaging Data/NXJF28050/100108/data/NXJF28050_100108_L5_surfC_reg',...
% % % '/Volumes/RAID Data/2P-Imaging Data/NXJF28050/100108/data/NXJF28050_100108_L5_surfD_reg'};


data_dirs = {'/Volumes/GR_Data_01/Data/anm174708/testdata'};
% FileBaseName =  data_dirs;
% FileBaseName = cellfun(@(x) x(36:end-1), data_dirs, 'UniformOutput',false);
FileBaseName{1} = 'Image_Registration_5_anm174708_2012_08_27_11_main_';
%
FileNums = 1:50; % take the first 50 trials to compute
%%
for i = 1:length(data_dirs)
    clearvars -except data_dirs FileBaseName FileNums i
    %%
    cd(data_dirs{i});
    if ~exist(sprintf('../ICA_Results_%s.mat', FileBaseName{i}), 'file')
        Data = LoadData(data_dirs{i},FileBaseName{i},FileNums);
        %
        if ~exist(sprintf('../ICA_data_%s.mat', FileBaseName{i}))
            [U,S,V] = svd(Data,'econ');
            save(sprintf('../ICA_data_%s.mat', FileBaseName{i}), 'U','S','V','-v7.3');
        else
            usv = load(sprintf('../ICA_data_%s.mat', FileBaseName{i}));
            U = usv.U;
            S = usv.S;
            V = usv.V;
        end
        SVDComponentNum = 30;
        ICnum = 20;
         ICA_components = run_ICA(Data, {S, V, SVDComponentNum, ICnum});
%     ICA_components = PerformICA(Data,U,S,V,256,256)        
        ICA_results.FileBaseName = FileBaseName{i};
        ICA_results.FileNums_used = FileNums;
        ICA_results.ICA_components = ICA_components;
        save(sprintf('../ICA_Results_%s.mat', FileBaseName{i}), 'ICA_results');
    end
end
