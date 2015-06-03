require 'gnuplot'
require 'string'
require 'nn'
local NNVizualizeStatistics = torch.class('NNVizualizeStatistics')
-- TODO consider adding this to Sequential
--
function NNVizualizeStatistics:__init()

end

function NNVizualizeStatistics:plotAll(model)
    nbr_parameters = #model:parameters()
    -- Assume all models have
    --nbr_modules = #model:modules
    --print(nbr_modules)
    gnuplot.raw('set loadpath ~/.gnuplotconfig')
    gnuplot.raw('load parula.pal')
    nbr_modules = nbr_parameters/2
    command_string = string.format("set multiplot layout %d,2", nbr_modules)
    gnuplot.raw(command_string)
    gnuplot.raw('title "My special plot"')
    for i=1,nbr_modules do
        gnuplot.raw(string.format('lt %d', 2*(i-1)+1))
        gnuplot.imagesc(model:parameters()[2*i-1], 'color')
        gnuplot.raw(string.format('lt %d', 2*i))
        double_bias = model:parameters()[2*i]:clone()
        double_bias = torch.repeatTensor(double_bias,2,2) 
        gnuplot.imagesc(double_bias)
    end
end

function NNVizualizeStatistics:plotWeights()
end

function NNVizualizeStatistics:plotActivations()
end

function NNVizualizeStatistics:HintonDiagram()
end