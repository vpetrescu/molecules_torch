require 'gnuplot'
require 'string'
require 'os'
require 'nn'
require 'sys'

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
--    gnuplot.raw(command_string)
    gnuplot.raw('title "My special plot"')
    for i=1,nbr_modules do
--        gnuplot.raw(string.format('lt %d', 2*(i-1)+1))
        -- save weights to file
        self:plotWeights(model:parameters()[2*i-1] ,i)
--        gnuplot.imagesc(model:parameters()[2*i-1], 'color')
--        gnuplot.raw(string.format('lt %d', 2*i))
        double_bias = model:parameters()[2*i]:clone()
        double_bias = torch.repeatTensor(double_bias,2,2) 
 --       gnuplot.imagesc(double_bias)
    end
end

function NNVizualizeStatistics:plotWeights(weights, nbr)
    N1 = weights:size(1)
    N2 = weights:size(2)
    weightsfile = string.format('weights%d', nbr)
    local timer = torch.Timer()
    file = torch.DiskFile(weightsfile,'w')
    for i=1,N1 do
        for j=1,N2 do
            line_entry = string.format("%d %d %f\n", i, j, weights[{i, j}]) 
            file:writeString(line_entry)
        end
    end
    file:close()
    print('Time for writing to file ' .. timer:time().real)

    timer = torch.Timer()
    gnuplot.raw('set term png')
    gnuplot.raw(string.format('set output "printme%d.png"', nbr))
    gnuplot.raw(string.format('set dgrid3d %d ,%d', N1, N2))
    gnuplot.raw('set hidden3d')
    gnuplot.raw(string.format('splot "%s" u 1:2:3 with lines', weightsfile))
    print('Time elapsed '.. timer:time().real)
    gnuplot.raw('set term wxt')
    gnuplot.raw(string.format('set term wxt %d', nbr -1))
    gnuplot.raw('replot')
end

function NNVizualizeStatistics:plotActivations()
end

function NNVizualizeStatistics:HintonDiagram()
end
