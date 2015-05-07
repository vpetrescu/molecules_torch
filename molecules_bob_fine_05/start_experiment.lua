require 'doall'
local parameters = {}
parameters.nhiddens1 = {type = 'int', min = 40, max = 250}
parameters.nhiddens2 = {type = 'int', min = 100, max = 710}
parameters.activation = {type = 'enum', options = {'Tanh', 'ReLU'}}
parameters.learning_rate = {type ='float', min = 1e-7, max = 1e-5}
parameters.preprocessing_type = {type = 'enum', options = {'none','local-normalization', 'local-standardization','global-normalization'}}

local outcome = {}
outcome.name = 'Regression 250 - rmse_test'

whetlab = require 'whetlab'
local scientist = whetlab('BoB', 'is nan not ignored', parameters, outcome, True,'a6cea373-547c-4810-9023-32de11d09012')
local job = scientist:suggest()
for ei = 1,20 do
    print 'trail number'
    print(ei)
    job = scientist:suggest()
    valid_accuracy = run_neural_net(job.nhiddens1, job.nhiddens2,  job.learning_rate, job.preprocessing_type, job.activation)
    for k,v in pairs(job) do print(k,v) end
    scientist:update(job, valid_accuracy);
end
best_job = scientist:best()
for k,v in pairs(best_job) do print(k,v) end
