function m = powerMeasure(N,q)
    m = zeros(length(q),N);
    m(:,1) = 1;
    for idxQ = 1:length(q)
        m(idxQ,2:end) = ((N-1:-1:1)/N).^q(idxQ);
    end
end