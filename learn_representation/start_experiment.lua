require 'doall'
local parameters = {}
parameters.nhiddens1 = {type = 'int', min = 50, max = 500}
parameters.nhiddens2 = {type = 'int', min = 100, max = 1000}
parameters.activation = {type = 'enum', options = {'Tanh', 'ReLU'}}
parameters.learning_rate = {type ='float', min = 1e-8, max = 1e-6}
parameters.preprocessing_type = {type = 'enum', options = {'none', 'local-normalization', 'local-standardization', 'global-standardization', 'global-normalization'}}

local outcome = {}
outcome.name = 'Classification accuracy'

whetlab = require 'whetlab'
local scientist = whetlab('NN molecules 2', 'Example', parameters, outcome, True,'a6cea373-547c-4810-9023-32de11d09012')
local job = scientist:suggest()
for i = 1,100 do
    job = scientist:suggest()
    valid_accuracy = run_neural_net(job.nhiddens1, job.nhiddens2, job.activation, job.learning_rate, job.preprocessing_type)
    for k,v in pairs(job) do print(k,v) end
    scientist:update(job, valid_accuracy);
end
best_job = scientist:best()
for k,v in pairs(best_job) do print(k,v) end
