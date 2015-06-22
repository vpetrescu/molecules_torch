----------------------------------------------------------------------
-- using multiple optimization techniques (SGD, ASGD, CG), and
-- multiple types of models.
--
-- This script demonstrates a classical example of training 
-- well-known models (convnet, MLP, logistic regression)
--
-- It illustrates several points:
-- 1/ description of the model
-- 2/ choice of a loss function (criterion) to minimize
-- 3/ creation of a dataset as a simple Lua table
-- 4/ description of training and test procedures
--
-- Clement Farabet
----------------------------------------------------------------------
require '1_data'
require 'torch'
require 'math'
function run_neural_net(nhiddens1, nhiddens2, learning_rate, preprocessing_type, activation_type)
----------------------------------------------------------------------
print '==> processing options'
opt = {}
opt.seed = 1
opt.threads = 1
opt.save = 'results' -- 'subdirectory to save/log experiments in')
opt.optimization = 'SGD' -- 'optimization method: SGD | ASGD | CG | LBFGS')
opt.learningRate = learning_rate --'learning rate at t=0')1
opt.batchSize = 10-- 'mini-batch size (1 = pure stochastic)')
opt.weightDecay = 0.05 -- 'weight decay (SGD only)')
opt.learningRateDecay =  1e-7
opt.momentum = 0.0 -- 'momentum (SGD only)')
--cmd:option('-t0', 1, 'start averaging at t0 (ASGD only), in nb of epochs')
--cmd:option('-maxIter', 2, 'maximum nb of iterations for CG and LBFGS')
opt.type = 'double' -- | float | cuda')
opt.nhiddens1 = nhiddens1
opt.nhiddens2 = nhiddens2
opt.activation_type = activation_type
opt.preprocessing_type = preprocessing_type
-- nb of threads and fixed seed (for repeatable experiments)
if opt.type == 'float' then
   print('==> switching to floats')
   torch.setdefaulttensortype('torch.FloatTensor')
elseif opt.type == 'cuda' then
   print('==> switching to CUDA')
   require 'cunn'
   torch.setdefaulttensortype('torch.FloatTensor')
end
torch.setnumthreads(opt.threads)
torch.manualSeed(opt.seed)

print '==> executing all'
print '==> training!'

local total_properties_count = 14
local CV = 5
local data_filename = 'desc_BoB-20-fine020'
local train_error = {}
train_error['rmse'] = torch.Tensor(total_properties_count, CV):fill(0)
train_error['mae'] = torch.Tensor(total_properties_count, CV):fill(0)
local test_error = {}
test_error['rmse'] = torch.Tensor(total_properties_count, CV):fill(0)
test_error['mae'] = torch.Tensor(total_properties_count, CV):fill(0)

for property_nbr = 1,total_properties_count do
    for fold_nbr=1,CV do
        test_bucket = fold_nbr
        print(property_nbr)
        load_molecules_data(data_filename, 0, fold_nbr, property_nbr)
        dofile '2_model.lua'
        dofile '3_loss.lua'
        dofile '4_train.lua'
        dofile '5_test.lua'
        for epoch_id = 1,100 do
            train(epoch_id, fold_nbr)
            train_rmse, train_mae, test_rmse, test_mae = test()
        end
        train_error['rmse'][property_nbr][fold_nbr] = train_rmse
        train_error['mae'][property_nbr][fold_nbr] = train_mae
        test_error['rmse'][property_nbr][fold_nbr] = test_rmse
        test_error['mae'][property_nbr][fold_nbr] = test_mae
        torch.save('train_error_14_properties', train_error)
        torch.save('test_error_14_properties',test_error)
    end
end
end
