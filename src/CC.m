function [imgFeat] = CC(img,tamW,F,measure,params)

img=gaussianSmooth(img,Sigma);

imgP=padarray(img,[floor(tamW(1)/2) floor(tamW(2)/2)],'symmetric');

[~,imgPwin] = im2col_3D_sliding_v1(imgP,[tamW(1) tamW(2)],[1 1]);

imgPwin(round(size(imgPwin,1)/2),:,:,:) = [];
imgDiff = abs(bsxfun(@minus,imgPwin,permute(img,[3 1 2])));

imgPwinOrd=sort(imgDiff,1,'ascend');

N = size(imgPwin,1);

params.tam = N;

m = measure(measure,params);
res = min(1,imgPwinOrd(1,:,:) + sum(Fagg(imgPwinOrd(2:N,:,:),m,F)-Fagg(imgPwinOrd(1:N-1,:,:),m,F),1));

imgFeat=permute(res,[2 3 1]);
imgFeat=imgFeat./max(imgFeat(:));

end
