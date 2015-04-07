----------------------------------------------------------------------
-- This script implements a test procedure, to report accuracy
-- on the test data. Nothing fancy here...
--
-- Clement Farabet
----------------------------------------------------------------------

require 'torch'   -- torch
require 'xlua'    -- xlua provides useful tools, like progress bars
require 'optim'   -- an optimization package, for online and batch methods

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
   error_rmse = 0
   error_mae = 0
   for t = 1,testData:size() do
      -- disp progress
      xlua.progress(t, testData:size())

      -- get new sample
      local input = testData.data[t]
      if opt.type == 'double' then input = input:double()
      elseif opt.type == 'cuda' then input = input:cuda() end
      local target = testData.labels[t]

      -- test sample
      local pred = model:forward(input)
      --confusion:add(pred, target)
      error_rmse = error_rmse + (target - pred) * (target - pred)
      --if (target - pred > 0) then
         -- factor =  target - pred
     -- else
        --  factor = pred - target
      --end
      --error_mae = error_mae + factor
   end
   error_rmse = torch.sqrt(error_rmse / testData:size())
   error_mae =  error_mae / testData:size()
   print('error rmse')
   print(error_rmse)
   print('error mae')
   print(error_mae)

   -- timing
   time = sys.clock() - time
   time = time / testData:size()
   print("\n==> time to test 1 sample = " .. (time*1000) .. 'ms')

   -- print confusion matrix
   --print(confusion)

   -- update log/plot
   --testLogger:add{['% mean class accuracy (test set)'] = confusion.totalValid * 100}
   
   if opt.plot then
      testLogger:style{['% mean class accuracy (test set)'] = '-'}
      testLogger:plot()
   end

   -- averaged param use?
   if average then
      -- restore parameters
      parameters:copy(cachedparams)
   end
   
   -- next iteration:
   --confusion:zero()
end
