function res = Fagg(x,y,F)
% ------- (I) T-norms
    if strcmp(F,'min')
        res = bsxfun(@min,x,y);
    elseif strcmp(F,'prod')
        res = bsxfun(@times,x,y);
    elseif strcmp(F,'lukasiewicz')
        res = bsxfun(@max,0,bsxfun(@plus,x,y-1));
    elseif strcmp(F,'hamacker')
        numTn = bsxfun(@times,x,y);
        denomTn = bsxfun(@plus,x,y) - numTn;
        res = numTn./denomTn;
        res(bsxfun(@eq,x,y)) = 0;
    elseif strcmp(F,'DP')
        res = zeros(size(x));
        res(x == 1) = y(x == 1)';
        res(y == 1) = x(y == 1);
% ------- (II) Overlap functions
    elseif strcmp(F,'OB')
        res = bsxfun(@min,bsxfun(@times,x,sqrt(y)),bsxfun(@times,y,sqrt(x)));
    elseif strcmp(F,'OmM')
        res = bsxfun(@min,x,y).*bsxfun(@max,x.^2,(y).^2);
    elseif strcmp(F,'ODiv')
        res = (bsxfun(@times,x,y)+bsxfun(@min,x,y))./2;
    elseif strcmp(F,'GM')
        res = sqrt(bsxfun(@times,x,y));
    elseif strcmp(F,'HM')
        res = 2./bsxfun(@plus,1./x,1./y);
        res(bsxfun(@or,x == 0,y == 0)) = 0;
    elseif strcmp(F,'sine')
        res = sin((pi/2).*bsxfun(@times,x,y).^(1/4));
% ------- (III) Copulas (neither t-norms nor ovelap functions)
    elseif strcmp(F,'CF')
        res = bsxfun(@times,x,y) + bsxfun(@times,x.^2,bsxfun(@times,y,bsxfun(@times,1-x,1-y)));
    elseif strcmp(F,'CL')
        res = bsxfun(@max,bsxfun(@min,x,y.*2),bsxfun(@plus,x,y-1));
% ------- (IV) Agg functions other than (I)-(III)
    elseif strcmp(F,'AVG')
        res = bsxfun(@plus,x,y)./2;
    elseif strcmp(F,'RS')
        res = bsxfun(@min,bsxfun(@times,x+1,sqrt(y))./2,bsxfun(@times,y,sqrt(x)));
    elseif strcmp(F,'GL')
        res = sqrt(bsxfun(@times,x,y+1)./2);
    elseif strcmp(F,'FBPC')
        res = bsxfun(@times,x,y.^2);
% ------- (V) (1,0)-Pre-Aggregation functions
    elseif strcmp(F,'FNA')
        res = bsxfun(@min,x./2,y);
        res(bsxfun(@le,x,y)) = x(bsxfun(@le,x,y));
    elseif strcmp(F,'FNA2')
        res = bsxfun(@min,x./2,y);
        res(x == 0) = 0;
        aux = bsxfun(@plus,x,y)./2;
        res(bsxfun(@and,x > 0,bsxfun(@le,x,y))) = aux(bsxfun(@and,x > 0,bsxfun(@le,x,y)));
% ------- (VI) Non Pre-Aggregation functions
    elseif strcmp(F,'FIM')
        res = bsxfun(@max,1-y,x);
    elseif strcmp(F,'FIP')
        res = bsxfun(@plus,1-y,bsxfun(@times,x,y));
    end

end
