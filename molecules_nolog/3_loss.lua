----------------------------------------------------------------------
-- This script demonstrates how to define a couple of different
-- loss functions:
--   + negative-log likelihood, using log-normalized output units (SoftMax)
--   + mean-square error
--   + margin loss (SVM-like)
--
-- Clement Farabet
----------------------------------------------------------------------

require 'torch'   -- torch
require 'nn'      -- provides all sorts of loss functions

----------------------------------------------------------------------
-- parse command line arguments
if not opt then
   print '==> processing options'
   cmd = torch.CmdLine()
   cmd:text()
   cmd:text('SVHN Loss Function')
   cmd:text()
   cmd:text('Options:')
   cmd:option('-loss', 'nll', 'type of loss function to minimize: nll | mse | margin')
   cmd:text()
   opt = cmd:parse(arg or {})

   -- to enable self-contained execution:
   model = nn.Sequential()
end

-- 10-class problem
noutputs = 1
opt.loss = 'mse'
----------------------------------------------------------------------
print '==> define loss'


if opt.loss == 'mse' then

   -- for MSE, we add a tanh, to restrict the model's output
  --   model:add(nn.Tanh())

   -- The mean-square error is not recommended for classification
   -- tasks, as it typically tries to do too much, by exactly modeling
   -- the 1-of-N distribution. For the sake of showing more examples,
   -- we still provide it here:

   criterion = nn.MSECriterion()
   criterion.sizeAverage = false

else

   error('unknown -loss')

end

----------------------------------------------------------------------
print '==> here is the loss function:'
print(criterion)
