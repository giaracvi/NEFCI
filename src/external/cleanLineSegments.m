function  cleanImage=cleanLineSegments(orgImage,minLength)


% Function Clean Line Segments
%
%  function [cleanImage] = cleanLineSegments(image,limit)
%
% Cleans from the image orgImage the segments which are shorter
%   that minLength (those having length equal to minLength are kept).
%   A segment is defined as an 8-neighbour connected component.
%
% [Inputs]
%   orgImage(mandatory)- Feature pixels are those set to 1
%   minLength(mandatory)- Threshold for the cleaning. It can be set
%       as a value in ]1,infty] (raw length) or as a value in ]0,1]
%       (representing a percentage of the main diagonal.
%
% [outputs]
%   cleanImage- Image after cleaning
%
% [usages]
%   cleanImage=cleanLineSegments(orgImage,0.02)
%       -> Cleans the segments shorter than 2% of the main daigonal
%   
%
% [author]
%   Carlos Lopez-Molina (carlos.lopez@unavarra.es)
%
%

%
% [versioning]
%	0.1 /Initial Test/ (2016-III-04)
%
%

%
%	0- Validate Arguments 
%
assert(nargin==2,'Error at cleanLineSegments: Wrong number of arguments.');

%
%	1- Preprocessing
%

if (minLength<=1)
    minLength=minLength*sqrt(sum(size(orgImage).^2));
end

%
%	2- Processing
%
connComps=bwconncomp(orgImage,8);
cleanImage=orgImage;

for idxComp=1:length(connComps.PixelIdxList)
    pixList=connComps.PixelIdxList{idxComp};
    if (length(pixList)<minLength)
        cleanImage(pixList)=0;
    end
end










