

imagesList=getFileList(Experiment.orgDir,'*',Experiment.orgImagesExt);


fprintf('\n------\n All In One Maker (aioMaker)\n------\n');

%Timing matters

numImages=0;

fprintf('From: %d ---- To: %d\n',Experiment.imagesRange(1),Experiment.imagesRange(2));

measureWeights = [];

for idxMeasureType = 1:size(Experiment.config.measure,2)

    measureType = Experiment.config.measure{1,idxMeasureType};

    measureWeights = [measureWeights measure(measureType,Experiment.params.measure)];
end

listEmpty = {};

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

    idxImagesList = imgNum;
    idxRes = 1;

    %Read Image
    fullImageName=char(imagesList(idxImagesList));
    rawImageName=regexprep(fullImageName,strcat('.',Experiment.orgImagesExt),'');
    imagePath=strcat(Experiment.orgDir,fullImageName);

    fprintf('\nStarting image %d (%s)...\n',idxImagesList,rawImageName);

    reverseStr = '';
    totalT=0;

    img=double(imread(imagePath));
    img=img./255;

    smFileName=sprintf('%s%s-%s-[%s].%s',Experiment.smPrefix,rawImageName,smoothingMethod,config,Experiment.imageExt);
    smFilePath=strcat(Experiment.smDir,rawImageName,'/',smFileName);

    if (Experiment.SmWriter) && (~exist([Experiment.smDir rawImageName],'dir'))
        mkdir([Experiment.smDir rawImageName]);
    end

    tic;
    if ((~exist(smFilePath,'file')) || (Experiment.forceSmMaker==1))

        if (strcmp(smoothingMethod,'mshift'))
            smImage = imSmoother(img.*255,...
                                  smoothingMethod,...
                                  Experiment.mshift.spatialSupport,...
                                  Experiment.mshift.tonalSupport,...
                                  Experiment.mshift.stopCondition);
            smImage=smImage./255;

        elseif(strcmp(smoothingMethod,'gauss'))
            smImage = imSmoother(img,smoothingMethod,Experiment.gauss.sigma);
        elseif(strcmp(smoothingMethod,'grav'))
            smImage = imSmoother(img,smoothingMethod,Experiment.grav);
        else
            error('Wrong smoothing method %s at smMaker.',smoothingMethod);
        end

        if (Experiment.SmWriter)
            imwrite(smImage,smFilePath);
        end
    else
        smImage=double(imread(smFilePath));
        if (max(smImage(:))>1.001)
            smImage=smImage./255;
        end
    end

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
                ftFileName = sprintf('%s%s-%s-[%s]-%s-%s-F-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,measureType,choquetType,F1);
                bdryFileName = sprintf('%s%s-%s-[%s]-%s-%s-F-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,measureType,choquetType,F1);
                cpFileName = sprintf('%s%s-%s-[%s]-%s-%s-F-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,measureType,choquetType,F1);
                funcs = F1;
            else
                ftFileName = sprintf('%s%s-%s-[%s]-%s-%s-F1-%s-F2-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,measureType,choquetType,F1,F2);
                bdryFileName = sprintf('%s%s-%s-[%s]-%s-%s-F1-%s-F2-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,measureType,choquetType,F1,F2);
                cpFileName = sprintf('%s%s-%s-[%s]-%s-%s-F1-%s-F2-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,measureType,choquetType,F1,F2);
                funcs = [F1 '-' F2];
            end

            if (~exist([Experiment.cpDir rawImageName],'dir'))
                mkdir([Experiment.cpDir rawImageName]);
            end

            cpDataFilePath = sprintf('%s%s/%s.%s',Experiment.cpDir,rawImageName,cpFileName,Experiment.dataExt);

            if ((~exist(cpDataFilePath,'file')) || (Experiment.forceCpMaker==1))

                ftImgFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.imageExt);
                ftImgColorFilePath = sprintf('%s%s/%s_color.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.imageExt);
                ftDataFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.dataExt);

                if ((~exist(ftImgFilePath,'file')) || (Experiment.forceFtMaker==1) )

                    if (ismember(choquetType,{'CTM','CC'}))
                        imgFeat = CTM(smImage,Experiment.tamW,F1,mW);
                    else
                        imgFeat = CF1F2(smImage,Experiment.tamW,F1,F2,mW);
                    end

                    if (max(imgFeat(:))>0)
                        imgFeat=imgFeat./max(imgFeat(:));
                    end

                    if (Experiment.FtWriter)
                       imwrite(imgFeat,ftImgFilePath,'png');
                       writeColorMap(imgFeat,ftImgColorFilePath);
                    end

                else
                    data = load(ftDataFilePath);
                    imgFeat = data.imgFeat;
                end

                if (Experiment.BdryWriter) && (~exist([Experiment.bdryDir rawImageName],'dir'))
                    mkdir([Experiment.bdryDir rawImageName]);
                end

                bdryImgFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.imageExt);

                if ((~exist(bdryImgFilePath,'file')) || (Experiment.forceBdryMaker==1) )
                    [RES,imgBdry]=getBoundaries(imgFeat,Experiment.p);

                    if (Experiment.BdryWriter)
                       imwrite(255-imgBdry,bdryImgFilePath,'png');
                    end
                else
                    data = load(bdryDataFilePath);
                    imgBdry = data.imgBdry;
                end
            end

            if (Experiment.doCpMaker==1)
                if ((~exist(cpDataFilePath,'file')) || (Experiment.forceCpMaker==1))

                    imgBdry = logical(imgBdry./255);
                    res=ComparisonResiduals(Experiment.matching,imgBdry,gtImages,Experiment.matchingTolerance);
                    for idGTruthImage=1:size(gtImages.groundTruth,2)
                        solution(:,:,idGTruthImage)=gtImages.groundTruth{1,idGTruthImage}.Boundaries;
                    end
                    save(cpDataFilePath,'res');

                else
                    data = load(cpDataFilePath);
                    res = data.res;
                end

                thisT = toc;
                totalT = totalT + thisT;
                if (Experiment.verbose == 1)
                    msg = sprintf('\tBdry image: %d / %d, timeSmoo = %.2f secs, timeFeat = %.2f, timeBdry = %.2f, timeCp = %.2f  secs (est. %s)\n', idxRes,Experiment.numRes,tSmoo,tFeat,tBdry,tCp,timeToName(thisT*(Experiment.numRes-idxRes)));
                    fprintf([reverseStr, msg]);
                    reverseStr = repmat(sprintf('\b'), 1, length(msg));
                end
            end
        end
    end
    totalTall = totalTall + totalT;
    imgDone = imgDone +1;
    if (Experiment.verbose == 1)
        fprintf('\t done (%s) (est. %s)\n',timeToName(totalT),timeToName((totalTall/imgDone)*(imagesTo-imagesFrom-imgDone-1)));
    end
    fprintf('\t done (%s)\n',timeToName(totalT));
end
