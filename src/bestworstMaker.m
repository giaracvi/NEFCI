

imagesList=getFileList(Experiment.orgDir,'*',Experiment.orgImagesExt);


fprintf('\n------\n Best Worst Maker (bestworstMaker)\n------\n');

imagesFrom=max(1,Experiment.cpCollecterRange(1));
imagesTo=min(length(imagesList),Experiment.cpCollecterRange(2));

resAll = zeros(imagesTo-imagesFrom+1,size(Experiment.BestWorstConfigList,1));

for idxSmoothingMethod=1:length(Experiment.smoothingMethod)

    smoothingMethod=Experiment.smoothingMethod{idxSmoothingMethod};
    if (strcmp(smoothingMethod,'mshift'))
        config=strcat(num2str(Experiment.mshift.spatialSupport),'-',num2str(Experiment.mshift.tonalSupport),'-',num2str(Experiment.mshift.stopCondition));
    elseif(strcmp(smoothingMethod,'gauss'))
        config=sigma2name(Experiment.gauss.sigma);
    elseif(strcmp(smoothingMethod,'grav'))
        config=sprintf('it-%d-%s-G-%s-cF-%d-%s-%s',Experiment.grav.iterations,sigma2name(Experiment.grav.minDistInfFactor),sigma2name(Experiment.grav.gConst),Experiment.grav.colorFactor,Experiment.grav.colorMetric,Experiment.grav.posMetric);
    end

    bwFileName = sprintf('%s[%d-%d]-%s-[%s]-BestWorst',Experiment.cpPrefix,imagesFrom,imagesTo,smoothingMethod,config);
    bwDataFilePath = sprintf('%s%s.%s',Experiment.cpDir,bwFileName,Experiment.dataExt);

    for idxImagesList=imagesFrom:imagesTo

        idxRes = 1;
        fullImageName=char(imagesList(idxImagesList));
        rawImageName=regexprep(fullImageName,strcat('.',Experiment.orgImagesExt),'');

        fprintf('\nStarting image %d (%s)...\n',idxImagesList,rawImageName);

        for idxFunc = 1:size(Experiment.BestWorstConfigList,1)

            method = Experiment.BestWorstConfigList{idxFunc,1};

            cpFileName = sprintf('%s%s-%s-[%s]-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,method);
            cpDataFilePath = sprintf('%s%s/%s.%s',Experiment.cpDir,rawImageName,cpFileName,Experiment.dataExt);

            data = load(cpDataFilePath);
            res = data.res;

            resAll(idxImagesList,idxFunc)=  max(res(:,3));
        end
    end
    [valor1,metmax]=max(resAll,[],2);
    [valor2,metmin]=min(resAll,[],2);

    Best=hist(metmax,1:size(Experiment.BestWorstConfigList,1));
    Worst=hist(metmin,1:size(Experiment.BestWorstConfigList,1));

    bestworstMethods = [Experiment.BestWorstConfigList(:) num2cell(Best') num2cell(Worst')];

    save(bwDataFilePath,'Best','Worst','bestworstMethods','Experiment');
    
	fileID = fopen([Experiment.cpDir bwFileName '.txt'],'a+');
	fprintf(fileID,'%20s \t%5s \t%5s\n\n','Method','Best','Worst');
    for idxResAll = 1:size(bestworstMethods,1)
        fprintf(fileID,'%20s \t%d \t%d\n',bestworstMethods{idxResAll,:});
        fprintf(fileID,'\n');
    end
    fclose(fileID);

end
