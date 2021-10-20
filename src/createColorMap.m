
function customColorMap=createColorMap(from,middle,to,numSteps)

colorMatrix=zeros(numSteps,3);
for numStep=1:numSteps
    
    perc=(numStep-1)/(numSteps-1);
    if perc<=0.5
        perc=perc*2;
        colorMatrix(numStep,:)= from.*(1-perc)+middle.*(perc);
    else
        perc=(perc-0.5)*2;
        colorMatrix(numStep,:)= middle.*(1-perc)+to.*(perc);
    end
    
    
end

customColorMap=colormap(colorMatrix);

