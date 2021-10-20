function [mask,distMap]=makeRadialDist(dist,metric)

if (nargin==1)
    metric='euclidean';
else
    if (strcmp(metric,'euc'))
        metric='euclidean';
    elseif(strcmp(metric,'hau'))
        metric='chessboard';
    else
        error('Error at makeRadialDist.m: Unknown metric [%s]\n',metric);
    end
    
end
    

a=zeros((dist*2+1));
a(dist+1,dist+1)=1;
distMap=bwdist(a,metric);

mask=zeros((dist*2+1));
mask(distMap<=dist)=1;
mask(distMap>dist)=0;
