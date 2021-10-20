function valsVector=ComparisonResiduals(emName,bnImage,gtImages,Dist)

valsVector=zeros(1,size(gtImages,3));
if(strfind(emName,'ejBCM-F'))
    emParams.maxDist = Dist;
    valsVector=zeros(size(gtImages.groundTruth,2),3);
    for idGTruthImage=1:size(gtImages.groundTruth,2)
        solution=gtImages.groundTruth{1,idGTruthImage}.Boundaries;
        [~,residuals]=ejmBasedConfusionMatrix(solution,bnImage,emParams);
        valsVector(idGTruthImage,:)=[residuals.prec residuals.rec residuals.F];
    end

end
