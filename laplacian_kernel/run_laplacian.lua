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
require 'sys'

data_filename = 'desc_BoB-20-fine020'
--data_filename = 'desc_SemiSortedColoumb' 
fold_nbr = 1
opt = {}
opt.preprocessing_type = 'none'
load_molecules_data(data_filename, 0, fold_nbr)

--trainData.data = trainData.data:sub(1,25)
--print(trainData.labels)
--
--trainData.labels = trainData.labels:sub(1,25)

function kernel_laplacian(X, sigma)
    N = X:size(1)
    K = torch.Tensor(N,N)
    for i=1,N do
        --print(i)
        for j = i,N do
            element = torch.sum(torch.abs(X[{i,{}}] - X[{j,{}}]))
            K[{i,j}] = torch.exp(-element/sigma)
            K[{j,i}] = K[{i,j}]
        end
    end
    return K
end
function train_kernel(K, y, lambda)
    N = K:size(1)
    beta = torch.eye(N):mul(lambda)
    alpha = torch.inverse(K + beta)
--    print(alpha)
--    print(y)
    return alpha*y 
end

function predict_kernel(y, alpha, lambda, sigma, X, testdata)
   N = X:size(1)
   M = testdata:size(1)
   K = torch.Tensor(M,N)
   for i=1,M do
        for j=1, N do
            local element = torch.sum(torch.abs(X[{j,{}}] - testdata[{i,{}}]))
            K[{i,j}]  = torch.exp(-element/sigma)
        end
   end
  ypred = K* alpha
  err = torch.sum(torch.abs(ypred - y))
  err = err/testdata:size(1)
  print(string.format('MAE %f with sigma %f,lambda %f',err, sigma, lambda))
end

--all_sigma = torch.Tensor{0.001, 0.01, 0.1, 1, 10, 100}
all_sigma = torch.Tensor{1,10,100,150,200,250,300,800,1200,1500}
all_sigma = {3500,100,120}
all_lambda = torch.Tensor{0,0.00001}

for i=1,5 do
    for j=1,1 do
        sigma = all_sigma[i]
        K = kernel_laplacian(trainData.data, sigma)
        lambda = all_lambda[j]
        collectgarbage()
        y= trainData.labels
        print(trainData.data:size())
        print(testData.data:size())
        alpha = train_kernel(K, y, lambda)
        predict_kernel(testData.labels, alpha, lambda, sigma, trainData.data, testData.data)

        t = sys.clock()
        sys.tic()
        t = sys.toc()
    end
end



