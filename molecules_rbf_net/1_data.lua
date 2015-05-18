----------------------------------------------------------------------
-- Modified tutorial by
-- Clement Farabet
----------------------------------------------------------------------
require 'matio'
require 'torch'   -- torch
require 'nn'      -- provides a normalization operator
matio = require 'matio'

function load_molecules_data(base_filename, valid_bucket, test_bucket)
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
local train_bucket_indices_set = {}
for i=1,5 do
    train_bucket_indices_set[i]=i
end
train_bucket_indices_set[test_bucket] = nil
train_bucket_indices_set[valid_bucket] = nil

local temp_data = {}
local temp_labels = {}

-- Iterate over all the folds in the train set and add them to trainData structure
for fold_id, value in pairs(train_bucket_indices_set) do
    local fullfilename = '../../data/test_'..base_filename..'_fold_'..tonumber(fold_id)..'.mat'
    local tmp_fold = matio.load(fullfilename)
    print('==> loading dataset '..fullfilename)
    if #temp_data == 0 then
        temp_data = tmp_fold.testData.data
        temp_labels = tmp_fold.testData.labels
    else
        temp_data = torch.cat(tmp_fold.testData.data, temp_data, 1)
        temp_labels = torch.cat(tmp_fold.testData.labels, temp_labels, 1)
    end
end
trsize = temp_labels:size(1)
trainData = {
   data =  temp_data,
   labels = temp_labels,
   size = function() return trsize end
}
print('Final training data size '..tonumber(trainData.labels:size(1)))

-- Load testing or validation data
local testid = test_bucket
if valid_bucket ~= 0 then
    testid = valid_bucket
end
local tmp_test = matio.load('../../data/test_'..base_filename..'_fold_'..tonumber(testid)..'.mat')
tesize = tmp_test.testData.data:size(1)
testData = {
   data = tmp_test.testData.data,
   labels =  tmp_test.testData.labels,
   size = function() return tesize end
}

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

if preprocessing_type == 'none' then
    print 'No preprocessing'
elseif preprocessing_type == 'local-normalization' then
    local N = trainData.data:size(2)
    local max = {}
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

elseif preprocessing_type == 'local-standardization' then
    local N = trainData.data:size(2)
    local mean = {}
    local std = {}
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

end
