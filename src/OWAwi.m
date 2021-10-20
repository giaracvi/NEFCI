%% Function Q y Wi

function pesos = OWAwi(a,b,tam)
%     tam = reduc^2;
    pesos = zeros(1,tam);
    for i = 1:tam
        pesos(i) = Q(i/tam,a,b)-Q((i-1)/tam,a,b);
    end
    pesos = sort(pesos,1,'descend');
end

function q = Q(r,a,b)
    if (r<a)
        q = 0;
    elseif ((a<=r)&&(r<=b))
        q = (r-a)/(b-a);
    elseif (r>b)
        q = 1;
    end
end
