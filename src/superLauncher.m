clear;
setup;
OS_MODE='mac';% win, linux, mac
infoMaker;

% Smoothing phase
smMaker;

% Feature extraction phase
ftMaker;

% Boundary extraction phsse
bdryMaker;

% Comparison and quantitative results extraction
cpMaker;
cpCollecter;

% Experiment processing with classical methots
clear;
setup;
OS_MODE='mac';
infoMaker;
imgNum = 1;
aioMakerClassic;
