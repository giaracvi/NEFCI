function [imFuzzy,imBndry] = GED_EB(IM,Operator,Sigma)

IM=gaussianSmooth(IM,Sigma);
Experiment.AFDetectionSize=3;
Experiment.AFDetectionK='globalK';
[ft,fx,fy]=AFDetection(IM,Operator,Experiment.AFDetectionSize,Experiment.AFDetectionK);
fy=-fy;
maxGrad=max(max(ft));
fx=fx./maxGrad;
fy=fy./maxGrad;
ft=ft./maxGrad;
orientim = featureorient(ft,0,1); %Feature orientation. Function by Kovesi
NMS=nonmaxsup(ft,orientim,1.5);
[thrsHyst] = doubleRosinUnimodalThr(NMS,0.01,3);
NMS255=uint8(255*NMS);

HM=histmedcar(NMS255,thrsHyst(2),thrsHyst(1),5);
HM=cleanLineSegments(HM,0.02);
HM255=uint8(255*HM);

imFuzzy = ft;
imBndry = HM255;
