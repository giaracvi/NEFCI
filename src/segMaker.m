

fprintf('\n------\n Segmentation Maker (segMaker)\n------\n');

imagesList=getFileList(Experiment.orgDir,'*',Experiment.orgImageExt);

imFrom=max(1,Experiment.imagesFrom);
imTo=min(length(imagesList),Experiment.imagesTo);


for idxImagesList=imFrom:imTo
    fullImageName=char(imagesList(idxImagesList));
    rawImageName=regexprep(fullImageName,strcat('.',Experiment.orgImagesExt),'');
    imagePath=strcat(Experiment.orgDir,fullImageName);
    fprintf('\nStarting image %d / %d (%s)...\n',idxImagesList,Experiment.imagesTo-Experiment.imagesFrom+1,rawImageName);

    img=double(imread(imagePath));%/255;
    if (size(img,3)>1)
        img=mean(img,3);
    end
    img=img-min(img(:));
    img=img./max(img(:));

    if (ismember(Experiment.expName,{'C1','C2','C3'}))
        for idxP=1:length(Experiment.p)
            p=Experiment.p(idxP);
            fuzzyOutFile{idxP} = sprintf('%s%s_p[%.3f].png',Experiment.bnDir1,rawImageName,p);
            binOutImage{idxP} = sprintf('%s%s_p[%.3f].png',Experiment.bnDir2,rawImageName,p);
            binOutFile{idxP} = sprintf('%s%s_p[%.3f].mat',Experiment.bnDir2,rawImageName,p);
        end
    else
        fuzzyOutFile = sprintf('%s%s.png',Experiment.bnDir1,rawImageName);
        binOutImage = sprintf('%s%s.png',Experiment.bnDir2,rawImageName);
        binOutFile = sprintf('%s%s.mat',Experiment.bnDir2,rawImageName);
    end



        if (ismember(Experiment.expName,{'C1','C2','C3'}))
            if (~exist(fuzzyOutFile,'file') || Experiment.forceBnMaker)

            end
        else
            if (~exist(fuzzyOutFile,'file') || Experiment.forceBnMaker)
                if (strcmp(Experiment.expName,'GED'))
                    %Type=S_M o
                    Experiment.Operator='S_P';
                    [RES,imBdry]=GED_EB(img,Experiment.Operator,Experiment.Sigma);
                elseif (strcmp(Experiment.expName,'FM'))
                    %Type=SS Schweizer-Sklar
                    %Type=BB min and max
                    Experiment.Operator='SS';
                    [RES,imBdry]=FuzzyMorphEDV1(img,Experiment.Sigma,'T_nM', 'I_KD',Experiment.Operator);
                elseif (strcmp(Experiment.expName,'Canny'))
                    [RES,imBdry]=CannyCompleto(img,Experiment.Sigma);
                elseif (strcmp(Experiment.expName,'RF'))
                    [RES,imBdry]=RandomForest(img,Experiment.Sigma,Experiment.modelDir);
                    cd('/home/lab/research/ODedge');
                end
            end
        end
        RES=uint8(RES.*255);
        imwrite(RES, map,fuzzyOutFile, 'png');
        imwrite(imBdry, map,binOutImage, 'png');
        save(binOutFile,'imBdry');

end
