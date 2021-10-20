

imagesList=getFileList(Experiment.orgDir,'*',Experiment.orgImagesExt);


fprintf('\n------\n Boundary Image Maker (bdryMaker)\n------\n');

%Timing matters
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

    reverseStr = '';
    idxRes = 0;
    totalT=0;

    for idxSmoothingMethod=1:length(Experiment.smoothingMethod)

        smoothingMethod=Experiment.smoothingMethod{idxSmoothingMethod};
        if (strcmp(smoothingMethod,'mshift'))
            config=strcat(num2str(Experiment.mshift.spatialSupport),'-',num2str(Experiment.mshift.tonalSupport),'-',num2str(Experiment.mshift.stopCondition));
        elseif(strcmp(smoothingMethod,'gauss'))
            config=sigma2name(Experiment.gauss.sigma);
        elseif(strcmp(smoothingMethod,'grav'))
            config=sprintf('it-%d-%s-G-%s-cF-%d-%s-%s',Experiment.grav.iterations,sigma2name(Experiment.grav.minDistInfFactor),sigma2name(Experiment.grav.gConst),Experiment.grav.colorFactor,Experiment.grav.colorMetric,Experiment.grav.posMetric);
        end

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
                else
                    ftFileName = sprintf('%s%s-%s-[%s]-%s-%s-F1-%s-F2-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,measureType,choquetType,F1,F2);
                    bdryFileName = sprintf('%s%s-%s-[%s]-%s-%s-F1-%s-F2-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,measureType,choquetType,F1,F2);
                end

                if (~exist([Experiment.bdryDir rawImageName],'dir'))
                    mkdir([Experiment.bdryDir rawImageName]);
                end

                ftDataFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.dataExt);

                bdryImgFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.imageExt);
                bdryDataFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.dataExt);

                if ((~exist(bdryImgFilePath,'file')) || (Experiment.forceBdryMaker==1) )

                    tic;

                    data = load(ftDataFilePath);
                    imgFeat = data.imgFeat;

                    [RES,imgBdry]=getBoundaries(imgFeat,Experiment.p);
                    RES=uint8(RES.*255);

                    imwrite(255-imgBdry, Experiment.map, bdryImgFilePath, 'png');
                    save(bdryDataFilePath,'imgBdry');

                    thisT=toc;
                    time(idxImagesList)=thisT;

                    totalT = totalT + thisT;

                    msg = sprintf('\tBdry image: %d / %d, time = %.2f secs (est. %s)\n', idxRes,Experiment.numRes,thisT,timeToName(thisT*(Experiment.numRes-idxRes)));
                    fprintf([reverseStr, msg]);
                    reverseStr = repmat(sprintf('\b'), 1, length(msg));

                    idxRes = idxRes +1;
                end
            end
        end
    end
    fprintf('\t done (%s)\n',timeToName(totalT));
end
