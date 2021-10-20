function [cm,residuals] = ejmBasedConfusionMatrix(solution,candidate,parameters)

%
%   LEGAL WARNING: This code is distributed under the CC-BY-ND
%        license. Check it out at:
%
%       http://creativecommons.org/licenses/by-nd/3.0/
%       http://creativecommons.org/licenses/by-nd/3.0/legalcode
%
%
% Function Estrada Jepson Machting Based Confusion Matrix
%  function confMat = ejmBasedConfusionMatrix(solution,candidate,parameters)
%
% This method computes the confusion matrix of the candidate wrt the 
%   solution after matching the candidate to the solution using the
%   technique by Estrada and Jepson.
%
% [Inputs]
%   solution(mandatory)- First binary image
%   candidate(mandatory)- Second binary image
%   parameters(mandatory)- Structure including the parameters of the
%       method. Must include the following:
%
%   parameters.maxdist- Maximum distance allowed between matched pixels
%       It can be
%           ]0,1]       -> Expressed as a percentage of the main diagonal.
%           ]1,infty]   -> Expressed as number of pixels
%
%       Additionally, users can specify the following:
%       
%   parameters.maxAngDiff- Maximum angular difference between (a)
%       the vector connecting two pixels and (b) the vector connecting
%       the destination pixel and its closest match in imageFrom. See
%       Estrada-Jepson's paper for more details on this.
%
% [outputs]
%   cm- Confusion matrix (pos (1,1) is TP, pos (1,2) is FP); Because of the
%           conditions of the matching, FN and TN cannot be computed and 
%           are left to NaN.
%   residuals- Extra information. In this case it only contains some
%           derived results.
%        a) The TPrate (residuals.TPR)
%        b) The Precision (residuals.prec)
%        c) The Recall (residuals.rec)
%        d) The F-measure with alpha=0.5 (residuals.F)
%
% [usages]
%
%   [cm,residuals]= ejmBasedConfusionMatrix(solution,candidate,parameters)
%
%
% [default values]
%
%   This function does not allow for default parametter setting. If lost, an
%       advisable setup for the parameters is the following:
%
%       parameters.maxDist=0.025;
%       
%
% [author]
%   Carlos Lopez-Molina (carlos.lopez@unavarra.es)
%
% [references]
%   [1] Quantitative error measures for edge detection
%       C. Lopez-Molina, B. De Baets and H. Bustince, 
%       Pattern Recognition, 2013
%

% [versions]
%
%   1.00 /2015-05-18/ Initial Version
%


%---------------------------
%% INTERNAL PARAMETERS
%---------------------------


%---------------------------
%% ARGUMENTS
%---------------------------
if (nargin~=3)
    error('ejmBCM>\t Wrong number of parameters in function cBCM: %d is an incorrect number',nargin);
end


%---------------------------
%% ARGUMENT CHECKING
%---------------------------

%On the images
errorCode=checkImageSizes(size(candidate),size(solution));
if (errorCode>0)
    error('ejmBCM>\t There is an error in the image sizes\n');
end
if (sum(candidate(:))==0)
    error('ejmBCM>\t The candidate image is empty\n');
end
if (sum(solution(:))==0)
    error('ejmBCM>\t The solution image is empty\n');
end

%On the parameters
[errorCode,errorMessage]=checkParameters(parameters);
if (errorCode>0)
    error('ejmBCM>\t There is an error in the parameters: [%s]\n',errorMessage);
end


%---------------------------
%% PROCESSING
%---------------------------

%
% a) matching
%

imageDiagonal=sqrt(sum(size(candidate).^2));

if (parameters.maxDist<1) %if it is expressed as a distance
    maxDist=parameters.maxDist*imageDiagonal;
else
    maxDist=parameters.maxDist;
end
p.maxDist=maxDist;

[matchMap1]=estradaJepsonMatching(candidate,solution,p);
[matchMap2]=estradaJepsonMatching(solution,candidate,p);


%
% b) computing confusion matrix
%       Because of the assimetric conditions of the matching,
%       only TP and FP can be computed.
%


TP=sum(matchMap1(:));
FP=sum(sum(candidate-matchMap1));
FN=NaN;%sum(sum(solution-matchMap2));
TN=NaN;%numel(candidate)-TP-FP-FN;

cm=[TP FP; FN TN];

%
% c) Computing residuals
%       Because of the assimetric conditions of the matching,
%       only prec, rec and F can be computed.
%


residuals.prec=sum(matchMap1(:))/sum(candidate(:));
residuals.rec=sum(matchMap2(:))/sum(solution(:));
residuals.TPR=residuals.rec;

if (residuals.prec+residuals.rec==0)
	residuals.F=0;
else
	residuals.F=(residuals.prec*residuals.rec)/(0.5*residuals.prec+0.5*residuals.rec);
end








%---------------------------
%% AUXILIAR FUNCTIONS
%---------------------------


function errorCode=checkImageSizes(sizeC,sizeS)

if (length(sizeC)~=length(sizeS))
    errorCode=1;
else
    errorCode=1-min(sizeC==sizeS);
end

return;


% Checking the validity of the parameters
function [errorCode,errorMessage]=checkParameters(params)

if (~isfield(params,'maxDist'))
    errorCode=1;
    errorMessage='Parameteres do not include a variable [maxDist]';
else
    %all fields exist
    if(~isValidMaxDist(params.maxDist))
        errorCode=1;
        errorMessage='Variable [maxDist] is illegal';
    else
        errorCode=0;
        errorMessage='no error';
    end
end

return;
    
    
%Checking the validity of the distance function
function flag=isValidMaxDist(mdist)

if (0<mdist) && (mdist<=1)
    %as a pertentage of the diagonal
    flag=1;
elseif (0<mdist)
    %number of pixels
    flag=1;
else
    flag=0;
end


return;
    
