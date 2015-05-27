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

----------------------------------------------------------------------
print '==> define parameters'

-- 10-class problem
noutputs = trainData.labels:size(2)

-- input dimensions
ninputs = trainData.data:size(2)

nhiddens1 = opt.nhiddens1
nhiddens2 = opt.nhiddens2
activation_type = opt.activation_type
----------------------------------------------------------------------
print '==> construct model'
print(nhiddens1)
print(nhiddens2)
print(ninputs)

opt.model = 'mlp'
if opt.model == 'mlp' then

   -- Simple 2-layer neural network, with tanh hidden units
   model = nn.Sequential()
--   model:add(nn.InputDropout(0))
   model:add(nn.Linear(ninputs,nhiddens1))
   if (activation_type == 'Tanh') then
       model:add(nn.Tanh())
   elseif (activation_type =='ReLU') then
      -- model:add(nn.ReLU())
       model:add(nn.SoftPlus())
   else
       model:add(nn.HardTanh())
   end
   --model:add(nn.Linear(nhiddens1, noutputs))
   model:add(nn.Linear(nhiddens1, nhiddens2))
   if (activation_type == 'Tanh') then
     model:add(nn.Tanh())
  elseif (activation_type == 'ReLU') then
    -- model:add(nn:ReLU())
     model:add(nn.SoftPlus())
  else
    model:add(nn.HardTanh())
  end
   --model:add(nn.Dropout(0.5))
   model:add(nn.Linear(nhiddens2, noutputs))
--]]
elseif opt.model == 'convnet' then

      -- a typical convolutional network, with locally-normalized hidden
      -- units, and L2-pooling

      -- Note: the architecture of this convnet is loosely based on Pierre Sermanet's
      -- work on this dataset (http://arxiv.org/abs/1204.3968). In particular
      -- the use of LP-pooling (with P=2) has a very positive impact on
      -- generalization. Normalization is not done exactly as proposed in
      -- the paper, and low-level (first layer) features are not fed to
      -- the classifier.

      model = nn.Sequential()

      -- stage 1 : filter bank -> squashing -> L2 pooling -> normalization
      model:add(nn.SpatialConvolution(nfeats, nstates[1], wfiltersize, hfiltersize, 20, 1))
      model:add(nn.Tanh())
      --    model:add(nn.SpatialLPPooling(nstates[1], 2,poolsize,poolsize,poolsize,poolsize))
      --   model:add(nn.SpatialSubtractiveNormalization(nstates[1], normkernel) )
      -- nwidth =  width - wfiltersize + 1
      --- nwidth = nwidth / poolsize
      nwidth = width / 20

      nheight =  height - hfiltersize + 1
      nheight = nheight / poolsize

      -- stage 2 : filter bank -> squashing -> L2 pooling -> normalization
     -- model:add(nn.SpatialConvolution(nstates[1], nstates[2], wfiltersize, hfiltersize))
      model:add(nn.Reshape(nstates[1]*nwidth*nheight))
      model:add(nn.Linear(nstates[1]*nwidth*nheight, nstates[2]))
      model:add(nn.Tanh())
      model:add(nn.Linear(nstates[2], 1))
      --model:add(nn.Linear(nstates[2], nstates[3]))
      --model:add(nn.SpatialLPPooling(nstates[2], 2,1,poolsize,1,1))
      --  model:add(nn.SpatialSubtractiveNormalization(nstates[2], normkernel))

     -- nwidth =  nwidth - wfiltersize + 1

     -- nheight =  nheight - hfiltersize + 1
     -- nheight = nheight / poolsize
      -- stage 3 : standard 2-layer neural network
     -- model:add(nn.Reshape(nstates[2]*nwidth*nheight))
     -- model:add(nn.Linear(nstates[2]*nwidth*nheight, nstates[3]))
--      model:add(nn.Linear(nstates[2], nstates[3]))
 --     model:add(nn.Tanh())
  --    model:add(nn.Linear(nstates[3], noutputs))
else

   error('unknown -model')

end

----------------------------------------------------------------------
print '==> here is the model:'
print(model)

--model:get(1).weight = a -- torch.Tensor(2,1,1,3)

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
