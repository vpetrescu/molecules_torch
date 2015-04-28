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
require 'InputDropout'
require 'AtomLookupTable'
----------------------------------------------------------------------
print '==> define parameters'

-- 10-class problem
noutputs = 1

-- input dimensions
nfeats = 1
width = trainData.data:size(2)
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

nbr_input_size = 23*11*3 -- 23 * 24/2
nbr_atom_types = 6
descriptor_length = 7

opt.model = 'mlp'
if opt.model == 'mlp' then
    atom_representation = torch.Tensor(nbr_atom_types, descriptor_length)

    model = nn.Sequential()
    model:add(nn.AtomLookupTable(nbr_atom_types, descriptor_length))
    model:add(nn.SplitTable(1))
        p = nn.ParallelTable()
        for i=1,nbr_input_size do
            p2 = nn.Sequential()
            p2:add(nn.SplitTable(1))
            p2:add(nn.DotProduct())
            p:add(p2)
        end
    model:add(p)
    model:add(nn.JoinTable(1))

    model:add(nn.Tanh())
    nhiddens = {100,200}
    model:add(nn.Linear(nbr_input_size, nhiddens1))
    model:add(nn.Tanh())
    model:add(nn.Linear(nhiddens1, nhiddens2))
    model:add(nn.Tanh())
    model:add(nn.Linear(nhiddens2, 1))
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
