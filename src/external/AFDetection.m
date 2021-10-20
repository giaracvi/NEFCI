function [ft,fx,fy] = AFDetection(image,operator,windowsize,kmode)

%  AFDetection
%
%   [ft,fx,fy] = AFDetection(image,operator,windowsize,kmode)
%
%    This function extracts edges from an image using the 
%      gravitatory based on operator the used prefers.
%
%    Zero values removal is considered only in case
%      there is zero-valued pixels. 
%
%   NOTE: Same should have been done for 1-values
%
%  Usages:
%    function [ft,fx,fy] = AFDetection(image,operator,size)
%       Performs the operation using a gravitational constant
%       of value 1
%
%    function [ft,fx,fy] = AFDetection(image,operator,size,kmode)
%       The kmode can be introduced as a numerical value or
%       using the special words 'localK' or 'globalK'. In case
%       the first one is used, the constant is used to normalize
%       the results on the local neighbourhood (different
%       K for each neighbourhood). If using 'globalK', the
%       normalization is done all over the images, just considering
%       the operator and the maximum gradient situation.
%

%------------------------
%% ARGUMENTS
%------------------------

% Number of parameters = 3
if (nargin==3)
    Kval=ones(size(image));
    kmode='globalK';

% Number of parameters = 4
elseif (nargin==4)
    
    Ktype = strmatch(kmode,{'globalK','localK'});
    if isempty(Ktype) %no matching
        disp('Wrong invokation of the process() function');
        disp(sprintf('Invalid K-type selection: %s',kmode));
        disp('Selected K-type must be within {globalK,localK}.');
        return;
    elseif (Ktype == 1)
        Kval = ones(size(image)).*0.5054;%see paper
    elseif (Ktype==2)
        if (max(max(image))>1)
            image = double(double(image+1)./256);
        else
            image = double(double(image+0.01)./(1.01));
        end
        Kval = 0.5054*(1./image);%see paper
        %figure,imshow(Kval);
        %title(sprintf('%d',max(max(image))));
    else
        disp('Internal Error parsing K Type');
        return;           
    end
    
% Number of parameters != 3,4
else
    disp('Incorrect parameter number in method AFDetection');
    disp(sprintf('[%d] is not a valid parameter number',nargin));
    ft = NaN; fx = NaN; fy=NaN;
    return;
end

% Common parameter checkings
if (windowsize<=2)
    disp('Wrong invokation of the AFDetection function');
    disp(sprintf('Invalid windowsize value: %f',windowsize));
    return;
end
if(~ischar(operator))
    disp('Wrong invokation of the AFDetection function');
    disp(sprintf('Invalid t-norm selection: %f',operator));
    disp('Selected t-norm must be a string.');
    return;
end
    

%------------------------
%% PREPARISON
%------------------------

% Image Pre-Processing including 0-values removal
if (max(max(image))<0)
    disp('Error when pre-processing image');
    disp('Image should not contain pixel values below 0');
    return;
elseif (max(max(image))>1)
    if (min(min(image))==0)
        procImage = (double(image)+1)./256;
    else
        procImage = (double(image))./255;
    end
else
    if (min(min(image))==0)
        procImage = (image+(1/255))/(256/255);
    else
        procImage=image;
        %else nothing to be done
    end
end

%edges images declaring
ft = zeros(size(procImage));
if (nargout >1)
    fx = zeros(size(procImage));
    fy = zeros(size(procImage));
end

%------------------------
%% BOOTRAPS
%% Faster processing
%------------------------

% % % if (strcmp(operator,'t_prod'))
% % %     if (strcmp(kmode,'globalK'))
% % %         if (windowsize==3)
% % %             [ft,fx,fy]=sobel(image);
% % %             %normalize
% % %             fx=fx./4;
% % %             fy=fy./4;
% % %             %productize :)
% % %             fy=fy.*image;
% % %             fx=fx.*image;
% % %             ft=sqrt(fx.^2+fy.^2);
% % %             return;
% % %         end
% % %     end
% % % end


if(max(strcmp(operator,{'S_M','S_P','S_L'}))==1) 
    [fx,fy,ft]=gedS(image,operator);
    return;
elseif(max(strcmp(operator,{'T_M','T_P','T_L','T_nM'}))==1)     
    [fx,fy,ft]=gedT(image,operator);
    return;
end




%------------------------
%% CALCULATIONS
%------------------------

margin = floor(windowsize/2); %number of non included row/col

for i=margin+1:size(image,1)-margin
    for j=margin+1:size(image,2)-margin
        zone = procImage(i-margin:i+margin,j-margin:j+margin);
        [ft(i,j),fx(i,j),fy(i,j)] = localAFDetection(zone,operator,1,Kval(i,j));
    end
end


%------------------------
%% FINAL STEPS
%------------------------



