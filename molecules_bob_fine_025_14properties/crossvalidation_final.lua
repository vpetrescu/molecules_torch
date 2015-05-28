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
opt.threads = 2
opt.save = 'results' -- 'subdirectory to save/log experiments in')
opt.optimization = 'SGD' -- 'optimization method: SGD | ASGD | CG | LBFGS')
opt.learningRate = learning_rate --'learning rate at t=0')
opt.batchSize = 100-- 'mini-batch size (1 = pure stochastic)')
opt.weightDecay = 0.0000 -- 'weight decay (SGD only)')
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

----------------------------------------------------------------------
print '==> executing all'


----------------------------------------------------------------------
print '==> training!'
old_rmse = 1000

-- the bucket that will be left over
test_bucket = 1
--data_filename = 'desc_BoB-20-fine05'
data_filename = 'desc_BoB-20-fine025'
avg_rmse = torch.Tensor(14):fill(0)
for fold_nbr=1,1 do
    test_bucket = fold_nbr
    load_molecules_data(data_filename, 0, test_bucket)
    dofile '2_model.lua'
    dofile '3_loss.lua'
    dofile '4_train.lua'
    dofile '5_test.lua'
    for epoch_id = 1,100 do
        train(epoch_id, fold_nbr)
        if epoch_id % 1 == 0 then
            te,tt = test()
            if te:sum() > 0 then
               print(te:sum())
            end

        end
    end
    avg_rmse = avg_rmse + test_rmse
end
avg_rmse = avg_rmse/1
return 250 - avg_rmse
end