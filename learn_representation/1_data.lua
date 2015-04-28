----------------------------------------------------------------------
-- Modified tutorial by
-- Clement Farabet
----------------------------------------------------------------------
require 'matio'
require 'torch'   -- torch
require 'nn'      -- provides a normalization operator
matio = require 'matio'

----------------------------------------------------------------------
print '==> loading dataset'

noutputs = 1
tmp_train = matio.load('../../data/train_desc_Triplets_fold_5.mat') 
trsize = tmp_train.trainData.data:size(1)
trainData = {
   data =  tmp_train.trainData.data,
   labels = tmp_train.trainData.labels,
   size = function() return trsize end
}

print(trainData.data:size())

tmp_test = matio.load('../../data/test_desc_Triplets_fold_5.mat')
tesize = tmp_test.testData.data:size(1)
testData = {
   data = tmp_test.testData.data,
   labels =  tmp_test.testData.labels,
   size = function() return tesize end
}

print(testData.data:size())
----------------------------------------------------------------------
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


