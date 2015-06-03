require 'nn'
require 'NNVizualizeStatistics'

model = nn.Sequential()
model:add(nn.Linear(100,100))
model:add(nn.Linear(100,50))
model:add(nn.Linear(50,50))

vstats = NNVizualizeStatistics()
vstats:plotAll(model)

local answer = io.read()
