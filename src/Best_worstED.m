function [Best,Worst] = Best_worstED(smoo,methods)
numMethods=length(methods);
numImages=200;
Res25TAll=zeros(numImages,numMethods);

for idxImagesList=imagesFrom:imagesTo
for idxMethod=1:numMethods
    data = load(filePath);
    Res25T = data.Res25T;
    Res25TAll(:,idxMethod)= Res25T(:,end);
end

[valor1,metmax]=max(Res25TAll,[],2);
[valor2,metmin]=min(Res25TAll,[],2);

Best=hist(metmax,1:length(methods));
Worst=hist(metmin,1:length(methods));

end
