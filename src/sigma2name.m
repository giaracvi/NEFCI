function name = sigma2name(sigma)

name=sprintf('%.4f',sigma);
name=regexprep(name,'\.','-');