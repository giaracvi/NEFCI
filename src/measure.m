function m = measure(measure,params)
    if strcmp(measure,'power')
        m = powerMeasure(params.tam,params.power.q);
    elseif strcmp(measure,'owaling')
        m = OWAwi(params.owaling.a,params.owaling.b,params.tam);
    elseif strcmp(measure,'owa')
        m = OWA(params.tam);
    elseif strcmp(measure,'wmean')
        m = weightedMean(params.tam);
    end
    m = m';
end