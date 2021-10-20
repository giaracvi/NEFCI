function [Sal,imBdry]=getBoundaries(im,p)
    if (p~=inf)
        Sal=im.^p;

    else
        Sal=(im-min(im(:)))/(max(im(:))-min(im(:)));
    end

    orientim = featureorient(Sal,0,1);
    NMS=nonmaxsup(Sal,orientim,1.5);
    NMS255=uint8(255*NMS);
    [thrsHyst] = doubleRosinUnimodalThr(NMS,0.01,3);
    HM=histmedcar(NMS255,thrsHyst(2),thrsHyst(1),5);
    HM=cleanLineSegments(HM,0.02);
    HM255=uint8(HM*255);
    imBdry=HM255;
end
