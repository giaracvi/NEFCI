function w = OWA(tam)
    rng(123456);
    w = rand(1,tam);
    w = sort(w,1,'descend');
end