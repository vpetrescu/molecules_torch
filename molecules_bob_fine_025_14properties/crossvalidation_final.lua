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
require '4_train'
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
opt.learningRate = learning_rate --'learning rate at t=0')
opt.batchSize = 1-- 'mini-batch size (1 = pure stochastic)')
opt.weightDecay = 0.05 -- 'weight decay (SGD only)')
opt.momentum = 0.0 -- 'momentum (SGD only)')
opt.learningRateDecay = 1e-7
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

----------------------------------------------------------------------
print '==> executing all'


----------------------------------------------------------------------
print '==> training!'
old_rmse = 1000

-- the bucket that will be left over
test_bucket = 1
max_fold = 1
max_properties = 14
--data_filename = 'desc_BoB-20-fine05'
data_filename = 'desc_BoB-20-fine020'
test_avg_rmse = torch.Tensor(max_properties, max_fold):fill(0)
train_avg_rmse =  torch.Tensor(max_properties, max_fold):fill(0)
test_avg_mae = torch.Tensor(max_properties, max_fold):fill(0)
train_avg_mae = torch.Tensor(max_properties, max_fold):fill(0)

allerrors = {}
for property=1,max_properties do
    for fold_nbr=1,max_fold do
        print(string.format('processing property %d', property))
        test_bucket = fold_nbr
        load_molecules_data(data_filename, 0, fold_nbr, property)
        dofile '2_model.lua'
        dofile '3_loss.lua'
        dofile '4_train.lua'
        dofile '5_test.lua'
        for epoch_id = 1,400 do
            train(epoch_id, fold_nbr)
            if epoch_id % 1 == 0 then
                local train_rmse,train_mae,test_rmse,test_mae = test()
                print(train_rmse)
                print(train_mae)
                print(test_rmse)
                print(test_mae)
                test_avg_rmse[{property, fold_nbr}] = test_rmse
                test_avg_mae[{property, fold_nbr}] = test_mae[1]
                train_avg_rmse[{property, fold_nbr}] = train_rmse
                train_avg_mae[{property, fold_nbr}] = train_mae[1]
            end
        end
        allerrors['testmae'] = test_avg_mae
        allerrors['testrmse'] = test_avg_rmse
        allerrors['trainmae'] = train_avg_mae
        allerrors['trainrmse'] = train_avg_rmse
        torch.save('allerrors', allerrors)
    end
end
for property=1,max_properties do
    print('mean %f', train_avg_rmse[{property, {}}]:mean())
    print('std %f', train_avg_rmse[{property, {}}]:std())
    --test_avg_mae[{{}, property}]:mean()
    --test_avg_mae[{{}, property}]:std()
end


end
