require 'crossvalidation_final'
local parameters = {}
parameters.nhiddens1 = {type = 'int', min = 40, max = 250}
parameters.nhiddens2 = {type = 'int', min = 100, max = 710}
parameters.activation = {type = 'enum', options = {'Tanh', 'ReLU'}}
parameters.learning_rate = {type ='float', min = 1e-7, max = 1e-5}
parameters.preprocessing_type = {type = 'enum', options = {'none','local-normalization', 'local-standardization','global-normalization'}}

local outcome = {}
outcome.name = 'Regression 250 - rmse_test'

for ei = 1,1 do
    print 'trail number'
    print(ei)
    --valid_accuracy = run_neural_net(job.nhiddens1, job.nhiddens2,  job.learning_rate, job.preprocessing_type, job.activation)
    --valid_accuracy = run_neural_net(219, 100,  1e-2, 'local-normalization', 'ReLU')
    valid_accuracy = run_neural_net(219, 80,  1e-5, 'local-normalization', 'ReLU')
    print('valid accuracy')
    print(valid_accuracy)
end
