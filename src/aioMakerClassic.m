

imagesList=getFileList(Experiment.orgDir,'*',Experiment.orgImagesExt);


fprintf('\n------\n All In One Maker Other Methods (aioMakerClassic)\n------\n');

%Timing matters

numImages=0;

fprintf('From: %d ---- To: %d\n',Experiment.imagesRange(1),Experiment.imagesRange(2));

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
    tSmoo = toc;

    pathIm = sprintf('%s%s.%s',Experiment.gtBnDir,rawImageName,Experiment.dataExt);
    gtImages=load(pathIm);

    for idxFunc = 1:size(Experiment.funcListClassic,1)

        method = Experiment.funcListClassic{idxFunc,1};
        params = Experiment.funcListClassic{idxFunc,2};

        if (ismember(method,{'canny'}))
            ftFileName = sprintf('%s%s-%s-[%s]-%s-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,method,sigma2name(cell2mat(params)));
            bdryFileName = sprintf('%s%s-%s-[%s]-%s-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,method,sigma2name(cell2mat(params)));
            cpFileName = sprintf('%s%s-%s-[%s]-%s-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,method,sigma2name(cell2mat(params)));
        elseif (ismember(method,{'fuzzyM'}))
            ftFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,method,params{1,1},params{1,2},params{1,3});
            bdryFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,method,params{1,1},params{1,2},params{1,3});
            cpFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,method,params{1,1},params{1,2},params{1,3});
        elseif (ismember(method,{'ged'}))
            ftFileName = sprintf('%s%s-%s-[%s]-%s-%s-%d-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,method,params{1,1},params{1,2},params{1,3});
            bdryFileName = sprintf('%s%s-%s-[%s]-%s-%s-%d-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,method,params{1,1},params{1,2},params{1,3});
            cpFileName = sprintf('%s%s-%s-[%s]-%s-%s-%d-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,method,params{1,1},params{1,2},params{1,3});
        end

        if (~exist([Experiment.cpDir rawImageName],'dir'))
            mkdir([Experiment.cpDir rawImageName]);
        end

        cpDataFilePath = sprintf('%s%s/%s.%s',Experiment.cpDir,rawImageName,cpFileName,Experiment.dataExt);

        if ((~exist(cpDataFilePath,'file')) || (Experiment.forceCpMaker==1))

            ftImgFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.imageExt);
            ftImgColorFilePath = sprintf('%s%s/%s_color.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.imageExt);
            ftDataFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.dataExt);

            tic;
            if ((~exist(ftImgFilePath,'file')) || (Experiment.forceFtMaker==1) )

                if (ismember(method,{'canny'}))
                    imgFeat = canny(smImage,cell2mat(params));
                elseif (ismember(method,{'fuzzyM'}))
                    imgFeat = FuzzyMorph(smImage,params{1,1},params{1,2},params{1,3});
                elseif (ismember(method,{'ged'}))
                    [imgFeat,~,~] = AFDetection(smImage,params{1,1},params{1,2},params{1,3});
                end

                if (max(imgFeat(:))>0)
                    imgFeat=imgFeat./max(imgFeat(:));
                end

                if (Experiment.FtWriter)
                   imgFeatColorMap = ind2rgb(round(imgFeat.*255),Experiment.dtDiffColorMap);
                   imwrite(imgFeatColorMap,ftImgFilePath,'png');
                   %writeColorMap(imgFeatColorMap,ftImgColorFilePath);
                end

            else
                data = load(ftDataFilePath);
                imgFeat = data.imgFeat;
            end
            tFeat = toc;

            bdryImgFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.imageExt);

            if (Experiment.BdryWriter) && (~exist([Experiment.bdryDir rawImageName],'dir'))
                mkdir([Experiment.bdryDir rawImageName]);
            end

            tic;
            if ((~exist(bdryImgFilePath,'file')) || (Experiment.forceBdryMaker==1) )
                [RES,imgBdry]=getBoundaries(imgFeat,inf);

                if (Experiment.BdryWriter)
%                        imwrite(imgBdry,bdryImgFilePath,'png');
                   imwrite(255-imgBdry,bdryImgFilePath,'png');
                end
            else
                data = load(bdryDataFilePath);
                imgBdry = data.imgBdry;
            end
            tBdry = toc;
        end

        tic;
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
            tCp = toc;

            thisT = tSmoo+tFeat+tBdry+tCp;
            totalT = totalT + thisT;
            if (Experiment.verbose == 1)
                msg = sprintf('\tBdry image: %d / %d, timeSmoo = %.2f secs, timeFeat = %.2f, timeBdry = %.2f, timeCp = %.2f  secs (est. %s)\n', idxRes,Experiment.numRes,tSmoo,tFeat,tBdry,tCp,timeToName(thisT*(Experiment.numRes-idxRes)));
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
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
