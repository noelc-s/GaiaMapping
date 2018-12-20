addpath(genpath('./Data'))

opts = genOpts();

if exist(['Data/PROCESSED/' opts.file(1:end-4) '_processed.mat']) ~= 2
    ReadGaiaData(opts)
end

PlotGaiaData(opts)