
clear Experiment;

if (strcmp(OS_MODE,'linux'))
    ROOT_FOLDER='/home/lab/';
    if (~exist(ROOT_FOLDER,'dir'))
    	ROOT_FOLDER='/home/lab/';
    end
elseif (strcmp(OS_MODE,'cluster'))
    ROOT_FOLDER='/home/lab/';
elseif (strcmp(OS_MODE,'mac'))
    ROOT_FOLDER='/Users/lab/Research/';
elseif(strcmp(OS_MODE,'win') || strcmp(OS_MODE,'windows'))
    ROOTFOLDER='D:/';
else
    error('Error at infoMaker.m> Unknown OS_MODE [%s]\n',OS_MODE);
end


%
% Paths
%

Experiment.set='test';
Experiment.experimentName = 'choquetEdges';
Experiment.databaseName = 'BSDS5full';


if (strcmp(Experiment.databaseName,'BSDS5full'))
    Experiment.orgDir=[ROOT_FOLDER 'Resources/Images/BSDS5full/originalGS/' Experiment.set '/'];
    Experiment.gtBnDir=[ROOT_FOLDER 'Resources/Images/BSDS5full/gtruthBN/' Experiment.set '/'];
    Experiment.researchDataDir=[ROOT_FOLDER 'ResearchData/' Experiment.experimentName '/' Experiment.databaseName '/' Experiment.set '/'];
    Experiment.publishDataDir=[ROOT_FOLDER 'Publishing/' Experiment.experimentName '/' Experiment.databaseName '/' Experiment.set '/'];
    Experiment.imagesRange = [1 500];
    Experiment.cpCollecterRange = [1 500];
elseif (strcmp(Experiment.databaseName,'BSDS5test'))
    Experiment.orgDir=[ROOT_FOLDER 'Resources/Images/BSDS5test/originalGS/'];
    Experiment.gtBnDir=[ROOT_FOLDER 'Resources/Images/BSDS5test/gtruthBN/'];
    Experiment.researchDataDir=[ROOT_FOLDER 'ResearchData/' Experiment.experimentName '/' Experiment.databaseName '/' Experiment.set '/'];
    Experiment.imagesRange = [imgNum imgNum];
    Experiment.cpCollecterRange = [1 200];
elseif (strcmp(Experiment.databaseName,'test'))
    Experiment.orgDir=[ROOT_FOLDER 'Resources/Images/BSDS5full/testGS/'];
    Experiment.gtBnDir=[ROOT_FOLDER 'Resources/Images/BSDS5full/testGT/'];
    Experiment.researchDataDir=[ROOT_FOLDER 'ResearchData/' Experiment.experimentName '/' Experiment.databaseName '/'];
    Experiment.publishDataDir=[ROOT_FOLDER 'Publishing/' Experiment.experimentName '/' Experiment.databaseName '/' Experiment.set '/'];
    Experiment.imagesRange = [1 1];
    Experiment.cpCollecterRange = [1 1];
elseif (strcmp(Experiment.databaseName,'testCF1F2'))
    Experiment.orgDir=[ROOT_FOLDER 'Resources/Images/BSDS5full/testCF1F2GS/'];
    Experiment.gtBnDir=[ROOT_FOLDER 'Resources/Images/BSDS5full/testCF1F2GT/'];
    Experiment.researchDataDir=[ROOT_FOLDER 'ResearchData/' Experiment.experimentName '/' Experiment.databaseName '/'];
    Experiment.publishDataDir=[ROOT_FOLDER 'Publishing/' Experiment.experimentName '/' Experiment.databaseName '/' Experiment.set '/'];
    Experiment.imagesRange = [1 2];
    Experiment.cpCollecterRange = [1 1];
else
    error('Wrong Experiment.databaseName at infoMaker.m');
end

Experiment.smDir=[Experiment.researchDataDir 'sm/'];
Experiment.featImDir = [Experiment.researchDataDir 'featIm/'];
Experiment.featImDirColor = [Experiment.publishDataDir 'featIm/'];
Experiment.bdryDir = [Experiment.researchDataDir 'bn/'];
Experiment.bdryPublishDir = [Experiment.publishDataDir 'bn/'];
Experiment.cpDir = [Experiment.researchDataDir 'cp/'];
Experiment.texDir = [Experiment.researchDataDir 'plots/'];

if (~exist(Experiment.smDir,'dir'))
    mkdir(Experiment.smDir);
end
if (~exist(Experiment.featImDir,'dir'))
    mkdir(Experiment.featImDir);
end
if (~exist(Experiment.bdryDir,'dir'))
    mkdir(Experiment.bdryDir);
end
if (~exist(Experiment.cpDir,'dir'))
    mkdir(Experiment.cpDir);
end
if (~exist(Experiment.texDir,'dir'))
    mkdir(Experiment.texDir);
end

%
% 2- File profiling
%

Experiment.smPrefix='sm-';%Smoothing
Experiment.ftPrefix='ft-';%Feature image
Experiment.bdryPrefix='bdry-';%Boundary image
Experiment.cpPrefix='cp-';%Comparison

Experiment.imageExt='png';
Experiment.orgPrefix='jpg';
Experiment.bnPrefix='bn';
Experiment.cpPrefix='cp';
Experiment.orgImagesExt='png';
Experiment.dataExt='mat';

Experiment.SmWriter=1;
Experiment.FtWriter=1;
Experiment.BdryWriter=1;
Experiment.CpWriter=1;

Experiment.forceSmMaker=0;
Experiment.forceFtMaker=1;
Experiment.forceBdryMaker=1;
Experiment.forceCpMaker=1;

Experiment.doCpMaker=0;

Experiment.verbose=0;

Experiment.config.measure = {'power'};


Experiment.config.F = {'CTM'...
                        {'hamacker','CF','OB','FBPC'} {}};


Experiment.tamW=[3 3];

Experiment.params.measure.tam = prod(Experiment.tamW)-1;
Experiment.params.measure.power.q = [1 0.8 0.4];
Experiment.params.measure.owaling.a = 0.3;%0.3
Experiment.params.measure.owaling.b = 0.5;%0.8

if (ismember('power',Experiment.config.measure))

    for idxQ = 1:length(Experiment.params.measure.power.q)
        mName{1,idxQ} = ['power-' sigma2name(Experiment.params.measure.power.q(idxQ))];
    end

    idxPower = find(not(cellfun('isempty', strfind(Experiment.config.measure, 'power'))));

    Experiment.config.measure = [Experiment.config.measure(idxPower) Experiment.config.measure(1:end ~= idxPower)];
    Experiment.config.measureComplete = [mName Experiment.config.measure(1:end ~= idxPower)];
else
    Experiment.config.measureComplete = Experiment.config.measure;
end



Experiment.funcList = [];
for idxChoquetType = 1:size(Experiment.config.F,1)

    choquetType = Experiment.config.F(idxChoquetType,1);

    if (ismember(choquetType,{'CTM','CC'}))
        Experiment.funcList = [Experiment.funcList; repmat(choquetType,[size(Experiment.config.F{idxChoquetType,2},2) 1]) Experiment.config.F{idxChoquetType,2}' repmat({'-'},[size(Experiment.config.F{idxChoquetType,2},2) 1])];
    else
        F1unique = Experiment.config.F{idxChoquetType,2};
        F2unique = Experiment.config.F{idxChoquetType,3};
        nPairs = combvec(1:size(F1unique,2),1:size(F2unique,2));
        F1 = F1unique(nPairs(1,:));
        F2 = F2unique(nPairs(2,:));

        Experiment.funcList = [Experiment.funcList; repmat(choquetType,[size(F1,2) 1]) F1' F2'];
    end
end

Experiment.funcListClassic = {'canny' {2.25};...
                              'fuzzyM' {'T_nM' 'I_KD' 'SS'};...
                              'ged' {'S_M' 3 'global'};...
                              'ged' {'S_P' 3 'global'}};

Experiemnt.smFilePrefix = 'grav-[it-50-0-0200-G-0-0500-cF-70-euc-euc]';
Experiment.BestWorstConfigList = {'canny-2-2500';...
                                  'fuzzyM-T_nM-I_KD-SS';...
                                  'ged-S_P-3-global';...
                                  'ged-S_M-3-global'};

Experiment.config.FwMeasure = {{'CTM','CF','-','power',0.8},...
                               {'CTM','hamacker','-','power',1},...
                               {'CTM','OB','-','power',1},...
                               {'CTM','FBPC','-','power',0.4}};


Experiment.numRes = 0;
for idxChoquetType = 1:size(Experiment.config.F,1)
    choquetType = Experiment.config.F{idxChoquetType,1};
    if (ismember(choquetType,{'CTM','CC'}))
        Experiment.numRes = Experiment.numRes + size(Experiment.config.F{idxChoquetType,2},2);
    else
        Experiment.numRes = Experiment.numRes + size(Experiment.config.F{idxChoquetType,2},2)*size(Experiment.config.F{idxChoquetType,3},2);
    end
end

Experiment.numRes = Experiment.numRes*size(Experiment.config.measureComplete,2);

%
% Parameters
%

Experiment.smoothingMethod = {'grav'};% gauss, grav
Experiment.gauss.sigma=[2];%2

Experiment.grav.iterations = 50;%30, 50
Experiment.grav.minDistInfFactor = 0.02;%0.05, 0.02
Experiment.grav.gConst = 0.05;%0.05
Experiment.grav.colorFactor = 70;%20, 70
Experiment.grav.colorMetric = 'euc';
Experiment.grav.posMetric = 'euc';

Experiment.p=0.35;

Experiment.map = gray(256);

Experiment.matching = 'ejBCM-F';
Experiment.matchingTolerance = 0.025;%25

Experiment.dtDiffColorMap=createColorMap([0.9, 0.9, 0.9],...
                                         [0.14, 0.12, 0.1],...
                                         [0.92, 0.37, 0],...
                                         256);
