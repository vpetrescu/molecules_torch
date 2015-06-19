----------------------------------------------------------------------
-- Modified tutorial by
-- Clement Farabet
----------------------------------------------------------------------
require 'matio'
require 'torch'   -- torch
require 'nn'      -- provides a normalization operator
matio = require 'matio'

function load_molecules_data(base_filename, valid_bucket, test_bucket, property_nbr)
--[[
-- @base_filename The name of the descriptor which is used as filename basepath
-- All the data is split into 5 folds.
-- fold_nbr and test_bucket are numbers in {1,2,3,4,5}
-- @ test_bucket is the id of the bucket used for testing
-- @ valid_bucket is the id of the bucket used for validation. 
-- All the other buckets are used for training. If we want to train an 
-- 4 buckets and test on the 5th one, valid_bucket is set to 0
----]]
--'desc_BoB-20-fine05'

-- Initially the train set contains all the folds
-- Iterate over all the folds in the train set and add them to trainData structure

local tmp_train = matio.load('../../data14properties/train_'..base_filename..'_fold_'..tonumber(test_bucket)..'.mat')
trsize = tmp_train.trainData.data:size(1)
trainData = {
   data =  tmp_train.trainData.data,
   labels = tmp_train.trainData.labels[{{},property_nbr}],
   size = function() return trsize end
}
trainData.labels:resize(trsize,1)
print('Final training data size '..tonumber(trainData.labels:size(1)))

-- Load testing or validation data
-- local tmp_test = matio.load('../../data14properties/test_'..base_filename..'_fold_'..tonumber(testid)..'.mat')
testfilename = '../../data14properties/test_'..base_filename..'_fold_'..tonumber(test_bucket)..'.mat'
print(testfilename)
local tmp_test = matio.load(testfilename)
tesize = tmp_test.testData.data:size(1)
testData = {
   data = tmp_test.testData.data,
   labels =  tmp_test.testData.labels[{{}, property_nbr}],
   size = function() return tesize end
}
testData.labels:resize(tesize, 1)
print('Validation/Testing data size '..tonumber(testData.data:size(1)))
print '==> preprocessing data'

-- Preprocessing requires a floating point representation (the original
-- data is stored on bytes). Types can be easily converted in Torch, 
-- in general by doing: dst = src:type('torch.TypeTensor'), 
-- where Type=='Float','Double','Byte','Int',... Shortcuts are provided
-- for simplicity (float(),double(),cuda(),...):

trainData.data = trainData.data:float()
testData.data = testData.data:float()


-- Normalize each channel, and store mean/std
-- per channel. These values are important, as they are part of
-- the trainable parameters. At test time, test data will be normalized
-- using these values.
print '==> preprocessing data:'

preprocessing_type = opt.preprocessing_type -- N(0,1), [0,1], global N(0,1), global [0,1]
              --  local standardization, local normalization
              --  global standardization, global normalization

if preprocessing_type == 'local-normalization' then
    print 'No preprocessing'
elseif preprocessing_type == 'local-normalization' then
    local max = {}
    local N  = trainData.data:size(2)
    for i = 1,N do
        -- normalize each feature globally:
        max[i] = trainData.data[{ {}, i}]:max()
        if max[i] ~= 0 then
            trainData.data[{ {},i }]:div(max[i])
        end
    end
    for i =1,testData.data:size(2) do
       if max[i] ~= 0 then
          testData.data[{{},i}]:div(max[i])
       end
    end
elseif preprocessing_type == 'two-local-normalization' then
    local a = -1
    local b = 1
    local abdif = a - b
    local max = {}
    local min = {}
    local N = trainData.data:size(2)
    for i = 1,N do
        max[i] = trainData.data[{{}, i}]:max()
        min[i] = trainData.data[{{}, i}]:min()
        local factor = (min[i] - max[i])/ (a-b)
        trainData.data[{{}, i}]:mul(factor)
        trainData.data[{{}, i}]:add(b - factor*max[i])
    end
    for i = 1,N do
        local factor = (min[i] - max[i])/(a-b)
        testData.data[{{}, i}]:mul(factor)
        testData.data[{{}, i}]:add(b - factor*max[i])
    end
elseif preprocessing_type == 'local-standardization' then
    local mean = {}
    local std = {}
    local N  = trainData.data:size(2)
    for i = 1,N do
        -- stadardize each feature globally:
        mean[i] = trainData.data[{ {}, i}]:mean()
        std[i] = trainData.data[{ {},i }]:std()
        trainData.data[{ {},i }]:add(-mean[i])
        if std[i] ~= 0 then
            trainData.data[{ {},i }]:div(std[i])
        end
    end
    for i =1,testData.data:size(2) do
       testData.data[{{},i}]:add(-mean[i]) 
       if std[i] ~= 0 then
          testData.data[{{},i}]:div(std[i])
       end
    end

elseif preprocessing_type == 'global-normalization' then
   max_global = trainData.data[{ {},{} }]:max()
   -- train data normalization
   trainData.data[{ {},{} }]:div(max_global)
   -- test data normalization
   testData.data[{ {},{} }]:div(max_global)

elseif preprocessing_type == 'global-standardization' then
   mean_global = trainData.data[{ {},{} }]:mean()
   std_global = trainData.data[{ {},{} }]:std()
   -- train data standardization
   trainData.data[{ {},{} }]:add(-mean_global)
   trainData.data[{ {},{} }]:div(std_global)
   -- test data standardization
   testData.data[{ {},{} }]:add(-mean_global)
   testData.data[{ {},{} }]:div(std_global)
end

if trainData.labels:nDimension() > 1 then
    local N  = trainData.labels:size(2)
    global_std = torch.Tensor(N):fill(1)
end

--local label_preprocessing_type = 'two-local-normalization';
--local label_preprocessing_type = 'local-standardization';
local label_preprocessing_type = 'none';
--
if label_preprocessing_type == 'two-local-normalization' then
    local a = -1
    local b = 1
    local abdif = a - b
    local max = {}
    local min = {}
    local N = trainData.labels:size(2)
    for i = 1,N do
        max[i] = trainData.labels[{{}, i}]:max()
        min[i] = trainData.labels[{{}, i}]:min()
        local factor = (min[i] - max[i])/ (a-b)
        trainData.labels[{{}, i}]:mul(factor)
        trainData.labels[{{}, i}]:add(b - factor*max[i])
    end
    for i = 1,N do
        local factor = (min[i] - max[i])/(a-b)
        testData.labels[{{}, i}]:mul(factor)
        testData.labels[{{}, i}]:add(b - factor*max[i])
    end
elseif label_preprocessing_type == 'local-standardization' then
    local mean = {}
    local N  = trainData.labels:size(2)
    global_std = torch.Tensor(N):fill(0)
    for i = 1,N do
        -- stadardize each feature globally:
        mean[i] = trainData.labels[{ {}, i}]:mean()
        global_std[i] = trainData.labels[{ {},i }]:std()
        trainData.labels[{ {},i }]:add(-mean[i])
        if global_std[i] ~= 0 then
            trainData.labels[{ {},i }]:div(global_std[i])
        end
    end
    print(global_std)
    print('mean is ')
    print(mean)
    for i =1,testData.labels:size(2) do
       testData.labels[{{},i}]:add(-mean[i]) 
       if global_std[i] ~= 0 then
          testData.labels[{{},i}]:div(global_std[i])
       end
    end
end
end
