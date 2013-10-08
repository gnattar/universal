function optionsTree = getDefaultOptionsTreeSimon(animalName)
optionsTree.zscore             = 1;
optionsTree.featuresAll        = 0;
optionsTree.featuresCross      = 0;
optionsTree.nFold              = 5;
optionsTree.storeTree          = 0;
optionsTree.verbose            = 1;
optionsTree.minLeaf            = 5; % deprecated?
optionsTree.minLeafClassifier  = 1;
optionsTree.minLeafRegression  = 5;
optionsTree.N_bagging          = 32;
optionsTree.minTrials          = 4;
optionsTree.save               = 'onlyTree';
optionsTree.path               =  ['~/data/' animalName '/tree/'];
optionsTree.rootPath             = optionsTree.path;
optionsTree.pathAllFeatures      = ['allFeatures' filesep];
optionsTree.pathTrees            = ['onlyTrees' filesep];
optionsTree.pathSingleFeatures   = ['singleFeatures' filesep];
optionsTree.pathSingleCategories = ['singleCategories' filesep];
optionsTree.pathPairCategories   = ['pairCategories' filesep];
optionsTree.pathSingleNeuron     = ['singleNeurons' filesep];
optionsTree.pathPopulation       = ['population' filesep];
optionsTree.baseFilename         = '';

% decoder stuff
optionsTree.decoder.calciumShifts = [-2 -1 0 1 2]; 
optionsTree.pathPopulation       = ['population' filesep];
optionsTree.pathSingleNeuron     = ['singleNeurons' filesep];

warning ('off');
mkdir (optionsTree.rootPath,optionsTree.pathAllFeatures);
mkdir (optionsTree.rootPath,optionsTree.pathSingleFeatures);
mkdir (optionsTree.rootPath,optionsTree.pathSingleCategories);
mkdir (optionsTree.rootPath,optionsTree.pathPairCategories);
mkdir (sprintf('%s%s',optionsTree.rootPath,optionsTree.pathAllFeatures),optionsTree.pathTrees);
warning ('on');
