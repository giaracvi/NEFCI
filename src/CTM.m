function [imgFeat, imgFeatStack] = CTM(img,tamW,Tn,measureWeights)

positions = [1 2 3 4 6 7 8 9];
imgFeatStack = zeros(size(img,1),size(img,2),length(positions));
for idxPos =1:length(positions)
        mask = zeros(3);
        mask(2,2) = 1;
        mask(positions(idxPos)) = -1;
        imgFeatStack(:,:,idxPos) = abs(conv2(img, mask, 'same'));
end

imgP=padarray(img,[floor(tamW(1)/2) floor(tamW(2)/2)],'symmetric');

[~,imgPwin] = im2col_3D_sliding_v1(imgP,[tamW(1) tamW(2)],[1 1]);

imgPwin(round(size(imgPwin,1)/2),:,:,:) = [];
imgDiff = abs(bsxfun(@minus,imgPwin,permute(img,[3 1 2])));

imgPwinOrd=sort(imgDiff,1,'ascend');

N = size(imgPwin,1);

res = imgPwinOrd(1,:,:).*measureWeights(1) + sum(Fagg(imgPwinOrd(2:N,:,:)-imgPwinOrd(1:N-1,:,:),measureWeights(2:end),Tn),1);

imgFeat=permute(res,[2 3 1]);

end
