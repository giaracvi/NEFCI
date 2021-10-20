

imagesList=getFileList(Experiment.orgDir,'*',Experiment.orgImagesExt);


fprintf('\n------\n Feature Image Maker (smMaker)\n------\n');

%Timing matters
totalT=0;
numImages=0;


imagesFrom=max(1,Experiment.imagesRange(1));
imagesTo=min(length(imagesList),Experiment.imagesRange(2));

measureWeights = [];
for idxMeasureType = 1:size(Experiment.config.measure,2)

    measureType = Experiment.config.measure{1,idxMeasureType};

    measureWeights = [measureWeights measure(measureType,Experiment.params.measure)];
end

time = zeros(imagesTo-imagesFrom,1);

for idxImagesList=imagesFrom:imagesTo

    %Read Image
    fullImageName=char(imagesList(idxImagesList));
    rawImageName=regexprep(fullImageName,strcat('.',Experiment.orgImagesExt),'');
    imagePath=strcat(Experiment.orgDir,fullImageName);

    fprintf('\nStarting image %d / %d (%s)...\n',idxImagesList,imagesTo-imagesFrom+1,rawImageName);
    tic;


    for idxSmoothingMethod=1:length(Experiment.smoothingMethod)

        smoothingMethod=Experiment.smoothingMethod{idxSmoothingMethod};
        if (strcmp(smoothingMethod,'mshift'))
            config=strcat(num2str(Experiment.mshift.spatialSupport),'-',num2str(Experiment.mshift.tonalSupport),'-',num2str(Experiment.mshift.stopCondition));
        elseif(strcmp(smoothingMethod,'gauss'))
            config=sigma2name(Experiment.gauss.sigma);
        elseif(strcmp(smoothingMethod,'grav'))
            config=sprintf('it-%d-%s-G-%s-cF-%d-%s-%s',Experiment.grav.iterations,sigma2name(Experiment.grav.minDistInfFactor),sigma2name(Experiment.grav.gConst),Experiment.grav.colorFactor,Experiment.grav.colorMetric,Experiment.grav.posMetric);
        end

        smFileName=sprintf('%s%s-%s-[%s].%s',Experiment.smPrefix,rawImageName,smoothingMethod,config,Experiment.imageExt);
        smFilePath=strcat(Experiment.smDir,rawImageName,'/',smFileName);

        smImage=double(imread(smFilePath));
        if (max(smImage(:))>1.001)
            smImage=smImage./255;
        end

        for idxChoquetType = 1:size(Experiment.config.F,1)

            choquetType = Experiment.config.F{idxChoquetType,1};
            if (ismember(choquetType,{'CTM','CC'}))
                F = Experiment.config.F{idxChoquetType,2};
                numComb = size(F,2);
            else
                F1unique = Experiment.config.F{idxChoquetType,2};
                F2unique = Experiment.config.F{idxChoquetType,3};
                nPairs = combvec(1:size(F1unique,2),1:size(F2unique,2));
                F1 = F1unique(nPairs(1,:));
                F2 = F2unique(nPairs(2,:));
                numComb = size(nPairs,2);
            end

            for idxFunc = 1:numComb

                for idxMeasureType = 1:size(Experiment.config.measureComplete,2)

                    measureType = Experiment.config.measureComplete{1,idxMeasureType};
                    mW = measureWeights(:,idxMeasureType);

                    if (ismember(choquetType,{'CTM','CC'}))
                        ftFileName = sprintf('%s%s-%s-[%s]-%s-%s-F-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,measureType,choquetType,F{idxFunc});

                    else
                        ftFileName = sprintf('%s%s-%s-[%s]-%s-%s-F1-%s-F2-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,measureType,choquetType,F1{idxFunc},F2{idxFunc});
                    end

                    if (~exist([Experiment.featImDir rawImageName],'dir'))
                        mkdir([Experiment.featImDir rawImageName]);
                    end

                    ftImgFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.imageExt);
                    ftDataFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.dataExt);

                    if ((~exist(ftImgFilePath,'file')) || (Experiment.forceFtMaker==1) )

                        if (ismember(choquetType,{'CTM','CC'}))
                            [imgFeat, imgFeatStack] = CTM(smImage,Experiment.tamW,F{idxFunc},mW);
                        else
                            imgFeat = CF1F2(smImage,Experiment.tamW,F1{idxFunc},F2{idxFunc},mW);
                        end

                        if (max(imgFeat(:))>0)
                            imgFeat=imgFeat./max(imgFeat(:));
                        end

                        imgFeatColorMap = ind2rgb(round(imgFeat.*255),Experiment.dtDiffColorMap);

                        for idxFeatStack = 1:size(imgFeatStack,3)
                           imgFeatColorStackMap = ind2rgb(round(imgFeatStack(:,:,idxFeatStack).*255),Experiment.dtDiffColorMap);
                           ftImgStackFilePath = sprintf('%s%s/%s_ori_%d.%s',Experiment.featImDir,rawImageName,ftFileName,idxFeatStack,Experiment.imageExt);
                           imwrite(imgFeatColorStackMap,ftImgStackFilePath,'png');
                        end

                        imwrite(imgFeatColorMap,ftImgFilePath,'png');
                        save(ftDataFilePath,'imgFeat');


                        thisT=toc;
                        totalT=totalT+thisT;
                        fprintf('\t done (%.1f)\n',thisT);
                        time(idxImagesList)=thisT;
                    end
                end
            end
        end
    end
end
