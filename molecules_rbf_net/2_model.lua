----------------------------------------------------------------------
-- This script demonstrates how to define a couple of different
-- models:
--   + linear
--   + 2-layer neural network (MLP)
--   + convolutional network (ConvNet)
--
-- It's a good idea to run this script with the interactive mode:
-- $ torch -i 2_model.lua
-- this will give you a Torch interpreter at the end, that you
-- can use to play with the model.
--
-- Clement Farabet
----------------------------------------------------------------------
--require 'itorch'
require 'torch'   -- torch
require 'image'   -- for image transforms
require 'nn'      -- provides all sorts of trainable modules/layers
require 'unsup'
require '1_data'
----------------------------------------------------------------------
print '==> define parameters'

-- 10-class problem
noutputs = trainData.labels:size(2)

-- input dimensions
nfeats = 1
width = trainData.data:size(4)
height = 1
ninputs = nfeats*width*height

-- number of hidden units (for MLP only):
nhiddens = ninputs / 2

-- hidden units, filter sizes (for ConvNet only):
nstates = {20, 400, 500}
wfiltersize = 20
hfiltersize = 1
poolsize = 1

nhiddens1 = opt.nhiddens1
nhiddens2 = opt.nhiddens2
activation_type = opt.activation_type
----------------------------------------------------------------------
print '==> construct model'
print(nhiddens1)
print(nhiddens2)
print(ninputs)

opt.model = 'rbf'
if opt.model == 'mlp' then

   -- Simple 2-layer neural network, with tanh hidden units
   model = nn.Sequential()
   model:add(nn.Reshape(ninputs))
--   model:add(nn.InputDropout(0))
   model:add(nn.Linear(ninputs,nhiddens1))
   if (activation_type == 'Tanh') then
       model:add(nn.Tanh())
   elseif (activation_type =='ReLU') then
       model:add(nn.ReLU())
   else
       model:add(nn.HardTanh())
   end

   -- add here a Laplacian of size 100
   --model:add(nn.Dropout(0.5))
   model:add(nn.Linear(nhiddens2, noutputs))

elseif opt.model == 'rbf' then
     input_dim = ninputs
     n_bumps = nhiddens1
     n_replications =  nhiddens2
     dim = 2
     model = nn.Sequential()
     model:add(nn.Reshape(ninputs))
     model:add(nn.Replicate(n_replications))
     model:add(nn.SplitTable(1))
     p = nn.ParallelTable()
     for i=1, n_replications do
        p2 = nn.Sequential()
        p2:add(nn.WeightedEuclidean(input_dim, n_bumps))
        local st = trainData.data:view(trainData.data:size(1), trainData.data:size(4)) --torch.Tensor(trainData.data:size()):copy(trainData.data)
      --  newsize = torch.LongStorage({trainData.data:size(1), trainData.data:size(4)})
     --   st:resize(newsize)
        print 'start kmeans'
        outclusters = unsup.kmeans(st, n_bumps, 100 +i)
        print 'end kmeans'
        p2:get(1).weights = outclusters
        p2:add(nn.Square())
        p2:add(nn.MulConstant(-1))
        p2:add(nn.Exp())
        ndim = 2
        --p2:add(nn.Sum(ndim))
        p2:add(nn.Linear(n_bumps, 1))
        p:add(p2)
     end
     model:add(p)
     model:add(nn.JoinTable(1))
     model:add(nn.Transpose({1,2}))
--    model:add(nn.Tanh())
     model:add(nn.Linear(n_replications,20))
     model:add(nn.Tanh())
     model:add(nn.Linear(20,1))
--[[    model:add(nn.WeightedEuclidean(n_replications, n_bumps))
    model:add(nn.Square())
    model:add(nn.MulConstant(-1))
    model:add(nn.Exp())
    model:add(nn.Linear(n_bumps, 1))--]]
else

   error('unknown -model')

end

----------------------------------------------------------------------
print '==> here is the model:'
print(model)


--print(model:get(1).weight)
----------------------------------------------------------------------
-- Visualization is quite easy, using itorch.image().
opt.visualize = true
if opt.visualize then
   if opt.model == 'convnet' then
      if itorch then
	 print '==> visualizing ConvNet filters'
	 print('Layer 1 filters:')
	 itorch.image(model:get(1).weight)
     print(model:get(1).weight)
	-- print('Layer 2 filters:')
	 --itorch.image(model:get().weight)
      else
	 print '==> To visualize filters, start the script in itorch notebook'
      end
   end
end
