

imagesList=getFileList(Experiment.orgDir,'*',Experiment.orgImagesExt);


fprintf('\n------\n Comparison Maker (cpMaker)\n------\n');

%Timing matters

numImages=0;


imagesFrom=max(1,Experiment.imagesRange(1));
imagesTo=min(length(imagesList),Experiment.imagesRange(2));

measureWeights = [];

for idxMeasureType = 1:size(Experiment.config.measure,2)

    measureType = Experiment.config.measure{1,idxMeasureType};

    measureWeights = [measureWeights measure(measureType,Experiment.params.measure)];
end

listEmpty = {};

cpAll = cell(Experiment.numRes,5,imagesTo-imagesFrom+1);

time = zeros(imagesTo-imagesFrom,1);

for idxSmoothingMethod=1:length(Experiment.smoothingMethod)

    totalTall = 0;
    imgDone = 0;

    smoothingMethod=Experiment.smoothingMethod{idxSmoothingMethod};
    if (strcmp(smoothingMethod,'mshift'))
        config=strcat(num2str(Experiment.mshift.spatialSupport),'-',num2str(Experiment.mshift.tonalSupport),'-',num2str(Experiment.mshift.stopCondition));
    elseif(strcmp(smoothingMethod,'gauss'))
        config=sigma2name(Experiment.gauss.sigma);
    elseif(strcmp(smoothingMethod,'grav'))
        config=sprintf('it-%d-%s-G-%s-cF-%d-%s-%s',Experiment.grav.iterations,sigma2name(Experiment.grav.minDistInfFactor),sigma2name(Experiment.grav.gConst),Experiment.grav.colorFactor,Experiment.grav.colorMetric,Experiment.grav.posMetric);
    end

    cpAllFileName = sprintf('%s[%d-%d]-%s-[%s]',Experiment.cpPrefix,imagesFrom,imagesTo,smoothingMethod,config);
    cpAllDataFilePath = sprintf('%s%s.%s',Experiment.cpDir,cpAllFileName,Experiment.dataExt);

    for idxImagesList=imagesFrom:imagesTo
        idxRes = 1;

        %Read Image
        fullImageName=char(imagesList(idxImagesList));
        rawImageName=regexprep(fullImageName,strcat('.',Experiment.orgImagesExt),'');
        imagePath=strcat(Experiment.orgDir,fullImageName);

        fprintf('\nStarting image %d / %d (%s)...\n',idxImagesList,imagesTo,rawImageName);

        reverseStr = '';
        totalT=0;

        pathIm = sprintf('%s%s.%s',Experiment.gtBnDir,rawImageName,Experiment.dataExt);
        gtImages=load(pathIm);

        for idxFunc = 1:size(Experiment.funcList,1)

            choquetType = Experiment.funcList{idxFunc,1};
            F1 = Experiment.funcList{idxFunc,2};
            F2 = Experiment.funcList{idxFunc,3};

            for idxMeasureType = 1:size(Experiment.config.measureComplete,2)

                measureType = Experiment.config.measureComplete{1,idxMeasureType};
                mW = measureWeights(:,idxMeasureType);

                if (ismember(choquetType,{'CTM','CC'}))
                    bdryFileName = sprintf('%s%s-%s-[%s]-%s-%s-F-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,measureType,choquetType,F1);
                    cpFileName = sprintf('%s%s-%s-[%s]-%s-%s-F-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,measureType,choquetType,F1);
                    funcs = F1;
                else
                    bdryFileName = sprintf('%s%s-%s-[%s]-%s-%s-F1-%s-F2-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,measureType,choquetType,F1,F2);
                    cpFileName = sprintf('%s%s-%s-[%s]-%s-%s-F1-%s-F2-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,measureType,choquetType,F1,F2);
                    funcs = [F1 '-' F2];
                end

                if (~exist([Experiment.cpDir rawImageName],'dir'))
                    mkdir([Experiment.cpDir rawImageName]);
                end

                bdryDataFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.dataExt);
                cpDataFilePath = sprintf('%s%s/%s.%s',Experiment.cpDir,rawImageName,cpFileName,Experiment.dataExt);

                data = load(bdryDataFilePath);
                imgBdry = data.imgBdry;

                tic;
                if ((~exist(cpDataFilePath,'file')) || (Experiment.forceCpMaker==1))

                    imgBdry = logical(imgBdry./255);

                    res=ComparisonResiduals(Experiment.matching,imgBdry,gtImages,Experiment.matchingTolerance);

                    save(cpDataFilePath,'res');

                else
                    data = load(cpDataFilePath);
                    res = data.res;
                end
                resMean = mean(res,1);
                resSorted = sortrows(res,3);
                resMax = resSorted(end,:);

                cpAll(idxRes,:,idxImagesList) = {choquetType funcs measureType resMax resMean};

                thisT=toc;
                totalT = totalT + thisT;
                msg = sprintf('\tBdry image: %d / %d, time = %.2f secs (est. %s)\n', idxRes,Experiment.numRes,thisT,timeToName(thisT*(Experiment.numRes-idxRes)));
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
                idxRes = idxRes+1;
            end
        end
        totalTall = totalTall + totalT;
        imgDone = imgDone +1;
        fprintf('\t done (%s) (est. %s)\n',timeToName(totalT),timeToName((totalTall/imgDone)*(imagesTo-imagesFrom-imgDone-1)));
    end
    cpAll = [cpAll(:,1:3,1) num2cell(mean(cell2mat(cpAll(:,4,:)),3),[size(cpAll,1) 3]) num2cell(mean(cell2mat(cpAll(:,5,:)),3),[size(cpAll,1) 3])];
    save(cpAllDataFilePath,'cpAll','Experiment');
end
