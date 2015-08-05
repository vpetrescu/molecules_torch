----------------------------------------------------------------------
-- This script implements a test procedure, to report accuracy
-- on the test data. Nothing fancy here...
--
-- Clement Farabet
----------------------------------------------------------------------
require 'gnuplot'
require 'torch'   -- torch
require 'xlua'    -- xlua provides useful tools, like progress bars
require 'optim'   -- an optimization package, for online and batch methods
require 'os'
----------------------------------------------------------------------
print '==> defining test procedure'

-- test function
function test()
   -- local vars
   local time = sys.clock()

   -- averaged param use?
   if average then
      cachedparams = parameters:clone()
      parameters:copy(average)
   end

   -- set model to evaluate mode (for modules that differ in training and testing, like Dropout)
   model:evaluate()

   -- test over test data
   print('==> testing on test set:')
   N = trainData.labels:size(2)
   test_error_rmse = torch.Tensor(N):fill(0)
   test_error_mae = torch.Tensor(N):fill(0)
   all_errors = torch.Tensor(testData:size(),N):fill(0)
   all_labels = torch.Tensor(testData:size(),N):fill(0)
   for t = 1,testData:size() do
      -- disp progress
      --xlua.progress(t, testData:size())

      -- get new sample
      local input = testData.data[t]
      input = input:double()
      local target = testData.labels[t]
      -- test sample
      local pred = model:forward(input)
      --print(global_std)
      --print(target)
      local o = (target-pred):cmul(global_std)
      factor =  torch.abs(o)
      test_error_mae = error_mae + factor
      test_error_rmse = error_rmse + (o):cmul(o)
      all_labels[t] = testData.labels[t]
      all_errors[t] = factor
     -- print(target)
   end
   error_rmse_test = torch.sqrt(error_rmse / testData:size())
   error_mae_test =  error_mae / testData:size()
   print('error rmse')
   print(error_rmse_test)
   print(error_mae_test)
   --gnuplot.plot(all_labels, all_errors, '+')
  -- print(all_errors)

   all_errors = torch.Tensor(trainData:size(),N):fill(0)
   all_labels = torch.Tensor(trainData:size(),N):fill(0)
   train_error_rmse = torch.Tensor(N):fill(0)
   train_error_mae = torch.Tensor(N):fill(0)
   for t = 1,trainData:size() do
      -- disp progress
      xlua.progress(t, trainData:size())

      -- get new sample
      local input = trainData.data[t]
      input = input:double()
      local target = trainData.labels[t]
      -- test sample
      local pred = model:forward(input)
      local o = (target - pred):cmul(global_std)
      all_errors[t] = torch.abs(o)
      o = o:cmul(o)
      error_rmse = error_rmse + o
      error_mae = error_mae + all_errors[t]
      all_labels[t] = trainData.labels[t]
   end
   error_rmse = torch.sqrt(error_rmse / trainData:size())
   print('error rmse')
   sorted_mae_errors, sorted_indices = torch.sort(all_errors)
   tN = trainData:size()
--   print(sorted_mae_errors[tN])
--   print(sorted_indices[tN])
--   print(sorted_mae_errors[tN-1])
--   print(sorted_indices[tN-1])
--   gnuplot.plot(all_labels, all_errors, '+')
   print(error_rmse)
   -- timing
   time = sys.clock() - time
   time = time / testData:size()
   print("\n==> time to test 1 sample = " .. (time*1000) .. 'ms')


   -- averaged param use?
   if average then
      -- restore parameters
      parameters:copy(cachedparams)
   end

   return error_rmse_test, error_rmse
   -- next iteration:
   --confusion:zero()
end
