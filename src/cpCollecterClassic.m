

imagesList=getFileList(Experiment.orgDir,'*',Experiment.orgImagesExt);


fprintf('\n------\n Comparison Collecter (cpCollecter)\n------\n');

imagesFrom=max(1,Experiment.cpCollecterRange(1));
imagesTo=min(length(imagesList),Experiment.cpCollecterRange(2));

cpAll = cell(Experiment.numRes,5,imagesTo-imagesFrom+1);

for idxSmoothingMethod=1:length(Experiment.smoothingMethod)

    smoothingMethod=Experiment.smoothingMethod{idxSmoothingMethod};
    if (strcmp(smoothingMethod,'mshift'))
        config=strcat(num2str(Experiment.mshift.spatialSupport),'-',num2str(Experiment.mshift.tonalSupport),'-',num2str(Experiment.mshift.stopCondition));
    elseif(strcmp(smoothingMethod,'gauss'))
        config=sigma2name(Experiment.gauss.sigma);
    elseif(strcmp(smoothingMethod,'grav'))
        config=sprintf('it-%d-%s-G-%s-cF-%d-%s-%s',Experiment.grav.iterations,sigma2name(Experiment.grav.minDistInfFactor),sigma2name(Experiment.grav.gConst),Experiment.grav.colorFactor,Experiment.grav.colorMetric,Experiment.grav.posMetric);
    end

    cpAllFileName = sprintf('%s[%d-%d]-%s-[%s]-Classic',Experiment.cpPrefix,imagesFrom,imagesTo,smoothingMethod,config);
    cpAllDataFilePath = sprintf('%s%s.%s',Experiment.cpDir,cpAllFileName,Experiment.dataExt);

    for idxImagesList=imagesFrom:imagesTo

        idxRes = 1;
        fullImageName=char(imagesList(idxImagesList));
        rawImageName=regexprep(fullImageName,strcat('.',Experiment.orgImagesExt),'');

        fprintf('\nStarting image %d (%s)...\n',idxImagesList,rawImageName);

        for idxFunc = 1:size(Experiment.funcListClassic,1)

            method = Experiment.funcListClassic{idxFunc,1};
            params = Experiment.funcListClassic{idxFunc,2};

            if (ismember(method,{'canny'}))
                cpFileName = sprintf('%s%s-%s-[%s]-%s-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,method,sigma2name(cell2mat(params)));
                configCP = sprintf('%s',sigma2name(cell2mat(params)));
            elseif (ismember(method,{'fuzzyM'}))
                cpFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,method,params{1,1},params{1,2},params{1,3});
                configCP = sprintf('%s-%s-%s',params{1,1},params{1,2},params{1,3});
            elseif (ismember(method,{'ged'}))
                cpFileName = sprintf('%s%s-%s-[%s]-%s-%s-%d-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,method,params{1,1},params{1,2},params{1,3});
                configCP = sprintf('%s-%d-%s',params{1,1},params{1,2},params{1,3});
            end

            cpDataFilePath = sprintf('%s%s/%s.%s',Experiment.cpDir,rawImageName,cpFileName,Experiment.dataExt);

            data = load(cpDataFilePath);
            res = data.res;

            resMean = mean(res,1);
            resSorted = sortrows(res,3);
            resMax = resSorted(end,:);

            cpAll(idxRes,:,idxImagesList) = {method configCP '-' resMax resMean};
            idxRes = idxRes+1;
        end
    end
    cpAll = [cpAll(:,1:3,1) num2cell(mean(cell2mat(cpAll(:,4,:)),3),[size(cpAll,1) 3]) num2cell(mean(cell2mat(cpAll(:,5,:)),3),[size(cpAll,1) 3])];
    save(cpAllDataFilePath,'cpAll','Experiment');

	fileID = fopen([Experiment.cpDir cpAllFileName '.txt'],'a+');
	fprintf(fileID,'%10s %15s %15s %8s %8s %8s %8s %8s %8s\n\n','Method','config','-','Prec','Rec','F','Prec','Rec','F');
    for idxResAll = 1:size(cpAll,1)
        fprintf(fileID,'%10s %15s %15s \t%.4f \t%.4f \t%.4f \t%.4f \t%.4f \t%.4f\n',cpAll{idxResAll,:});
        fprintf(fileID,'\n');
    end
    fclose(fileID);
end
