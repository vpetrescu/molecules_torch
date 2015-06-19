require 'nn'
require 'NNVizualizeStatistics'
require 'Linear01'

model = nn.Sequential()
model:add(nn.Linear01(100,100))
model:add(nn.Linear01(100,80))
model:add(nn.Linear01(80,50))

vstats = NNVizualizeStatistics()
vstats:plotAll(model)

local answer = io.read()
