require '1_data'
require 'torch'
require 'math'
require 'sys'
require 'io'

local function phi(x, y, kWidth)
    local t = torch.abs(x-y)
    t = t * global_std
   -- print('difference tensor ')
   -- print(t)
   -- print(torch.sum(t))
    return torch.exp(-(1/kWidth) * torch.sum(torch.abs(x-y)))
end

function predict_setup(kW, lambda, opt)
data_filename = 'desc_BoB-20-fine020'
fold_nbr = 1
load_molecules_data(data_filename, 0, fold_nbr)
local nData = trainData.data:size(1)
trainData.data = trainData.data:sub(1,nData)
trainData.labels = trainData.labels:sub(1,nData)
local K = torch.Tensor(nData, nData)
for i = 1, nData do
    for j = 1, nData do
        K[i][j] = phi(trainData.data[{{i},{}}], trainData.data[{{j},{}}], kW)
        --print(trainData.data[{{i}, {}}])
        --print(trainData.data[{{j}, {}}])
        --print(string.format('other %f',K[i][j]))
        --local answer = io.read()
    end
end
--print('%f ', K:mean())
--print('min and max')
local K2 = torch.Tensor(nData, nData)
local kW2 = 10
for i = 1, nData do
    for j = 1, nData do
        K2[i][j] = phi(trainData.data[{{i},{}}], trainData.data[{{j},{}}], kW2)
    end
end
--print('other ')
--print('%f ', K2:mean())
local regularizer = torch.mul(torch.eye(nData), lambda)
local theta = torch.inverse(K:t()*K + regularizer)*K:t() * trainData.labels
nTestData = testData.data:size(1)
local Ktest = torch.Tensor(nData, nTestData)
for i=1,nData do
    for j =1,nTestData do
        Ktest[i][j] = phi(trainData.data[{{i},{}}], testData.data[{{j},{}}], kW)
    end
end
local yPred = Ktest:t() * theta
local err = torch.sum(torch.abs(yPred - testData.labels))
err = err/ testData.labels:size(1)
print(err)
--print(theta)
--print(regularizer)
end

kk = torch.Tensor{700,0.01,0.1,1,10}
ll = torch.Tensor{0.0000000,0.01,0.1, 1}
opt = {}
ptypes = {'local-standardization', 'local-normalization', 'none'}
for i=1, kk:size(1) do
    for j=1, ll:size(1) do
--        for t = 1,3 do
            t = 1
            print(string.format('i j t %d %d %d', i, j, t))
            opt.preprocessing_type = ptypes[t]
            predict_setup(kk[i], ll[j] , opt)
--        end
    end
end

